//
//  MNPersonsSearchController.m
//  MyNSTU
//
//  Created by Дмитрий Богомолов on 05.09.15.
//  Copyright (c) 2015 Дмитрий Богомолов. All rights reserved.
//

#import "MNPersonsSearchController.h"
#import "MNAPI+Addition.h"
#import "MNPersonsTabController.h"
#import "MNPersonSearchCell.h"
@interface MNPersonsSearchController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UISearchControllerDelegate>
{
    NSMutableArray *personsArray;
    NSMutableArray *imageArray;
    NSMutableArray *persallArray;
}

@end

@implementation MNPersonsSearchController

- (void)viewDidLoad {
    [super viewDidLoad];
    personsArray = [NSMutableArray new];
    persallArray = [NSMutableArray new];
    imageArray = [NSMutableArray new];
    self.searchBar.delegate = self;
    //
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithImage:[MNAPI_Addition imageWithIcon:icon_navicon size:30.0f color:[UIColor whiteColor]] style:UIBarButtonItemStylePlain target:self action:@selector(leftButton)];
    [leftBarButton setBackButtonBackgroundVerticalPositionAdjustment:-10 forBarMetrics:UIBarMetricsDefault];
    leftBarButton.imageInsets = UIEdgeInsetsMake(0, -7.5f, 0, 0);
    self.navigationItem.leftBarButtonItem = leftBarButton;
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    [leftBarButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor],  NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    //
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"persons" ofType:@"json"];
        NSData* responseObject = [NSData dataWithContentsOfFile:filePath];
        id jsonObject;
        NSError *jsonError = nil;
        if(responseObject!=nil)
            jsonObject= [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&jsonError];
        __block NSInteger index = 0;
        [[((NSDictionary*)jsonObject) allKeys] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            id t_obj = jsonObject[obj];
            NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
            f.numberStyle = NSNumberFormatterDecimalStyle;
            if(index<20)
            {
                [personsArray addObject:@{ @"name":t_obj[@"name"],@"id":[f numberFromString:obj] ,@"job_title":t_obj[@"post"]}];
                [persallArray addObject: @{ @"name":t_obj[@"name"],@"id":[f numberFromString:obj] ,@"job_title":t_obj[@"post"]}];
            }
            else
                [persallArray addObject: @{ @"name":t_obj[@"name"],@"id":[f numberFromString:obj] ,@"job_title":t_obj[@"post"]}];
            index++;
            
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.personsTable.delegate = self;
            self.personsTable.dataSource = self;
            [self.personsTable reloadData];
        });
    });

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)leftButton
{
    [MNAPI_Addition hideORShowLeftBar];
}
- (void) cleanResults
{
    [personsArray removeAllObjects];
    [self.personsTable reloadData];
}
#pragma mark - Public API
- (void) searchWithText:(NSString*)text
{
    NSLog(@"Search with: %@",text);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [personsArray removeAllObjects];
    });
    dispatch_queue_t backgroundQueue = dispatch_queue_create("dimones-dev.MyNSTU", 0);
    
    dispatch_async(backgroundQueue, ^{
        __block int countFind = 0;
        [persallArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSArray *compNames = [obj[@"name"] componentsSeparatedByString:@" "];
            __block BOOL isFinded = NO;
            [compNames enumerateObjectsUsingBlock:^(id _obj, NSUInteger _idx, BOOL *_stop) {
                if ([[_obj lowercaseString] hasPrefix:[text lowercaseString]]) {
                    isFinded = YES;
                    ++countFind;
                    [personsArray addObject:obj];
                    *_stop = YES;
                }
            }];
            dispatch_async(dispatch_get_main_queue(), ^{
                if(countFind >= 3)
                {
                    [self.personsTable reloadData];
                    countFind = 0;
                }
                
            });
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.personsTable reloadData];
        });
    });
}

- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if(self.searchBar.text.length >= 3)
        [self searchWithText:self.searchBar.text];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [personsArray count];
}
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MNPersonSearchCell *cell = (MNPersonSearchCell*)[tableView dequeueReusableCellWithIdentifier:@"PersonListCell" forIndexPath:indexPath];
    if (cell==nil) {
        cell = [MNPersonSearchCell new];
    }
    if([personsArray count]>0)
    {
        NSDictionary *dict = [personsArray objectAtIndex:[indexPath row]];
        cell.personFirstName.text = dict[@"name"];
        cell.personSecondName.text = [[dict[@"job_title"] lowercaseString] stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[NSString stringWithFormat:@"%C",[dict[@"job_title"] characterAtIndex:0]]];
        UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"%@.jpg",dict[@"id"]]];
        if(img!=nil)
        {
            [cell.personImage setImage:[MNAPI_Addition scaleTheImage:img andRect:CGSizeMake(50,50)]];//[self croppIngimageByImageName:image toRect:CGRectMake(0, 0, 50, 50)]];
            CGRect r = cell.personImage.frame;
            r.size = CGSizeMake(50,50);
            [cell.personImage setFrame:r];
            cell.personImage.layer.cornerRadius = 25;
            cell.personImage.layer.masksToBounds = YES;
        }
        else
        {
            [cell.personImage setImage:[MNAPI_Addition scaleTheImage:[UIImage imageNamed:@"profile_gray.png"] andRect:CGSizeMake(50,50)]];
            CGRect r = cell.personImage.frame;
            r.size = CGSizeMake(50,50);
            [cell.personImage setFrame:r];
            cell.personImage.layer.cornerRadius = 16;
            cell.personImage.layer.masksToBounds = YES;
        }
        [cell setNeedsDisplay];
    }
    else
    {
        UITableViewCell *ce = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TableViewCell"];
        ce.backgroundColor = [UIColor colorWithRed:29 green:29 blue:29 alpha:1.0];
        return ce;
    }
    return cell;
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *tDict = [personsArray objectAtIndex:[indexPath row]];
        UINavigationController *pDet = [MNAPI_Addition getViewControllerWithIdentifier:@"PersonDetail"];
        MNPersonsTabController *res = (MNPersonsTabController*)[pDet.viewControllers firstObject];
        res.personID = (NSNumber*)tDict[@"id"];
        [IQSideMenuController turnScroll];
        [MNAPI_Addition changeContentViewControllerWithController:pDet];
    });
}
@end
