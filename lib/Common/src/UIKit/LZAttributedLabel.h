/**
	LZAttributedLabel.h
	
	Created by Roderick Mann on 1/18/11.
	Copyright 2011 Latency: Zero. All rights reserved.
*/

#import <UIKit/UIKit.h>

//
//	Standard Imports
//

#import <CoreText/CoreText.h>



@interface
LZAttributedLabel : UIView
{
	NSAttributedString*				mText;
	bool							mEnabled;
	
	CTFramesetterRef				mFramesetter;
	CGPathRef						mFramePath;
	CTFrameRef						mFrame;
	CGFloat							mTextHeight;
	bool							mNeedsHitBounds;		///< Set to true to recalculate hit bounds on next draw
}

@property (nonatomic, copy)		NSAttributedString*				text;
@property (nonatomic, assign)	bool							enabled;
@property (nonatomic, assign)	CGFloat							textHeight;


- (void)			updateFramesetter;

@end


@interface
YAttributedLabelLinkHit : NSObject
{
	NSAttributedString*				mString;
	NSRange							mLinkRange;
	id								mContext;
}

@property (nonatomic, retain)	NSAttributedString*			string;
@property (nonatomic, assign)	NSRange						linkRange;
@property (nonatomic, retain)	id							context;

@end
