//
//  MNNewsTextCell.m
//  MyNSTU
//
//  Created by Дмитрий Богомолов on 22.08.15.
//  Copyright (c) 2015 Дмитрий Богомолов. All rights reserved.
//

#import "MNNewsTextCell.h"
#import "MNAPI+Addition.h"
@implementation MNNewsTextCell
@synthesize newsPubdate,newsTitle;
- (void)awakeFromNib {
    
}
- (IBAction)favourNews:(id)sender {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *favouritesPath = [[UIApplication applicationDocumentDirectory] stringByAppendingPathComponent:@"/news_favourite.plist"];
        if ([fileManager fileExistsAtPath:favouritesPath isDirectory:(BOOL*)NO]) {
            NSMutableArray *favoutiteList = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSData alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/news_favourite.plist", [UIApplication applicationDocumentDirectory]]]];
            __block BOOL deleted = NO;
            [favoutiteList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([obj[@"id"] isEqual:self.newsDict[@"id"]]) {
                    [favoutiteList removeObject:obj];
                    deleted = YES;
                    *stop = YES;
                }
            }];
            if (!deleted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.favouriteButton setImage:[UIImage imageNamed:@"star_filled.png"] forState:UIControlStateNormal];
                });
                [favoutiteList addObject:self.newsDict];
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.favouriteButton setImage:[UIImage imageNamed:@"star.png"] forState:UIControlStateNormal];
                });
            }
            [[NSKeyedArchiver archivedDataWithRootObject:favoutiteList] writeToFile:[NSString stringWithFormat:@"%@/news_favourite.plist", [UIApplication applicationDocumentDirectory]] atomically:YES];
        }
        else{
            NSMutableArray *favouriteList = [NSMutableArray new];
            [favouriteList addObject:self.newsDict];
            [[NSKeyedArchiver archivedDataWithRootObject:favouriteList] writeToFile:[NSString stringWithFormat:@"%@/news_favourite.plist", [UIApplication applicationDocumentDirectory]] atomically:YES];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.favouriteButton setImage:[UIImage imageNamed:@"star_filled.png"] forState:UIControlStateNormal];
            });
        }
    });
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
