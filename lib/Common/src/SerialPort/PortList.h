//
//  PortList.h
//  IchibotConsole
//
//  Created by Roderick Mann on 9/21/08.
//  Copyright 2008 Latency: Zero. All rights reserved.
//


//
//	Mac OS X Includes
//

#include <IOKit/IOKitLib.h>


@class Port;

@protocol PortListDelegate

- (void)			portAdded: (Port*) inPort;
- (void)			portRemoved: (Port*) inPort;

@end

/**
	Maintains a list of available serial ports.
*/

@interface
PortList : NSObject<NSFastEnumeration>
{
	NSMutableDictionary*			mPortsByName;
	NSMutableArray*					mPorts;
	
	IONotificationPortRef			mNotifyPort;
	io_iterator_t					mDeviceAddedIter;
	io_iterator_t					mDeviceRemovedIter;
}

@property (strong, readonly)	NSArray*				ports;
@property (weak)				id<PortListDelegate>	delegate;
@property (assign, readonly)	NSUInteger				count;

+ (PortList*)		defaultPortList;
+ (Port*)			firstAvailablePort;

- (Port*)			portForName: (NSString*) inName;
- (Port*)			portForNamePrefix: (NSString*) inName;

@end
