//
//  Port.m
//  MacCTU
//
//  Created by Roderick Mann on 6/17/08.
//  Copyright 2008 Latency: Zero. All rights reserved.
//

#import "Port.h"

#include <sys/fcntl.h>
#include <sys/ioctl.h>
#include <sys/param.h>

#include <IOKit/IOTypes.h>
#include <IOKit/IOKitLib.h>
#include <IOKit/serial/IOSerialKeys.h>
#include <IOKit/serial/ioss.h>
#include <IOKit/IOBSD.h>




/*
	//	Change property access for this file only:
	
@interface Port ()
@property (readwrite, copy)	NSString*	name;
@end
*/

//	"Proper" KVO registration:
//static NSString * const FlowControlObservationContext = @"FlowControlObservationContext";
//[self addObserver: self forKeyPath: @"flowControl" options: NSKeyValueObservingOptionNew context: FlowControlObservationContext];

@interface Port()
- (void)		setupBaudRates;
@end

@implementation Port



+ (NSString*)
nameForSystemPort: (io_object_t) inSystemPort
{
	NSString* name = CFBridgingRelease(::IORegistryEntryCreateCFProperty(inSystemPort, CFSTR(kIOTTYDeviceKey), kCFAllocatorDefault, 0));
	//(__bridge_transfer NSString*) ;
	return name;
}




- (id)
init: (io_object_t) inSystemPort
{
	self = [super init];
	if (self != nil)
	{
		mSystemPort = inSystemPort;
		::IOObjectRetain(mSystemPort);
		
		mName = [Port nameForSystemPort: mSystemPort];
		//CFStringRef bsdPath = (CFStringRef) ::IORegistryEntryCreateCFProperty(mSystemPort, CFSTR(kIOCalloutDeviceKey), kCFAllocatorDefault, 0);
		//CFStringRef serviceType = (CFStringRef) ::IORegistryEntryCreateCFProperty(mSystemPort, CFSTR(kIOSerialBSDTypeKey), kCFAllocatorDefault, 0);
		mFD = -1;
		
		[self setupBaudRates];
		
		mParameters = [[PortParameters alloc] init];
		self.parameters.speed = 115200;
		self.parameters.flowControl = kFlowControlNone;
		//self.parameters.flowControl = kFlowControlHardware;
		self.parameters.dataBits = 8;
		self.parameters.parity = kParityNone;
		self.parameters.stopBits = 1;
		
		mBuffer = [NSMutableData data];
#if !ARC_ENABLED
		[mBuffer retain];
#endif
	}
	
	return self;
}

- (void)
dealloc
{
	[self close];
	
	if (mSystemPort != 0)
	{
		::IOObjectRelease(mSystemPort);
	}
	
#if !ARC_ENABLED
	[mBuffer release];
	[mHandle release];
	[mName release];
	[mParameters release];
	[mBaudRates release];
	
	[super dealloc];
#endif
}

/**
	Two Ports are considered equal if their names are the same.
*/

- (BOOL)
isEqual: (id) inObject
{
	if (![inObject isKindOfClass: [Port class]])
	{
		return NO;
	}
	
	Port* port = (Port*) inObject;
	return [self.name isEqual: port.name];
}


- (void)
setupBaudRates
{
	if (mBaudRates == nil)
	{
		NSMutableArray* rates = [[NSMutableArray alloc] init];
		
		[rates addObject: [NSNumber numberWithUnsignedInt: B300]];
		[rates addObject: [NSNumber numberWithUnsignedInt: B600]];
		[rates addObject: [NSNumber numberWithUnsignedInt: B1200]];
		[rates addObject: [NSNumber numberWithUnsignedInt: B1800]];
		[rates addObject: [NSNumber numberWithUnsignedInt: B2400]];
		[rates addObject: [NSNumber numberWithUnsignedInt: B4800]];
		[rates addObject: [NSNumber numberWithUnsignedInt: B7200]];
		[rates addObject: [NSNumber numberWithUnsignedInt: B9600]];
		[rates addObject: [NSNumber numberWithUnsignedInt: B14400]];
		[rates addObject: [NSNumber numberWithUnsignedInt: 19200]];
		[rates addObject: [NSNumber numberWithUnsignedInt: B28800]];
		[rates addObject: [NSNumber numberWithUnsignedInt: 38400]];
		[rates addObject: [NSNumber numberWithUnsignedInt: B57600]];
		[rates addObject: [NSNumber numberWithUnsignedInt: B76800]];
		[rates addObject: [NSNumber numberWithUnsignedInt: B115200]];
		[rates addObject: [NSNumber numberWithUnsignedInt: B230400]];
		[rates addObject: [NSNumber numberWithUnsignedInt: 250000]];
		[rates addObject: [NSNumber numberWithUnsignedInt: 1000000]];
		[rates addObject: [NSNumber numberWithUnsignedInt: 2000000]];
		[rates addObject: [NSNumber numberWithUnsignedInt: 3000000]];
		
		mBaudRates = [[NSArray alloc] initWithArray: rates];
	}
}

