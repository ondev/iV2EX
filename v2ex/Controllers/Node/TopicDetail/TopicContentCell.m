//
//  TopicContentCell.m
//  v2ex
//
//  Created by Haven on 16/2/14.
//  Copyright (c) 2014 LF. All rights reserved.
//

#import "TopicContentCell.h"
#import "Utils.h"

@implementation TopicContentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (IBAction)favorBtnTrigger:(id)sender {
    if ([_delegate respondsToSelector:@selector(favorBtnTrigger:)]) {
        [_delegate favorBtnTrigger:self];
    }
}

- (IBAction)unLike:(id)sender {
    [Utils unLike];
}

- (IBAction)shareBtnTrigger:(id)sender {
    if ([_delegate respondsToSelector:@selector(shareBtnTrigger:)]) {
        [_delegate shareBtnTrigger:self];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
