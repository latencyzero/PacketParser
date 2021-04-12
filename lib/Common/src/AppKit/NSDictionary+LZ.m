//
//  NSDictionary+LZ.m
//  SnapShot
//
//  Created by Roderick Mann on 6/5/12.
//  Copyright (c) 2012 Latency: Zero. All rights reserved.
//

#import "NSDictionary+LZ.h"

@implementation NSDictionary(LZ)



- (NSDate*)
unixDateForKey: (NSString*) inKey
{
	NSNumber* ti = [self valueForKey: inKey];
	NSDate* date = [NSDate dateWithTimeIntervalSince1970: ti.doubleValue];
	return date;
}

- (NSDate*)
unixDateForKeyPath: (NSString*) inKeyPath
{
	NSNumber* ti = [self valueForKeyPath: inKeyPath];
	NSDate* date = [NSDate dateWithTimeIntervalSince1970: ti.doubleValue];
	return date;
}

@end
