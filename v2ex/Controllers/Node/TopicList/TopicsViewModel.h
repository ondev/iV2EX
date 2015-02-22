//
//  TopicsViewModel.h
//  v2ex
//
//  Created by Haven on 8/20/14.
//  Copyright (c) 2014 LF. All rights reserved.
//

#import "RVMViewModel.h"
#import "MemNode.h"

@interface TopicsViewModel : RVMViewModel

@property (nonatomic, strong) NSArray *topics;
@property (nonatomic, getter=isLoading) BOOL loading;
@property (nonatomic, strong) NSString *nodeTitle;
@property (nonatomic, strong) MemNode *node;

@property (nonatomic) BOOL apiLoading;
@property (nonatomic, strong) NSNumber *page;
@property (nonatomic, strong) NSNumber *limit;

- (void)fetchTopics;
- (void)fetchMoreWithPolicy:(RequestPolicy)policy;
- (void)fetchRefresh;
@end
