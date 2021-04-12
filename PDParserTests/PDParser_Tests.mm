//
//  PDParser_Tests.m
//  PDParser Tests
//
//  Created by Roderick Mann on 1/13/13.
//  Copyright (c) 2013 Latency: Zero. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <sstream>

//
//	Library Imports
//

#import "llvm/IR/LLVMContext.h"
#import "llvm/IR/Module.h"
#import "llvm/IR/Verifier.h"
#import "llvm/ExecutionEngine/GenericValue.h"
#import "llvm/ExecutionEngine/ExecutionEngine.h"
#import "llvm/ExecutionEngine/JIT.h"
//#import "llvm/ADT/StringRef.h"
//#import "llvm/Support/IRReader.h"
//#import "llvm/Support/MemoryBuffer.h"
#import "llvm/Support/TargetSelect.h"
#include "llvm/Support/raw_ostream.h"

#import "Debug.h"

//
//	Project Imports
//

#import "DecoderRuntime.h"
#import "PDCodeGenPass.h"
#import "PDDeclarationPass.h"
#import "PDFirstPassWalker.h"
#import "PDLexer.h"
#import "PDParser.h"
#import "PDSymbol.h"
#import "PDToken.h"
#import "PDTreeNode.h"
#import "XParse.h"

@interface PDParser_Tests : XCTestCase

@property (nonatomic, strong, readonly)		NSManagedObjectContext*			managedObjectContext;
@property (nonatomic, strong, readonly)		NSManagedObjectModel*			managedObjectModel;
@property (nonatomic, strong, readonly)		NSPersistentStoreCoordinator*	persistentStoreCoordinator;
@property (nonatomic, strong, readonly)		NSString*						docsDir;

@end



@implementation PDParser_Tests

void
DumpTree(const PDTreeNode* inNode, NSUInteger inDepth)
{
	NSMutableString* s = [NSMutableString string];
	for (NSUInteger i = 0; i < inDepth; ++i)
	{
		[s appendString: @"  "];
	}
	
	const PDToken tok = inNode->token();
	if (!tok.isEOF())
	{
		[s appendFormat: @"%@", tok.string()];
	}
	else
	{
		[s appendString: @"<null>"];
	}
	NSLog(@"TreeNode: %@", s);
	for (auto iter = inNode->children().begin(); iter != inNode->children().end(); ++iter)
	{
		DumpTree(*iter, inDepth + 1);
	}
}


- (void)
setUp
{
	[super setUp];
	
	
}

- (void)
tearDown
{
	NSURL* url = [self.persistentStoreCoordinator URLForPersistentStore: self.persistentStoreCoordinator.persistentStores.lastObject];
	NSFileManager* fm = [NSFileManager defaultManager];
	NSError* err = nil;
	if (![fm removeItemAtURL: url error: &err])
	{
		NSLogDebug(@"Unable to delete [%@]: %@", url.path, err);
	}
	[super tearDown];
}

- (void)
testLexer
{
	NSLog(@"foo");
	
	NSString* p =
	  @"packet Foo\n"
	  @"{\n"
	  @"	marker						0x7e;\n"
	  @"	field u16					payloadLength;\n"
	  @"	field u8					apiType;\n"
	  @"	block(payloadLength - 1)	payload;\n"
	  @"	field u8					checksum;\n"
	  @"}\n";
	
	PDLexer			pdl(p);
	NSSet* reservedWords = [NSSet setWithArray: @[@"block", @"field", @"marker", @"packet"]];
	pdl.setReservedWords(reservedWords);
	
	while (true)
	{
		PDToken tok = pdl.nextToken();
		if (tok.type() == kTokenTypeEOF)
		{
			break;
		}
		
		NSString* s = tok.string();
		NSLog(@"Token: type: %3lu, start: %3lu, len: %3lu %3lu:%-3lu [%@]", tok.type(), tok.startIdx(), tok.length(), tok.line(), tok.col(), s);
	}
}

- (void)
DtestParsePacket
{
	NSString* p =
	  @"packet Foo\n"
	  @"{\n"
	  @"    field u16        payloadLength;\n"
	  @"    field u8         apiType;\n"
	  @"}\n";
	
	PDLexer			pdl(p);
	NSSet* reservedWords = [NSSet setWithArray: @[@"block", @"field", @"marker", @"packet"]];
	pdl.setReservedWords(reservedWords);
	
	PDGlobalScope* globalScope = new PDGlobalScope(NULL);
		
	PDParser		pdp(&pdl);
	try
	{
		PDTreeNode* root = pdp.definition();
		
		//	Create global scope and predefine stuff…
		
		PDFirstPassWalker walker1(globalScope);
		walker1.walk(root);
		
		[NSThread sleepForTimeInterval: 0.25];
	}
	
	catch (XParse& e)
	{
		NSLog(@"Exception parsing: %@", e.msg());
		XCTFail(@"Exception parsing");
	}
}

