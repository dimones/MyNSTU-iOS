//
//  MNScheduleCell.h
//  MyNSTU
//
//  Created by Дмитрий Богомолов on 22.02.16.
//  Copyright © 2016 Дмитрий Богомолов. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MNScheduleCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *pair_number;
@property (weak, nonatomic) IBOutlet UILabel *pair_location;
@property (weak, nonatomic) IBOutlet UILabel *pair_name;
@property (weak, nonatomic) IBOutlet UILabel *pair_person_name;
@property (weak, nonatomic) IBOutlet UILabel *pair_week;

@end
