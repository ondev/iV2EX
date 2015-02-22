//
//  TopicCell.h
//  v2ex
//
//  Created by Haven on 19/12/13.
//  Copyright (c) 2013 LF. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"
#import "MemTopic.h"

@class TopicCell;

@protocol TopicCellDelegate <NSObject>

- (void)favorBtnTrigger:(TopicCell *)cell;

@end

@interface TopicCell : UITableViewCell

@property (weak, nonatomic) id<TopicCellDelegate> delegate;

@property (nonatomic, strong) MemTopic *topic;
- (CGFloat)calculateWithData:(MemTopic *)topic;
@end
