//
//  TopicViewController.h
//  v2ex
//
//  Created by Haven on 8/25/14.
//  Copyright (c) 2014 LF. All rights reserved.
//

#import "JSMessagesViewController.h"
#import "TopicViewModel.h"
#import "EGORefreshTableHeaderView.h"

@interface TopicViewController : JSMessagesViewController<EGORefreshTableHeaderDelegate>

@property (nonatomic, strong) TopicViewModel *viewModel;

@property (nonatomic, strong) EGORefreshTableHeaderView *refreshHeaderView;
@property (nonatomic) BOOL reloading;
- (void)enableRefresh:(BOOL)enable;
@end
