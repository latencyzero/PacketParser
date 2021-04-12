//
//  Port.h
//  MacCTU
//
//  Created by Roderick Mann on 6/17/08.
//  Copyright 2008 Latency: Zero. All rights reserved.
//

//
//	Standard Imports
//

#include <sys/termios.h>

#include <IOKit/IOTypes.h>

//
//	Project Imports
//

#import "PortParameters.h"



@class Port;

@protocol PortDelegate<NSObject>

@optional

- (void)		portRemoved: (Port*) inPort;

@end




@interface
Port : NSObject
{
@private
	io_object_t				mSystemPort;
	int						mFD;
	NSFileHandle*			mHandle;
	SEL						mReadNotificationSelector;
	id						mNotificationTarget;
	
	NSString*				mName;
	PortParameters*			mParameters;
	
	NSArray*				mBaudRates;
	
	struct termios			mOptions;
	bool					mIsOpen;
	
	NSMutableData*			mBuffer;
	bool					mNotify;
}

@property (nonatomic, retain, readonly)		NSString*			name;
@property (nonatomic, retain, readwrite)	PortParameters*		parameters;
@property (nonatomic, assign)				speed_t				speed;
@property (retain, readonly)				NSArray*			baudRates;
@property (nonatomic, assign, readwrite)	bool				isOpen;
@property (nonatomic, assign)				bool				notify;
@property (nonatomic, weak)					id<PortDelegate>	delegate;

+ (NSString*)	nameForSystemPort: (io_object_t) inSystemPort;

- (id)			init: (io_object_t) inSystemPort;


- (bool)		open;
- (void)		close;

- (ssize_t)	write: (const void*) inData length: (ssize_t) inLength;
- (ssize_t)	writeString: (NSString*) inString;
- (ssize_t)	writeData: (NSData*) inData;

- (ssize_t)	read: (void*) outData length: (ssize_t) inLength;
- (NSData*)		read;

- (void)		readData: (NSNotification*) inNotification;
- (void)		notifyWhenDataRead: (SEL) inSelector object: (id) inObject;



@end
