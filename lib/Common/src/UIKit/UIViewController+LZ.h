//
//  UIViewController+LZ.h
//  MissionClock
//
//  Created by Roderick Mann on 11/15/12.
//  Copyright (c) 2012 Latency: Zero. All rights reserved.
//




@interface UIViewController (LZ)

/**
	Searches the view controller hierarchy for the associated detail controller. If there
	is no ancestral UISplitViewController, this method returns nil.
*/

- (UIViewController*)		findSplitViewDetailController;

- (void)					dumpAncestors;

@end
