//
//  MNSessCell.h
//  MyNSTU
//
//  Created by Дмитрий Богомолов on 04.09.15.
//  Copyright (c) 2015 Дмитрий Богомолов. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MNSessCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *audienceLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *groupsLabel;
@end
