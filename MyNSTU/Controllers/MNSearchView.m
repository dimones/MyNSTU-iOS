//
//  MNSearchView.m
//  MyNSTU
//
//  Created by Дмитрий Богомолов on 30.08.15.
//  Copyright (c) 2015 Дмитрий Богомолов. All rights reserved.
//

#import "MNSearchView.h"
#import "MNAPI+Addition.h"
#define log_btn_size 28.f
@implementation MNSearchView
@synthesize searchBar,nameLabel,delegate,logButton,profileIcon,cancelButton;

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    //Search bar draw
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 22, rect.size.width, 44)];
    searchBar.tintColor = [UIColor colorFromHexString:@"#353535"];
    searchBar.searchBarStyle = UISearchBarStyleDefault;
    searchBar.barTintColor = [UIColor colorFromHexString:@"#353535"];
    searchBar.placeholder = @"Поиск";
    [self addSubview:searchBar];
    //Profile icon draw
    profileIcon = [[UIImageView alloc] initWithFrame:CGRectMake(14, searchBar.frame.origin.y + searchBar.frame.size.height + 5, 37, 37)];
    [profileIcon setImage:[UIImage imageNamed:@"profile.png"]];
    [self addSubview:profileIcon];
    //nameLabel draw
    nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(63, profileIcon.frame.origin.y + profileIcon.frame.size.height/2 - 30/2,
                                                          rect.size.width - 80, 30)];
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.text = @"Гость";
    [self addSubview:nameLabel];
    // log button
    logButton = [[UIButton alloc] initWithFrame:CGRectMake(rect.size.width - 10 - log_btn_size,
                                                           profileIcon.frame.origin.y + 2, log_btn_size, log_btn_size)];
    [logButton setImage:[UIImage imageNamed:@"login.png"] forState:UIControlStateNormal];
    [self addSubview:logButton];
}


@end
