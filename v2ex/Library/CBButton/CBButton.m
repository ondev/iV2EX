//
//  CButton.m
//  CheckboxButton
//
//  Created by Haven on 4/2/14.
//  Copyright (c) 2014 LF. All rights reserved.
//

#import "CBButton.h"

#define KCheckBoxLabelTag  100

@implementation CBButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [self setCheckBoxImages];
    return self;
}

-(id)initCheckboxAtPoint:(CGPoint)_point{
    self = [self initWithFrame:CGRectMake(_point.x, _point.y, 20, 20)];
    [self setCheckBoxImages];
    return self;
}

-(id)initCheckboxAtPoint:(CGPoint)_point withSideLabel:(NSString *)_sideLabel{
    self = [self initCheckboxAtPoint:_point];
    self.sideString = _sideString;
    return self;
}

- (void)setSideString:(NSString *)sideString {
    _sideString = sideString;
    
    UILabel *sideLabel = [[UILabel alloc]initWithFrame: CGRectMake(25, 0, 260, 20)];
    sideLabel.backgroundColor = [UIColor clearColor];
    sideLabel.text = sideString;
    sideLabel.tag = KCheckBoxLabelTag;
    sideLabel.userInteractionEnabled = YES;
    sideLabel.exclusiveTouch = YES;
    self.exclusiveTouch = YES;
    self.shouldHitTest = YES;
    
    [self addSubview:sideLabel];
    [self resetHitTestRect];
}

- (void)setCheckBoxImages {
    [self setBackgroundImage:[UIImage imageNamed:@"checkmark"] forState:UIControlStateNormal];
    [self setBackgroundImage:[UIImage imageNamed:@"checkmark_onclick.png"] forState:UIControlStateSelected];
    
    self.adjustsImageWhenHighlighted = NO;
}

- (void)resetHitTestRect {
    UILabel *sideLabel = (UILabel *)[self viewWithTag:KCheckBoxLabelTag];
    CGSize expectedLabelSize = CGSizeZero;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary *attributes = @{NSFontAttributeName:sideLabel.font, NSParagraphStyleAttributeName:paragraphStyle.copy};
        
        expectedLabelSize = [sideLabel.text boundingRectWithSize:CGSizeMake(207, 999) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    }
    else {
        expectedLabelSize = [sideLabel.text sizeWithFont:sideLabel.font
                                       constrainedToSize:CGSizeMake(260, 20)
                                           lineBreakMode:sideLabel.lineBreakMode];
    }
    
    CGRect rect = CGRectMake(25, 0, expectedLabelSize.width, expectedLabelSize.height);
    sideLabel.frame = rect;
    CGRect hitRect = CGRectMake(sideLabel.frame.origin.x-25,
                                sideLabel.frame.origin.y,
                                expectedLabelSize.width+sideLabel.frame.origin.x,
                                MAX(self.frame.size.height, sideLabel.frame.size.height));
    self.hitTestRect = hitRect;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    if(CGRectContainsPoint(self.hitTestRect, point)){
        
        return self;
    }
    
    return [super hitTest:point withEvent:event];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
