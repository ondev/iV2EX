//
//  TopicViewModel.m
//  v2ex
//
//  Created by Haven on 8/24/14.
//  Copyright (c) 2014 LF. All rights reserved.
//

#import "TopicViewModel.h"
#import "DataModel.h"

@interface TopicViewModel()

@property (nonatomic, strong) DataModel *fetchAction;
@property (nonatomic) NSInteger finishedFetchActionCount;

@end

@implementation TopicViewModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.fetchAction = [DataModel new];
        @weakify(self);
        [self.didBecomeActiveSignal subscribeNext:^(id x) {
            @strongify(self);
            [self fetchTopic];
        }];
    }
    return self;
}

- (void)fetchTopic {
    self.finishedFetchActionCount = 0;
    @weakify(self);
    self.loading = YES;
    [[RACSignal merge:@[[self.fetchAction fetchTopicReplay:self.topic.topicId], [self.fetchAction fetchTopicDetail:self.topic.topicId]]] subscribeNext:^(id x) {
        @strongify(self);
        _finishedFetchActionCount++;
        if (_finishedFetchActionCount >= 2) {
            self.loading = NO;
        }
        if ([x isKindOfClass:[NSArray class]]) {
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"created" ascending:NO];
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            self.sortedReplies = [[x allObjects] sortedArrayUsingDescriptors:sortDescriptors];
            self.topic.replies = [NSSet setWithArray:x];
        }
        else if ([x isKindOfClass:[MemTopic class]]) {
            self.topic = x;
        }
        else {
            self.topic = nil;
        }
    }];
}

- (void)fetchMoreWithPolicy:(RequestPolicy)policy {
    self.fetchAction.requestPolicy = policy;
    [self fetchTopic];
}

- (void)fetchRefresh {
    self.fetchAction.requestPolicy = RequestReloadIgnoringCacheData;
    [self fetchTopic];
}

@end
