/**
	NSURLConnection+LZ.m
	
	Created by Roderick Mann on 10/7/11.
	Copyright 2011 Latency: Zero, Inc. All rights reserved.
	
	This simplified blocks-based wrapper around NSURLConnection is designed to make
	it very easy to do simple async URL requests using completion blocks.
	
	The main entry point is
	
		+ (NSURLConnection*)		asyncLoadPath: (NSString*) inPath
										startImmediately: (bool) inStartImmediately
										withCompletion: (ResponseCompletionBlock) inCompletion;
	
	This method creates a private subclass of NSURLConnection called LZURLConnection,
	owned by LZPrivateURLConnectionDelegate, a simple object that acts as delegate (there was some issue
	making LZURLConnection be the delegate directly; I don't remember now what that was).
	
	This class also adds a "debugName" property to the resulting NSURLConnection object that can
	be used for debugging (typically by logging information in the completion handler).
*/

#import "NSURLConnection+LZ.h"


//
//	Library Imports
//

#import "Debug.h"


//
//	Project Imports
//

//#import "LZUtils.h"


#define	qLogConnections								0
#define	qLogNetworkActivity							0
#define	qPendingConnectionSupport					0


#if qPendingConnectionSupport
static
NSMutableDictionary*
getPendingConnections()
{
	static NSMutableDictionary*	sPendingConnections;
	static dispatch_once_t		sInit;
	dispatch_once(&sInit,
		^{
			sPendingConnections = [[NSMutableDictionary alloc] init];
		});
		
	return sPendingConnections;
}
#endif

static
NSOperationQueue*
getCompletionQueue()
{
#if 0
	static NSOperationQueue*	sCompletionQueue;
	static dispatch_once_t		sInit;
	dispatch_once(&sInit,
		^{
			sCompletionQueue = [[NSOperationQueue alloc] init];
			sCompletionQueue.name = @"NSURLConnection Completion Queue";
			sCompletionQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
		});
		
	return sCompletionQueue;
#else
	return [NSOperationQueue mainQueue];
#endif
}

@class LZPrivateURLConnectionDelegate;

/**
	A private subclass of NSURLConnection that holds a reference to our management
	object.
*/

@interface
LZURLConnection : NSURLConnection

@property (nonatomic, strong)	LZPrivateURLConnectionDelegate*			delegate;
@property (nonatomic, copy)		NSString*								debugName;
#if qPendingConnectionSupport
@property (nonatomic, copy)		NSURLRequest*							request;
#endif

@end








/**
	This object acts as delegate for async NSURLConnection operations.
*/

@interface
LZPrivateURLConnectionDelegate : NSObject
{
	NSURLResponse*					mResponse;
	ResponseCompletionBlock			mCompletionBlock;
	
	NSMutableData*					mData;
}

@property (nonatomic, weak)	LZURLConnection*			conn;
@property (nonatomic, copy)	ResponseCompletionBlock		completionBlock;

- (id)				initWithRequest: (NSURLRequest*) inReq;

@end













@implementation LZURLConnection


- (id)
initWithRequest: (NSURLRequest*) inReq
	delegate: (id) inDelegate
	startImmediately: (BOOL) inStartImmediately
{
#if TARGET_OS_IPHONE
	if (inStartImmediately)
	{
		[NSURLConnection showNetworkActivity];
	}
#endif

	self = [super initWithRequest: inReq delegate: inDelegate startImmediately: inStartImmediately];
	if (self != nil)
	{
		self.delegate = inDelegate;
#if qPendingConnectionSupport
		self.request = inReq;
#endif
	}
	
	return self;
}

- (void)
dealloc
{
	self.delegate.conn = nil;
}

/**
	If a connection for this URI is already pending, just queue ourselves
	onto that. If not, set it up and start us.
*/

- (void)
start
{
#if TARGET_OS_IPHONE
	[NSURLConnection showNetworkActivity];
#endif

#if qPendingConnectionSupport
	bool		start = false;
	
	NSURL* url = self.request.URL;
	NSMutableDictionary* pending = getPendingConnections();
	@synchronized (pending)
	{
		NSMutableArray* conns = [pending objectForKey: url];
		if (conns == nil)
		{
			start = true;
			conns = [NSMutableArray array];
			[pending setObject: conns forKey: url];
		}
		
		NSAssert(![conns containsObject: self], @"Looks like start was called multiple times");
		[conns addObject: self];
	}
	
	if (start)
	{
		NSRunLoop* loop = [NSRunLoop currentRunLoop];
		[self scheduleInRunLoop: loop forMode: NSRunLoopCommonModes];
		[super start];
	}
#else
	[super start];
#endif
}


@synthesize delegate;
@synthesize debugName;
#if qPendingConnectionSupport
@synthesize request;
#endif

@end




