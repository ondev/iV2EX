//
//  ViewModel.m
//  v2ex
//
//  Created by Haven on 8/25/14.
//  Copyright (c) 2014 LF. All rights reserved.
//

#import "ViewModel.h"

@interface ViewModel()
@property (nonatomic,assign,getter=isLoading) BOOL loading;
@end

@implementation ViewModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.fetchAction = [DataModel new];
        @weakify(self);
        [self.didBecomeActiveSignal subscribeNext:^(id x) {
            @strongify(self);
            [self fetchData];
        }];
    }
    return self;
}

- (void)fetchData {
    
}
@end
