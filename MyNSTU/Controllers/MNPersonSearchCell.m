//
//  MNPersonSearchCell.m
//  MyNSTU
//
//  Created by Дмитрий Богомолов on 05.09.15.
//  Copyright (c) 2015 Дмитрий Богомолов. All rights reserved.
//

#import "MNPersonSearchCell.h"

@implementation MNPersonSearchCell

@synthesize personFirstName,personImage,personSecondName;
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
