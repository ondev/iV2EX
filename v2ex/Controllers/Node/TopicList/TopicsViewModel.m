//
//  TopicsViewModel.m
//  v2ex
//
//  Created by Haven on 8/20/14.
//  Copyright (c) 2014 LF. All rights reserved.
//

#import "TopicsViewModel.h"
#import "DataModel.h"
#import "DBUtil.h"

@interface TopicsViewModel()

@property (nonatomic, strong) DataModel *fetchTopicList;

@end

@implementation TopicsViewModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.page = @(1);
        self.limit = @(20);
        @weakify(self);
        self.fetchTopicList = [DataModel new];
        [self.didBecomeActiveSignal subscribeNext:^(id x) {
            @strongify(self);
            self.fetchTopicList.requestPolicy = RequestReturnCacheDataElseLoad;
            [self generalRequest];
        }];
    }
    return self;
}

- (void)fetchTopics {
    
    self.loading = YES;
    if (self.apiLoading) {
        @weakify(self);
        [[self.fetchTopicList fetchLatestTopics] subscribeNext:^(id x) {
            @strongify(self);
            self.topics = x;
            self.loading = NO;
        }];
    }
    else {
        NSString *urlString = [NSString stringWithFormat:@"http://v2ex.com/go/%@", _node.nodeName];
        @weakify(self);
        [[self.fetchTopicList fetchTopics:urlString page:_page limit:_limit] subscribeNext:^(id x) {
            @strongify(self);
            self.topics = x;
            self.loading = NO;
        }];
    }

}

- (void)fetchMoreWithPolicy:(RequestPolicy)policy {
    NSInteger limit = [self.node.topicCount integerValue] - self.topics.count;
    if (limit > 20) {
        limit = 20;
    }
    self.page = @(1 + self.topics.count / 20);
    self.limit = @(limit);

    self.fetchTopicList.requestPolicy = policy;
    [self fetchTopics];
}

- (void)fetchRefresh {
    self.fetchTopicList.requestPolicy = RequestReloadIgnoringCacheData;
    self.topics = nil;
    self.limit = @(20);
    self.page = @(1);
    [self fetchTopics];
}

- (void)generalRequest {
    self.fetchTopicList.requestPolicy = RequestReturnCacheDataElseLoad;
    self.topics = nil;
    self.limit = @(20);
    self.page = @(1);
    [self fetchTopics];
}
@end
