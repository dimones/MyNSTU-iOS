//
//  MNBannerView.h
//  MyNSTU
//
//  Created by Дмитрий Богомолов on 23.08.15.
//  Copyright (c) 2015 Дмитрий Богомолов. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MNNewsListController.h"
@interface MNBannerView : UIView
{
    NSString *imgLink;
    UIImageView *imgView;
    UIActivityIndicatorView *loadingIndicator;
    CGRect myRect;

}
@property NSInteger newsId;
@property (nonatomic,strong) MNNewsListController *newsContr;
- (void) setImageLink: (NSString*)imageLink;
@end
