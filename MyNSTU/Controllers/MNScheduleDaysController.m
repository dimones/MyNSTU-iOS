//
//  MNScheduleDaysController.m
//  MyNSTU
//
//  Created by Дмитрий Богомолов on 17.02.16.
//  Copyright © 2016 Дмитрий Богомолов. All rights reserved.
//

#import "MNScheduleDaysController.h"
#import "MNAPI+Addition.h"
#include "MNScheduleLeftCapController.h"
#include "MNScheduleRightCapController.h"
#include "MNScheduleDayController.h"
@interface MNScheduleDaysController()<UIScrollViewDelegate,UIGestureRecognizerDelegate>
{
    NSInteger currentWeek;
    NSInteger displayWeek;
    NSMutableArray *dayControllers;
    NSDictionary *dayDisc;
    NSInteger pageNumber;
}

@end
@implementation MNScheduleDaysController
@synthesize daysScroll,pageControl;


- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithImage:[MNAPI_Addition imageWithIcon:icon_navicon size:30.0f color:[UIColor whiteColor]] style:UIBarButtonItemStylePlain target:self action:@selector(leftButton)];
    [leftBarButton setBackButtonBackgroundVerticalPositionAdjustment:-10 forBarMetrics:UIBarMetricsDefault];
    self.navigationItem.leftBarButtonItem = leftBarButton;
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    
    
    
    dayDisc = @{ @"1": @"Понедельник", @"2":@"Вторник",@"3":@"Среда",
                 @"4": @"Четверг", @"5":@"Пятница", @"6":@"Суббота"};
    dayControllers = [NSMutableArray new];
    daysScroll.delegate = self;
    daysScroll.pagingEnabled = YES;
    NSString *plistPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"schedules.plist"];
    
    NSData *data = [NSData dataWithContentsOfFile:plistPath];
    if (data == nil) {
        [MNAPI_Addition setObjectTONSUD:@"move" withKey:@"sch"];
        [MNAPI_Addition changeContentViewControllerWithName:@"SchedulePrep"];
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        NSMutableDictionary *t = [[NSMutableDictionary alloc] initWithDictionary:[NSKeyedUnarchiver unarchiveObjectWithData:data]];
        NSString *currentGroup = t[@"current"];
        [t[@"data"] enumerateObjectsUsingBlock:^(id groups, NSUInteger idx, BOOL *stop){
            NSString *dateString = groups[@"semester_begin"];
            NSArray *validDiscs = groups[@"valid_discs"];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"dd.MM.yyyy"];
            NSDate *dateFromString = [[NSDate alloc] init];
            dateFromString = [dateFormatter dateFromString:dateString];
            NSTimeInterval diff = [dateFromString timeIntervalSinceDate:[NSDate date]];
            currentWeek = (int)(-1*diff/60/60/24/7)+1;
            displayWeek = currentWeek;
            MNScheduleLeftCapController *left = [MNAPI_Addition getViewControllerWithIdentifier:@"ScheduleCapLeft"];
            [left.weekLabel setText:[NSString stringWithFormat:@"%ld неделя",(long)displayWeek - 1]];
            [dayControllers addObject:left];
            __block NSInteger i = 0;
            if ([groups[@"name"] isEqualToString:currentGroup]) {
                [groups[@"days"] enumerateObjectsUsingBlock:^(id day, NSUInteger idx, BOOL *stopp) {
                    MNScheduleDayController *dayController = [MNAPI_Addition getViewControllerWithIdentifier:@"ScheduleDay"];
                    dayController.dayNumber = idx;
                    [dayController setDayDate:day andWeekNumber:displayWeek andValidDisks:validDiscs];
                    [dayControllers addObject:dayController];
                    i++;
                }];
            }
            MNScheduleRightCapController *right = [MNAPI_Addition getViewControllerWithIdentifier:@"ScheduleCapRight"];
            [right.weekLabel setText:[NSString stringWithFormat:@"%ld неделя",(long)displayWeek + 1]];
            [dayControllers addObject:right];
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            CGRect scrollFrame = self.daysScroll.frame;
            MNScheduleLeftCapController *leftC = dayControllers[0];
            [leftC.weekLabel setText:[NSString stringWithFormat:@"%ld неделя",(long)displayWeek - 1]];
            leftC.view.frame = CGRectMake(0, 0, scrollFrame.size.width, scrollFrame.size.height);
            [daysScroll addSubview:leftC.view];
            for(int i = 2;i<=7;i++)
            {
                MNScheduleDayController *contr = dayControllers[i-1];
                contr.view.frame = CGRectMake((i-1)*scrollFrame.size.width, 0, scrollFrame.size.width, scrollFrame.size.height);
                [daysScroll addSubview:contr.view];
            }
            
            MNScheduleRightCapController *rightC = dayControllers[7];
            [rightC.weekLabel setText:[NSString stringWithFormat:@"%ld неделя",(long)displayWeek + 1]];
            rightC.view.frame = CGRectMake(7*scrollFrame.size.width, 0, scrollFrame.size.width, scrollFrame.size.height);
            [daysScroll addSubview:rightC.view];
            
            
            daysScroll.contentSize = CGSizeMake(scrollFrame.size.width*8, scrollFrame.size.height);
            NSDate *now = [NSDate date];
            NSDateFormatter *nowDateFormatter = [[NSDateFormatter alloc] init];
            [nowDateFormatter setDateFormat:@"e"];
            NSInteger weekdayNumber = (NSInteger)[[nowDateFormatter stringFromDate:now] integerValue];
            self.daysScroll.bounces = YES;
            pageControl.currentPage = weekdayNumber-2;
            self.title = [NSString stringWithFormat:@"%@ %ld неделя",dayDisc[[NSString stringWithFormat:@"%ld",(long)weekdayNumber]],(long)displayWeek];
            [daysScroll scrollRectToVisible:CGRectMake(scrollFrame.size.width*(weekdayNumber), 0,scrollFrame.size.width, scrollFrame.size.height) animated:NO];
        });
        return;
    });
}
- (void) leftButton{
    [MNAPI_Addition hideORShowLeftBar];
}

