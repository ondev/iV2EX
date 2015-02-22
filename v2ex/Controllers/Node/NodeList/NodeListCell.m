//
//  NodeListCell.m
//  v2ex
//
//  Created by Haven City on 27/2/14.
//  Copyright (c) 2014 LF. All rights reserved.
//

#import "NodeListCell.h"
#import "DBUtil.h"
#import "Utils.h"

@implementation NodeListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)favorNode:(id)sender {
    DBUser *user = [DBUtil loadDBUser];
    NSArray *c = user.collections;
    NSMutableArray *collections = [NSMutableArray arrayWithArray:c];
    __block BOOL alreadyExist = NO;
    [c enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (obj) {
            *stop = [[obj allKeys] containsObject:self.node.nodeName];
            
            alreadyExist = *stop;
        }
    }];
    if (!alreadyExist) {
        [collections addObject:@{self.node.nodeName:self.node.nodeTitle}];
        user.collections = collections;
        [user save];
    }
    
    [Utils showMessage:@"收藏成功"];
}


- (IBAction)shareNode:(id)sender {
    if ([_delegate respondsToSelector:@selector(shareNodeTrigger:)]) {
        [_delegate shareNodeTrigger:self];
    }
}
@end
