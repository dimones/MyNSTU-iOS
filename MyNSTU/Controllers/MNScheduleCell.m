//
//  MNScheduleCell.m
//  MyNSTU
//
//  Created by Дмитрий Богомолов on 22.02.16.
//  Copyright © 2016 Дмитрий Богомолов. All rights reserved.
//

#import "MNScheduleCell.h"

@implementation MNScheduleCell
@synthesize pair_name,pair_week,pair_number,pair_location,pair_person_name;
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
