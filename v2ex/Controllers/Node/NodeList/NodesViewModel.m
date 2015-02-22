//
//  NodesViewModel.m
//  v2ex
//
//  Created by Haven on 8/25/14.
//  Copyright (c) 2014 LF. All rights reserved.
//

#import "NodesViewModel.h"

@interface NodesViewModel()
@property (nonatomic,assign,getter=isLoading) BOOL loading;
@end

@implementation NodesViewModel
@synthesize loading;

- (void)fetchData {
    self.loading = YES;
    @weakify(self);
    [[self.fetchAction fetchAllNodes] subscribeNext:^(id x) {
        @strongify(self);
        self.nodes = x;
        self.loading = NO;
    }];
}
@end
