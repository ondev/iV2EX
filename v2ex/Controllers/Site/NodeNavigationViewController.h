//
//  NodeNavigationViewController.h
//  v2ex
//
//  Created by Haven on 8/28/14.
//  Copyright (c) 2014 LF. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableViewController.h"
#import "DataModel.h"

@interface NodeNavigationViewController : BaseTableViewController
@property (nonatomic, strong) NSArray *navigations;
@property (nonatomic, strong) DataModel *logoutModel;
@end
