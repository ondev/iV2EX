//
//  NodeNavigationTableViewCell.m
//  v2ex
//
//  Created by Haven on 8/28/14.
//  Copyright (c) 2014 LF. All rights reserved.
//

#import "NodeNavigationTableViewCell.h"

@implementation NodeNavigationTableViewCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (CGFloat)cacluateHeight {
    CGRect r = self.frame;
    CGFloat height = [self.adapteView calculateHeight];
    [self.adapteView updateConstraintsIfNeeded];
    return height + 1;
}

@end
