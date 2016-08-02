//
//  MNMapViewController.m
//  MyNSTU
//
//  Created by Дмитрий Богомолов on 01.08.16.
//  Copyright © 2016 Дмитрий Богомолов. All rights reserved.
//

#import "MNMapViewController.h"
#import "MNAPI+Addition.h"
#import "MNHTTPAPI.h"
#import "IQSideMenuController.h"
@interface MNMapViewController ()

@end

@implementation MNMapViewController
@synthesize mapWebView;
- (void)viewDidLoad {
    self.title = @"Карта";
    [super viewDidLoad];
    NSString *filePath=[[NSBundle mainBundle]pathForResource:@"map" ofType:@"html" inDirectory:nil];
    
    NSLog(@"%@",filePath);
//    NSString *htmlstring=[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    [mapWebView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:filePath]]];
    // Do any additional setup after loading the view.
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithImage:[MNAPI_Addition imageWithIcon:icon_navicon size:30.0f color:[UIColor whiteColor]] style:UIBarButtonItemStylePlain target:self action:@selector(leftButton)];
    leftBarButton.imageInsets = UIEdgeInsetsMake(0, -7.5f, 0, 0);
    self.navigationItem.leftBarButtonItem = leftBarButton;
}
- (void) leftButton{
    [MNAPI_Addition hideORShowLeftBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
