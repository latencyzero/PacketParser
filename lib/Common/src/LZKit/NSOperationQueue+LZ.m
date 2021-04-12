/**
	NSOperationQueue.m
	
	Created by Roderick Mann on 10/7/11.
	Copyright 2011 Latency: Zero!, Inc. All rights reserved.
*/

#import "NSOperationQueue+LZ.h"







@implementation NSOperationQueue(LZ)


+ (NSBlockOperation*)
addOperationOnMainQueueWithBlock: (void (^)(void)) inBlock
{
	NSOperationQueue* q = [NSOperationQueue mainQueue];
	NSBlockOperation* op = [NSBlockOperation blockOperationWithBlock: inBlock];
	[q addOperation: op];
	return op;
}


@end



@implementation LZRunloopOperation

+ (LZRunloopOperation*)
operationWithBlock: (YRunloopOperationBlock) inBlock
{
	LZRunloopOperation* op = [[LZRunloopOperation alloc] init];
	op.block = inBlock;
	
	
	return op;
}

- (id)
init
{
	self = [super init];
	if (self != nil)
	{
	}
	return self;
}

- (void)
cancel
{
	[mOp cancel];
}

- (void)
setNeedsExecute
{
	NSAssert([NSThread isMainThread], @"Call -setNeedsExecute only on main thread");
	
	if (!mNeedsExecute)
	{
		mNeedsExecute = true;
		
		//	Schedule the execution at the end of the run loop…
		
		NSBlockOperation* op = [NSOperationQueue addOperationOnMainQueueWithBlock:
			^
			{
				//	If there’s a fetch in progress, when it’s done, a
				//	new fetch will start, so only start one if there isn’t one…
				
				if (!mInProgress)
				{
					mInProgress = true;
					mNeedsExecute = false;
					mBlock(self);
				}
			}];
		mOp = op;
	}
}

- (void)
operationComplete
{
	NSAssert([NSThread isMainThread], @"Call -operationComplete only on main thread");
	
	if (mNeedsExecute)
	{
		mBlock(self);
		return;
	}
	
	mInProgress = false;
	mOp = nil;
}

@synthesize block				=	mBlock;

@end
