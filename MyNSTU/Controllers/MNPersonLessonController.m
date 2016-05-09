//
//  MNPersonLessonController.m
//  MyNSTU
//
//  Created by Дмитрий Богомолов on 04.09.15.
//  Copyright (c) 2015 Дмитрий Богомолов. All rights reserved.
//

#import "MNPersonLessonController.h"
#import "MNPersonsTabController.h"
#import "MNAPI+Addition.h"
#import "MNSessCell.h"
#import "MNRedHeaderTableViewCell.h"
@interface MNPersonLessonController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSArray *lessonsArray;
    NSDictionary *pairDict;
    NSDictionary *dayDict;
    NSDictionary *oddArray;
    NSMutableDictionary *heightDict;
}

@end

@implementation MNPersonLessonController

- (void)viewDidLoad {
    [super viewDidLoad];
    heightDict = [NSMutableDictionary new];
    dayDict = @{ @0 : @"Понедельник" , @1: @"Вторник",
                 @2 : @"Среда" ,  @3 : @"Четверг",
                 @4 : @"Пятница", @5 : @"Суббота"};
    pairDict =  @{ @"1":@"08:30 - 09:55",@"2":@"10:10 - 11:35",
                   @"3":@"11:50 - 13:15",@"4":@"13:45 - 15:10",
                   @"5":@"15:25 - 16:50",@"6":@"17:05 - 18:30",
                   @"7":@"18:40 - 20:00",@"8":@"20:10 - 21:30"};
    oddArray = @{ @-1 : @"Нечетная\\четная неделя", @0:@"Четная неделя", @1:@"Нечетная неделя" };
    self.lessonsTable.delegate = self;
    self.lessonsTable.dataSource = self;
    self.lessonsTable.tableFooterView = [UIView new];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    MNPersonsTabController * parentTab = (MNPersonsTabController*)self.parentViewController;
    parentTab.title = [MNAPI_Addition getObjectFROMNSUDWithKey:@"person_name"];
    NSString *persID = parentTab.personID.stringValue;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"persons" ofType:@"json"];
        id jsonObject = [MNAPI_Addition JSONObjectFromFile:filePath];
        NSString *FIO = jsonObject[persID][@"name"];
        NSArray *nameArray = [FIO componentsSeparatedByString:@" "];
        dispatch_async(dispatch_get_main_queue(), ^{
            parentTab.title = [NSString stringWithFormat:@"%@ %@.%@.",nameArray[0],
                                                    [[nameArray[1] uppercaseString] substringWithRange:NSMakeRange(0, 1)],
                                                    [[nameArray[2] uppercaseString] substringWithRange:NSMakeRange(0, 1)]];
        });
        
    });
    [self initHelper];
}

- (void) initHelper {
    MNPersonsTabController * parentTab = (MNPersonsTabController*)self.parentViewController;
    NSNumber *idPerson = parentTab.personID;
    parentTab.title = [MNAPI_Addition getObjectFROMNSUDWithKey:@"person_name"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"details" ofType:@"json"];
        id personObj = [MNAPI_Addition JSONObjectFromFile:filePath];
        lessonsArray = [personObj[idPerson.stringValue][@"lessons"] copy];
        dispatch_async(dispatch_get_main_queue(), ^{
            self .lessonsTable.contentInset = UIEdgeInsetsMake(64, 0, 50, 0);
            [self.lessonsTable reloadData];
        });
    });
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSString*) getGroupsFixedString:(NSArray*)arr
{
    __block NSString *outString;
    __block NSString *prevString = @"";
    if ([arr count] > 0) {
        [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *tempString = obj;
            NSArray *_arr = [obj componentsSeparatedByString:@"-"];
            if ([_arr[0] rangeOfString:prevString].location != NSNotFound)
                outString = [outString stringByAppendingString:[NSString stringWithFormat:@"%@ ",_arr[1]]];
            else
                outString = [outString stringByAppendingString:[NSString stringWithFormat:@"%@ ",obj]];
            prevString = [tempString copy];
        }];
    }
    if ([arr count] == 1 && [outString isEqualToString:@""])
        outString = arr[0];
    else
        outString = [arr lastObject];
    return outString;
}
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [lessonsArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if([lessonsArray[section] count] == 0)
        return 1;
    else return [lessonsArray[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if([lessonsArray[indexPath.section] count] > 0){
        MNSessCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SessCell" forIndexPath:indexPath];
        if(cell == nil)
        {
            cell = [MNSessCell new];
        }
        if ([lessonsArray[indexPath.section] count] > 0) {
            id obj = lessonsArray[indexPath.section][indexPath.row][@"description"];
            NSString *nameString;
            if(obj == nil){
                nameString = [NSString stringWithFormat:@"%@",[self getGroupsFixedString:lessonsArray[indexPath.section][indexPath.row][@"groups"]]];
            }
            else nameString = [NSString stringWithFormat:@"%@ %@",lessonsArray[indexPath.section][indexPath.row][@"description"],[self getGroupsFixedString:lessonsArray[indexPath.section][indexPath.row][@"groups"]]];
            cell.nameLabel.text = nameString;
        }
        NSString *pair_num = ((NSNumber*)lessonsArray[indexPath.section][indexPath.row][@"pair_number"]).stringValue;
        cell.timeLabel.text = pairDict[pair_num];
        [cell.nameLabel sizeToFit];
        CGRect nameRect = cell.nameLabel.frame;
        CGRect frameGroups = cell.groupsLabel.frame;
        frameGroups.origin.x = nameRect.size.width+nameRect.origin.x+5;
        frameGroups.size.width = self.view.frame.size.width-nameRect.size.width+nameRect.origin.x-10;
        [cell.groupsLabel setFrame:[self rectByLabel:cell.groupsLabel]];
        
        [cell.timeLabel setTextColor:[UIColor grayColor]];
        [cell.audienceLabel setTextColor:[UIColor grayColor]];
        [heightDict setObject:[NSNumber numberWithFloat:cell.groupsLabel.frame.origin.x + cell.groupsLabel.frame.size.height] forKey:indexPath];
        return cell;
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LessonsNo" forIndexPath:indexPath];
    
    [cell setNeedsLayout];
    [cell setNeedsDisplay];
    return cell;
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
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor whiteColor]];
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    MNRedHeaderTableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"MNRedHeaderTableViewCell" owner:self options:nil] firstObject];
    if(cell == nil)
    {
        cell = [MNRedHeaderTableViewCell new];
    }
    cell.redLabel.text = dayDict[[NSNumber numberWithInt:section]];
    
    [cell setBackgroundColor:[UIColor colorFromHexString:@"E53935"]];
    return cell;
}
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 32;
}
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([lessonsArray[indexPath.section] count] > 0)
        return ((NSNumber*)heightDict[indexPath]).floatValue;
    else return 32;
}

@end