@implementation LZPrivateURLConnectionDelegate


- (id)
initWithRequest: (NSURLRequest*) inReq
{
	self = [super init];
	if (self != nil)
	{
		self.conn = [[LZURLConnection alloc] initWithRequest: inReq
														delegate: self
														startImmediately: false];
	}
	
	return self;
}

- (void)
dealloc
{
	[mConnection cancel];
	
#if !ARC_ENABLED
	[mResponse release];
	[mData release];
	[mConnection release];
	
	[super dealloc];
#endif
}

- (void)
connection: (NSURLConnection*) inConnection
	didReceiveResponse: (NSURLResponse*) inResponse
{
#if qLogConnections
	NSLogDebug(@"%s", __PRETTY_FUNCTION__);
#endif

	//NSLogDebug(@"Response URI: %@", inResponse.URL);
	mResponse = inResponse;
#if !ARC_ENABLED
	[mResponse retain];
#endif
}

- (void)
connection: (NSURLConnection*) inConnection
	didReceiveData: (NSData*) inData
{
#if qLogConnections
	NSLogDebug(@"%s", __PRETTY_FUNCTION__);
#endif

	if (mData == nil)
	{
		mData = [[NSMutableData alloc] initWithData: inData];
	}
	else
	{
		[mData appendData: inData];
	}
	
#if qLogConnections
	NSLogDebug(@"Got bytes: %u", mData.length);
#endif
}

- (void)
connectionDidFinishLoading: (NSURLConnection*) inConnection
{
#if qLogConnections
	NSLogDebug(@"%s", __PRETTY_FUNCTION__);
#endif

	LZURLConnection* conn = (LZURLConnection*) inConnection;
	//NSLogDebug(@"Connection finished: %@", conn.debugName);
	
#if qPendingConnectionSupport
	NSArray* conns = nil;
	NSURL* url = conn.request.URL;
	NSMutableDictionary* pending = getPendingConnections();
	@synchronized (pending)
	{
		conns = [[pending objectForKey: url] copy];
		//NSLogDebug(@"%u request completed for %@", conns.count, url);
		
		NSAssert([conns containsObject: conn], @"Connection finished, but operation is not in pending operations");
		
		[pending removeObjectForKey: url];
	}
	
	for (LZURLConnection* pendingConn in conns)
	{
		[getCompletionQueue() addOperationWithBlock:
			^{
				ResponseCompletionBlock block = pendingConn.delegate.completionBlock;
				if (block != nil)
				{
					//NSLogDebug(@"Calling connection completion: (0x%08x): %@", block, pendingConn.debugName);
					block(pendingConn, mResponse, mData, nil);
					
#if TARGET_OS_IPHONE
					[NSURLConnection hideNetworkActivity];
#endif
				}
			}];
	}
#else	//	qPendingConnectionSupport

	[getCompletionQueue()
		addOperationWithBlock:
		^{
			ResponseCompletionBlock block = conn.delegate.completionBlock;
			if (block != nil)
			{
				//NSLogDebug(@"Calling connection completion: (0x%08x): %@", block, pendingConn.debugName);
				block(conn, mResponse, mData, nil);
				
#if TARGET_OS_IPHONE
				[NSURLConnection hideNetworkActivity];
#endif
			}
		}];
#endif	//	qPendingConnectionSupport
}

- (void)
connection: (NSURLConnection*) inConnection
	didFailWithError: (NSError*) inError
{
	NSLogDebug(@"%s", __PRETTY_FUNCTION__);
	
	LZURLConnection* conn = (LZURLConnection*) inConnection;
	//NSLogDebug(@"Connection finished: %@", conn.debugName);
	
#if qPendingConnectionSupport
	NSArray* conns = nil;
	NSURL* url = conn.request.URL;
	NSMutableDictionary* pending = getPendingConnections();
	@synchronized (pending)
	{
		conns = [[pending objectForKey: url] copy];
		//NSLogDebug(@"%u request(s) completed for %@", conns.count, url);
		
		NSAssert([conns containsObject: conn], @"Connection finished, but operation is not in pending operations");
		
		[pending removeObjectForKey: url];
	}
	
	for (LZURLConnection* pendingConn in conns)
	{
		[getCompletionQueue() addOperationWithBlock:
			^{
				ResponseCompletionBlock block = pendingConn.delegate.completionBlock;
				if (block != nil)
				{
					//NSLogDebug(@"Calling connection error (0x%08x): %@", block, pendingConn.debugName);
					block(pendingConn, mResponse, mData, inError);
					
#if TARGET_OS_IPHONE
					[NSURLConnection hideNetworkActivity];
#endif
				}
			}];
	}
#else	//	qPendingConnectionSupport
	[getCompletionQueue()
		addOperationWithBlock:
		^{
			ResponseCompletionBlock block = conn.delegate.completionBlock;
			if (block != nil)
			{
				//NSLogDebug(@"Calling connection error (0x%08x): %@", block, pendingConn.debugName);
				block(conn, mResponse, mData, inError);
				
#if TARGET_OS_IPHONE
				[NSURLConnection hideNetworkActivity];
#endif
			}
		}];
#endif	//	qPendingConnectionSupport
}

