/**
	LZFreeMemoryView.m
	
	Created by Roderick Mann on 3/4/11.
	Copyright 2011 Latency: Zero. All rights reserved.
*/

#import "LZFreeMemoryView.h"





static NSUInteger				memoryAvailable();


//
//	Standard Imports
//

#import <mach/mach_host.h>



static
NSUInteger
memoryAvailable()
{
	mach_port_t hostPort = mach_host_self();
	vm_size_t pageSize;
	host_page_size(hostPort, &pageSize);        

	vm_statistics_data_t vm_stat;
	mach_msg_type_number_t hostSize = sizeof (vm_statistics_data_t) / sizeof (integer_t);
	kern_return_t result = host_statistics(hostPort, HOST_VM_INFO, (host_info_t) &vm_stat, &hostSize);
	if (result == KERN_SUCCESS)
	{
		// Stats in bytes.
		/* natural_t mem_used = (vm_stat.active_count +
		vm_stat.inactive_count +
		vm_stat.wire_count) * pagesize; */
		natural_t freeMem = vm_stat.free_count * pageSize;

		//natural_t mem_total = mem_used + mem_free;

		return freeMem;
	}
	return 0;
}



@interface LZFreeMemoryView()

- (void)		commonInit;
- (void)		update: (NSTimer*) inTimer;
- (void)		didReceiveMemoryWarning: (NSNotification*) inNotification;

@end


@implementation LZFreeMemoryView

- (id)
initWithFrame: (CGRect) inFrame
{
	self = [super initWithFrame: inFrame];
	if (self != nil)
	{
		self.backgroundColor = [UIColor whiteColor];
		self.textColor = [UIColor blackColor];
		self.textAlignment = NSTextAlignmentRight;
		[self commonInit];
	}
	return self;
}

- (void)
awakeFromNib
{
	[super awakeFromNib];
	[self commonInit];
}

- (void)
commonInit
{
	[mTimer invalidate];
	mTimer = [NSTimer scheduledTimerWithTimeInterval: 0.5 target: self selector: @selector(update:) userInfo: NULL repeats: true];
	mNF = [[NSNumberFormatter alloc] init];
	mNF.numberStyle = NSNumberFormatterDecimalStyle;
	mSavedBackgroundColor = self.backgroundColor;
	
	[[NSNotificationCenter defaultCenter]
		addObserver: self
		selector: @selector(didReceiveMemoryWarning:)
		name: UIApplicationDidReceiveMemoryWarningNotification
		object: nil];
}

- (void)
dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	
	[mTimer invalidate];
}

- (void)
update: (NSTimer*) inTimer
{
	float freeMem = memoryAvailable();
	
	const float	kBytesThreshold				=	10.0f * 1024.0f;
	const float	kKiBytesThreshold			=	10.0f * 1024.0f * 1024.0f;
	const float	kMiBytesThreshold			=	10.0f * 1024.0f * 1024.0f * 1024.0f;
	const float	kGiBytesThreshold			=	10.0f * 1024.0f * 1024.0f * 1024.0f * 1024.0f;
	
	NSString* units = nil;
	if (freeMem < kBytesThreshold)
	{
		units = @"B";
	}
	else if (freeMem < kKiBytesThreshold)
	{
		freeMem /= 1024;
		units = @"KiB";
	}
	else if (freeMem < kMiBytesThreshold)
	{
		freeMem /= 1024 * 1024;
		units = @"MiB";
	}
	else if (freeMem < kGiBytesThreshold)
	{
		freeMem /= 1024 * 1024 * 1024;
		units = @"GiB";
	}
	
	NSString* s = [mNF stringFromNumber: [NSNumber numberWithUnsignedInteger: freeMem]];
	
	self.text = [NSString stringWithFormat: @"%@ %@ ", s, units];
	[self.superview bringSubviewToFront: self];
}

- (void)
didReceiveMemoryWarning: (NSNotification*) inNotification
{
	[super setBackgroundColor: [UIColor redColor]];	//	Do this so we don't stomp on our saved value.
	
	[self performSelector: @selector(setBackgroundColor:) withObject: mSavedBackgroundColor afterDelay: 1.0f];
}

#pragma mark -
#pragma mark • Attributes

- (void)
setBackgroundColor: (UIColor*) inColor
{
	mSavedBackgroundColor = inColor;
	[super setBackgroundColor: inColor];
}

@end
