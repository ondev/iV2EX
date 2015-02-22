//
//  TabViewController.h
//  v2ex
//
//  Created by Haven on 8/3/14.
//  Copyright (c) 2014 LF. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HMSegmentedControl;

@interface TabViewController : UIViewController
@property (nonatomic, strong) HMSegmentedControl *segmentedControl;
@property (nonatomic, strong) NSDictionary *segs;
@end