- (void)
setFlowControl: (FlowControl) inVal
{
	self.parameters.flowControl = inVal;
	
	//	TODO: Do something.
}

- (bool)
open
{
	//	Get the BSD path, because OS X is too stupid to provide decent
	//	APIs, instead sticking us with this POSIX shit…
	
	::NSLog(@"System port: 0x%08X\n", mSystemPort);
	CFStringRef bsdPathAsCFString = (CFStringRef) ::IORegistryEntryCreateCFProperty(mSystemPort,
																		CFSTR(kIOCalloutDeviceKey),
																		kCFAllocatorDefault,
																		0);
	if (bsdPathAsCFString == NULL)
	{
		::NSLog(@"Couldn't get BSD path\n");
		return false;
	}
	//::NSLog(@"Path: %@\n", bsdPathAsCFString);
	
    char		bsdPath[MAXPATHLEN];
	bool result = ::CFStringGetCString(bsdPathAsCFString,
										bsdPath,
										MAXPATHLEN,
										kCFStringEncodingUTF8);
	::CFRelease(bsdPathAsCFString);
	if (!result)
	{
		::NSLog(@"Can't get bsdPath as CString %@\n", bsdPathAsCFString);
		return false;
	}
	
	//	Do the open non-blocking, set blocking below…
	
	//char* foo = "/foo.txt";
	//mFD = ::open(foo, O_RDWR);
	mFD = ::open(bsdPath, O_RDWR | O_NOCTTY | O_NONBLOCK);
	if (mFD == -1)
	{
		::NSLog(@"Error opening serial port %@ (%s): %s (%d)\n", self.name, bsdPath, ::strerror(errno), errno);
		return false;
	}
	
	NSLog(@"Opened serial port %s, FD: %d", bsdPath, mFD);
	//	Disallow multiple opens…
	
	if (::ioctl(mFD, TIOCEXCL) == -1)
	{
		::NSLog(@"Error setting TIOCEXCL %@: %s (%d)\n", self.name, ::strerror(errno), errno);
		if (mFD != -1)		::close(mFD);
		return false;
	}
	
	//	Set blocking on the port…
	
	if (::fcntl(mFD, F_SETFL, 0) == -1)
	{
		::NSLog(@"Error clearing O_NONBLOCK %@ - %s(%d).\n", self.name, ::strerror(errno), errno);
		if (mFD != -1)		::close(mFD);
		return false;
	}
	
	//	Get the current options…
	
	if (::tcgetattr(mFD, &mOptions) == -1)
	{
		::NSLog(@"Error getting termios %@ - %s(%d).\n", self.name, ::strerror(errno), errno);
		if (mFD != -1)		::close(mFD);
		return false;
	}
	
	//	Set raw (non-canonical) mode…
	
	if (true)
	{
		::cfmakeraw(&mOptions);
		mOptions.c_cc[VMIN] = 1;
		mOptions.c_cc[VTIME] = 0;
	}
	else
	{
		//mOptions.c_cc[VEOL] = '\r';
	}

	::NSLog(@"Current options: 0x%08lX\n", mOptions.c_cflag);
	::cfsetspeed(&mOptions, self.parameters.speed);
	[self willChangeValueForKey: @"speed"];
	mSpeed = self.parameters.speed;
	[self didChangeValueForKey: @"speed"];
	
	NSLog(@"Opened with speed %ld", self.parameters.speed);
	if (self.parameters.dataBits == 7)			mOptions.c_cflag |= CS7;
	if (self.parameters.dataBits == 8)			mOptions.c_cflag |= CS8;
	if (self.parameters.parity != kParityNone)	mOptions.c_cflag |= PARENB;
	if (self.parameters.parity == kParityOdd)	mOptions.c_cflag |= PARODD;
	if (self.parameters.flowControl == kFlowControlHardware)
	{
		mOptions.c_cflag |= (CCTS_OFLOW | CRTS_IFLOW);
	}
	else if (self.parameters.flowControl == kFlowControlSoftware)
	{
	}
	::NSLog(@"Current options: 0x%08lX\n", mOptions.c_cflag);
	
	int err = ::tcsetattr(mFD, TCSANOW, &mOptions);
	if (err != 0)
	{
		NSLog(@"Error calling tcsetattr: %d, %d, %s", err, errno, strerror(errno));
	}
	
	mHandle = [[NSFileHandle alloc] initWithFileDescriptor: mFD];
	if (mHandle == nil)
	{
		return false;
	}
	
	self.isOpen = true;
	[[NSNotificationCenter defaultCenter]
		addObserver: self
		selector: @selector(readData:)
		name: NSFileHandleReadCompletionNotification
		object: mHandle];
		
	[mHandle readInBackgroundAndNotify];
	
	return true;
	
	//	TODO: Set other params
	
}

