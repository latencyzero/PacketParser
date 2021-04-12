//
//  NSDictionary+LZ.h
//  SnapShot
//
//  Created by Roderick Mann on 6/5/12.
//  Copyright (c) 2012 Latency: Zero. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary(LZ)

- (NSDate*)			unixDateForKey: (NSString*) inKey;
- (NSDate*)			unixDateForKeyPath: (NSString*) inKeyPath;

@end
