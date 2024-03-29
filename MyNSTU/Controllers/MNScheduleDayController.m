//
//  MNScheduleDayController.m
//  MyNSTU
//
//  Created by Дмитрий Богомолов on 17.02.16.
//  Copyright © 2016 Дмитрий Богомолов. All rights reserved.
//

#import "MNScheduleDayController.h"
#import "MNSchedulePairCell.h"
#import "MNAPI+Addition.h"
#import "MNPersonsTabController.h"
#import "MNEmptyViewController.h"
#define NEW 0

@interface MNScheduleDayController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *pairArray;
    NSDictionary *pairDescripion;
    NSDictionary *typeDescription;
    NSMutableDictionary *heightDict;
    NSInteger maxcount;
    BOOL canUpdate;
    id personsName;
}
@end
@implementation MNScheduleDayController
@synthesize pairArray,dayArray,dayNumber,validDiscs,weekNumber,scheduleTable;
- (void)viewDidLoad {
    [super viewDidLoad];
    heightDict = [NSMutableDictionary new];
    personsName = [NSMutableDictionary new];
    typeDescription = @{ @"6" : @"(Лек.)", @"7": @"(Лаб.)", @"8": @"(Прак.)"};
    pairDescripion = @{ @"1":@"08:30 - 09.55",@"2": @"10:10 - 11:35",
                        @"3":@"11:50 - 13:15",@"4" : @"13:45 - 15:10",
                        @"5":@"15:25 - 16:50",@"6" : @"17:05 - 18:30",
                        @"7":@"18:40 - 20:00"};
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"persons" ofType:@"json"];
    NSData* responseObject = [NSData dataWithContentsOfFile:filePath];
    NSError *jsonError = nil;
    if(responseObject!=nil)
        personsName = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&jsonError];
    self.scheduleTable.delegate = self;
    
//    self.scheduleTable.dataSource = self;
    self.clearsSelectionOnViewWillAppear = NO;
    self.scheduleTable.tableFooterView = [UIView new];
    
    self.scheduleTable.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);

    self.scheduleTable.estimatedRowHeight = 150.f;
    self.scheduleTable.rowHeight = UITableViewAutomaticDimension;

}
- (void) viewWillAppear:(BOOL)animated
{
}
- (void)viewDidAppear:(BOOL)animated
{
    [self.scheduleTable reloadData];
    if([pairArray count] == 0){
        MNEmptyViewController* contr = [MNAPI_Addition getViewControllerWithIdentifier:@"EmptyView"];
        contr.emptyLabel.text = @"В этот день занятий нет.";
        [contr.view setFrame:self.scheduleTable.bounds];
        [self.view addSubview:contr.view];
    }
//    dispatch_async(dispatch_get_main_queue(), ^{
//        //This code will run in the main thread:
//        CGRect frame = scheduleTable.frame;
//        frame.size.height = scheduleTable.contentSize.height;//commenting this code worked.
//        scheduleTable.frame = frame;
//        
//    });
    //   self.scheduleTable.tableFooterView = [UIView new];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (void) setDayDate:(NSArray*)dayArray andWeekNumber:(NSInteger)weekNumber andValidDisks:(NSArray*)ValidDiscs
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        maxcount = 0;
        canUpdate = false;
        pairArray = [NSMutableArray new];
        self.weekNumber = weekNumber;
        NSMutableArray *validDiscs = [NSMutableArray new];
        [ValidDiscs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [validDiscs addObject:[NSNumber numberWithLong:((NSString*)obj).longLongValue]];
        }];
        [dayArray enumerateObjectsUsingBlock:^(id pair, NSUInteger idx, BOOL *stop) {
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
            
            canUpdate = true;
        });
    });
    
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(canUpdate)
    {
        NSLog(@"pair %lu",(unsigned long)[pairArray count]);
        return [pairArray count];
    }
    else return 0;
}

