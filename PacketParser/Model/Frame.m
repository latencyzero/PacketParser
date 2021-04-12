//
//  Frame.m
//  PacketParser
//
//  Created by Roderick Mann on 12/30/12.
//  Copyright (c) 2012 Latency: Zero. All rights reserved.
//

#import "Frame.h"




@interface Frame()
{
	NSUInteger			mNextSequence;
}

@property (nonatomic, strong)	NSMutableSet*					primitiveSubframes;

@end




@implementation Frame

- (void)
awakeFromFetch
{
	//	Get the largest sequence number…
	
	mNextSequence = 0;
	for (Frame* f in self.subframes)
	{
		NSUInteger seq = f.sequence.unsignedLongValue;
		if (seq > mNextSequence)
		{
			mNextSequence = seq;
		}
	}
	
	NSLog(@"Largest sequence found: %lu", mNextSequence);
	mNextSequence += 1;		//	Start one past that.
}

- (void)
addFrame: (Frame*) inFrame
{
    NSSet* changedObjects = [NSSet setWithObject: inFrame];
    
	inFrame.sequence = @(mNextSequence++);
	
    [self willChangeValueForKey: @"subframes"
			withSetMutation: NSKeyValueUnionSetMutation
			usingObjects: changedObjects];
    
	[self.primitiveSubframes addObject: inFrame];
	
    [self didChangeValueForKey: @"subframes"
			withSetMutation: NSKeyValueUnionSetMutation
			usingObjects: changedObjects];
}

@dynamic primitiveSubframes;
@dynamic name;
@dynamic summary;
@dynamic start;
@dynamic length;
@dynamic sequence;
@dynamic parentFrame;
@dynamic subframes;

@end
