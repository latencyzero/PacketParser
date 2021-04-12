/**
	LZAlertView.m
	iUAV
	
	Created by Roderick Mann on 9/10/11.
	Copyright 2011 Latency: Zero. All rights reserved.
*/

#import "LZAlertView.h"







@implementation LZAlertView

+ (LZAlertView*)
alertViewWithTitle: (NSString*) inTitle
	message: (NSString*) inMsg
	cancelButtonTitle: (NSString*) inCancel
	okButtonTitle: (NSString*) inOK
	withBlock: (LZAlertDismissedBlock) inBlock
{
	LZAlertView* av = [[LZAlertView alloc]
							initWithTitle: inTitle
							message: inMsg
							delegate: nil
							cancelButtonTitle: inCancel
							otherButtonTitles: inOK, nil];
	av.delegate = av;
	av->mDismissedBlock = [inBlock copy];
	
#if ARC_ENABLED
	return av;
#else
	return [av autorelease];
#endif
}

#if !ARC_ENABLED
- (void)
dealloc
{
	[mDismissedBlock release];
	
    [super dealloc];
}
#endif

- (void)
alertView: (UIAlertView*) inAlertView
	didDismissWithButtonIndex: (NSInteger) inButtonIndex
{
	if (mDismissedBlock != nil)
	{
		mDismissedBlock(inButtonIndex);
	}
}


@end
