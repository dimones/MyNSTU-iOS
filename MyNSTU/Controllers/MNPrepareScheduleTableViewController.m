//
//  MNPrepareScheduleTableViewController.m
//  MyNSTU
//
//  Created by Дмитрий Богомолов on 21.08.15.
//  Copyright (c) 2015 Дмитрий Богомолов. All rights reserved.
//

#import "MNPrepareScheduleTableViewController.h"
#import "MNHTTPAPI.h"
#import "MNAPI+Addition.h"
#import "MBProgressHUD.h"
#import "MNRedHeaderTableViewCell.h"
#import "MNDefaultTableViewCell.h"
@interface MNPrepareScheduleTableViewController ()<MNAPIHTTPDelegate,UITableViewDataSource,UITableViewDelegate,MBProgressHUDDelegate>
{
    id needData;
    NSArray *sortedFaculties;
    MNHTTPAPI *api;
    MBProgressHUD *hud;
    NSString *_semesterBegin;
    NSMutableArray *dics;
    UISegmentedControl *segmentControl;
    NSInteger sub_group;
    NSMutableDictionary *sizes;
}
@property (strong, nonatomic) IBOutlet UITableView *prepareTable;
@end

@implementation MNPrepareScheduleTableViewController
@synthesize prepareStage,prepareTable,groupName;

- (void) setNeedData:(id)data
{
    needData = [data copy];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    sizes = [NSMutableDictionary new];
    //Appearance
    prepareTable.delegate = self;
    prepareTable.dataSource = self;
    prepareTable.tableFooterView = [UIView new];
    self.clearsSelectionOnViewWillAppear = NO;
    if(prepareStage == MNGetFaculty)
        self.title = @"Выберите факультет";
    else if(prepareStage == MNGetGroup)
        self.title = @"Выберите группу";
    else if(prepareStage == MNGetSchedule)
        self.title = @"Выберите предметы";
    if(prepareStage != MNGetSchedule){
        UIBarButtonItem *closeBarButton = [[UIBarButtonItem alloc] initWithImage:[MNAPI_Addition imageWithIcon:icon_close size:30.0f color:[UIColor whiteColor]] style:UIBarButtonItemStylePlain target:self action:@selector(dismissController)];
        closeBarButton.imageInsets = UIEdgeInsetsMake(5, 0, 0, 7.5f);
        self.navigationItem.rightBarButtonItem = closeBarButton;
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
        [closeBarButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor],  NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    }
    else{
        UIBarButtonItem *closeBarButton = [[UIBarButtonItem alloc] initWithImage:[MNAPI_Addition imageWithIcon:icon_ios7_checkmark size:35.0f color:[UIColor whiteColor]] style:UIBarButtonItemStylePlain target:self action:@selector(finishPreparing)];
        closeBarButton.imageInsets = UIEdgeInsetsMake(5, 0, 0, 7.5f);
        self.navigationItem.rightBarButtonItem = closeBarButton;
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
        [closeBarButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor],  NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    }
    //MNAPI init
    api = [MNHTTPAPI new];
    api.delegate = self;
    //Loading hud
    if (self.prepareStage == MNGetFaculty) {
        //HUD init
        [api getFaculties];
        hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:hud];
        hud.delegate = self;
        hud.labelText = @"Загрузка";
        hud.detailsLabelText = @"Загружаю данные о факультетах";
        [hud show:YES];
        
    }
    if (self.prepareStage == MNGetSchedule) {
        //HUD init
        [api getScheduleFromGroup:groupName];
        hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:hud];
        hud.delegate = self;
        hud.labelText = @"Загрузка";
        hud.detailsLabelText = @"Загружаю расписание";
        [hud show:YES];
        //Segment control init
        segmentControl = [[UISegmentedControl alloc] initWithItems:@[@"1 подгруппа", @"2 подгруппа"]];
        [segmentControl addTarget:self action:@selector(onSegmentChanged:) forControlEvents:UIControlEventValueChanged];
        [segmentControl setTintColor:[UIColor colorWithRed:0.961f green:0.263f blue:0.216f alpha:1.00f]];
        segmentControl.selectedSegmentIndex = 0;
        sub_group = 1;
    }
}
- (void) finishPreparing{
    NSDictionary *dict = @{@"semester_begin":_semesterBegin,@"days":needData,@"valid_discs":dics};
    NSString *plistPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"schedule.plist"];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:plistPath isDirectory:(BOOL*)NO])
        [[NSFileManager defaultManager] removeItemAtPath:plistPath error:nil];
    NSData *datad = [NSKeyedArchiver archivedDataWithRootObject:dict];
    [datad writeToFile:plistPath atomically:YES];
