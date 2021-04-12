//
//  NSXMLNode+LZ.m
//  LPCalculator
//
//  Created by Roderick Mann on 8/19/12.
//  Copyright (c) 2012 Latency: Zero. All rights reserved.
//

#import "NSXMLNode+LZ.h"







@implementation NSXMLNode(LZ)


- (NSNumber*)
doubleForXQuery: (NSString*) inQuery
{
	NSError* err = nil;
	NSArray* vals = [self objectsForXQuery: inQuery error: &err];
	if (vals == nil)
	{
		NSLog(@"Error in XQuery [%@]: %@", inQuery, err);
		return nil;
	}
	
	if (vals.count == 0)
	{
		NSLog(@"No results for XQuery [%@]", inQuery);
		return nil;
	}
	
	NSNumber* n = @([[vals objectAtIndex: 0] doubleValue]);
	return n;
}



@end
