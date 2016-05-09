//
//  MNPrepareScheduleTableViewController.h
//  MyNSTU
//
//  Created by Дмитрий Богомолов on 21.08.15.
//  Copyright (c) 2015 Дмитрий Богомолов. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum : NSUInteger {
    MNGetFaculty = 0,
    MNGetGroup,
    MNGetSchedule
} MNPrepareStage;
@protocol MNSchedulePreparingDelegate <NSObject>
@required
- (void) MNSchedulePreparingFinishing:(BOOL)finished;
@end
@interface MNPrepareScheduleTableViewController : UITableViewController
{
    __weak id <MNSchedulePreparingDelegate> delegate;
}
@property (nonatomic, weak) id <MNSchedulePreparingDelegate> delegate;
@property (nonatomic) MNPrepareStage prepareStage;
@property (nonatomic,strong) NSString *groupName;

@property (strong,nonatomic) UIWindow* _wind;
- (void) setNeedData:(id)data;

@end
