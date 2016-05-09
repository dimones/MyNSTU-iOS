//
//  MNScheduleChooseFaculty.m
//  MyNSTU
//
//  Created by Дмитрий Богомолов on 14.02.16.
//  Copyright © 2016 Дмитрий Богомолов. All rights reserved.
//

#import "MNScheduleChooseFaculty.h"
#import "MBProgressHUD.h"
#import "MNScheduleChooseGroup.h"
@interface MNScheduleChooseFaculty ()<MBProgressHUDDelegate>
{    
    MNHTTPAPI *api;
    NSDictionary *facs;
    MBProgressHUD *hud;
    NSMutableArray *facsArray;
}

@end

@implementation MNScheduleChooseFaculty
@synthesize facultiesTable;
- (void)viewDidLoad {
    [super viewDidLoad];
    facsArray = [NSMutableArray new];
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Получаю список факультетов";
    api = [MNHTTPAPI new];
    api.delegate = self;
    self.facultiesTable.delegate = self;
    self.facultiesTable.dataSource = self;
    self.clearsSelectionOnViewWillAppear = YES;
    [facultiesTable reloadData];
    [api getFaculties];
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithImage:[MNAPI_Addition imageWithIcon:icon_navicon size:30.0f color:[UIColor whiteColor]] style:UIBarButtonItemStylePlain target:self action:@selector(leftButton)];
    leftBarButton.imageInsets = UIEdgeInsetsMake(0, -7.5f, 0, 0);
    self.navigationItem.leftBarButtonItem = leftBarButton;
    self.facultiesTable.tableFooterView = [UIView new];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) leftButton{
    [MNAPI_Addition hideORShowLeftBar];
}
-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[facs allKeys] count];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MNScheduleChooseGroup *gr_choose = [MNAPI_Addition getViewControllerWithIdentifier:@"GroupChoose"];
    gr_choose.groupsArray = facs[[facs allKeys][indexPath.row]];
    [self.navigationController pushViewController:gr_choose animated:YES];
    gr_choose.title = facsArray[indexPath.row];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FacultyCell" forIndexPath:indexPath];
    if (cell==nil) {
        cell = [UITableViewCell new];
    }
    cell.textLabel.text = facsArray[indexPath.row];
    return cell;
}

#pragma mark - MNHTTPAPI
- (void) MNHTTPDidRecieveFaculties:(MNHTTPAPI *)api andFacs:(id)faculties
{
    facs = faculties;
    [hud hide:YES];
    [[facs allKeys] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [facsArray addObject:obj];
    }];
    [self.facultiesTable reloadData];
}

@end
