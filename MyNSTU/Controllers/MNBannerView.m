//
//  MNBannerView.m
//  MyNSTU
//
//  Created by Дмитрий Богомолов on 23.08.15.
//  Copyright (c) 2015 Дмитрий Богомолов. All rights reserved.
//

#import "MNBannerView.h"
#import "MNAPI+Addition.h"
#define act_size 50.f
@implementation MNBannerView

- (void) setImageLink: (NSString*)imageLink{
    imgLink = [imageLink copy];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    self.backgroundColor = [UIColor whiteColor];
    myRect = rect;
    imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
    imgView.backgroundColor = [UIColor whiteColor];
    imgView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:imgView];
    loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    loadingIndicator.color = [UIColor grayColor];
    [loadingIndicator setFrame:CGRectMake(rect.size.width/2-act_size/2, rect.size.height/2-act_size/2, act_size, act_size)];
    [imgView addSubview:loadingIndicator];
    loadingIndicator.hidden = YES;
    [self loadImage];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnImage)];
    singleTap.numberOfTapsRequired = 1;
    [imgView setUserInteractionEnabled:YES];
    [imgView addGestureRecognizer:singleTap];
    // Drawing code
}
- (void) tapOnImage{
    [self.newsContr goToNews:self.newsId];
}
- (void) loadImage{
    loadingIndicator.hidden = NO;
    [loadingIndicator startAnimating];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *pngName = [[imgLink componentsSeparatedByString:@"/"] lastObject];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:[NSString stringWithFormat:@"@%/%@",[UIApplication applicationDocumentDirectory],pngName] isDirectory:NO]) {
            NSData *pngData = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"@%/%@",[UIApplication applicationDocumentDirectory],pngName]];
            dispatch_async(dispatch_get_main_queue(),^{
                UIImage *img = [UIImage imageWithData:pngData];
                UIGraphicsBeginImageContextWithOptions(img.size, NO, img.scale);
                
                [img drawAtPoint:CGPointZero];
                
                img = UIGraphicsGetImageFromCurrentImageContext();
                
                UIGraphicsEndImageContext();
                CGImageRef imageRef = CGImageCreateWithImageInRect([img CGImage], CGRectMake(0, 0, myRect.size.width, myRect.size.height));
                // or use the UIImage wherever you like
                [imgView setImage:[UIImage imageWithCGImage:imageRef]];
                CGImageRelease(imageRef);
                [loadingIndicator stopAnimating];
                loadingIndicator.hidden = YES;
                [imgView setFrame:myRect];
            });
        }
        else{
            NSURL  *url = [NSURL URLWithString:imgLink];
            NSData *urlData = [NSData dataWithContentsOfURL:url];
            if ( urlData )
            {
                [urlData writeToFile:[NSString stringWithFormat:@"@%/%@",[UIApplication applicationDocumentDirectory],pngName] atomically:YES];
                dispatch_async(dispatch_get_main_queue(),^{
                    UIImage *img = [UIImage imageWithData:urlData];
                    UIGraphicsBeginImageContextWithOptions(img.size, NO, img.scale);
                    
                    [img drawAtPoint:CGPointZero];
                    
                    img = UIGraphicsGetImageFromCurrentImageContext();
                    
                    UIGraphicsEndImageContext();
                    CGImageRef imageRef = CGImageCreateWithImageInRect([img CGImage], CGRectMake(0, 0, myRect.size.width, myRect.size.height));
                    // or use the UIImage wherever you like
                    [imgView setImage:[UIImage imageWithCGImage:imageRef]];
                    CGImageRelease(imageRef);
                    [loadingIndicator stopAnimating];
                    loadingIndicator.hidden = YES;
                    [imgView setFrame:myRect];
                });
            }
        }
    });
}

@end
