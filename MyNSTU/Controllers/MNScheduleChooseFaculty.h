//
//  MNScheduleChooseFaculty.h
//  MyNSTU
//
//  Created by Дмитрий Богомолов on 14.02.16.
//  Copyright © 2016 Дмитрий Богомолов. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MNHTTPAPI.h"
@interface MNScheduleChooseFaculty : UITableViewController <MNAPIHTTPDelegate>
@property (strong, nonatomic) IBOutlet UITableView *facultiesTable;
@property (nonatomic, copy) void (^didDismiss)(NSString *data);
@end
