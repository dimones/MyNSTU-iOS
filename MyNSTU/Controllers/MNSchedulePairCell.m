//
//  MNSchedulePairCell.m
//  MyNSTU
//
//  Created by Дмитрий Богомолов on 17.02.16.
//  Copyright © 2016 Дмитрий Богомолов. All rights reserved.
//

#import "MNSchedulePairCell.h"

@implementation MNSchedulePairCell
@synthesize labelPersons,labelRoom,labelTime,labelTitle,labelWeeks,roomImage,personImage,weeksImage;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
