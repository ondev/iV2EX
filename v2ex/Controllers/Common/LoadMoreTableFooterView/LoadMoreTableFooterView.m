//
//  LoadMoreTableFooterView.h
//  TableViewPull
//
//  Created by Ye Dingding on 10-12-24.
//  Copyright 2010 Intridea, Inc. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//


#import "LoadMoreTableFooterView.h"


#define TEXT_COLOR	 [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]
#define FLIP_ANIMATION_DURATION 0.18f
#define TRIGGER_LOADING_HEIGHT     60


@interface LoadMoreTableFooterView () {
	LoadMoreState _state;
	
	UILabel *_statusLabel;
	UIActivityIndicatorView *_activityView;
}
- (void)setState:(LoadMoreState)aState;
@end

@implementation LoadMoreTableFooterView


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
		
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 20.0f, self.frame.size.width, 20.0f)];
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label.font = [UIFont boldSystemFontOfSize:15.0f];
		label.textColor = TEXT_COLOR;
		label.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
		label.shadowOffset = CGSizeMake(0.0f, 1.0f);
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = NSTextAlignmentCenter;
		[self addSubview:label];
		_statusLabel=label;
				
		UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		view.frame = CGRectMake(150.0f, 20.0f, 20.0f, 20.0f);
		[self addSubview:view];
		_activityView = view;
		self.hidden = YES;
		
		[self setState:LoadMoreNormal];
    }
	
    return self;	
}


#pragma mark -
#pragma mark Setters

- (void)setState:(LoadMoreState)aState{	
	switch (aState) {
		case LoadMorePulling:
			_statusLabel.text = NSLocalizedString(@"Release to load more...", @"Release to load more");
			break;
		case LoadMoreNormal:
			_statusLabel.text = NSLocalizedString(@"Load More...", @"Load More");
			_statusLabel.hidden = NO;
			[_activityView stopAnimating];
			break;
		case LoadMoreLoading:
			_statusLabel.hidden = YES;
			[_activityView startAnimating];
			break;
        case LoadMoreDisable:
            _statusLabel.hidden = NO;
			_statusLabel.text = NSLocalizedString(@"No More", @"No More");
			[_activityView stopAnimating];
            break;
		default:
			break;
	}
    
	_state = aState;
}


#pragma mark -
#pragma mark ScrollView Methods

- (void)loadMoreScrollViewDidScroll:(UIScrollView *)scrollView {
	if (_state == LoadMoreLoading) {
		scrollView.contentInset = UIEdgeInsetsMake(scrollView.contentInset.top, 0.0f, 60.0f, 0.0f);
	} else if (scrollView.isDragging) {
		
        BOOL _loading = NO;
        if ([_delegate respondsToSelector:@selector(loadMoreTableFooterDataSourceIsLoading:)]) {
            _loading = [_delegate loadMoreTableFooterDataSourceIsLoading:self];
        }
        
        if ([_delegate respondsToSelector:@selector(loadMoreTableFooterCanTrigger:)]) {
            if (![_delegate loadMoreTableFooterCanTrigger:self]) {
                [self setState:LoadMoreDisable];
            }
        }
        
        if (_state == LoadMoreNormal && scrollView.contentOffset.y > (TRIGGER_LOADING_HEIGHT + scrollView.contentSize.height - scrollView.frame.size.height) && !_loading) {
            [self setState:LoadMorePulling];
        } else if ((_state == LoadMoreNormal || _state == LoadMoreDisable) && scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height) && !_loading) {
            self.frame = CGRectMake(0, scrollView.contentSize.height, self.frame.size.width, self.frame.size.height);
            self.hidden = NO;
        }  else if (_state == LoadMorePulling && scrollView.contentOffset.y < (TRIGGER_LOADING_HEIGHT + scrollView.contentSize.height - scrollView.frame.size.height) && !_loading) {
            [self setState:LoadMoreNormal];
        }
        
        if (scrollView.contentInset.bottom != 0) {
            scrollView.contentInset = UIEdgeInsetsMake(scrollView.contentInset.top, 0.0f, 0.0f, 0.0f);
        }
        
	}
}

- (void)loadMoreScrollViewDidEndDragging:(UIScrollView *)scrollView {
	
	BOOL _loading = NO;
	if ([_delegate respondsToSelector:@selector(loadMoreTableFooterDataSourceIsLoading:)]) {
		_loading = [_delegate loadMoreTableFooterDataSourceIsLoading:self];
	}
	
	if (_state != LoadMoreDisable && scrollView.contentOffset.y > (TRIGGER_LOADING_HEIGHT + scrollView.contentSize.height - scrollView.frame.size.height) && (scrollView.contentSize.height > scrollView.frame.size.height)&& !_loading) {
        [self sendActionsForControlEvents:UIControlEventValueChanged];
        
		if ([_delegate respondsToSelector:@selector(loadMoreTableFooterDidTriggerRefresh:)]) {
			[_delegate loadMoreTableFooterDidTriggerRefresh:self];
		}
		
		[self setState:LoadMoreLoading];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
		scrollView.contentInset = UIEdgeInsetsMake(scrollView.contentInset.top, 0.0f, 60.0f, 0.0f);
		[UIView commitAnimations];
	}
}

- (void)loadMoreScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView {
	[self setState:LoadMoreNormal];
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
	[scrollView setContentInset:UIEdgeInsetsMake(scrollView.contentInset.top, 0.0f, 0.0f, 0.0f)];
	[UIView commitAnimations];
    self.hidden = YES;
}


#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
	_activityView = nil;
	_statusLabel = nil;
}


@end