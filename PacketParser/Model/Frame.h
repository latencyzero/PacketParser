//
//  Frame.h
//  PacketParser
//
//  Created by Roderick Mann on 12/30/12.
//  Copyright (c) 2012 Latency: Zero. All rights reserved.
//

//
//	Library Imports
//

#import "NSManagedObject+LZ.h"






@class Packet;

@interface Frame : NSManagedObject

@property (nonatomic, copy) NSString * name;
@property (nonatomic, copy) NSString * summary;
@property (nonatomic, copy) NSNumber * start;
@property (nonatomic, copy) NSNumber * length;
@property (nonatomic, copy) NSNumber * sequence;
@property (nonatomic, strong) Frame *parentFrame;
@property (nonatomic, strong) NSSet *subframes;
@end

@interface Frame (CoreDataGeneratedAccessors)

- (void)addFrame:(Frame *)value;
- (void)addSubframesObject:(Frame *)value;
- (void)removeSubframesObject:(Frame *)value;
- (void)addSubframes:(NSSet *)values;
- (void)removeSubframes:(NSSet *)values;

@end
