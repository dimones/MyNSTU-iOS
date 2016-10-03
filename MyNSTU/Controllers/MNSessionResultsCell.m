//
//  MNSessionResultsCell.m
//  MyNSTU
//
//  Created by Дмитрий Богомолов on 17.09.16.
//  Copyright © 2016 Дмитрий Богомолов. All rights reserved.
//

#import "MNSessionResultsCell.h"

@implementation MNSessionResultsCell
@synthesize dateLabel,ectsLabel,markLabel,textLabel,ballsLabel,detailTextLabel;
- (void) setDataDict: (NSDictionary*) dict
{
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