- (void)
close
{
	if (!self.isOpen)
	{
		return;
	}
	
	NSLog(@"Closing FD %d", mFD);
	
	//	Supposedly this stops any pending read, but it doesn't help
	//	with the problem of NSFileHandle not closing all its descriptors…
	
	if (fcntl(mFD, F_SETFL, fcntl(mFD, F_GETFL, 0) | O_NONBLOCK) == -1)
	{
		NSLog(@"Error clearing O_NONBLOCK - %s(%d).\n", strerror(errno), errno);
	}
	
	self.isOpen = false;
	[mHandle closeFile];
	mFD = -1;
	mHandle = nil;
}

- (ssize_t)
write: (const void*) inData length: (ssize_t) inLength
{
	return ::write(mFD, inData, inLength);
}

- (ssize_t)
writeData: (NSData*) inData
{
	return [self write: inData.bytes length: inData.length];
}

- (ssize_t)
writeString: (NSString*) inString
{
	NSData* data = [inString dataUsingEncoding: NSUTF8StringEncoding];
	return [self writeData: data];
}

- (ssize_t)
read: (void*) outData length: (ssize_t) inLength
{
	return ::read(mFD, outData, inLength);
}

- (NSData*)
read
{
	NSData* data = [NSData dataWithData: mBuffer];
	mBuffer.length = 0;
	return data;
}

- (void)
readData: (NSNotification*) inNotification
{
	NSData* data = [inNotification.userInfo objectForKey: NSFileHandleNotificationDataItem];
	if (data.length > 0)
	{
		[mBuffer appendData: data];
		
		if (mNotify)
		{
			data = [self read];
	#pragma clang diagnostic push
	#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
			[mNotificationTarget performSelector: mReadNotificationSelector withObject: data];
	#pragma clang diagnostic pop
		}
	}
	
	if (self.isOpen)
	{
		[mHandle readInBackgroundAndNotify];
	}
}

- (void)
notifyWhenDataRead: (SEL) inSelector
	object: (id) inObject
{
	mReadNotificationSelector = inSelector;
	mNotificationTarget = inObject;
	
	mNotify = true;
}

- (NSString*)
description
{
	NSString* desc = [NSString stringWithFormat: @"%@, %@", self.name, self.parameters];
	return desc;
}

- (void)
setSpeed: (speed_t) inSpeed
{
	if (inSpeed == mSpeed)
	{
		return;
	}
	
	mSpeed = inSpeed;
	
#if 0
	struct termios	options;
	int err = ::tcgetattr(mFD, &options);
	if (err != 0)
	{
		::NSLog(@"Error getting termios %@ - %s(%d).\n", self.name, ::strerror(errno), errno);
		return;
	}
	
	::cfsetspeed(&options, mSpeed);
	
	err = ::tcsetattr(mFD, 0, &options);
	if (err != 0)
	{
		NSLog(@"Error calling tcsetattr: %d, %d, %s", err, errno, strerror(errno));
		return;
	}
#else
    if (::ioctl(mFD, IOSSIOSPEED, &mSpeed) == -1)
	{
		NSLog(@"Error calling ioctl(mFD, IOSSIOSPEED: %d, %s", errno, strerror(errno));
	}
#endif
}

- (speed_t)
speed
{
	return mSpeed;
}


@synthesize	name					=	mName;
@synthesize	baudRates				=	mBaudRates;
@synthesize	parameters				=	mParameters;
@synthesize speed					=	mSpeed;
@synthesize	isOpen					=	mIsOpen;

@synthesize notify					=	mNotify;
@synthesize	delegate				=	mDelegate;

@end
