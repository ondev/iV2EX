//
//  NodeButton.h
//  v2ex
//
//  Created by Haven on 8/28/14.
//  Copyright (c) 2014 LF. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NodeButton : UIButton
@property (nonatomic) BOOL isTab;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSDictionary *dic;

@end
