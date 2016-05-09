//
//  MNPersonsTabController.m
//  MyNSTU
//
//  Created by Дмитрий Богомолов on 02.09.15.
//  Copyright (c) 2015 Дмитрий Богомолов. All rights reserved.
//

#import "MNPersonsTabController.h"
#import "MNAPI+Addition.h"
@interface MNPersonsTabController ()

@end

@implementation MNPersonsTabController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithImage:[MNAPI_Addition imageWithIcon:icon_navicon size:30.0f color:[UIColor whiteColor]] style:UIBarButtonItemStylePlain target:self action:@selector(leftButton)];
    leftBarButton.imageInsets = UIEdgeInsetsMake(0, -7.5f, 0, 0);
    self.navigationItem.leftBarButtonItem = leftBarButton;
}
- (void) leftButton
{
    [MNAPI_Addition hideORShowLeftBar];
}
- (void) setBarTitle:(NSString*)string
{
    self.title = string;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
