/**
	NSManagedObject+LZ.h
	Common
	
	Created by Roderick Mann on 9/14/11.
	Copyright 2011 Latency: Zero. All rights reserved.
*/

#import <CoreData/CoreData.h>


@interface NSManagedObject(LZ)


+ (NSEntityDescription*)	entityInMOC: (NSManagedObjectContext*) inMOC;
+ (id)						createInMOC: (NSManagedObjectContext*) inMOC;
+ (NSArray*)				allInMOC: (NSManagedObjectContext*) inMOC;
+ (NSArray*)				allInMOC: (NSManagedObjectContext*) inMOC
								sortKey: (NSString*) inSortKey
								ascending: (bool) inAscending;
+ (NSArray*)				allInMOC: (NSManagedObjectContext*) inMOC
								withPredicateFormat: (NSString*) inFormat, ...;
+ (void)					deleteAllInMOC: (NSManagedObjectContext*) inMOC;

@end
