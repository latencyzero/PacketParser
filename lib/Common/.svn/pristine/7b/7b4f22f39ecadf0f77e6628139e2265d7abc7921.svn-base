//
//  NSHTTPURLResponse+LZ.m
//  GCClientTest
//
//  Created by Roderick Mann on 11/23/12.
//  Copyright (c) 2012 Latency: Zero. All rights reserved.
//

#import "NSHTTPURLResponse+LZ.h"



//
//	Library Imports
//

#import "Debug.h"





@implementation NSHTTPURLResponse (LZ)

- (void)
dump
{
	NSInteger statusCode = self.statusCode;
	NSLogDebug(@"HTTP Response Status: %ld", statusCode);
	
	for (NSString* header in self.allHeaderFields.allKeys)
	{
		NSString* val = [self.allHeaderFields valueForKey: header];
		NSLogDebug(@"%@: %@", header, val);
	}
}

- (NSDate*)
lastModifiedDate
{
	NSString* d = [self.allHeaderFields valueForKey: kHeaderLastModified];
	if (d.length == 0)
	{
		return nil;
	}
	
	NSDateFormatter* df = [[NSDateFormatter alloc] init];
	df.dateFormat = @"EEE, dd MMM yyyy HH:mm:ss z";
	df.timeZone = [NSTimeZone timeZoneWithAbbreviation: @"GMT"];
		
	NSDate* modDate = [df dateFromString: d];
	return modDate;
}



@end



NSString*		kHeaderLastModified				=	@"Last-Modified";
