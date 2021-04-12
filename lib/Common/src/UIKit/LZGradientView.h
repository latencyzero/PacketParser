//
//  LZGradientView.h
//
//  Created by Roderick Mann on 6/12/09.
//  Copyright 2009 Latency: Zero. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface
LZGradientView : UIView
{
	UIColor*			mStartColor;
	UIColor*			mEndColor;
	UIColor*			mBorderColor;
	CGFloat				mCornerRadius;
}

@property (nonatomic, strong)	UIColor*			startColor;
@property (nonatomic, strong)	UIColor*			endColor;
@property (nonatomic, strong)	UIColor*			borderColor;
@property (nonatomic, assign)	CGFloat				cornerRadius;

@end
