//
//  TopicViewModel.h
//  v2ex
//
//  Created by Haven on 8/24/14.
//  Copyright (c) 2014 LF. All rights reserved.
//

#import "RVMViewModel.h"
#import "MemTopic.h"
#import "MemReply.h"

@interface TopicViewModel : RVMViewModel
@property (nonatomic, strong) MemTopic *topic;
@property (nonatomic, getter=isLoading) BOOL loading;
@property (nonatomic, strong) NSArray *sortedReplies;

- (void)fetchMoreWithPolicy:(RequestPolicy)policy;
- (void)fetchRefresh;
@end
