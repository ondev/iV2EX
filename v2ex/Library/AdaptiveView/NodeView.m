//
//  NodeView.m
//  NodeViewDemo
//
//  Created by Haven on 8/27/14.
//  Copyright (c) 2014 Haven. All rights reserved.
//

#import "NodeView.h"
#import "NodeButton.h"
#import "NodesViewController.h"
#import "TopicsViewController.h"
#import "TabViewController.h"
#import "DBUtil.h"

#define LeftPadding  20
#define RightPadding 20
#define ItemHPadding 20
#define ItemVPadding 10

@interface NodeView  ()

@property (nonatomic, strong) NSMutableArray *views;

@property (nonatomic) NSInteger row;
@property (nonatomic) UIInterfaceOrientation orientation;
@end

@implementation NodeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.views = [NSMutableArray new];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.views = [NSMutableArray new];
    }
    
    return self;
}

- (void)dealloc {
    
}

- (void)setData:(NSArray *)data {
    if (_data != data) {
        _data = data;
    }
    if (_data.count == 0) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.tag = 100;
        [btn setTitle:@"还没有收藏节点，点击开始收藏" forState:UIControlStateNormal];
        btn.frame = CGRectMake(0, 0, 320, 50);
        
        [btn addTarget:self action:@selector(showAllNode) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
    }
    else {
        
        [self makeViews];
    }
}

- (void)showAllNode {
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    NodesViewController *vc = (NodesViewController *)[sb instantiateViewControllerWithIdentifier:@"NodesViewController"];
    [self.nav pushViewController:vc animated:YES];
}

- (void)reset {
    [self removeConstraints:self.constraints];
    for (UIView *v in self.views) {
        [v removeFromSuperview];
    }
    [self.views removeAllObjects];
    UIView *v = [self viewWithTag:100];
    [v removeFromSuperview];
    _data = nil;
}

- (void)makeViews {
    for (NSDictionary *dic in _data) {
        id value = [dic allValues][0];
        NSString *title = nil;
        BOOL isTab = NO;
        if ([value isKindOfClass:[NSString class]]) {
            title = value;
        }
        else if ([value isKindOfClass:[NSArray class]]) {
            title = [dic allKeys][0];
            isTab = YES;
        }
        NodeButton *btn = [NodeButton buttonWithType:UIButtonTypeRoundedRect];
        btn.title = title;
        btn.isTab = isTab;
        btn.dic = dic;
        [btn addTarget:self action:@selector(tapBtn:) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitle:title forState:UIControlStateNormal];
        [btn setTitle:title forState:UIControlStateHighlighted];
        [btn.titleLabel setTextColor:[UIColor blackColor]];
        [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        btn.layer.masksToBounds = YES;
        btn.layer.cornerRadius = 3;
        [self.views addObject:btn];
        [self addSubview:btn];
    }
    
    [self layoutIfNeeded];
}

- (void)tapBtn:(id)sender {
    NodeButton *btn = (NodeButton *)sender;
    id value = [btn.dic allValues][0];
    if (btn.isTab) {
        if ([btn.title isEqualToString:@"全部"]) {
            [self showAllNode];
        }
        else if ([btn.title isEqualToString:@"最新"]) {
            TopicsViewController *vc = [TopicsViewController new];
            vc.viewModel.nodeTitle = btn.title;
            vc.viewModel.apiLoading = YES;
            [self.nav pushViewController:vc animated:YES];
            [vc showOrHideAds];
            
        }
        else if ([btn.title isEqualToString:@"问与答"]) {
            
            TopicsViewController *vc = [[TopicsViewController alloc] init];
            vc.viewModel.apiLoading = NO;
            vc.viewModel.nodeTitle = btn.title;
            MemNode *node = [DBUtil nodeByName:@"qna"];
            vc.viewModel.node = node;
            [self.nav pushViewController:vc animated:YES];
        }
        else {
            NSMutableDictionary *segs = [NSMutableDictionary new];
            for (NSDictionary *dic in value) {
                NSString *obj = [dic allKeys][0];
                NSString *key = [dic allValues][0];
                [segs setObject:obj forKey:key];
            }
            TabViewController *vc = [TabViewController new];
            vc.title = btn.title;
            vc.segs = segs;
            [self.nav pushViewController:vc animated:YES];
        }
    }
    else {
        NSString *key = [btn.dic allKeys][0];
        TopicsViewController *vc = [[TopicsViewController alloc] init];
        vc.viewModel.apiLoading = NO;
        vc.viewModel.nodeTitle = btn.title;
        MemNode *node = [DBUtil nodeByName:key];
        vc.viewModel.node = node;
        [self.nav pushViewController:vc animated:YES];
    }
}

- (CGFloat)calculateHeight {
    CGFloat x = 20;
    CGFloat y = 20;
    for (UIView *v in _views) {
        CGSize s = [v intrinsicContentSize];
        if (x + s.width > 300) {
            x = 20;
            y += s.height + 10;  //字高度是21, item padding 是10
        }
        x += s.width + 10;
    }
    
    y += 21;
    
    return y + 20;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat x = 20;
    CGFloat y = 20;
    for (UIView *l in _views) {
        CGSize s = [l intrinsicContentSize];
        if (x + s.width > 300) {
            x = 20;
            y += s.height + 10;
        }
        
        l.frame = CGRectMake(x, y, s.width, s.height);
        
        x += s.width + 10;
    }
}

@end
