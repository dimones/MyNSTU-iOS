//
//  MNScheduleDiscChooser.m
//  MyNSTU
//
//  Created by Дмитрий Богомолов on 14.02.16.
//  Copyright © 2016 Дмитрий Богомолов. All rights reserved.
//

#import "MNScheduleDiscChooser.h"
#import "MNAPI+Addition.h"
@interface MNScheduleDiscChooser ()<UITableViewDataSource,UITableViewDelegate>
{
    UISegmentedControl *seg_contr;
    NSMutableDictionary *rowSizes;
}
@end

@implementation MNScheduleDiscChooser
@synthesize discTable,data_array,days;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Дисциплины";
    rowSizes = [NSMutableDictionary new];
    discTable.delegate = self;
    discTable.dataSource = self;
    [self.discTable setFrame:CGRectMake(0, self.navigationController.navigationBar.frame.origin.y + 10, self.discTable.frame.size.width, self.discTable.frame.size.height - 40)];
    seg_contr = [[UISegmentedControl alloc] initWithFrame:CGRectMake(0, self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height, self.view.frame.size.width, 40)];
    [self.discTable addSubview:seg_contr];
    //    [seg_contr addTarget:self action:@selector(segmentSwitch:) forControlEvents:UIControlEventValueChanged];
    
    UIBarButtonItem *readyButton = [[UIBarButtonItem alloc] initWithTitle:@"Готово" style:UIBarButtonItemStylePlain target:self action:@selector(finish)];
    self.navigationItem.rightBarButtonItem = readyButton;
    [discTable reloadData];
    self.discTable.tableFooterView = [UIView new];
    
    discTable.estimatedRowHeight = 30.0;
    discTable.rowHeight = UITableViewAutomaticDimension;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) finish
{
    NSMutableArray *validDiscs = [NSMutableArray new];
    NSMutableArray *goodDiskArray = [NSMutableArray new];
    [data_array enumerateObjectsUsingBlock:^(id disc, NSUInteger idx, BOOL *stop) {
        NSNumber *check = disc[@"check"];
        if([check  isEqual: @1])
            [validDiscs addObject:@{ disc[@"id"]: disc[@"check"] }];
        [goodDiskArray addObject:@{ disc[@"id"] : disc[@"description"]}];
    }];
    
    NSString *plistPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"schedules.plist"];
    if(![[NSFileManager defaultManager] fileExistsAtPath:plistPath isDirectory:NO])
        [[NSFileManager defaultManager] createFileAtPath:plistPath contents:nil attributes:nil];
    NSData *data = [NSData dataWithContentsOfFile:plistPath];
    NSMutableDictionary *t = [[NSMutableDictionary alloc] initWithDictionary:[NSKeyedUnarchiver unarchiveObjectWithData:data]];
    NSMutableArray *newValDisc = [NSMutableArray new];
    [validDiscs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [newValDisc addObject:[obj allKeys][0]];
    }];
    
    if([t count] == 0)
    {
        [t setObject:self.group_name forKey:@"current"];
        NSArray *arr = @[ @{ @"name":self.group_name,@"semester_begin":self.semester_begin,@"valid_discs":newValDisc,
                             @"days":days ,@"good_discs":goodDiskArray , @"sub_group" : [NSNumber numberWithInt:seg_contr.selectedSegmentIndex]}];
        [t setObject:arr forKey:@"data"];
    }
    else
    {
        [t removeObjectForKey:@"current"];
        [t setObject:self.group_name forKey:@"current"];
        NSMutableArray *groupArray = [NSMutableArray arrayWithArray:t[@"data"]];
        [groupArray addObject:@{ @"name":self.group_name,@"semester_begin":self.semester_begin,@"valid_discs":newValDisc,
                                 @"days":days ,@"good_discs":goodDiskArray, @"sub_group" : [NSNumber numberWithInt:seg_contr.selectedSegmentIndex]}];
    }
    NSData *datad = [NSKeyedArchiver archivedDataWithRootObject:t];
    [datad writeToFile:plistPath atomically:YES];
    [MNAPI_Addition changeContentViewControllerWithName:@"ScheduleController"];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.data_array count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DiscCell" forIndexPath:indexPath];
    if (cell==nil) {
        cell = [UITableViewCell new];
    }
    cell.translatesAutoresizingMaskIntoConstraints = YES;
    cell.textLabel.text = data_array[indexPath.row][@"description"];
    NSNumber *checked = data_array[indexPath.row][@"check"];
    cell.textLabel.numberOfLines = 0;
    if([checked  isEqual: @1])
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:data_array[indexPath.row]];
    NSNumber *checked = dict[@"check"];
    if([checked  isEqual: @1])
        checked = @0;
    else
        checked = @1;
    [dict removeObjectForKey:@"check"];
    [dict setObject:checked forKey:@"check"];
    [data_array replaceObjectAtIndex:indexPath.row withObject:(NSDictionary*)dict];
    [discTable reloadData];
    // [self.discTable deselectRowAtIndexPath:indexPath animated:NO];
    
}

@end
