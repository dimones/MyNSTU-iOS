//
//  MNSideTopCell.m
//  MyNSTU
//
//  Created by Дмитрий Богомолов on 10.05.16.
//  Copyright © 2016 Дмитрий Богомолов. All rights reserved.
//

#import "MNSideTopCell.h"

@implementation MNSideTopCell
@synthesize nameLabel,authButton,searchBar;

- (void) drawRect:(CGRect)rect
{
    [super drawRect:rect];
    [self.authButton addTarget:self action:@selector(authAction:) forControlEvents:UIControlEventTouchUpInside];
}
- (void) authAction:(id) sender{
    NSLog(@"I'm here");
}
- (IBAction)heeeui:(id)sender {
    NSLog(@"да ты заебал ");
}


@end
