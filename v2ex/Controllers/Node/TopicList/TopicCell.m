//
//  TopicCell.m
//  v2ex
//
//  Created by Haven on 19/12/13.
//  Copyright (c) 2013 LF. All rights reserved.
//

#import "TopicCell.h"
#import "Utils.h"
#import "NSDate+TimeAgo.h"
#import "DBUser.h"
#import "DBUtil.h"

@interface TopicCell()


@property (weak, nonatomic) IBOutlet UILabel *authorName;
@property (weak, nonatomic) IBOutlet AsyncImageView *authorImg;
@property (weak, nonatomic) IBOutlet UILabel *ibTopicTime;
@property (weak, nonatomic) IBOutlet UILabel *ibTopicLabel;
@property (weak, nonatomic) IBOutlet UILabel *ibReplayLabel;
@property (weak, nonatomic) IBOutlet UILabel *ibNodeNameLabel;

@end

@implementation TopicCell

- (void)awakeFromNib {
    self.authorImg.layer.masksToBounds = YES;
    self.authorImg.layer.cornerRadius = 3;
    // Initialization code
    RAC(self.authorName, text) = [RACObserve(self, topic.topicAuthorName) ignore:nil];
    RAC(self.ibTopicLabel, text) = [RACObserve(self, topic.topicTitle) ignore:nil];
    RAC(self.ibReplayLabel, text) = [RACObserve(self, topic.topicRepliesCount) ignore:nil];
    RAC(self.ibNodeNameLabel, text) = [RACObserve(self, topic.nodeName) ignore:nil];
    RAC(self.ibTopicTime, text) = [[RACObserve(self, topic.topicCreated) ignore:nil] map:^id(id value) {
        if (value) {
            NSTimeInterval _interve = [value doubleValue];
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interve];
            return [date timeAgo];
        }
        else {
            return  @"NA";
        }
    }];
    
    RAC(self.authorImg, imageURL) = [[RACObserve(self, topic.topicAuthorImgUrl) ignore:nil] map:^id(id value) {
        [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:self.authorImg];
        return [NSURL URLWithString:value];
    }];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)addFavor:(id)sender {
    DBUser *user = [DBUtil loadDBUser];
    NSArray *c = user.collections;
    NSMutableArray *collections = [NSMutableArray arrayWithArray:c];
    __block BOOL alreadyExist = NO;
    [c enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (obj) {
            *stop = [[obj allKeys] containsObject:self.topic.nodeName];
            
            alreadyExist = *stop;
        }
    }];
    if (!alreadyExist) {
        MemNode *node = [DBUtil nodeByName:self.topic.nodeName];
        [collections addObject:@{self.topic.nodeName:node.nodeTitle}];
        user.collections = collections;
        [user save];
    }
}

- (IBAction)unLike:(id)sender {
    [Utils unLike];
}

- (CGFloat)calculateWithData:(MemTopic *)topic {
    self.ibTopicLabel.text = topic.topicTitle;
    CGSize s = [self.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return s.height + 1;
}
@end
