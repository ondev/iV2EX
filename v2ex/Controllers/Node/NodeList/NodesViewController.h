//
//  NodesViewController.h
//  v2ex
//
//  Created by Haven on 19/12/13.
//  Copyright (c) 2013 LF. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NodesViewModel.h"

@interface NodesViewController : UITableViewController

@property (nonatomic, strong) NodesViewModel *viewModel;
@end
