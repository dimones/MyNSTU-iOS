//
//  MNSideController.m
//  MyNSTU
//
//  Created by Дмитрий Богомолов on 22.08.15.
//  Copyright (c) 2015 Дмитрий Богомолов. All rights reserved.
//

#import "MNSideController.h"
#import "MNSideUniCell.h"
#import "MNAuthViewController.h"
#import "MNSearchView.h"
#import "MNAPI+Addition.h"
#import "MNHTTPAPI.h"
#import "MNSideTopCell.h"
@interface MNSideController ()<UITableViewDelegate,UITableViewDataSource,MNAuthDelegate,MNSearchDelegate>
{
    BOOL isSearching;
    BOOL isAuthed;
    NSMutableArray *personsArray;
    NSDictionary *cellsProperty;
    MNAuthViewController *authController;
    MNSearchView *searchView;
    MNHTTPAPI *api;
    MNSideTopCell *topCell;
}
@end

@implementation MNSideController
@synthesize sideTable;
- (void)viewDidLoad {
    [super viewDidLoad];
    api = [MNHTTPAPI new];
    api.delegate = self;
    if (([MNAPI_Addition getObjectFROMNSUDWithKey:@"user_info"] == nil) && [MNHTTPAPI isAuthed])
        [api getInfo];
    cellsProperty = @{ @1 : @{ @"title": @"Новости", @"imageName": @"news.png"},
                       @2 : @{ @"title": @"Задания", @"imageName": @"tasks.png"},
                       @3 : @{ @"title": @"Расписание", @"imageName": @"schedule.png"},
                       @4 : @{ @"title": @"Преподаватели", @"imageName": @"persons.png"},
                       @5 : @{ @"title": @"Контрольные недели", @"imageName": @"schedule.png"},
                       @6 : @{ @"title": @"Результаты сессии", @"imageName": @"persons.png"}};
    isSearching = NO;
    self.clearsSelectionOnViewWillAppear = NO;
    
    
    //UITableView Appeareance
    self.sideTable.backgroundColor = [UIColor colorFromHexString:@"#353535"];
    self.sideTable.tableFooterView = [UIView new];
    //Search View
    if (searchView == nil) {
        searchView = [[MNSearchView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width * .87f, 112)];
        searchView.backgroundColor = [UIColor colorFromHexString:@"#353535"];
        searchView.delegate = self;
    }
    [self.sideTable insertSubview:searchView aboveSubview:self.sideTable];
    [self.sideTable bringSubviewToFront:searchView];
    [searchView.logButton addTarget:self action:@selector(authAction:) forControlEvents:UIControlEventTouchUpInside];
}
- (void) viewWillAppear:(BOOL)animated
{
    if (([MNAPI_Addition getObjectFROMNSUDWithKey:@"user_info"] == nil) && [MNHTTPAPI isAuthed])
        [api getInfo];
    
}
- (IBAction)authAction:(id)sender {
    
}
- (void) viewDidAppear:(BOOL)animated
{
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (isSearching) {
        return [personsArray count] + 1;
    }
    return 5;
}
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!isSearching) {
        if (indexPath.row == 0) {
            return 112;
        }
        return 47.f;
    }
    return 47.f;
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 1:
        {
            [MNAPI_Addition changeContentViewControllerWithName:@"NewsNavigation"];
            [MNAPI_Addition hideORShowLeftBar];
        }
            break;
        case 2:
        {
            [MNAPI_Addition changeContentViewControllerWithName:@"SchedulePrep"];
            [MNAPI_Addition hideORShowLeftBar];
            
        }
            break;
        case 3:
        {
            //[MNAPI_Addition changeContentViewControllerWithName:@"SchedulePrep"];
            [MNAPI_Addition changeContentViewControllerWithName:@"ScheduleController"];
            [MNAPI_Addition hideORShowLeftBar];
        }
            break;
        case 4:
        {
            [MNAPI_Addition changeContentViewControllerWithName:@"PersonList"];
            [MNAPI_Addition hideORShowLeftBar];
        }
            break;
        case 5:
        {
            
        }
            break;
        case 6:
        {
            
        }
            break;
            
        default:
            break;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MNSideUniCell *cell = [tableView dequeueReusableCellWithIdentifier:@"sideUniCell" forIndexPath:indexPath];
    if (indexPath.row == 0) {
        topCell = [tableView dequeueReusableCellWithIdentifier:@"sideProfileCell"];
        
        [topCell.authButton addTarget:self action:@selector(authAction:) forControlEvents:UIControlEventTouchUpInside];
        if(topCell == nil)
            return [MNSideTopCell new];
        return topCell;
//        return [UITableViewCell new];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.iconView.image = [UIImage imageNamed:cellsProperty[[NSNumber numberWithInteger:indexPath.row]][@"imageName"]];
    cell.titleLabel.text = cellsProperty[[NSNumber numberWithInteger:indexPath.row]][@"title"];
    cell.backgroundColor = [UIColor colorFromHexString:@"#353535"];
    UIView *graySeparator = [[UIView alloc] initWithFrame:CGRectMake(0, cell.frame.size.height - 1.f, cell.frame.size.width, 1.0f)];
    graySeparator.backgroundColor = [UIColor grayColor];
    graySeparator.alpha = 0.5f;
    [cell addSubview:graySeparator];
    return cell;
}

#pragma mark - MNAuthDelegate

- (void) MNAuthCompleted:(id)infoDict
{
    NSLog(@"auth completed %@", infoDict);
}
- (void) MNHTTPDidRecieveInfo: (MNHTTPAPI*) api
                      andInfo: (id) infoDictionary
{
    [MNAPI_Addition setObjectTONSUD:infoDictionary withKey:@"user_info"];
    [searchView updateInfo];
    [api getSchedule];
}
#pragma mark - MNSearchDelegate
- (void) MNSearchBegin
{
    
}
- (void) MNSearchEnd
{
    
}
- (void) MNNeedLogin
{
    MNAuthViewController *authContr = [MNAPI_Addition getViewControllerWithIdentifier:@"AuthController"];
    
    [self presentViewController:authContr animated:YES completion:nil];
}
@end
