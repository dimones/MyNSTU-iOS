//
//  MNSessCell.m
//  MyNSTU
//
//  Created by Дмитрий Богомолов on 04.09.15.
//  Copyright (c) 2015 Дмитрий Богомолов. All rights reserved.
//

#import "MNSessCell.h"

@implementation MNSessCell

@synthesize timeLabel,audienceLabel,nameLabel,groupsLabel;
- (void)awakeFromNib {
    
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
