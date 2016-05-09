//
//  MNScheduleDiscChooser.h
//  MyNSTU
//
//  Created by Дмитрий Богомолов on 14.02.16.
//  Copyright © 2016 Дмитрий Богомолов. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MNScheduleDiscChooser : UIViewController
@property (strong, nonatomic) IBOutlet UITableView *discTable;
@property (nonatomic, strong) NSString *semester_begin;
@property (nonatomic, strong) NSMutableArray *data_array;
@property (nonatomic, strong) NSString *group_name;
@property (nonatomic, strong) NSArray *days;
@end
