//
//  MNNewsListController.m
//  MyNSTU
//
//  Created by Дмитрий Богомолов on 22.08.15.
//  Copyright (c) 2015 Дмитрий Богомолов. All rights reserved.
//

#import "MNNewsListController.h"
#import "MNNewsTextCell.h"
#import "MNBannerScrollView.h"
#import "MNAPI+Addition.h"
#import "MNHTTPAPI.h"
#import "IQSideMenuController.h"
#import "MNNewsDetailController.h"
#import "MBProgressHUD.h"
#import "REMenu.h"
#import "UIScrollView+InfiniteScroll.h"
//#import "AFNetworking.h"
#import <QuartzCore/QuartzCore.h>
#import "AFNetworking.h"


#define banner_ratio 16*9
//#define banner_ratio 220*160
#define ind_size 50.f
//#define banner_ratio 220*140
@interface MNNewsListController ()<UITableViewDataSource,UITableViewDelegate,MNAPIHTTPDelegate,MBProgressHUDDelegate,REMenuDelegate>
{
    id _bannerData;
    MNHTTPAPI *api;
    NSMutableArray *newsList;
    NSMutableDictionary *heightDict;
    NSMutableDictionary *heightDictFavourites;
    MNBannerScrollView *bannerView;
    MBProgressHUD *hud;
    MNNewsType currentType;
    NSMutableArray *favoutiteList;
    UIActivityIndicatorView *newsIndicator;
}
@property (strong, readwrite, nonatomic) REMenu *menu;
@property (weak, nonatomic) IBOutlet UIButton *menuButton;
@property (strong, nonatomic) IBOutlet UITableView *newsTable;

@end

