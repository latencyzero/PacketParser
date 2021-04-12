//
//  NSHTTPURLResponse+LZ.h
//  GCClientTest
//
//  Created by Roderick Mann on 11/23/12.
//  Copyright (c) 2012 Latency: Zero. All rights reserved.
//


@interface
NSHTTPURLResponse(LZ)

- (void)			dump;
- (NSDate*)			lastModifiedDate;

@end


extern NSString*		kHeaderLastModified;
