//
//  MNAuthButton.m
//  MyNSTU
//
//  Created by Дмитрий Богомолов on 20.08.15.
//  Copyright (c) 2015 Дмитрий Богомолов. All rights reserved.
//

#import "MNAuthButton.h"

@implementation MNAuthButton


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    //// Color Declarations
    
    UIColor* color = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    [self customDraw:rect withColor:color];

}
- (void) customDraw:(CGRect) rect withColor:(UIColor*) color
{
    
    //// Rectangle Drawing
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(0, 0, rect.size.width, rect.size.height) cornerRadius: self.cornerRadius];
    [color setFill];
    [rectanglePath fill];
    [self setTitleColor:self.textColor forState:UIControlStateNormal];
}
- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    [self customDraw:self.frame withColor:[UIColor colorWithRed:0.953f green:0.922f blue:0.914f alpha:1.00f]];
    
}

@end
