//
//  Packet.h
//  PacketParser
//
//  Created by Roderick Mann on 12/30/12.
//  Copyright (c) 2012 Latency: Zero. All rights reserved.
//

#import "Frame.h"

//
//	Library Imports
//

#import "NSManagedObject+LZ.h"




@interface Packet : Frame

@property (nonatomic, retain) NSNumber * timeStamp;
@property (nonatomic, retain) NSNumber * complete;

@end

@interface Packet (CoreDataGeneratedAccessors)

- (void)addFramesObject:(NSManagedObject *)value;
- (void)removeFramesObject:(NSManagedObject *)value;
- (void)addFrames:(NSSet *)values;
- (void)removeFrames:(NSSet *)values;

@end
