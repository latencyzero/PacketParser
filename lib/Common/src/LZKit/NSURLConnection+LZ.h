/**
	NSURLConnection+LZ.h
	
	Created by Roderick Mann on 10/7/11.
	Copyright 2011 Latency: Zero, Inc. All rights reserved.
*/


@interface NSURLConnection(LZ)

@property (nonatomic, copy)	NSString*				debugName;

typedef	void		(^ResponseCompletionBlock)(NSURLConnection* inConn,
												NSURLResponse* inResp,
												NSData* inData,
												NSError* inError);
typedef	void		(^ResponseCompletionBlock2)(NSURLResponse* inResp,
												NSData* inData,
												NSError* inError);

/**
	Creates an asynchronous load operation that fetches the resource at
	inPath. If inStartImmediately is false (recommended), then you must
	call -start on the returned NSURLConnection object.
	
	If an operation for the same inPath is currently pending, then a
	new request is not initiated. Instead, the NSURLConnection object is
	queued, and the completion block is called when the pending request
	completes.
	
	Note: Strictly speaking, coalescing requests like this is incorrect.
	During the first request, each new request to the same URI *should* be
	treated independently. But in practice, it's almost always
	going to return the same result, and it's more important here to reduce
	the number of requests, than to get up-to-the-microsecond versions of
	resources. If this ends up being a problem, it would not be hard to add
	a "don't coalesce" flag to this call.
*/

+ (NSURLConnection*)		asyncLoadPath: (NSString*) inPath
								startImmediately: (bool) inStartImmediately
								completionHandler: (ResponseCompletionBlock) inCompletion;

+ (NSURLConnection*)		asyncSendRequest: (NSURLRequest*) inReq
								completionHandler: (ResponseCompletionBlock) inCompletion;


+ (void)					asyncPUT: (NSString*) inPath
								withBody: (NSData*) inData
								contentType: (NSString*) inContentType
								completion: (ResponseCompletionBlock2) inCompletion;


#if TARGET_OS_IPHONE

+ (void)					showNetworkActivity;
+ (void)					hideNetworkActivity;

#endif

@end
