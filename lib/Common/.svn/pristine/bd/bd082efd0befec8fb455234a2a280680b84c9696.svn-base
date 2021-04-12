/**
	NSURL+LZ.m
	PlanetaryClock

	Created by Roderick Mann on 9/4/12.
	Copyright (c) 2012 Latency: Zero. All rights reserved.
*/

#import "NSURL+LZ.h"









@implementation NSURL(LZ)

- (NSString*)
baseResourceName
{
	NSString* name = self.lastPathComponent;
	NSString* ext = self.pathExtension;
	ext = [@"." stringByAppendingString: ext];
	if ([name hasSuffix: ext])
	{
		NSRange r = [name rangeOfString: ext options: NSBackwardsSearch];
		name = [name substringToIndex: r.location];
	}
	
	return name;
}

@end