-(void) personTapped: (UIGestureRecognizer*) sender{
//    NSLog(@"%@", sender.view.tag);
    dispatch_async(dispatch_get_main_queue(), ^{
        if(sender.view.tag != -1)
        {
            UINavigationController *pDet = [MNAPI_Addition getViewControllerWithIdentifier:@"PersonDetail"];
            MNPersonsTabController *res = (MNPersonsTabController*)[pDet.viewControllers firstObject];
            res.personID = [NSNumber numberWithInt:sender.view.tag];
            [IQSideMenuController turnScroll];
            [MNAPI_Addition changeContentViewControllerWithController:pDet];
        }
    });
}
//-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return ((NSNumber*)heightDict[[NSNumber numberWithInt:indexPath.row]]).intValue;
//}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
#if NEW == 0
    static NSString *CellIdentifier = @"SPairCell";
    MNSchedulePairCell *cell = [self.scheduleTable dequeueReusableCellWithIdentifier:CellIdentifier ];
    if(cell == nil)
    {
        cell = [[MNSchedulePairCell alloc] init];
    }
    __block NSString *weeksString = @"";
    NSArray *weekArray = pairArray[indexPath.row][@"weeks"];
    __block int i = 1;
    NSString *odd = pairArray[indexPath.row][@"odd"];
    if(odd.intValue!=0&& odd.intValue!=1&& [weekArray containsObject:@0])
    {
        [weekArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if([[NSString stringWithFormat:@"%@",obj] isEqualToString:[NSString stringWithFormat:@"%d",1]])
                weeksString = [weeksString stringByAppendingString:[NSString stringWithFormat:@" %d",i]];
            ++i;
        }];
    }
    NSString *typeString;
    if(typeDescription[pairArray[indexPath.row][@"type"]] == nil)
        typeString = @"";
    else typeString = typeDescription[pairArray[indexPath.row][@"type"]];
    
    //Text assign
    if(![pairArray[indexPath.row][@"person1"] isEqual:[NSNull null]]){
        NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
        if(![pairArray[indexPath.row][@"person1"] isEqual:[NSNull null]]){
            cell.labelPersons.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", personsName[((NSNumber*)pairArray[indexPath.row][@"person1"]).stringValue][@"name"]]
                                                                               attributes:underlineAttribute];
            //        cell.labelPersons.text = [NSString stringWithFormat:@"%@", personsName[((NSNumber*)pairArray[indexPath.row][@"person1"]).stringValue][@"name"]];
        }
        if (![pairArray[indexPath.row][@"person2"] isEqual:[NSNull null]]){
            cell.labelPersons.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@",cell.labelPersons.text, personsName[((NSNumber*)pairArray[indexPath.row][@"person2"]).stringValue][@"name"]]
                                                                               attributes:underlineAttribute];
            //cell.labelPersons.text = [NSString stringWithFormat:@"%@ %@", cell.labelPersons.text, personsName[((NSNumber*)pairArray[indexPath.row][@"person2"]).stringValue][@"name"]];
        }
    }
    else
    {
        [cell.labelPersons setTextColor:[UIColor blackColor]];
        
    }
    if([pairArray[indexPath.row][@"person1"] isEqual:[NSNull null]])
    {
        [cell.labelPersons setText:@"Не указано"];
        [cell.labelPersons setTag:-1];
    }
    else
        [cell.labelPersons setTag:((NSNumber*)pairArray[indexPath.row][@"person1"]).integerValue];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(personTapped:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [cell.labelPersons addGestureRecognizer:tapGestureRecognizer];
    cell.labelPersons.userInteractionEnabled = YES;
    if(pairArray[indexPath.row][@"pair_number"]!=nil)
        cell.labelTime.text = pairDescripion[[NSString stringWithFormat:@"%@",pairArray[indexPath.row][@"pair_number"]]];
    if(pairArray[indexPath.row][@"name"]!=nil)
        cell.labelTitle.text = [NSString stringWithFormat:@"%@ %@",pairArray[indexPath.row][@"name"],typeString];
    if(pairArray[indexPath.row][@"room"]!=nil)
        cell.labelRoom.text = [NSString stringWithFormat:@"%@",pairArray[indexPath.row][@"room"]];
    else cell.roomImage.hidden = YES;
    if([pairArray[indexPath.row][@"person1"] isEqual:[NSNull null]] && [pairArray[indexPath.row][@"person2"] isEqual:[NSNull null]])
        cell.labelPersons.text = @"Не указано";
    if([cell.labelRoom.text isEqual:@""])
        cell.labelRoom.text = @"Не указано";
    if(weeksString)
    {
        if([weeksString length] > 0)
            cell.labelWeeks.text = [NSString stringWithFormat:@"Недели: %@", weeksString];
        else{
            if (odd.intValue == 0) {
                cell.labelWeeks.text = @"Недели: Четные";
            }
            if (odd.intValue == 1) {
                cell.labelWeeks.text = @"Недели: Нечетные";
            }
            if(odd.intValue == -1)
            {
                cell.labelWeeks.text = @"Недели: Все";
            }
        }
        
    }
    [cell.labelTitle setFrame:[self rectByLabel:cell.labelTitle]];
    [cell.labelTime setFrame:[self rectByLabel:cell.labelTime]];
    [cell.labelRoom setFrame:[self rectByLabel:cell.labelRoom]];
    [cell.labelPersons setFrame:[self rectByLabel:cell.labelPersons]];
    //PersonLabel
    CGRect per = cell.labelPersons.frame;
    CGRect tit = cell.labelTitle.frame;
    per.origin.y = tit.origin.y+tit.size.height+5;
    tit.origin.x = 20;
    [cell.labelTitle setFrame:tit];
    CGRect perImg = cell.personImage.frame;
    perImg.origin.y = per.origin.y;
    [cell.personImage setFrame:perImg];
    [cell.labelPersons setFrame:per];
    //WeeksLabel
    CGRect week = cell.labelWeeks.frame;
    week.origin.y = per.origin.y+5+per.size.height;
    CGRect weekImg = cell.weeksImage.frame;
    weekImg.origin.y = week.origin.y;
    [cell.labelWeeks setFrame:week];
    [cell.weeksImage setFrame:weekImg];
    //self frame
    CGRect ss = cell.frame;
    ss.size.height = week.origin.y + week.size.height + 5;
    [cell setFrame:ss];
    [heightDict setObject:[NSNumber numberWithInt:ss.size.height] forKey:[NSNumber numberWithInt:indexPath.row]];
    [cell setNeedsLayout];
    [cell setNeedsDisplay];
    [tableView setNeedsLayout];
    [tableView setNeedsDisplay];
    return cell;
#else
    MNScheduleCell *cell = [[NSBundle mainBundle] loadNibNamed:@"MNScheduleCell" owner:self options:nil][0];
    if(cell == nil)
    {
        cell = [MNScheduleCell new];
    }
    [self setUpCell:cell atIndexPath:indexPath];
    
    return cell;
#endif
}
- (void)setUpCell:(MNScheduleCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    __block NSString *weeksString = @"";
    NSArray *weekArray = pairArray[indexPath.row][@"weeks"];
    __block int i = 1;
    NSString *odd = pairArray[indexPath.row][@"odd"];
    if(odd.intValue!=0&& odd.intValue!=1&& [weekArray containsObject:@0])
    {
        [weekArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if([[NSString stringWithFormat:@"%@",obj] isEqualToString:[NSString stringWithFormat:@"%d",1]])
                weeksString = [weeksString stringByAppendingString:[NSString stringWithFormat:@" %d",i]];
            ++i;
        }];
    }
    NSString *typeString;
    if(typeDescription[pairArray[indexPath.row][@"type"]] == nil)
        typeString = @"";
    else typeString = typeDescription[pairArray[indexPath.row][@"type"]];
    
    //Text assign
    if(![pairArray[indexPath.row][@"person1"] isEqual:[NSNull null]])
        cell.pair_person_name.text = [NSString stringWithFormat:@"%@", personsName[((NSNumber*)pairArray[indexPath.row][@"person1"]).stringValue][@"name"]];
    if (![pairArray[indexPath.row][@"person2"] isEqual:[NSNull null]])
        cell.pair_person_name.text = [NSString stringWithFormat:@"%@ %@", cell.pair_person_name.text, personsName[((NSNumber*)pairArray[indexPath.row][@"person2"]).stringValue][@"name"]];
    if(pairArray[indexPath.row][@"pair_number"]!=nil)
        cell.pair_number.text = pairDescripion[[NSString stringWithFormat:@"%@",pairArray[indexPath.row][@"pair_number"]]];
    if(pairArray[indexPath.row][@"name"]!=nil)
        cell.pair_name.text = [NSString stringWithFormat:@"%@ %@",pairArray[indexPath.row][@"name"],typeString];
    if(pairArray[indexPath.row][@"room"]!=nil)
        cell.pair_location.text = [NSString stringWithFormat:@"%@",pairArray[indexPath.row][@"room"]];
    //else cell.roomImage.hidden = YES;
    if([pairArray[indexPath.row][@"person1"] isEqual:[NSNull null]] && [pairArray[indexPath.row][@"person2"] isEqual:[NSNull null]])
        cell.pair_person_name.text = @"Не указано";
    if([cell.pair_location.text isEqual:@""])
        cell.pair_location.text = @"Не указано";
    if(weeksString!=nil)
    {
        if(![weeksString isEqualToString:@""])
            cell.pair_week.text = [NSString stringWithFormat:@"Недели: %@", weeksString];
        if (odd.intValue == 0) {
            cell.pair_week.text = @"Недели: Четные";
        }
        if (odd.intValue == 1) {
            cell.pair_week.text = @"Недели: Нечетные";
        }
        if(odd.intValue == -1)
        {
            cell.pair_week.text = @"Недели: Все";
        }
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
#if NEW == 1
    static MNScheduleCell *cell = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"MNScheduleCell"];
    });
    
    [self setUpCell:cell atIndexPath:indexPath];
    
    return [self calculateHeightForConfiguredSizingCell:cell];
#else
    return ((NSNumber*)heightDict[[NSNumber numberWithInt:indexPath.row]]).intValue;
#endif
}

- (CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell {
    [sizingCell layoutIfNeeded];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height;
}
- (CGRect) rectByLabel:(UILabel*) label
{
    CGSize maximumLabelSize = CGSizeMake(self.view.bounds.size.width-20, FLT_MAX);
    
    CGSize expectedLabelSize = [label.text sizeWithFont:label.font constrainedToSize:maximumLabelSize lineBreakMode:label.lineBreakMode];
    
    //adjust the label the the new height.
    CGRect newFrame = label.frame;
    newFrame.size.height = expectedLabelSize.height;
    return newFrame;
}

@end
