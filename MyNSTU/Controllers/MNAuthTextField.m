//
//  MNAuthTextField.m
//  MyNSTU
//
//  Created by Дмитрий Богомолов on 20.08.15.
//  Copyright (c) 2015 Дмитрий Богомолов. All rights reserved.
//

#import "MNAuthTextField.h"

@implementation MNAuthTextField


- (void)drawRect:(CGRect)rect {
    //// Color Declarations
    UIColor* color = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    //// Rectangle Drawing
    if (_needCorner) {
        self.cornerRadius = 0;
    }
    if(self.isUpper)
    {
        UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(0, 0, rect.size.width, rect.size.height) byRoundingCorners: UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii: CGSizeMake(self.cornerRadius, self.cornerRadius)];
        
        [rectanglePath closePath];
        [color setFill];
        [rectanglePath fill];
   
    }
    else
    {
        UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(0, 0, rect.size.width, rect.size.height) byRoundingCorners: UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii: CGSizeMake(self.cornerRadius, self.cornerRadius)];
        [rectanglePath closePath];
        [color setFill];
        [rectanglePath fill];

    }
}
// placeholder position
- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset( bounds , 20 , 0 );
}

// text position
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset( bounds , 20 , 0 );
}
@end
