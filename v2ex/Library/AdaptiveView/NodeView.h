//
//  NodeView.h
//  NodeViewDemo
//
//  Created by Haven on 8/27/14.
//  Copyright (c) 2014 Haven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NodeView : UIView
@property (nonatomic, strong) NSArray *data;
@property (nonatomic, weak) UINavigationController *nav;
- (void)reset;
- (CGFloat)calculateHeight;
@end
