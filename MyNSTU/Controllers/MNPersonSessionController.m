//
//  MNPersonSessionController.m
//  MyNSTU
//
//  Created by Дмитрий Богомолов on 04.09.15.
//  Copyright (c) 2015 Дмитрий Богомолов. All rights reserved.
//

#import "MNPersonSessionController.h"
#import "MNPersonsTabController.h"
#import "MNAPI+Addition.h"
#import "MNSessCell.h"
#import "MNRedHeaderTableViewCell.h"
@interface MNPersonSessionController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *sess_o;
    NSMutableArray *sess_z;
    BOOL isSessZ;
    NSDictionary *pairDict;
    NSMutableDictionary *heightDict;
}
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@end

@implementation MNPersonSessionController
@synthesize sessTable;
- (void)viewDidLoad {
    heightDict = [NSMutableDictionary new];
    pairDict =  @{ @"1":@"08:30",@"2":@"10:10",
                   @"3":@"11:50",@"4":@"13:45",
                   @"5":@"15:25",@"6":@"17:05",
                   @"7":@"18:40",@"8":@"20:10"};
    [super viewDidLoad];
    isSessZ = false;
    self.sessTable.delegate = self;
    self.sessTable.dataSource = self;
    self.sessTable.tableFooterView = [UIView new];
    MNPersonsTabController * parentTab = (MNPersonsTabController*)self.parentViewController;
    parentTab.title = [MNAPI_Addition getObjectFROMNSUDWithKey:@"person_name"];
    isSessZ = false;
    [self initHelper];
    // Do any additional setup after loading the view.
}

- (void) initHelper {
    MNPersonsTabController * parentTab = (MNPersonsTabController*)self.parentViewController;
    NSNumber *idPerson = parentTab.personID;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"details" ofType:@"json"];
        id personObj = [MNAPI_Addition JSONObjectFromFile:filePath];
        sess_o = [personObj[idPerson][@"sess_o"] copy];
        sess_z = [personObj[idPerson][@"sess_z"] copy];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.sessTable reloadData];
        });
    });
    isSessZ = false;
}
- (IBAction)segmentChanged:(id)sender {
    switch (self.segmentControl.selectedSegmentIndex) {
        case 0:
        {
            isSessZ = false;
        }
            break;
        case 1:
        {
            isSessZ = true;
        }
            break;
            
        default:
            break;
    }
    [self.sessTable reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(isSessZ)
        return [[((NSMutableDictionary*)sess_z) allKeys] count];
    else return [[((NSMutableDictionary*)sess_o) allKeys] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(isSessZ)
        return  [([((NSMutableDictionary*)sess_z) allValues][section]) count];
    else return [([((NSMutableDictionary*)sess_o) allValues][section]) count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MNSessCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SessCell" forIndexPath:indexPath];
    if(!cell)
    {
        cell = [MNSessCell new];
    }
    if(isSessZ)
    {
        if ([([((NSMutableDictionary*)sess_z) allValues][indexPath.section]) count] > 0) {
            id dict = ([((NSMutableDictionary*)sess_z) allValues][indexPath.section]);
            id name = dict[indexPath.row][@"description"][@"full_name"];
            if(name==nil) name = @"Экзамен";
            cell.nameLabel.text = name;
            cell.timeLabel.text = pairDict[dict[indexPath.row][@"pair"]];
            cell.audienceLabel.text = dict[indexPath.row][@"room"];
            [cell.timeLabel setTextColor:[UIColor grayColor]];
            [cell.audienceLabel setTextColor:[UIColor grayColor]];
            
        }
    }
    else
    {
        if ([([((NSMutableDictionary*)sess_o) allValues][indexPath.section]) count] > 0) {
            id dict = ([((NSMutableDictionary*)sess_o) allValues][indexPath.section]);
            id name = pairDict[dict[indexPath.row][@"pair_number"]];
            if(name == nil) name = @"Экзамен";
            cell.nameLabel.text = dict[indexPath.row][@"name"];
            cell.timeLabel.text = name;
            cell.audienceLabel.text = dict[indexPath.row][@"room"];
            [cell.timeLabel setTextColor:[UIColor grayColor]];
            [cell.audienceLabel setTextColor:[UIColor grayColor]];
        }
    }
    [cell.timeLabel setFrame:[MNAPI_Addition rectByLabel:cell.timeLabel andMaxWidth:self.view.frame.size.width-20]];
    [heightDict setObject:[NSNumber numberWithFloat:cell.timeLabel.frame.size.height + cell.timeLabel.frame.origin.y + 5] forKey:[NSNumber numberWithInteger:indexPath.row]];
    [cell setNeedsLayout];
    [cell setNeedsDisplay];
    return cell;
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
    NSString *dateStringBefore;
    if(isSessZ)
        dateStringBefore = [((NSMutableDictionary*)sess_z) allKeys][section];
    else dateStringBefore = [((NSMutableDictionary*)sess_o) allKeys][section];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    //[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setDateFormat:@"dd.MM.yy"];
    NSDate *date = [dateFormatter dateFromString:dateStringBefore];
    //date = date dateByAddingTimeInterval:86400
    NSDateFormatter *format = [[NSDateFormatter alloc] init ];
    [format setDateStyle:NSDateFormatterLongStyle];
    format.locale = [NSLocale currentLocale];
    [format setDateFormat:@"dd LLLL"];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
    NSString *string = [NSString stringWithFormat:@"%ld %@",(long)[components day], [format shortMonthSymbols][[components month]]];
    if(isSessZ)
        cell.redLabel.text = string;
    else cell.redLabel.text = string;
    [cell setBackgroundColor:[UIColor colorFromHexString:@"E53935"]];
    
    return cell;
}
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 32;
}
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ((NSNumber*)heightDict[[NSNumber numberWithInteger:indexPath.row]]).floatValue;
}

@end
