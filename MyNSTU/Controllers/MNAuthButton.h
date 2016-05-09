//
//  MNAuthButton.h
//  MyNSTU
//
//  Created by Дмитрий Богомолов on 20.08.15.
//  Copyright (c) 2015 Дмитрий Богомолов. All rights reserved.
//

#import <UIKit/UIKit.h>
IB_DESIGNABLE
@interface MNAuthButton : UIButton
@property (nonatomic) IBInspectable NSUInteger cornerRadius;

@property (nonatomic, copy) IBInspectable UIColor *textColor;
@end
