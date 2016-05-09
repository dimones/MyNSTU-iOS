//
//  MNRedHeaderTableViewCell.m
//  MyNSTU
//
//  Created by Дмитрий Богомолов on 21.08.15.
//  Copyright (c) 2015 Дмитрий Богомолов. All rights reserved.
//

#import "MNRedHeaderTableViewCell.h"

@implementation MNRedHeaderTableViewCell
@synthesize redLabel;
- (void)awakeFromNib {
    [redLabel setCenter:self.center];
    CGRect t = redLabel.frame;
    t.size.height = self.frame.size.height;
    [redLabel setFrame:t];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
