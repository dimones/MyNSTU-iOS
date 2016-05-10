//
//  MNSideTopCell.h
//  MyNSTU
//
//  Created by Дмитрий Богомолов on 10.05.16.
//  Copyright © 2016 Дмитрий Богомолов. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MNSideTopCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *authButton;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end
