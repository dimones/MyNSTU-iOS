//
//  MNScheduleChooseGroup.m
//  MyNSTU
//
//  Created by Дмитрий Богомолов on 14.02.16.
//  Copyright © 2016 Дмитрий Богомолов. All rights reserved.
//

#import "MNScheduleChooseGroup.h"
#import "MNHTTPAPI.h"
#import "MNRedHeaderTableViewCell.h"
#import "MBProgressHUD.h"
#import "MNScheduleDiscChooser.h"
@interface MNScheduleChooseGroup ()<UITableViewDataSource,UITableViewDelegate,MNAPIHTTPDelegate>
{
    MNHTTPAPI *API;
    MBProgressHUD *hud;
}
@end

@implementation MNScheduleChooseGroup
@synthesize groupString,groupsArray;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.groupTable.delegate = self;
    self.groupTable.dataSource = self;
    API = [MNHTTPAPI new];
    API.delegate = self;
    self.clearsSelectionOnViewWillAppear = NO;
    [self.groupTable reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}









#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[groupsArray  allKeys] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger t = [groupsArray[[NSString stringWithFormat:@"%ld",(long)section + 1]] count];
    return t;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 32;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    groupString = groupsArray[[NSString stringWithFormat:@"%ld",(long)indexPath.section + 1]][indexPath.row];
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Получаю расписание";
    [API getScheduleFromGroup:groupString];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GroupCell" forIndexPath:indexPath];
    if (cell==nil) {
        cell = [UITableViewCell new];
    }
    id dict = groupsArray[[NSString stringWithFormat:@"%ld",(long)indexPath.section+1]];
    cell.textLabel.text = dict[indexPath.row];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    MNRedHeaderTableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"MNRedHeaderTableViewCell" owner:self options:nil] firstObject];
    if(cell == nil)
    {
        cell = [MNRedHeaderTableViewCell new];
    }
    cell.redLabel.text = [NSString stringWithFormat:@"%ld курс",section + 1];
    return cell;
}

#pragma mark - MNHTTPAPI Delegate

- (void) MNHTTPDidRecieveSchedule:(MNHTTPAPI *)api andResults:(NSArray *)results andSemesterBegin:(NSString *)semesterBegin
{
    NSMutableArray *discArray = [NSMutableArray new];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [results enumerateObjectsUsingBlock:^(id day, NSUInteger idx, BOOL *stop) {
            [day enumerateObjectsUsingBlock:^(id pair, NSUInteger idx, BOOL *stop) {
                NSDictionary *dict = @{ @"id" : pair[@"id"], @"description" : pair[@"name"], @"check": @1 };
                if(![discArray containsObject:dict])
                    [discArray addObject:dict];
            }];
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            MNScheduleDiscChooser *d_choose = [MNAPI_Addition getViewControllerWithIdentifier:@"DiscChooser"];
            d_choose.semester_begin = semesterBegin;
            d_choose.data_array = discArray;
            d_choose.days = results;
            d_choose.group_name = self.groupString;
            [hud hide:YES];
            [self.navigationController pushViewController:d_choose animated:YES];
        });
    });
    
    
}
@end
