//
//  MNAuthViewController.m
//  MyNSTU
//
//  Created by Дмитрий Богомолов on 20.08.15.
//  Copyright (c) 2015 Дмитрий Богомолов. All rights reserved.
//

#import "MNAuthViewController.h"
#import "MNPrepareScheduleTableViewController.h"
#import "MNAPI+Addition.h"
@interface MNAuthViewController ()<UITextFieldDelegate,MNSchedulePreparingDelegate>

@end

@implementation MNAuthViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.loginField.delegate = self;
    self.passField.delegate = self;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
- (IBAction)authButton:(id)sender {
    
}
- (IBAction)guestButton:(id)sender {
    UINavigationController *contr = [MNAPI_Addition getViewControllerWithIdentifier:@"PrepareNavigation"];
    MNPrepareScheduleTableViewController *needContr = [contr.viewControllers firstObject];
    needContr.delegate = self;
    needContr._wind = self._wind;
    needContr.prepareStage = MNGetFaculty;
    [self presentViewController:contr animated:YES completion:^{
        
    }];
    
}
#pragma mark - MNSchedulePreparingDelegate
- (void) MNSchedulePreparingFinishing:(BOOL)finished
{
    if (finished) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}
@end
