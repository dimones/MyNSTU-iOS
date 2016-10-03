//
//  TodayViewController.m
//  schedule
//
//  Created by Дмитрий Богомолов on 17.09.16.
//  Copyright © 2016 Дмитрий Богомолов. All rights reserved.
//

#import "TodayViewController.h"
#import "MNPairCell.h"
#import <NotificationCenter/NotificationCenter.h>

@interface TodayViewController () <NCWidgetProviding,UITableViewDelegate,UITableViewDataSource>
{
    NSUInteger weekNumber;
    NSMutableArray *pairArray;
    
    NSInteger maxcount;
    NSDictionary *pairDescripion;
    NSDictionary *typeDescription;
    NSDictionary *dayDescription;
}
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *testLabel;

@end

@implementation TodayViewController
@synthesize tableView,dayLabel;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.extensionContext.widgetLargestAvailableDisplayMode = NCWidgetDisplayModeExpanded;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
//    [self.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, 500)];
    dayDescription = @{ @1: @"понедельник", @2: @"вторник",
                        @3: @"среду", @4: @"четверг",
                        @5: @"пятницу", @6: @"субботу"};
    typeDescription = @{ @"6" : @"(Лек.)", @"7": @"(Лаб.)", @"8": @"(Прак.)"};
    pairDescripion = @{ @"1":@"08:30 - 09.55",@"2": @"10:10 - 11:35",
                        @"3":@"11:50 - 13:15",@"4" : @"13:45 - 15:10",
                        @"5":@"15:25 - 16:50",@"6" : @"17:05 - 18:30",
                        @"7":@"18:40 - 20:00"};
    pairArray = [NSMutableArray new];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSUserDefaults *myDefaults = [[NSUserDefaults alloc]
                                      initWithSuiteName:@"group.com.mynstu.schedule"];
        NSMutableDictionary *schedule = [[NSMutableDictionary alloc] initWithDictionary:[NSKeyedUnarchiver unarchiveObjectWithData:[myDefaults objectForKey:@"schedule_data"]]][@"data"][0];
        
		//week
        NSString *dateString = schedule[@"semester_begin"];

        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd.MM.yyyy"];
        NSDate *dateFromString = [[NSDate alloc] init];
		//dateString
        dateFromString = [dateFormatter dateFromString:@"29.08.2016"];

        NSTimeInterval diff = [dateFromString timeIntervalSinceDate:[NSDate date]];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:[NSDate date]];
        weekNumber = (int)(-1*diff/60/60/24/7)+1;
        NSDate *now = [NSDate date];
        NSDateFormatter *nowDateFormatter = [[NSDateFormatter alloc] init];
        [nowDateFormatter setDateFormat:@"e"];
        NSInteger weekdayNumber = (NSInteger)[[nowDateFormatter stringFromDate:now] integerValue];
    	
        if ((weekdayNumber == 6 && components.hour > 19 ) || weekdayNumber == 7) {
            weekNumber += 1;
            weekdayNumber = 1;
        }
        maxcount = 0;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.dayLabel setText:[NSString stringWithFormat:@"Расписание на %@, %ld неделя",dayDescription[[NSNumber numberWithInt:weekdayNumber]],weekNumber]];
        });
        pairArray = [NSMutableArray new];
        NSMutableArray *validDiscs = [NSMutableArray new];
        [schedule[@"valid_discs"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [validDiscs addObject:[NSNumber numberWithLong:((NSString*)obj).longLongValue]];
        }];
        [schedule[@"days"][weekdayNumber-1] enumerateObjectsUsingBlock:^(id pair, NSUInteger idx, BOOL *stop) {
            if([validDiscs containsObject:pair[@"id"]])
            {
                NSArray *arrWeek = pair[@"weeks"];
                if([arrWeek count] >= weekNumber)
                {
                    if(((NSNumber*)arrWeek[weekNumber-1]).intValue == 1)
                    {
                        [pairArray addObject:pair];
                        maxcount++;
                    }
                }
                else
                {
                    if(weekNumber % 2 == 0)
                    {
                        if(pair[@"odd"] == 0)
                        {
                            [pairArray addObject:pair];
                            maxcount++;
                        }
                    }
                    else
                    {
                        if(pair[@"odd"] == 1){
                            [pairArray addObject:pair];
                            maxcount++;
                        }
                    }
                }
            }
        }];
        NSArray *sortedArray = [pairArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [[obj1 valueForKey:@"pair_number"] compare:[obj2 valueForKey:@"pair_number"]];
        }];
        pairArray = sortedArray;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            self.preferredContentSize = self.tableView.contentSize;
            [self.tableView setTranslatesAutoresizingMaskIntoConstraints:NO];
        });
    });
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) widgetActiveDisplayModeDidChange:(NCWidgetDisplayMode)activeDisplayMode withMaximumSize:(CGSize)maxSize
{
    CGSize s = self.tableView.contentSize;
    if (activeDisplayMode == NCWidgetDisplayModeCompact) {
        self.preferredContentSize = maxSize;
        [self.tableView setTranslatesAutoresizingMaskIntoConstraints:NO];
//        self.preferredContentSize = self.tableView.contentSize;
//        self.preferredContentSize = self.tableView.contentSize;
    }
    else {
        self.preferredContentSize = self.tableView.contentSize;
        [self.tableView setTranslatesAutoresizingMaskIntoConstraints:NO];
//        self.preferredContentSize = CGSizeMake(maxSize.width, 400);
    }
}
- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData
    
    //    self.preferredContentSize = CGSizeMake(0, 600);
