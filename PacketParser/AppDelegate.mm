//
//  AppDelegate.m
//  PacketParser
//
//  Created by Roderick Mann on 1/5/13.
//  Copyright (c) 2013 Latency: Zero. All rights reserved.
//

#import "AppDelegate.h"

#import "PacketTypeWindowController.h"
#import "PacketTypesLibraryController.h"

#import "Disassembler.h"
#import "ParserByteCode.h"
#import "Parser.h"

#import "PDLexer.h"
#import "PDToken.h"
#import "PDTreeNode.h"
#import "PDParser.h"
#import "XParse.h"







@interface AppDelegate()

@property (nonatomic, strong)	PacketTypesLibraryController*				libraryController;

@end






@implementation AppDelegate


- (void)
applicationDidFinishLaunching: (NSNotification*) inNotification
{
	//	Open the packet types list if it was open before…
	
	NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
	if ([ud boolForKey: @"PacketTypesLibraryShowing"])
	{
		[self showPacketTypesLibrary: nil];
	}
	
	
}

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


- (IBAction)
showPacketTypesLibrary: (id) inSender
{
	[self.libraryController.window makeKeyAndOrderFront: inSender];
}

- (IBAction)
newParserType: (id) inSender
{
	[self.libraryController newParserType: inSender];
}


- (PacketTypesLibraryController*)
libraryController
{
	if (mLibraryController == nil)
	{
		mLibraryController = [[PacketTypesLibraryController alloc] init];
	}
	
	return mLibraryController;
}


@synthesize libraryController				=	mLibraryController;

@end
