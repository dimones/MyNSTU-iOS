//
//  MNBannerScrollView.h
//  MyNSTU
//
//  Created by Дмитрий Богомолов on 25.08.15.
//  Copyright (c) 2015 Дмитрий Богомолов. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MNNewsListController.h"
@interface MNBannerScrollView : UIView<UIScrollViewDelegate>
{
    id needData;
    NSMutableArray *banners;
    NSInteger currentBanner;
    UIScrollView *bannerScroll;
    NSTimer *timer;
}

- (void) setBannerData: (id) data;

@property (nonatomic,strong) MNNewsListController *newsContr;
@end
