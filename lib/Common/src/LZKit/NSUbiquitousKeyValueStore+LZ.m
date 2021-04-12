//
//  NSUbiquitousKeyValueStore+LZ.m
//  MissionClock
//
//  Created by Roderick Mann on 11/24/12.
//  Copyright (c) 2012 Latency: Zero. All rights reserved.
//

#import "NSUbiquitousKeyValueStore+LZ.h"










@implementation NSUbiquitousKeyValueStore (LZ)



- (void)
setSet: (NSSet*) inSet
	forKey: (NSString*) inKey
{
	[self setObject: inSet.allObjects forKey: inKey];
}

- (NSSet*)
setForKey: (NSString*) inKey
{
	NSArray* objs = [self arrayForKey: inKey];
	if (objs == nil)
	{
		return nil;
	}
	
	NSSet* set = [NSSet setWithArray: objs];
	return set;
}


@end
