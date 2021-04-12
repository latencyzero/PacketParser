//
//  UIViewController+LZ.m
//  MissionClock
//
//  Created by Roderick Mann on 11/15/12.
//  Copyright (c) 2012 Latency: Zero. All rights reserved.
//

#import "UIViewController+LZ.h"










@implementation UIViewController (LZ)

- (UISplitViewController*)
findSplitViewController
{
	UISplitViewController* svc = nil;
	UIViewController* vc = self;
	do
	{
		if ([vc isKindOfClass: [UISplitViewController class]])
		{
			svc = (UISplitViewController*) vc;
			break;
		}
		
		vc = vc.parentViewController;
	} while (vc != nil);
	
	return svc;
}

- (UIViewController*)
findSplitViewDetailController
{
	UISplitViewController* svc = [self findSplitViewController];
	
	if (svc != nil)
	{
		NSArray* vcs = svc.viewControllers;
		if (vcs.count > 1)
		{
			UIViewController* dc = vcs.lastObject;		//	Get the detail controller
			
			//	If it’s a nav controller, drill down one more…
			
			if ([dc isKindOfClass: [UINavigationController class]])
			{
				dc = [((UINavigationController*) dc).viewControllers objectAtIndex: 0];
			}
			
			return dc;
		}
	}
	
	return nil;
}


- (void)
dumpAncestors
{
	UIViewController* vc = self;
	while (vc != nil)
	{
		NSLog(@"VC: %@", vc);
		vc = vc.parentViewController;
	}
}

@end