//    self.preferredContentSize = self.tableView.contentSize;
    completionHandler(NCUpdateResultNewData);
}

//-(CGSize) sizeForChildContentContainer:(id<UIContentContainer>)container withParentContainerSize:(CGSize)parentSize
//{
//    return self.tableView.contentSize;
//}

#pragma mark - UITableViewDelegate

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([pairArray count] > 0) {
//        CGSize size = self.preferredContentSize;
//        size.height = pairArray.count * 44.0f;
//        self.preferredContentSize = size;
    }
    return [pairArray count];
}

- (UITableViewCell*) tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([pairArray count] == 0) {
        UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"TodayPairNone" forIndexPath:indexPath];
        return cell;
    }
    MNPairCell *cell = (MNPairCell*)[_tableView dequeueReusableCellWithIdentifier:@"TodayPair" forIndexPath:indexPath];
    if(!cell)
        cell = [MNPairCell new];
    NSString *typeString;
    if(typeDescription[pairArray[indexPath.row][@"type"]] == nil)
        typeString = @"";
    else typeString = typeDescription[pairArray[indexPath.row][@"type"]];
    
    
    if(![pairArray[indexPath.row][@"person1_name"] isEqual:[NSNull null]])
        cell.personLabel.text = pairArray[indexPath.row][@"person1_name"];
    if (![pairArray[indexPath.row][@"person2_name"] isEqual:[NSNull null]])
        cell.personLabel.text = [NSString stringWithFormat:@"%@ %@", cell.personLabel.text, pairArray[indexPath.row][@"person2_name"]];
    if(pairArray[indexPath.row][@"pair_number"]!=nil)
        cell.pairLabel.text = pairDescripion[[NSString stringWithFormat:@"%@",pairArray[indexPath.row][@"pair_number"]]];
    if(pairArray[indexPath.row][@"name"]!=nil)
        cell.discLabel.text = [NSString stringWithFormat:@"%@ %@",pairArray[indexPath.row][@"name"],typeString];
    if(pairArray[indexPath.row][@"room"]!=nil)
        cell.roomLabel.text = [NSString stringWithFormat:@"%@",pairArray[indexPath.row][@"room"]];
    //else cell.roomImage.hidden = YES;
    if([pairArray[indexPath.row][@"person1"] isEqual:[NSNull null]] && [pairArray[indexPath.row][@"person2"] isEqual:[NSNull null]])
        cell.personLabel.text = @"Не указано";
    if([cell.personLabel.text isEqual:@""])
        cell.personLabel.text = @"Не указано";
    return cell;
}
@end
