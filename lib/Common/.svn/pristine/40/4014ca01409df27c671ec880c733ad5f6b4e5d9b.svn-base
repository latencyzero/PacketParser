/**
	NSOperationQueue.h
	
	Created by Roderick Mann on 10/7/11.
	Copyright 2011 Latency: Zero!, Inc. All rights reserved.
*/



@class LZRunloopOperation;

typedef	void (^YRunloopOperationBlock)(LZRunloopOperation* inOp);

@interface
LZRunloopOperation : NSObject
{
	YRunloopOperationBlock			mBlock;
	NSBlockOperation*				mOp;
	bool							mNeedsExecute;
	bool							mInProgress;
}

@property (nonatomic, copy)	YRunloopOperationBlock			block;

+ (LZRunloopOperation*)		operationWithBlock: (YRunloopOperationBlock) inBlock;

- (void)		setNeedsExecute;
- (void)		operationComplete;
- (void)		cancel;

@end



@interface NSOperationQueue(LZ)

+ (NSBlockOperation*)		addOperationOnMainQueueWithBlock: (void (^)(void)) inBlock;


@end