- (void)
DtestParseFail
{
	NSString* p =
	  @"packet Foo\n"							//	1
	  @"{\n"									//	2
	  @"    field u16        payloadLength\n"	//	3
	  @"    field u8         apiType;\n"		//	4
	  @"}\n";									//	5
	
	PDLexer			pdl(p);
	NSSet* reservedWords = [NSSet setWithArray: @[@"block", @"field", @"marker", @"packet"]];
	pdl.setReservedWords(reservedWords);
	
	PDParser		pdp(&pdl);
	
	bool			gotException = false;
	try
	{
		PDTreeNode* root = pdp.definition();
		DumpTree(root, 0);
	}
	
	catch (XUnexpected& e)
	{
		gotException = true;
	}
	
	if (!gotException)
	{
		XCTFail(@"Failed to get expected exception");
	}
}

- (void)
DtestParsePacketAndExecute
{
	llvm::InitializeNativeTarget();
	
	NSString* p =
	  @"packet Foo\n"
	  @"{\n"
	  @"    field u16        payloadLength;\n"
	  @"    field u8         apiType;\n"
	  @"    field u8         darren;\n"
	  @"}\n";
	
	PDLexer			pdl(p);
	NSSet* reservedWords = [NSSet setWithArray: @[@"block", @"field", @"marker", @"packet"]];
	pdl.setReservedWords(reservedWords);
	
	//	Create global scope and predefine stuff…
	
	llvm::Module* module = new llvm::Module("testParsePacketAndExecute", llvm::getGlobalContext());
	PDGlobalScope* globalScope = new PDGlobalScope(module);
	
	PDFirstPassWalker walker1(globalScope);
	
	//	Parse and walk…
	
	PDParser		pdp(&pdl);
	try
	{
		PDTreeNode* root = pdp.definition();
		
		walker1.walk(root);
		
		[NSThread sleepForTimeInterval: 0.25];
	}
	
	catch (XParse& e)
	{
		NSLog(@"Exception parsing: %@", e.msg());
		XCTFail(@"Exception parsing");
	}
	
	//	Execute the generated code…
	
	module->dump();
	
	__block bool testComplete = false;
	
	DecoderRuntime* rt = [[DecoderRuntime alloc] init];
	rt.moc = self.managedObjectContext;
	rt.packetDecoder = module;
	[rt parseData: nil
		completion:
		^{
			testComplete = true;
		}];
		
	NSDate* loopUntil = [NSDate dateWithTimeIntervalSinceNow: 10.0];
	while (testComplete && loopUntil.timeIntervalSinceNow > 0)
	{
		[[NSRunLoop currentRunLoop] runUntilDate: loopUntil];
	}
	
	if (!testComplete)
	{
		XCTFail(@"Test timed out");
	}
}

