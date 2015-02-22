//
//  NodeListCell.h
//  v2ex
//
//  Created by Haven City on 27/2/14.
//  Copyright (c) 2014 LF. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MemNode.h"

@class NodeListCell;
@protocol NodeListCellDelegate <NSObject>

- (void)favorNodeTrigger:(NodeListCell *)cell;
- (void)shareNodeTrigger:(NodeListCell *)cell;

@end


@interface NodeListCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *ibName;
@property (nonatomic, weak) IBOutlet UILabel *ibCreateTime;
@property (nonatomic, weak) IBOutlet UILabel *ibHeader;
@property (weak, nonatomic) IBOutlet UILabel *ibTopicCount;
@property (nonatomic, strong) MemNode *node;
@property (nonatomic, weak) id<NodeListCellDelegate> delegate;
@end
