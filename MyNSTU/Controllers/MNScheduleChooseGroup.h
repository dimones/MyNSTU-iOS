//
//  MNScheduleChooseGroup.h
//  MyNSTU
//
//  Created by Дмитрий Богомолов on 14.02.16.
//  Copyright © 2016 Дмитрий Богомолов. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MNScheduleChooseGroup : UITableViewController
@property (strong, nonatomic) IBOutlet UITableView *groupTable;
@property (strong, nonatomic) NSString* groupString;
@property (strong, nonatomic) id groupsArray;
@end
