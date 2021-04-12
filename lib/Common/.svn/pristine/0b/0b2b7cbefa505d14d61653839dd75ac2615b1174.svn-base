//
//  PortList.mm
//  IchibotConsole
//
//  Created by Roderick Mann on 9/21/08.
//  Copyright 2008 Latency: Zero. All rights reserved.
//

#import "PortList.h"

//
//	Mac OS X Includes
//

#include <mach/mach.h>

#include <IOKit/IOCFPlugIn.h>
#include <IOKit/IOKitLib.h>
#include <IOKit/serial/IOSerialKeys.h>
#include <IOKit/usb/IOUSBLib.h>


//
//	Project Imports
//

#import "Port.h"




void			DeviceAdded(void* inRefCon, io_iterator_t inIter);
void			DeviceRemoved(void* inRefCon, io_iterator_t inIter);


@interface PortList()

- (void)		registerUSBNotifications;
- (void)		deviceAdded: (io_iterator_t) inIter;
- (void)		deviceRemoved: (io_iterator_t) inIter;

@end

static PortList*			sPortList;

@implementation PortList


+ (void)
initialize
{
	//::NSLog(@"init por list");
	sPortList = [[PortList alloc] init];
	[sPortList registerUSBNotifications];
}

+ (PortList*)
defaultPortList
{
	return sPortList;
}

+ (Port*)
firstAvailablePort
{
	for (Port* port in [PortList defaultPortList].ports)
	{
		if (!port.isOpen)
		{
			return port;
		}
	}
	
	return nil;
}

- (id)
init
{
	self = [super init];
	if (self != NULL)
	{
		//	Typical MacBook Pro has 2 ports, plus the USB serial port that's
		//	likely to be used in conjunction with this software…
		
		mPortsByName = [NSMutableDictionary dictionaryWithCapacity: 3];
		mPorts = [NSMutableArray array];
	}
	
	return self;
}

- (void)
dealloc
{
	::IONotificationPortDestroy(mNotifyPort);
}

/**
	Build an array from the Port objects we know about
*/

- (NSArray*)
ports
{
	NSArray* ports = [mPorts copy];
	return ports;
}

- (NSUInteger)
count
{
	return [mPortsByName count];
}

- (Port*)
portForName: (NSString*) inName
{
	Port* port = [mPortsByName objectForKey: inName];
	return port;
}

- (Port*)
portForNamePrefix: (NSString*) inName
{
	for (Port* port in mPortsByName.allValues)
	{
		if ([port.name hasPrefix: inName])
		{
			return port;
		}
	}
	
	return nil;
}

- (void)
registerUSBNotifications
{
	//	Search for the USB device…
	
	mach_port_t			masterPort;
	kern_return_t kr = ::IOMasterPort(MACH_PORT_NULL, &masterPort);
	if (kr != kIOReturnSuccess)
	{
		NSError* ex = [[NSError alloc] initWithDomain:NSMachErrorDomain
								code:kr userInfo:nil];

#if !ARC_ENABLED
		[ex autorelease];
#endif
		@throw ex;
	}
	
	CFMutableDictionaryRef matchDict = ::IOServiceMatching(kIOSerialBSDServiceValue);
	if (matchDict == NULL)
	{
		::NSLog(@"Couldn't create USB matching dictionary");
		::mach_port_deallocate(mach_task_self(), masterPort);
		return;
	}
	
	::CFDictionarySetValue(matchDict, CFSTR(kIOSerialBSDTypeKey), CFSTR(kIOSerialBSDAllTypes));
	
	mNotifyPort = ::IONotificationPortCreate(masterPort);
	CFRunLoopSourceRef runLoopSource = ::IONotificationPortGetRunLoopSource(mNotifyPort);
	::CFRunLoopAddSource(::CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopDefaultMode);

	//	Set up notification of device additions…
	
#if ARC_ENABLED
	void* voidSelf = (__bridge void*) self;
#else
	void* voidSelf = reinterpret_cast<void*> (self);
#endif

    matchDict = (CFMutableDictionaryRef) ::CFRetain(matchDict);
	kr = ::IOServiceAddMatchingNotification(mNotifyPort,
											kIOFirstMatchNotification,
											matchDict,
											DeviceAdded,
											voidSelf,
											&mDeviceAddedIter);
	
	[self deviceAdded: mDeviceAddedIter];			//	Deal with existing devices (if any)

	//	Set up notification of device removals…
	
    matchDict = (CFMutableDictionaryRef) ::CFRetain(matchDict);
	kr = ::IOServiceAddMatchingNotification(mNotifyPort,
											kIOTerminatedNotification,
											matchDict,
											DeviceRemoved,
											voidSelf,
											&mDeviceRemovedIter);
	
	[self deviceRemoved: mDeviceRemovedIter];			//	Deal with existing devices (if any)
	
	//	Clean up…
	
	::mach_port_deallocate(::mach_task_self(), masterPort);
}

- (void)
insertObject: (Port*) inPort
	inPortsAtIndex: (NSUInteger) inIndex
{
	[mPorts insertObject: inPort atIndex: inIndex];
}

- (void)
removeObjectFromPortsAtIndex: (NSUInteger) inIndex
{
	[mPorts removeObjectAtIndex: inIndex];
}

