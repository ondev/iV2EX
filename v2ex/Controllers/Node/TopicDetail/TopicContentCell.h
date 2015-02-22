//
//  TopicContentCell.h
//  v2ex
//
//  Created by Haven on 16/2/14.
//  Copyright (c) 2014 LF. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"
#import "MemTopic.h"

@class TopicContentCell;

@protocol TopicContentCellDelegate <NSObject>

- (void)shareBtnTrigger:(TopicContentCell *)cell;
- (void)favorBtnTrigger:(TopicContentCell *)cell;

@end

@interface TopicContentCell : UITableViewCell
@property (nonatomic, strong) MemTopic *topic;

@property (nonatomic, weak) id <TopicContentCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet AsyncImageView *userIcon;

@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *topicTitle;
@property (weak, nonatomic) IBOutlet UILabel *topicAuthorLabel;
@property (weak, nonatomic) IBOutlet UILabel *topicTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *topicReplayCountLabel;

@end
