//
//  MNScheduleDayController.h
//  MyNSTU
//
//  Created by Дмитрий Богомолов on 17.02.16.
//  Copyright © 2016 Дмитрий Богомолов. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MNScheduleCell.h"
@interface MNScheduleDayController : UITableViewController
@property (strong, nonatomic) IBOutlet UITableView *scheduleTable;
@property NSInteger dayNumber;
@property NSInteger weekNumber;
@property (strong, nonatomic) NSArray *dayArray;
@property (strong, nonatomic) NSArray *validDiscs;
@property (strong, nonatomic) NSArray *pairArray;
- (void) setDayDate:(NSArray*)dayArray andWeekNumber:(NSInteger)weekNumber andValidDisks:(NSArray*)ValidDiscs;

@end