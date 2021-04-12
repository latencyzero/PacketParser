//
//  Protocol.m
//  PacketParser
//
//  Created by Roderick Mann on 12/30/12.
//  Copyright (c) 2012 Latency: Zero. All rights reserved.
//

#import "FrameDescription.h"


//
//	Project Imports
//

#import "FrameField.h"








@interface FrameDescription()
{
	NSMutableArray*					mFields;
}


@end







@implementation FrameDescription

- (void)
appendField: (FrameField*) inField
{
	[mFields addObject: inField];
}

- (NSArray*)
fields
{
	if (mReadOnlyFields == nil)
	{
		mReadOnlyFields = [mFields copy];
	}
	
	return mReadOnlyFields;
}

@synthesize fields				=	mReadOnlyFields;


@end
