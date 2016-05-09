//
//  MNPersonSessionController.h
//  MyNSTU
//
//  Created by Дмитрий Богомолов on 04.09.15.
//  Copyright (c) 2015 Дмитрий Богомолов. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MNPersonSessionController : UIViewController
@property (weak, nonatomic) IBOutlet UISegmentedControl *segControl;
@property (weak, nonatomic) IBOutlet UITableView *sessTable;
@end