- (void)
deviceAdded: (io_iterator_t) inIter
{
	io_service_t	dev;
    while ((dev = ::IOIteratorNext(inIter)) != 0)
	{
		//::NSLog(@"Device was added: 0x%08X", dev);
		NSString* name = [Port nameForSystemPort: dev];
		//::NSLog(@"Port name for device: %@", name);
		Port* port = (Port*) [mPortsByName objectForKey: name];
		if (port == NULL)
		{
			port = [[Port alloc] init: dev];
			[mPortsByName setObject: port forKey: name];
			[[self mutableArrayValueForKey: @"ports"] addObject: port];
			if (self.delegate != nil)
			{
				[self.delegate portAdded: port];
			}
		}
		else
		{
			::NSLog(@"A port with name \"%@\" already exists", name);
		}
		(void) ::IOObjectRelease(dev);
	}
}

- (void)
deviceRemoved: (io_iterator_t) inIter
{
	io_service_t	dev;
    while ((dev = ::IOIteratorNext(inIter)) != 0)
	{
		NSString* name = [Port nameForSystemPort: dev];
		Port* port = (Port*) [mPortsByName objectForKey: name];
		if (port == NULL)
		{
			NSLog(@"A port with name \"%@\" could not be found", name);
		}
		else
		{
			[port close];
			[mPortsByName removeObjectForKey: name];
			[[self mutableArrayValueForKey: @"ports"] removeObject: port];
			//::NSLog(@"Device was removed: 0x%08X", dev);
			[port.delegate portRemoved: port];
			[self.delegate portRemoved: port];
		}
		
		(void) ::IOObjectRelease(dev);
	}
}


/**
	C-to-Obj-C glue code for USB notifications.
*/

void
DeviceAdded(void* inRefCon, io_iterator_t inIter)
{
	//	I really want to write the following, but ARC won’t let me.
	//
	//	PortList* me = reinterpret_cast<__bridge PortList*> (inRefCon);
	//
	//	So I settled for this…
	
#if ARC_ENABLED
	PortList* self = (__bridge PortList*) inRefCon;
#else
	PortList* self = reinterpret_cast<PortList*> (inRefCon);
#endif

	@try
	{
		[self deviceAdded: inIter];
	}
	
	@catch (id e)
	{
		::NSLog(@"Unhandled exception adding device %@", e);
	}
}

/**
	C-to-Obj-C glue code for USB notifications.
*/

void
DeviceRemoved(void* inRefCon, io_iterator_t inIter)
{
	//	I really want to write the following, but ARC won’t let me.
	//
	//	PortList* me = reinterpret_cast<__bridge PortList*> (inRefCon);
	//
	//	So I settled for this…
	
#if ARC_ENABLED
	PortList* self = (__bridge PortList*) inRefCon;
#else
	PortList* self = reinterpret_cast<PortList*> (inRefCon);
#endif
	
	@try
	{
		[self deviceRemoved: inIter];
	}
	
	@catch (id e)
	{
		::NSLog(@"Unhandled exception removing device %@", e);
	}
}

#if 0
- (void)
updatePortList
{
	if (mPortsByName == nil)
	{
		mPortsByName = [[NSMutableDictionary alloc] init];
	}
	
	// Serial devices are instances of class IOSerialBSDClient
	CFMutableDictionaryRef classesToMatch = ::IOServiceMatching(kIOSerialBSDServiceValue);
	if (classesToMatch != NULL)
	{
		NSMutableArray* ports = [[NSMutableArray alloc] init];
		
		::CFDictionarySetValue(classesToMatch, CFSTR(kIOSerialBSDTypeKey), CFSTR(kIOSerialBSDAllTypes));

		// This function decrements the refcount of the dictionary passed it
		
		io_iterator_t iter;
		kern_return_t kernResult = ::IOServiceGetMatchingServices(kIOMasterPortDefault, classesToMatch, &iter);    
		if (kernResult == KERN_SUCCESS)
		{			
			io_object_t systemPort;
			while ((systemPort = ::IOIteratorNext(iter)) != IO_OBJECT_NULL)
			{
				//	First look for a matching Port object in the current list…
				
				Port* port = [[Port alloc] init: systemPort];
				Port* existingPort = [mPortsByName objectForKey: port.name];
				if (existingPort == NULL)
				{
					[mPortsByName setObject: port forKey: port.name];
				}
				else
				{
				}
				
				/*
				NSUInteger idx = [mPorts indexOfObject: port];
				if (idx == NSNotFound)
				{
					[ports addObject: port];
					NSLog(@"Added port %@: %@", port.name, port);
				}
				else
				{
					NSLog(@"Removing port %@", ((Port*) [mPorts objectAtIndex: idx]).name);
					[mPorts removeObjectAtIndex: idx];
				}
				*/
				
				::IOObjectRelease(systemPort);
			}
			(void) ::IOObjectRelease(iter);
		}
		else
		{
			::NSLog(@"IOServiceGetMatchingServices returned %d", kernResult);
		}
		
		//self.ports = ports;
	}
	else
	{
		::NSLog(@"IOServiceMatching returned a NULL dictionary.");
	}
}
#endif

- (NSString*)
description
{
	NSMutableString* s = [NSMutableString string];
	for (Port* o in mPortsByName.allValues)
	{
		[s appendFormat: @"\n%@", o];
	}
	
	return s;
}

- (NSUInteger)
countByEnumeratingWithState: (NSFastEnumerationState*) outState
	objects: (id __unsafe_unretained []) outStackbuf
	count: (NSUInteger) inLen
{
	return [self.ports countByEnumeratingWithState: outState objects: outStackbuf count: inLen];
}


@dynamic	ports;
@synthesize	delegate			=	mDelegate;



@end
