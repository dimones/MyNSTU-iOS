//
//  MNPersonSearchCell.h
//  MyNSTU
//
//  Created by Дмитрий Богомолов on 05.09.15.
//  Copyright (c) 2015 Дмитрий Богомолов. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MNPersonSearchCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *personImage;
@property (weak, nonatomic) IBOutlet UILabel *personFirstName;
@property (weak, nonatomic) IBOutlet UILabel *personSecondName;
@end
