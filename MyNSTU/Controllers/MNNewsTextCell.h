//
//  MNNewsTextCell.h
//  MyNSTU
//
//  Created by Дмитрий Богомолов on 22.08.15.
//  Copyright (c) 2015 Дмитрий Богомолов. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MNNewsTextCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *newsTitle;
@property (weak, nonatomic) IBOutlet UILabel *newsPubdate;
@property (weak, nonatomic) IBOutlet UIButton *favouriteButton;
@property (strong, nonatomic) id newsDict;
@end
