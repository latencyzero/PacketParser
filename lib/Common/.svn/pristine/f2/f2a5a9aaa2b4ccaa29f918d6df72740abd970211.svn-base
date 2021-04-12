/**
	NSManagedObject+LZ.m
	Common
	
	Created by Roderick Mann on 9/14/11.
	Copyright 2011 Latency: Zero. All rights reserved.
*/

#import "NSManagedObject+LZ.h"

//
//	Standard Imports
//

#import <stdarg.h>

//
//	Library Imports
//

#import "Debug.h"
#import "LZUtils.h"






@implementation NSManagedObject(LZ)


+ (NSEntityDescription*)
entityInMOC: (NSManagedObjectContext*) inMOC
{
	NSString* name = NSStringFromClass(self);
	NSEntityDescription* entity = [NSEntityDescription entityForName: name inManagedObjectContext: inMOC];
	return entity;
}

+ (id)
createInMOC: (NSManagedObjectContext*) inMOC
{
	NSString* name = NSStringFromClass(self);
	id o = [NSEntityDescription insertNewObjectForEntityForName: name inManagedObjectContext: inMOC];
	return o;
}

+ (NSArray*)
allInMOC: (NSManagedObjectContext*) inMOC
{
	return [self allInMOC: inMOC sortKey: nil ascending: false];
}

+ (NSArray*)
allInMOC: (NSManagedObjectContext*) inMOC
	sortKey: (NSString*) inSortKey
	ascending: (bool) inAscending
{
	NSEntityDescription* entity = [self entityInMOC: inMOC];
	NSFetchRequest* req = [[NSFetchRequest alloc] init];
	req.entity = entity;
	
	if (inSortKey != nil)
	{
		NSSortDescriptor* sd = [[NSSortDescriptor alloc] initWithKey: inSortKey ascending: inAscending];
		NSArray* sds = [[NSArray alloc] initWithObjects: sd, nil];
		req.sortDescriptors = sds;
#if !ARC_ENABLED
		[sd release];
		[sds release];
#endif
	}
	
	NSError* err = nil;
	NSArray* results = [inMOC executeFetchRequest: req error: &err];
#if !ARC_ENABLED
	[req release];
#endif
	if (err != nil)
	{
		NSString* name = NSStringFromClass(self);
		NSLogDebug(@"Error fetching entities %@: %@", name, err);
		return nil;
	}
	
	return results;
}

+ (NSArray*)
allInMOC: (NSManagedObjectContext*) inMOC
	withPredicateFormat: (NSString*) inFormat, ...
{
	NSEntityDescription* entity = [self entityInMOC: inMOC];
	NSFetchRequest* req = [[NSFetchRequest alloc] init];
	req.entity = entity;
	
    va_list		args;
    va_start(args, inFormat);
	
	NSPredicate* pred = [NSPredicate predicateWithFormat: inFormat arguments: args];
	
	va_end(args);
	
	req.predicate = pred;
	
	NSError* err = nil;
	NSArray* results = [inMOC executeFetchRequest: req error: &err];
#if !ARC_ENABLED
	[req release];
#endif
	if (err != nil)
	{
		NSString* name = NSStringFromClass(self);
		NSLogDebug(@"Error fetching entities %@: %@", name, err);
		return nil;
	}
	
	return results;
}

+ (void)
deleteAllInMOC: (NSManagedObjectContext*) inMOC
{
	NSEntityDescription* entity = [self entityInMOC: inMOC];
	NSFetchRequest* req = [[NSFetchRequest alloc] init];
	req.entity = entity;
	
	NSError* err = nil;
	NSArray* results = [inMOC executeFetchRequest: req error: &err];
	if (results == nil)
	{
		NSString* name = NSStringFromClass(self);
		NSLogDebug(@"Error deleting entities %@: %@", name, err);
		return;
	}
	
	for (NSManagedObject* o in results)
	{
		[inMOC deleteObject: o];
	}
}

@end
