//
//  MNPairCell.h
//  MyNSTU
//
//  Created by Дмитрий Богомолов on 18.09.16.
//  Copyright © 2016 Дмитрий Богомолов. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MNPairCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *pairLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *roomLabel;
@property (weak, nonatomic) IBOutlet UILabel *discLabel;
@property (weak, nonatomic) IBOutlet UILabel *personLabel;
@end