- (void) updateScroll{
    [dayControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(((MNScheduleDayController*)obj).view) removeFromSuperview];
    }];
    [dayControllers removeAllObjects];
    NSString *plistPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"schedules.plist"];
    NSData *data = [NSData dataWithContentsOfFile:plistPath];
    NSMutableDictionary *t = [[NSMutableDictionary alloc] initWithDictionary:[NSKeyedUnarchiver unarchiveObjectWithData:data]];
    NSString *currentGroup = t[@"current"];
    [t[@"data"] enumerateObjectsUsingBlock:^(id groups, NSUInteger idx, BOOL *stop){
        NSArray *validDiscs = groups[@"valid_discs"];
        MNScheduleLeftCapController *left = [MNAPI_Addition getViewControllerWithIdentifier:@"ScheduleCapLeft"];
        [left.weekLabel setText:[NSString stringWithFormat:@"%ld неделя",(long)displayWeek - 1]];
        [dayControllers addObject:left];
        __block NSInteger i = 0;
        if ([groups[@"name"] isEqualToString:currentGroup]) {
            [groups[@"days"] enumerateObjectsUsingBlock:^(id day, NSUInteger idx, BOOL *stopp) {
                MNScheduleDayController *dayController = [MNAPI_Addition getViewControllerWithIdentifier:@"ScheduleDay"];
                dayController.dayNumber = i;
                [dayController setDayDate:day andWeekNumber:displayWeek andValidDisks:validDiscs];
                [dayControllers addObject:dayController];
                i++;
            }];
        }
        MNScheduleRightCapController *right = [MNAPI_Addition getViewControllerWithIdentifier:@"ScheduleCapRight"];
        [right.weekLabel setText:[NSString stringWithFormat:@"%ld неделя",(long)displayWeek + 1]];
        [dayControllers addObject:right];
    }];
    dispatch_async(dispatch_get_main_queue(), ^{
        CGRect scrollFrame = self.daysScroll.frame;
        MNScheduleLeftCapController *leftC = dayControllers[0];
        leftC.view.frame = CGRectMake(0, 0, scrollFrame.size.width, scrollFrame.size.height);
        [daysScroll addSubview:leftC.view];
        for(int i = 2;i<=7;i++)
        {
            MNScheduleDayController *contr = dayControllers[i-1];
            contr.view.frame = CGRectMake((i-1)*scrollFrame.size.width, 0, scrollFrame.size.width, scrollFrame.size.height);
            [daysScroll addSubview:contr.view];
        }
        
        MNScheduleRightCapController *rightC = dayControllers[7];
        rightC.view.frame = CGRectMake(7*scrollFrame.size.width, 0, scrollFrame.size.width, scrollFrame.size.height);
        [daysScroll addSubview:rightC.view];
        
        
        daysScroll.contentSize = CGSizeMake(scrollFrame.size.width*8, scrollFrame.size.height);
        NSDate *now = [NSDate date];
        NSDateFormatter *nowDateFormatter = [[NSDateFormatter alloc] init];
        [nowDateFormatter setDateFormat:@"e"];
        NSInteger weekdayNumber = (NSInteger)[[nowDateFormatter stringFromDate:now] integerValue];
        if(pageNumber==0)
        {
            pageControl.currentPage = 5;
            self.title = [NSString stringWithFormat:@"%@ %ld неделя",dayDisc[[NSString stringWithFormat:@"%ld",(long)6]],(long)displayWeek];
            [daysScroll scrollRectToVisible:CGRectMake(scrollFrame.size.width*6, 0,scrollFrame.size.width, scrollFrame.size.height) animated:NO];
        }
        else
        {
            pageControl.currentPage = 0;
            self.title = [NSString stringWithFormat:@"%@ %ld неделя",dayDisc[[NSString stringWithFormat:@"%ld",(long)1]],(long)displayWeek];
            [daysScroll scrollRectToVisible:CGRectMake(scrollFrame.size.width, 0,scrollFrame.size.width, scrollFrame.size.height) animated:NO];
            
        }
    });
}

- (IBAction)clickPageControl:(id)sender {
    int page = (int)pageControl.currentPage;
    CGRect frame = daysScroll.frame;
    frame.origin.x=frame.size.width=page;
    frame.origin.y=0;
    [daysScroll scrollRectToVisible:frame animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int page = scrollView.contentOffset.x/scrollView.frame.size.width;
    id contr = dayControllers[page];
    if([[contr class] isSubclassOfClass:[MNScheduleDayController class]])
    {
        pageControl.currentPage = ((MNScheduleDayController*)dayControllers[page]).dayNumber;
        self.title = [NSString stringWithFormat:@"%@ %ld неделя",dayDisc[[NSString stringWithFormat:@"%ld",((MNScheduleDayController*)dayControllers[page]).dayNumber+1]],(long)displayWeek];
    }
    if([[contr class] isSubclassOfClass:[MNScheduleLeftCapController class]])
    {
        pageNumber = 0;
        displayWeek -= 1;
        [self updateScroll];
    }
    if([[contr class] isSubclassOfClass:[MNScheduleRightCapController class]]){
        pageNumber = 7;
        displayWeek += 1;
        [self updateScroll];
    }
}



@end
