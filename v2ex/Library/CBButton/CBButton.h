//
//  CBButton.h
//  CheckboxButton
//
//  Created by Haven on 4/2/14.
//  Copyright (c) 2014 LF. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CBButton : UIButton
-(id)initCheckboxAtPoint:(CGPoint)_point withSideLabel:(NSString *)_sideLabel;
@property (nonatomic, strong) NSString *sideString;
@property (nonatomic) BOOL shouldHitTest;
@property (nonatomic) CGRect hitTestRect;
@end
