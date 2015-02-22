//
//  NodeNavigationTableViewCell.h
//  v2ex
//
//  Created by Haven on 8/28/14.
//  Copyright (c) 2014 LF. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NodeView.h"

@interface NodeNavigationTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet NodeView *adapteView;

- (CGFloat)cacluateHeight;
@end
