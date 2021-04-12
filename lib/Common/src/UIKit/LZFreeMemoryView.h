/**
	LZFreeMemoryView.h
	
	Created by Roderick Mann on 3/4/11.
	Copyright 2011 Latency: Zero. All rights reserved.
*/

#import <UIKit/UIKit.h>

/**
	Add this view somewhere in your UI, and you'll get a constantly-updating
	display of the amount of available memory.
*/

@interface
LZFreeMemoryView : UILabel
{
	NSTimer*			mTimer;
	NSNumberFormatter*	mNF;
	UIColor*			mSavedBackgroundColor;
}

@end
