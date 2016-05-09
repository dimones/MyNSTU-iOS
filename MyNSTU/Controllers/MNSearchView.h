//
//  MNSearchView.h
//  MyNSTU
//
//  Created by Дмитрий Богомолов on 30.08.15.
//  Copyright (c) 2015 Дмитрий Богомолов. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol MNSearchDelegate <NSObject>
@required
- (void) MNSearchBegin;
- (void) MNSearchEnd;
@end
@interface MNSearchView : UIView
{
    __weak id <MNSearchDelegate> apiDelegate;
}
@property (nonatomic, weak) id <MNSearchDelegate> delegate;

@property (strong, nonatomic) UIImageView *profileIcon;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UIButton *logButton;
@property (strong, nonatomic) UIButton *cancelButton;
@property (strong, nonatomic) UILabel *nameLabel;
@end
