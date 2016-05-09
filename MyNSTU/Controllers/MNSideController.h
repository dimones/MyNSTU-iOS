//
//  MNSideController.h
//  MyNSTU
//
//  Created by Дмитрий Богомолов on 22.08.15.
//  Copyright (c) 2015 Дмитрий Богомолов. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MNSideController : UITableViewController
@property (strong, nonatomic) IBOutlet UITableView *sideTable;
@property (weak, nonatomic) IBOutlet UIButton *authTest;

@end
