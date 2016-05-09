//
//  MNBannerScrollView.m
//  MyNSTU
//
//  Created by Дмитрий Богомолов on 25.08.15.
//  Copyright (c) 2015 Дмитрий Богомолов. All rights reserved.
//

#import "MNBannerScrollView.h"
#import "MNBannerView.h"
#define timer_interval 5.f
@implementation MNBannerScrollView

- (void) changeBanner{
    if(currentBanner == 5)
        currentBanner = 0;
    else ++currentBanner;
    [UIView animateWithDuration:0.7f animations:^{
        [bannerScroll scrollRectToVisible:CGRectMake(currentBanner*self.frame.size.width, 0, self.frame.size.width, self.frame.size.height) animated:YES];
    }];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:timer_interval target:self selector:@selector(changeBanner) userInfo:nil repeats:NO];
}
- (void) drawRect:(CGRect)rect
{
    self.backgroundColor = [UIColor whiteColor];
}
- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    int page = scrollView.contentOffset.x / scrollView.frame.size.width;
    currentBanner = page;
    [timer invalidate];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:timer_interval target:self selector:@selector(changeBanner) userInfo:nil repeats:NO];
    
}
- (void) setBannerData: (id) data{
    self.backgroundColor = [UIColor whiteColor];
    if(bannerScroll == nil)
    {
        bannerScroll = [[UIScrollView alloc] initWithFrame:self.frame];
        [self addSubview:bannerScroll];
        [bannerScroll setContentSize:CGSizeMake(self.frame.size.width*6, self.frame.size.height)];
        bannerScroll.backgroundColor = [UIColor whiteColor];
    }
    needData = [data copy];
    currentBanner = 0;
    banners = [NSMutableArray new];
    bannerScroll.delegate = self;
    bannerScroll.pagingEnabled = YES;
    for(NSInteger i = 0; i < 6; i++)
    {
        NSDictionary *dict = needData[i];
        MNBannerView *tempView = [[MNBannerView alloc] initWithFrame:CGRectMake(i*self.frame.size.width, 0, self.frame.size.width, self.frame.size.height)];
        tempView.newsContr = self.newsContr;
        tempView.backgroundColor = [UIColor whiteColor];
        [tempView setImageLink:dict[@"image_link"]];
        tempView.newsId = ((NSNumber*)dict[@"news_id"]).integerValue;
        [bannerScroll addSubview:tempView];
        [banners addObject:tempView];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSTimer scheduledTimerWithTimeInterval:timer_interval target:self selector:@selector(changeBanner) userInfo:nil repeats:NO];
    });
}

@end