@implementation MNNewsListController
@synthesize newsTable,menuButton;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Новости";
    currentType = NewsNSTU;
    heightDict = [NSMutableDictionary new];
    heightDictFavourites = [NSMutableDictionary new];
    newsList = [NSMutableArray new];
    api = [MNHTTPAPI new];
    api.delegate = self;
    self.clearsSelectionOnViewWillAppear = NO;
    newsTable.delegate = self;
    newsTable.dataSource = self;
    if (bannerView == nil) {
        bannerView = [[MNBannerScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, (self.view.frame.size.width/banner_ratio))];
        bannerView.backgroundColor = [UIColor whiteColor];
        bannerView.newsContr = self;
    }
    [self.newsTable insertSubview:bannerView aboveSubview:self.newsTable];
    [self.newsTable bringSubviewToFront:bannerView];
    self.newsTable.tableFooterView = [UIView new];
    
    //UItableview indicator
    newsIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    newsIndicator.color = [UIColor grayColor];
    [newsIndicator setFrame:CGRectMake(newsTable.frame.size.width/2-ind_size/2, newsTable.frame.size.height/2-ind_size/2, ind_size, ind_size)];
    newsIndicator.hidden = NO;
    [newsIndicator startAnimating];
    [self.newsTable addSubview:newsIndicator];
    [api getBanners];
    [self loadFirst];
    //news appearance
    
    REMenuItem *newsItem = [[REMenuItem alloc] initWithTitle:@"Новости"
                                                       image:nil
                                            highlightedImage:nil
                                                      action:^(REMenuItem *item) {
                                                          currentType = NewsNSTU;
                                                          [bannerView setHidden:NO];
                                                          [self loadFirst];
                                                          [self.menuButton setTitle:@"Новости" forState:UIControlStateNormal];
                                                          [self insertRefresh];
                                                          [self.refreshControl beginRefreshing];
                                                      }];
    
    REMenuItem *favouriteItem = [[REMenuItem alloc] initWithTitle:@"Избранное"
                                                           image:nil
                                                highlightedImage:nil
                                                          action:^(REMenuItem *item) {
                                                              currentType = News_favourite;
                                                              self.refreshControl = nil;
                                                              [bannerView setHidden:YES];
                                                              [self readFile];
                                                              [self.newsTable reloadData];
                                                              [self.menuButton setTitle:@"Избранное" forState:UIControlStateNormal];
                                                          }];
    newsItem.tag = 0;
    favouriteItem.tag = 1;
    
    self.menu = [[REMenu alloc] initWithItems:@[newsItem, favouriteItem]];
    self.menu.backgroundView.backgroundColor = [UIColor clearColor];
    self.menu.appearsBehindNavigationBar = NO;     self.menu.liveBlur = YES;
    self.menu.liveBlurBackgroundStyle = REMenuLiveBackgroundStyleLight;
    
    self.menu.separatorOffset = CGSizeMake(0.0, 0.0);
    self.menu.waitUntilAnimationIsComplete = NO;
    self.menu.delegate = self;
    
    
    [self.menu setClosePreparationBlock:^{
        [[IQSideMenuController getNowUsedController] disableOrEnableScroll];
    }];
    
    [self.menu setCloseCompletionHandler:^{
        [[IQSideMenuController getNowUsedController] disableOrEnableScroll];
    }];

    
    [self.menuButton addTarget:self action:@selector(menuShow:) forControlEvents:UIControlEventTouchUpInside];
    //Infinite scroll
    newsTable.infiniteScrollIndicatorStyle = UIActivityIndicatorViewStyleGray;
    [newsTable addInfiniteScrollWithHandler:^(id scrollView) {
        if (currentType == NewsNSTU)
            [api getNewsWithCount:20 andOffset:[newsList count]];
    }];
    //refresh control
    
    [self insertRefresh];
    // add button
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithImage:[MNAPI_Addition imageWithIcon:icon_navicon size:30.0f color:[UIColor whiteColor]] style:UIBarButtonItemStylePlain target:self action:@selector(leftButton)];
    leftBarButton.imageInsets = UIEdgeInsetsMake(0, -7.5f, 0, 0);
    self.navigationItem.leftBarButtonItem = leftBarButton;
}
- (void) insertRefresh{
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(loadFirst) forControlEvents:UIControlEventValueChanged];
}
- (void) leftButton{
    [MNAPI_Addition hideORShowLeftBar];
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    id test = [IQSideMenuController getNowUsedController];
    [[IQSideMenuController getNowUsedController] enableScroll];
    self.menuButton.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    self.menuButton.titleLabel.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    self.menuButton.imageEdgeInsets = UIEdgeInsetsMake(3.f,2.f, 0, 4.f);
    self.menuButton.imageView.transform = CGAffineTransformMakeScale(-1.0, 1.0);
}
- (void) menuShow: (id) sender
{
    if (self.menu.isOpen)
        return [self.menu close];
    
    [self.menu showFromNavigationController:self.navigationController];

}
- (void) loadFirst
{
    [api getBanners];
    if (currentType == News_favourite)
        return;
    NSString *filePath = [[UIApplication applicationDocumentDirectory] stringByAppendingString:@"/news.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        [self readFile];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.newsTable reloadData];
            newsIndicator.hidden = YES;
            [newsIndicator stopAnimating];
        });
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:[NSString stringWithFormat:@"%@2/get_news?count=20",SERVER_ADDRESS] parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            if ([newsList count] > 0) {
                if (![responseObject[0][@"id"] isEqual:newsList[0][@"id"]]) {
                    for (id someObject in [responseObject reverseObjectEnumerator])
                    {
                        if(((NSNumber*)someObject[@"id"]).intValue > ((NSNumber*)newsList[0][@"id"]).intValue)
                        {
                            [newsList insertObject:someObject atIndex:0];
                        }
                    }
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.refreshControl endRefreshing];
                        newsIndicator.hidden = YES;
                        [newsIndicator stopAnimating];
                    });
                    return;
                }
            }
            newsList = [NSMutableArray arrayWithArray:responseObject];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.refreshControl endRefreshing];
                [self.newsTable reloadData];
                [self saveFile];
                newsIndicator.hidden = YES;
                [newsIndicator stopAnimating];
            });
        });
        [self.newsTable reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.refreshControl endRefreshing];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Ошибка сети" message:@"Не удалось получить новости. Попробуйте поздее или проверьте сетевое соединение" delegate:self cancelButtonTitle:@"Хорошо" otherButtonTitles:nil];
        [alertView show];
        NSLog(@"%@",error);
    }];
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    [manager GET:[NSString stringWithFormat:@"%@2/get_news?count=20",SERVER_ADDRESS] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
//            if ([newsList count] > 0) {
//                if (![responseObject[0][@"id"] isEqual:newsList[0][@"id"]]) {
//                    for (id someObject in [responseObject reverseObjectEnumerator])
//                    {
//                        if(((NSNumber*)someObject[@"id"]).intValue > ((NSNumber*)newsList[0][@"id"]).intValue)
//                        {
//                            [newsList insertObject:someObject atIndex:0];
//                        }
//                    }
//                }
//                else {
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [self.refreshControl endRefreshing];
//                        newsIndicator.hidden = YES;
//                        [newsIndicator stopAnimating];
//                    });
//                    return;
//                }
//            }
//            newsList = [NSMutableArray arrayWithArray:responseObject];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.refreshControl endRefreshing];
//                [self.newsTable reloadData];
//                [self saveFile];
//                newsIndicator.hidden = YES;
//                [newsIndicator stopAnimating];
//            });
//        });
//        [self.newsTable reloadData];
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        [self.refreshControl endRefreshing];
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Ошибка сети" message:@"Не удалось получить новости. Попробуйте поздее или проверьте сетевое соединение" delegate:self cancelButtonTitle:@"Хорошо" otherButtonTitles:nil];
//        [alertView show];
//        NSLog(@"%@",error);
//    }];
}
- (void) saveFile{
    if (currentType == NewsNSTU) {
        [[NSKeyedArchiver archivedDataWithRootObject:newsList] writeToFile:[NSString stringWithFormat:@"%@/news.plist", [UIApplication applicationDocumentDirectory]] atomically:YES];
    }
    else if(currentType == News_favourite){
        [[NSKeyedArchiver archivedDataWithRootObject:favoutiteList] writeToFile:[NSString stringWithFormat:@"%@/news_favourite.plist", [UIApplication applicationDocumentDirectory]] atomically:YES];
    }
}
- (void) readFile{
    if (currentType == NewsNSTU) {
        newsList = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSData alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/news.plist", [UIApplication applicationDocumentDirectory] ]]];
    }else if(currentType == News_favourite){
        favoutiteList = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSData alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/news_favourite.plist", [UIApplication applicationDocumentDirectory] ]]];
    }
    
}

