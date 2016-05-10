//
//  MNRegController.h
//  MyNSTU
//
//  Created by Дмитрий Богомолов on 09.05.16.
//  Copyright © 2016 Дмитрий Богомолов. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MNRegController : UIViewController
@property (strong, nonatomic) NSString* username;
@property (strong, nonatomic) NSString* password;

@property (nonatomic, copy) void (^didDismiss)();
@end
