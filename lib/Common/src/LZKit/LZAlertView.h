/**
	LZAlert.h
	iUAV
	
	Created by Roderick Mann on 9/10/11.
	Copyright 2011 Latency: Zero. All rights reserved.
*/

typedef void (^LZAlertDismissedBlock) (NSInteger inButtonIdx);

/**
	Provides a block-based subclass of UIAlertView.
*/

@interface
LZAlertView : UIAlertView
{
	LZAlertDismissedBlock		mDismissedBlock;

}

+ (LZAlertView*)	alertViewWithTitle: (NSString*) inTitle
						message: (NSString*) inMsg
						cancelButtonTitle: (NSString*) inCancel
						okButtonTitle: (NSString*) inOK
						withBlock: (LZAlertDismissedBlock) inBlock;
						
@end
