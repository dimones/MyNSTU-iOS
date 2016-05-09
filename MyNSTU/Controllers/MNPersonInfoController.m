//
//  MNPersonInfoController.m
//  MyNSTU
//
//  Created by Дмитрий Богомолов on 02.09.15.
//  Copyright (c) 2015 Дмитрий Богомолов. All rights reserved.
//

#import "MNPersonInfoController.h"
#import "MNPersonInfoCell.h"
#import "MNPersonsTabController.h"
#import "MNAPI+Addition.h"
@interface MNPersonInfoController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSDictionary *personInfo;
    NSMutableDictionary *heightDict;
    NSString *FIO;
    NSString *post;
}
@property (weak, nonatomic) IBOutlet UIImageView *personImgBackground;
@property (weak, nonatomic) IBOutlet UILabel *personSurname;
@property (weak, nonatomic) IBOutlet UITableView *personTable;
@property (weak, nonatomic) IBOutlet UILabel *personRank;
@property (weak, nonatomic) IBOutlet UIImageView *personImgPhoto;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *personLastName;
@end

@implementation MNPersonInfoController
@synthesize personImgBackground,personImgPhoto,personLastName,personRank,personSurname,personTable;
- (void)viewDidLoad {
    [super viewDidLoad];
    heightDict = [NSMutableDictionary new];
    self.personTable.delegate = self;
    self.personTable.dataSource = self;
    self.personTable.tableFooterView = [UIView new];
    // Do any additional setup after loading the view.
}
- (void)viewDidAppear:(BOOL)animated {
    MNPersonsTabController * parentTab = (MNPersonsTabController*)self.parentViewController;
    parentTab.title = @"Информация";
    [super viewDidAppear:animated];
    [self initData];
    
}
- (void) loadDatas
{
    //Images
    UIImage *background = [[MNAPI_Addition getImageFromID:[NSString stringWithFormat:@"%@", personInfo[@"id"]]] blurredImage:.3f];
    self.personImgBackground.clipsToBounds = YES;
    self.personImgBackground.image = background;
    UIImage *persIm = [MNAPI_Addition getImageFromID:[NSString stringWithFormat:@"%@", personInfo[@"id"]]];
    
    persIm = [MNAPI_Addition scaleTheImage:persIm andRect:self.personImgPhoto.frame.size];
    [self.personImgPhoto setImage:persIm];
    self.personImgPhoto.layer.cornerRadius = self.personImgPhoto.frame.size.width/2;
    self.personImgPhoto.layer.masksToBounds = YES;
    //Name
    NSArray *nameArray = [FIO componentsSeparatedByString:@" "];
    self.personSurname.text = nameArray[0];
    self.personLastName.text = [NSString stringWithFormat:@"%@ %@",nameArray[1],nameArray[2]];
    //Job
    
    self.personRank.text = [[post lowercaseString] stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[NSString stringWithFormat:@"%C",[post characterAtIndex:0]]];
    NSArray *splitOtherName = [personInfo[@"name"] componentsSeparatedByString: @" "];
    NSString *outString = [NSString stringWithFormat:@"%@ ",[splitOtherName objectAtIndex:0]];
    for(int i = 1;i<[splitOtherName count];i++)
    {
        NSString *partName = [[splitOtherName objectAtIndex:i] uppercaseString];
        outString = [NSString stringWithFormat:@"%@ %@.",outString,[NSString stringWithFormat:@"%C",[partName characterAtIndex:0]]];
    }
    [MNAPI_Addition setObjectTONSUD:outString withKey:@"person_name"];
}
- (void) initData
{
    MNPersonsTabController *parent = (MNPersonsTabController*)self.parentViewController;
    NSNumber *personID = parent.personID;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"persons" ofType:@"json"];
        id jsonObject = [MNAPI_Addition JSONObjectFromFile:filePath];
        FIO = jsonObject[personID][@"name"];
        post = jsonObject[personID][@"post"];
        filePath =[[NSBundle mainBundle] pathForResource:@"details" ofType:@"json"];
        jsonObject = [MNAPI_Addition JSONObjectFromFile:filePath];
        personInfo = jsonObject[personID][@"info"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.personTable reloadData];
            self.scrollView.contentInset = UIEdgeInsetsMake(60, 0, 50, 0);
            [self loadDatas];
        });
    });
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark - UITableView delegates
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ((NSNumber*)heightDict[[NSNumber numberWithInteger:indexPath.row]]).floatValue;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MNPersonInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MNInfoCell" forIndexPath:indexPath];
    if (!cell) {
        cell = [MNPersonInfoCell new];
    }
    switch (indexPath.row) {
        case 0:
        {
            id emailText = personInfo[@"phone"];
            if([emailText isKindOfClass:[NSNull class]])
            {
                emailText = @"Отсутствует";
            }
            cell.titleLabel.text = [NSString stringWithFormat:@"Телефон: %@", emailText];
            [cell.imgView setImage:[UIImage imageNamed:@"Photo.png"]];
            [cell.titleLabel setFrame:[MNAPI_Addition rectByLabel:cell.titleLabel andMaxWidth:self.view.frame.size.width - 30]];
            [heightDict setObject:[NSNumber numberWithFloat:cell.titleLabel.frame.size.height + 10 + cell.titleLabel.frame.origin.y] forKey:[NSNumber numberWithInteger:indexPath.row]];
        }
            break;
        case 1:
        {
            id emailText = personInfo[@"email"];
            if([emailText isKindOfClass:[NSNull class]])
            {
                emailText = @"Отсутствует";
            }
            cell.titleLabel.text = [NSString stringWithFormat:@"E-mail: %@", emailText];
            [cell.imgView setImage:[UIImage imageNamed:@"Mail.png"]];
            [cell.titleLabel setFrame:[MNAPI_Addition rectByLabel:cell.titleLabel andMaxWidth:self.view.frame.size.width - 30]];
            [heightDict setObject:[NSNumber numberWithFloat:cell.titleLabel.frame.size.height + 10 + cell.titleLabel.frame.origin.y] forKey:[NSNumber numberWithInteger:indexPath.row]];
        }
            break;
        case 2:
        {
            id emailText = personInfo[@"location"];
            if([emailText isKindOfClass:[NSNull class]])
            {
                emailText = @"Отсутствует";
            }
            cell.titleLabel.text = [NSString stringWithFormat:@"Расположение: %@", emailText];
            [cell.imgView setImage:[UIImage imageNamed:@"place.png"]];
            [cell.titleLabel setFrame:[MNAPI_Addition rectByLabel:cell.titleLabel andMaxWidth:self.view.frame.size.width - 30]];
            [heightDict setObject:[NSNumber numberWithFloat:cell.titleLabel.frame.size.height + 10 + cell.titleLabel.frame.origin.y] forKey:[NSNumber numberWithInteger:indexPath.row]];
        }
            break;
        case 3:
        {
            id emailText = personInfo[@"access_time"];
            if([emailText isKindOfClass:[NSNull class]])
            {
                emailText = @"Отсутствует";
            }
            cell.titleLabel.text = [NSString stringWithFormat:@"Расписание: %@", emailText];
            [cell.imgView setImage:[UIImage imageNamed:@"calendar_use.png"]];
            [cell.titleLabel setFrame:[MNAPI_Addition rectByLabel:cell.titleLabel andMaxWidth:self.view.frame.size.width - 30]];
            [heightDict setObject:[NSNumber numberWithFloat:cell.titleLabel.frame.size.height + 10 + cell.titleLabel.frame.origin.y] forKey:[NSNumber numberWithInteger:indexPath.row]];
        }
            break;
            
        default:
            break;
    }
    return cell;
}

@end
