//
//  MNPairCell.m
//  MyNSTU
//
//  Created by Дмитрий Богомолов on 18.09.16.
//  Copyright © 2016 Дмитрий Богомолов. All rights reserved.
//

#import "MNPairCell.h"

@implementation MNPairCell
@synthesize timeLabel,roomLabel,discLabel,personLabel,pairLabel;
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