//    id sideController = [MNAPI_Addition getViewControllerWithIdentifier:@"SideController"];
//    id contentViewController = [MNAPI_Addition getViewControllerWithIdentifier:@"NewsNavigation"];
//    IQSideMenuController *sideMenuController = nil;
//    __wind.rootViewController = sideMenuController;
//    sideMenuController = [[IQSideMenuController alloc] initWithMenuViewController:sideController
//                                                                               andContentViewController:contentViewController];
//    
//    id tt = ((UIWindow*)[[UIApplication sharedApplication].windows firstObject]);
//    [tt setRootViewController:sideMenuController];
//    [self presentViewController:sideMenuController animated:YES completion:^{
//       // [((UIWindow*)[[UIApplication sharedApplication].windows firstObject]) setRootViewController:sideMenuController];
//
//    }];
    [MNAPI_Addition setObjectTONSUD:[NSNumber numberWithBool:YES] withKey:@"schedule_finished"];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    if([self.delegate respondsToSelector:@selector(MNSchedulePreparingFinishing:)])
        [self.delegate MNSchedulePreparingFinishing:YES];
    
}
- (void) dismissController{
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    if([self.delegate respondsToSelector:@selector(MNSchedulePreparingFinishing:)])
        [self.delegate MNSchedulePreparingFinishing:NO];
}
- (void)onSegmentChanged:(id)sender{
    sub_group = ((UISegmentedControl *)sender).selectedSegmentIndex + 1;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark - MNHTTPAPI usage
- (void) MNHttpDidRecieveFacultiesResponse:(MNHTTPAPI *)api andResults:(id)results sortedFacs:(NSArray *)facs
{
    needData = [results copy];
    sortedFaculties = [facs copy];
    [prepareTable reloadData];
    [hud hide:YES];
}
- (void) MNHTTPDidRecieveFaculties:(MNHTTPAPI *)api andFacs:(id)faculties
{
    
}
-(void) MNHTTPDidRecieveSchedule:(MNHTTPAPI *)api andResults:(NSArray *)results andSemesterBegin:(NSString *)semesterBegin
{
    _semesterBegin = semesterBegin;
    dics = [NSMutableArray new];
    needData = [results copy];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [results enumerateObjectsUsingBlock:^(id day, NSUInteger idx, BOOL *stop) {
            [day enumerateObjectsUsingBlock:^(id pair, NSUInteger idx, BOOL *stop) {
                NSDictionary *dict = @{ @"id" : pair[@"id"], @"description" : pair[@"name"], @"check": @1 };
                if(![dics containsObject:dict])
                    [dics addObject:dict];
            }];
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [prepareTable reloadData];
            [hud hide:YES];
        });
    });

}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //check stage for show contoller
    if(prepareStage == MNGetFaculty)
        return 1;
    else if(prepareStage == MNGetGroup)
        return [[needData allKeys] count];
    else if(prepareStage == MNGetSchedule)
        return 1;
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(prepareStage == MNGetFaculty)
        return [needData count];
    else if(prepareStage == MNGetGroup)
        return [needData[[NSString stringWithFormat:@"%ld",section+1]] count];
    else if(prepareStage == MNGetSchedule)
        return [dics count] + 1;
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PrepareCell" forIndexPath:indexPath];
    if(cell == nil)
    {
        cell = [UITableViewCell new];
    }
    if(prepareStage == MNGetFaculty){
        cell.textLabel.text = sortedFaculties[indexPath.row];
    }else if(prepareStage == MNGetGroup){ 
        cell.textLabel.text = needData[[NSString stringWithFormat:@"%ld",indexPath.section+1]][indexPath.row];
    
    }else if(prepareStage == MNGetSchedule){
        if (indexPath.row == 0) {
            [segmentControl setFrame:CGRectMake(10, 10, cell.frame.size.width-20, 25)];
            [cell addSubview:segmentControl];
            return cell;
        }
        else{
            cell.textLabel.text = dics[indexPath.row - 1][@"description"];
            NSNumber *checked = dics[indexPath.row - 1][@"check"];
            if([checked isEqual:@1])
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            else
                cell.accessoryType = UITableViewCellAccessoryNone;
        }
        CGRect textRect = [self rectByLabel:cell.textLabel];
        [cell.textLabel setFrame:textRect];
        [sizes setObject:[NSNumber numberWithFloat:textRect.origin.y + textRect.size.height + 10] forKey:[NSNumber numberWithInteger:indexPath.row]];
        return cell;
    }
    CGRect textRect = [self rectByLabel:cell.textLabel];
    [cell.textLabel setFrame:textRect];
    [sizes setObject:[NSNumber numberWithFloat:textRect.origin.y + textRect.size.height + 10] forKey:[NSNumber numberWithInteger:indexPath.row]];
    // Configure the cell...
    return cell;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (prepareStage == MNGetGroup) {
        MNRedHeaderTableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"MNRedHeaderTableViewCell" owner:self options:nil] firstObject];
        if(cell == nil)
        {
            cell = [MNRedHeaderTableViewCell new];
        }
        cell.redLabel.text = [NSString stringWithFormat:@"%ld курс",section + 1];
        return cell;
    }
    return [UIView new];
}
- (CGRect) rectByLabel:(UILabel*) label
{
    CGSize maximumLabelSize = CGSizeMake(self.view.frame.size.width-30, FLT_MAX);
    
    CGSize expectedLabelSize = [label.text sizeWithFont:label.font constrainedToSize:maximumLabelSize lineBreakMode:label.lineBreakMode];
    
    //adjust the label the the new height.
    CGRect newFrame = label.frame;
    newFrame.size.height = expectedLabelSize.height;
    return newFrame;
}
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (prepareStage == MNGetSchedule) {
        if(indexPath.section ==0)
            return 44.5f;
        NSNumber *numb = sizes[[NSNumber numberWithInteger:indexPath.row]];
        return numb.floatValue;
    }
    return 44.5f;
}
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (prepareStage == MNGetFaculty) {
        if (section == 0) {
            return 0;
        }
    }
    if (prepareStage == MNGetSchedule) {
        if (section == 0) {
            return 0;
        }
    }
    return 40;
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MNPrepareScheduleTableViewController *prepareController = [MNAPI_Addition getViewControllerWithIdentifier:@"SchedulePrepare"];
    if (prepareStage == MNGetFaculty) {
        prepareController.prepareStage = MNGetGroup;
        prepareController.delegate = self.delegate;
        [prepareController setNeedData:needData[sortedFaculties[indexPath.row]]];
        [self.navigationController pushViewController:prepareController animated:YES];
    }
    else if(prepareStage == MNGetGroup){
        prepareController.prepareStage = MNGetSchedule;
        prepareController.delegate = self.delegate;
        prepareController.groupName = needData[[NSString stringWithFormat:@"%ld",indexPath.section+1]][indexPath.row];
        [self.navigationController pushViewController:prepareController animated:YES];
    }
    else if(prepareStage == MNGetSchedule){
        prepareController.delegate = self.delegate;
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:dics[indexPath.row - 1]];
        NSNumber *checked = dict[@"check"];
        if([checked isEqual:@1])
            checked = @0;
        else
            checked = @1;
        [dict removeObjectForKey:@"check"];
        [dict setObject:checked forKey:@"check"];
        [dics replaceObjectAtIndex:indexPath.row - 1 withObject:(NSDictionary*)dict];
        [prepareTable reloadData];
    }
}

@end