- (void)
testTwoPass
{
	llvm::InitializeNativeTarget();
	
	NSString* p =
	  @"packet XBeePacket\n"
	  @"{\n"
	  @"    u64              mStart;\n"
	  @"    u64              mLength;\n"
	  @"\n"
	  @"    field u8         packetMarker;\n"
	  @"    field u16        payloadLength;\n"
	  @"    block            payload(payloadLength);\n"
	  @"}\n";
	
	PDLexer			pdl(p);
	
	//	Create global scope and predefine stuff…
	
	llvm::Module* module = new llvm::Module("testTwoPass", llvm::getGlobalContext());
	try
	{
		PDGlobalScope* globalScope = new PDGlobalScope(module);
		
		
		PDDeclarationPass	declarationPass(globalScope);
		PDCodeGenPass		codeGen(globalScope);
		
		//	Parse and walk…
		
		PDParser		pdp(&pdl);
		PDTreeNode* root = pdp.definition();
		
		NSLogDebug(@"Declaration pass --------------------------------------------------------------");
		
		declarationPass.walk(root);
		
		NSLogDebug(@"Verifying declarations --------------------------------------------------------");
		std::string msg;
		llvm::raw_string_ostream oss(msg);
		if (llvm::verifyModule(*module, &oss))
		{
			NSLogDebug("Verification issues: %s", msg.c_str());
		}
		
		NSLogDebug(@"Symbol table dump -------------------------------------------------------------");
		globalScope->dump();
		
		NSLogDebug(@"Code generation pass ----------------------------------------------------------");
		codeGen.walk(root);
		
		NSLogDebug(@"Verifying code gen ------------------------------------------------------------");
		if (llvm::verifyModule(*module, &oss))
		{
			NSLogDebug("Verification issues: %s", msg.c_str());
		}
		
		NSLogDebug(@"Module dump: ------------------------------------------------------------------");
		module->dump();
	
		//	Execute the generated code…
		
		NSLogDebug(@"Executing ---------------------------------------------------------------------");
		DecoderRuntime* rt = [[DecoderRuntime alloc] init];
		rt.moc = self.managedObjectContext;
		rt.packetDecoder = module;
		
		NSURL* url = [[NSBundle bundleForClass: self.class] URLForResource: @"ZigBee031832" withExtension: @"bin"];
		NSError* err = nil;
		NSData* inputData = [NSData dataWithContentsOfURL: url options: 0 error: &err];
		if (inputData == nil)
		{
			NSLogDebug(@"Error reading test data %@: %@", url.path, err);
		}
		
		
		__block bool testComplete = false;
	
		[rt parseData: inputData
			completion:
			^{
				testComplete = true;
			}];
		
		
		NSDate* loopUntil = [NSDate dateWithTimeIntervalSinceNow: 10.0];
		while (!testComplete && loopUntil.timeIntervalSinceNow > 0)
		{
			NSLog(@"RunLoopRun -------------------------------------------------------------------------");
			[[NSRunLoop currentRunLoop] runUntilDate: loopUntil];
			NSLog(@"RunLoopReturn ----------------------------------------------------------------------");
		}
		
		if (!testComplete)
		{
			XCTFail(@"Test timed out");
		}
		NSLogDebug(@"Completed ---------------------------------------------------------------------");
	}
	
	catch (XParse& e)
	{
		module->dump();
		XCTFail(@"Exception parsing: %@", e.msg());
	}
}

#pragma mark -
#pragma mark • Core Data stack

- (NSManagedObjectContext*)
managedObjectContext
{
	if (mManagedObjectContext == nil)
	{
		NSPersistentStoreCoordinator* coordinator = self.persistentStoreCoordinator;
		if (coordinator != nil)
		{
			mManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSMainQueueConcurrencyType];
			mManagedObjectContext.persistentStoreCoordinator = coordinator;
		}
	}
	
	return mManagedObjectContext;
}


- (NSManagedObjectModel*)
managedObjectModel
{
	if (mManagedObjectModel == nil)
	{
		NSURL* url = [[NSBundle bundleForClass: self.class] URLForResource: @"Document" withExtension: @"momd"];
		mManagedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL: url];
	}
	
	return mManagedObjectModel;
}


- (NSPersistentStoreCoordinator*)
persistentStoreCoordinator
{
    if (mPersistentStoreCoordinator == nil)
	{
		int64_t t = CFAbsoluteTimeGetCurrent() * 1000.0;
		NSString* path = [self.docsDir stringByAppendingPathComponent: [NSString stringWithFormat: @"PacketParserTest-%lld", t]];
		NSLogDebug(@"Store path: %@", path);
		
		mPersistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: self.managedObjectModel];
		NSURL*			url = [NSURL fileURLWithPath: path];
		NSDictionary*	options = [NSDictionary dictionaryWithObjectsAndKeys:
								   [NSNumber numberWithBool: true], NSMigratePersistentStoresAutomaticallyOption,
								   [NSNumber numberWithBool: true], NSInferMappingModelAutomaticallyOption, 
								   nil];
		NSError*		error = nil;
		
		NSPersistentStore* store = [mPersistentStoreCoordinator
							addPersistentStoreWithType: NSSQLiteStoreType
							configuration: nil
							URL: url
							options: options
							error: &error];
		if (store == nil)
		{
			//	TODO: handle error
			NSLogDebug(@"Error adding persistent store: %@", error);
			NSDictionary* dict = [error.userInfo valueForKey: NSDetailedErrorsKey];
			NSLogDebug(@"Dict: %@", error.userInfo);
			for (NSError* e in dict)
			{
				NSLogDebug(@"Error %@ %@", e, e.userInfo);
			}
			
			return nil;
		}
    }
	
    return mPersistentStoreCoordinator;
}


- (NSString*)
docsDir
{
	NSString* basePath = NSTemporaryDirectory();
	
	return basePath;
}

@synthesize managedObjectContext					=	mManagedObjectContext;
@synthesize managedObjectModel						=	mManagedObjectModel;
@synthesize persistentStoreCoordinator				=	mPersistentStoreCoordinator;

@end
