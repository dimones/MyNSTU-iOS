//
//  MNAuthViewController.h
//  MyNSTU
//
//  Created by Дмитрий Богомолов on 20.08.15.
//  Copyright (c) 2015 Дмитрий Богомолов. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MNAuthTextField.h"
@protocol MNAuthDelegate <NSObject>
@required
- (void) MNAuthCompleted:(id) infoDict;
@end
@interface MNAuthViewController : UIViewController
{
    __weak id <MNAuthDelegate> delegate;
}
@property (nonatomic, weak) id <MNAuthDelegate> delegate;
@property (weak, nonatomic) IBOutlet MNAuthTextField *loginField;
@property (weak, nonatomic) IBOutlet MNAuthTextField *passField;
@property (strong,nonatomic) UIWindow* _wind;
@end