- (void) addNews{
    if ([newsList count] == 0) {
        [api getNewsWithCount:20 andOffset:0];
    }
    else
    {
        [api getNewsWithCount:20 andOffset:[newsList count]];
    }
}
- (void) MNAPIDidRecieveNews:(MNHTTPAPI *)api news:(NSArray *)news
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        if ([newsList count] > 0) {
            [newsList addObjectsFromArray:news];
            [self saveFile];
        }
        [self.newsTable reloadData];
        [self.newsTable finishInfiniteScroll];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - MNHTTPAPI
- (void) MNHTTPDidRecieveBanners:(MNHTTPAPI *)api andBanners:(id)banners{
    _bannerData = [banners copy];
    [bannerView setBannerData:_bannerData];
}
- (void) MNHTTPDidRecieveOneNews:(MNHTTPAPI *)api andOneNews:(id)news
{
    MNNewsDetailController *newsDetail = (MNNewsDetailController*)[MNAPI_Addition getViewControllerWithIdentifier:@"NewsDetailed"];
    [newsDetail setSubjectDictionary:news];
    [hud hide:YES];
    
    [[IQSideMenuController getNowUsedController] disableScroll];
    [self.navigationController pushViewController:newsDetail animated:YES];

}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (currentType == NewsNSTU)
        return [newsList count] + 1;
    else if(currentType == News_favourite)
        return [favoutiteList count];
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(currentType == NewsNSTU)
        if (indexPath.row == 0) {
            return (self.view.frame.size.width/banner_ratio);
        }
    return ((NSNumber*)heightDict[[NSNumber numberWithInteger:indexPath.row]]).floatValue;
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MNNewsDetailController *newsDetail = (MNNewsDetailController*)[MNAPI_Addition getViewControllerWithIdentifier:@"NewsDetailed"];
    if (currentType == NewsNSTU) {
        [newsDetail setSubjectDictionary:newsList[indexPath.row - 1]];
    }
    else if(currentType == News_favourite){
        [newsDetail setSubjectDictionary:favoutiteList[indexPath.row]];
    }
    [[IQSideMenuController getNowUsedController] disableScroll];
    [self.navigationController pushViewController:newsDetail animated:YES];
}
- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (currentType == NewsNSTU) {
        if (indexPath.row == 0) {
            return;
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            MNNewsTextCell *ccell = (MNNewsTextCell*)cell;
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSString *favouritesPath = [[UIApplication applicationDocumentDirectory] stringByAppendingPathComponent:@"/news_favourite.plist"];
            if ([fileManager fileExistsAtPath:favouritesPath isDirectory:NO]) {
                NSMutableArray *favoutiteListt = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSData alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/news_favourite.plist", [UIApplication applicationDocumentDirectory]]]];
                __block BOOL needReturn = NO;
                [favoutiteListt enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    if ([obj[@"id"] isEqual:newsList[indexPath.row - 1][@"id"]]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [ccell.favouriteButton setImage:[UIImage imageNamed:@"star_filled.png"] forState:UIControlStateNormal];
                        });
                        needReturn = YES;
                        *stop = YES;
                    }
                }];
                if (!needReturn) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [ccell.favouriteButton setImage:[UIImage imageNamed:@"star.png"] forState:UIControlStateNormal];
                    });
                }
            }
        });
    }
    
}
- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (currentType == News_favourite) {
        return YES;
    }
    return NO;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [favoutiteList removeObjectAtIndex:indexPath.row];
        [self saveFile];
        [tableView reloadData];
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(currentType == NewsNSTU)
        if (indexPath.row == 0) {
            MNNewsTextCell *tcell = [MNNewsTextCell new];
            tcell.backgroundColor = [UIColor whiteColor];
            return tcell;
        }
    MNNewsTextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewsText" forIndexPath:indexPath];
    if (cell == nil)
        cell = [MNNewsTextCell new];
    if ([newsList count] > 0)
    {
        NSDictionary *dictTemp = nil;
        if (currentType == NewsNSTU) {
            dictTemp = newsList[indexPath.row - 1];
        }
        else if(currentType == News_favourite){
            dictTemp = favoutiteList[indexPath.row];
        }
        cell.newsDict = dictTemp;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"dd.MM.yyyy"];
        NSArray *ar = [[dictTemp valueForKey:@"pubdate"] componentsSeparatedByString:@" "];
        cell.newsTitle.text = [dictTemp valueForKey:@"title"];
        cell.newsPubdate.text = ar[0];
        
        CGRect textRect = [self rectByLabel:cell.newsTitle];
        [cell.newsTitle setFrame:textRect];
        CGRect dateRect = cell.newsPubdate.frame;
        dateRect.origin.y = textRect.origin.y + 5 + textRect.size.height;
        [cell.newsPubdate setFrame:dateRect];
        [heightDict setObject:[NSNumber numberWithInt:dateRect.origin.y+5+dateRect.size.height] forKey:[NSNumber numberWithInt:indexPath.row]];
    }
    if (currentType == NewsNSTU) {
        [cell.favouriteButton setHidden:NO];
    }else if(currentType == News_favourite){
        [cell.favouriteButton setHidden:YES];
    }
    return cell;
    
}
- (CGRect) rectByLabel:(UILabel*) label
{
    CGSize maximumLabelSize = CGSizeMake(self.view.frame.size.width-10, FLT_MAX);
    
    CGSize expectedLabelSize = [label.text sizeWithFont:label.font constrainedToSize:maximumLabelSize lineBreakMode:label.lineBreakMode];
    
    //adjust the label the the new height.
    CGRect newFrame = label.frame;
    newFrame.size.height = expectedLabelSize.height;
    return newFrame;
}
- (void) goToNews:(NSInteger)newsId
{
    hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:hud];
    hud.delegate = self;
    hud.labelText = @"Загрузка";
    hud.detailsLabelText = @"Загружаю новость";
    [hud show:YES];

    [api getOneNews:[NSString stringWithFormat:@"%ld",(long)newsId]];
}

@end
