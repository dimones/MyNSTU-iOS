//
//  MNSchedulePairCell.h
//  MyNSTU
//
//  Created by Дмитрий Богомолов on 17.02.16.
//  Copyright © 2016 Дмитрий Богомолов. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MNSchedulePairCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *labelTime;
@property (weak, nonatomic) IBOutlet UILabel *labelRoom;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelPersons;
@property (weak, nonatomic) IBOutlet UILabel *labelWeeks;
@property (weak, nonatomic) IBOutlet UIImageView *roomImage;
@property (weak, nonatomic) IBOutlet UIImageView *personImage;
@property (weak, nonatomic) IBOutlet UIImageView *weeksImage;
@end