@synthesize conn							=	mConnection;
@synthesize completionBlock					=	mCompletionBlock;

@end


/**
	The public interface to our blocks-based NSURLConnection.
*/

@implementation NSURLConnection(LZ)

+ (NSURLConnection*)
asyncLoadPath: (NSString*) inPath
	startImmediately: (bool) inStartImmediately
	completionHandler: (ResponseCompletionBlock) inCompletion
{
	NSURL* url = [NSURL URLWithString: inPath];
	NSURLRequest* req = [NSURLRequest requestWithURL: url];
	LZPrivateURLConnectionDelegate* conn = (LZPrivateURLConnectionDelegate*) [self asyncSendRequest: req completionHandler: inCompletion];
	
	if (inStartImmediately)
	{
		[conn.conn start];
	}
	
	return conn.conn;
}

+ (NSURLConnection*)
asyncSendRequest: (NSURLRequest*) inReq
	completionHandler: (ResponseCompletionBlock) inCompletion
{
	LZPrivateURLConnectionDelegate* delegate = [[LZPrivateURLConnectionDelegate alloc] initWithRequest: inReq];
	
	delegate.completionBlock = inCompletion;
	
	return delegate.conn;
}

+ (void)
asyncPUT: (NSString*) inPath
	withBody: (NSData*) inData
	contentType: (NSString*) inContentType
	completion: (ResponseCompletionBlock2) inCompletion
{
	NSURL* url = [NSURL URLWithString: inPath];
	NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL: url];
	req.HTTPMethod = @"PUT";
	req.HTTPBody = inData;
	[req setValue: inContentType forHTTPHeaderField: @"Content-Type"];
	
	NSOperationQueue* queue = nil;
	[NSURLConnection sendAsynchronousRequest: req queue: queue completionHandler: inCompletion];
}


- (void)
setDebugName: (NSString*) inVal
{
	if ([self isKindOfClass: [LZURLConnection class]])
	{
		LZURLConnection* this = (LZURLConnection*) self;
		this.debugName = inVal;
	}
}

- (NSString*)
debugName
{
	if ([self isKindOfClass: [LZURLConnection class]])
	{
		LZURLConnection* this = (LZURLConnection*) self;
		return this.debugName;
	}
	
	return nil;
}

dispatch_queue_t			networkActivityQueue(void);


dispatch_queue_t
networkActivityQueue(void)
{
	static	dispatch_queue_t	sNetworkActivityQueue;
	static	dispatch_once_t		sInitNetworkActivityQueue;
	
	dispatch_once(&sInitNetworkActivityQueue,
	^{
		//	TODO: Is this actually safe? We're calling UIKit off the main thread, I think it's probably bad.
		//		Not sure how this code got in here.
		sNetworkActivityQueue = dispatch_queue_create("com.latencyzero.NetworkActivity", NULL);
	});
	
	return sNetworkActivityQueue;
}

#if TARGET_OS_IPHONE

static	NSInteger			sNetworkActivityCount;

+ (void)
showNetworkActivity
{
#if qLogNetworkActivity
	NSLogDebug(@"Enter %s", __PRETTY_FUNCTION__);
#endif
	dispatch_sync(networkActivityQueue(),
	^{
		sNetworkActivityCount += 1;
		bool show = sNetworkActivityCount > 0;
		dispatch_async(dispatch_get_main_queue(),
		^{
			[UIApplication sharedApplication].networkActivityIndicatorVisible = show;
		});
	});
#if qLogNetworkActivity
	NSLogDebug(@"Exit %s", __PRETTY_FUNCTION__);
#endif
}

+ (void)
hideNetworkActivity
{
#if qLogNetworkActivity
	NSLogDebug(@"Enter %s", __PRETTY_FUNCTION__);
#endif
	dispatch_sync(networkActivityQueue(),
	^{
		NSAssert(sNetworkActivityCount > 0, @"+hideNetworkActivity called when network activity is 0");
		
		sNetworkActivityCount -= 1;
		bool show = sNetworkActivityCount > 0;
		dispatch_async(dispatch_get_main_queue(),
		^{
			[UIApplication sharedApplication].networkActivityIndicatorVisible = show;
		});
	});
#if qLogNetworkActivity
	NSLogDebug(@"Exit %s", __PRETTY_FUNCTION__);
#endif
}

#endif	//	TARGET_OS_IPHONE

@end
