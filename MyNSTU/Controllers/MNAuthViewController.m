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
#import "MNRegController.h"
#import "MNHTTPAPI.h"
#import "MNAuthButton.h"
#import "MNScheduleDiscChooser.h"
#define multiplier 667.f/[[UIScreen mainScreen] bounds].size.height
@interface MNAuthViewController ()<UITextFieldDelegate,MNSchedulePreparingDelegate,UIScrollViewDelegate,MNAPIHTTPDelegate>
{
    CGFloat offsetHeight;
    CGRect kbRect;
    CGFloat kbHeight;
    bool validUsername;
    MNHTTPAPI *api;
    id _userData;
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet MNAuthButton *regButton;
@property (weak, nonatomic) IBOutlet UIButton *guestButt;

@end

@implementation MNAuthViewController
@synthesize scrollView,regButton;
- (void)viewDidLoad {
    [super viewDidLoad];
    api = [MNHTTPAPI new];
    api.delegate = self;
    self.loginField.delegate = self;
    self.passField.delegate = self;
    self.loginField.tag = 1;
    [self registerForKeyboardNotifications];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(screenTapped:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.scrollView addGestureRecognizer:tapGestureRecognizer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:self.loginField];
}
- (void) screenTapped: (id) sender{
    [[self view] endEditing:YES];
    [scrollView setContentOffset:CGPointMake(0,0) animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)authButton:(id)sender {
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Авторизуюсь";
    [api authUser:self.loginField.text andPassword:self.passField.text];
}
- (IBAction)reg_button:(id)sender {
    MNRegController *regContr = [MNAPI_Addition getViewControllerWithIdentifier:@"RegController"];
    regContr.username = self.loginField.text;
    regContr.password = self.passField.text;
    [self presentViewController:regContr animated:YES completion:nil];
    
//    [self dismissViewControllerAnimated:NO completion:nil];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    CGFloat t = multiplier;
    CGFloat tt = t <= 1 ? t : t * powf(2.3,1.4);
    offsetHeight = textField.bounds.origin.y + textField.bounds.size.height + 50 * tt;
    [scrollView setContentOffset:CGPointMake(0,offsetHeight) animated:YES];
}
- (void) textFieldDidChange:(NSNotification *)notification
{
    if (self.loginField.text.length >= 3) {
        [api checkUsername:self.loginField.text];
    }
}
- (IBAction)guestButton:(id)sender {
    [MNAPI_Addition setObjectTONSUD:@"close" withKey:@"sch"];
    UINavigationController *nav = [MNAPI_Addition getViewControllerWithIdentifier:@"SchedulePrep"];
    [self presentViewController:nav animated:YES completion:^{
        //        [self dismissViewControllerAnimated:YES completion:nil];
    }];
//    UINavigationController *contr = [MNAPI_Addition getViewControllerWithIdentifier:@"PrepareNavigation"];
//    MNPrepareScheduleTableViewController *needContr = [contr.viewControllers firstObject];
//    needContr.delegate = self;
//    needContr._wind = self._wind;
//    needContr.prepareStage = MNGetFaculty;
//    [self presentViewController:contr animated:YES completion:^{
//        
//    }];
//    
}
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    kbHeight =  kbSize.height;
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
    [scrollView setContentOffset:CGPointMake(0,offsetHeight) animated:YES];

}
#pragma mark - MNSchedulePreparingDelegate
- (void) MNSchedulePreparingFinishing:(BOOL)finished
{
    if (finished) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}
#pragma mark - MNHTTPAPI delegate
- (void) MNHTTPDidRecieveCheckUsernameResult:(MNHTTPAPI *)api andResult:(bool)result
{
    validUsername = result;
}
- (void) MNHTTPDidRecieveAuthFail:(MNHTTPAPI *)api
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Ошибка авторизации" message:@"Неверные данные логина/пароля" delegate:self cancelButtonTitle:@"Хорошо" otherButtonTitles:nil];
    [alertView show];
}
- (void) MNHTTPDidRecieveAuthSuccess:(MNHTTPAPI *)aapi andToken:(NSString *)token userData:(NSDictionary *)userData
{
    
    [MNAPI_Addition setObjectTONSUD:token withKey:@"device_token"];
    [MNAPI_Addition setObjectTONSUD:@true withKey:@"authed"];
    [MNAPI_Addition setObjectTONSUD:userData withKey:@"user_info"];
//    [api getInfo];
    _userData = userData;
    [api getScheduleFromGroup:userData[@"group"]];
    
    hud.labelText = @"Получаю расписание";
//    [self dismissViewControllerAnimated:NO completion:^{
//        
//    }];
}

- (void) MNHTTPDidRecieveSchedule:(MNHTTPAPI *)api andResults:(NSArray *)results andSemesterBegin:(NSString *)semesterBegin
{
    NSMutableArray *discArray = [NSMutableArray new];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [results enumerateObjectsUsingBlock:^(id day, NSUInteger idx, BOOL *stop) {
            [day enumerateObjectsUsingBlock:^(id pair, NSUInteger idx, BOOL *stop) {
                NSDictionary *dict = @{ @"id" : pair[@"id"], @"description" : pair[@"name"], @"check": @1 };
                if(![discArray containsObject:dict])
                    [discArray addObject:dict];
            }];
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            MNScheduleDiscChooser *d_choose = [MNAPI_Addition getViewControllerWithIdentifier:@"DiscChooser"];
            d_choose.semester_begin = semesterBegin;
            d_choose.data_array = discArray;
            d_choose.days = results;
            d_choose.group_name = _userData[@"group"];
            [hud hide:YES];
            if(self.navigationController != nil){
                [self.navigationController pushViewController:d_choose animated:YES];
            }
            else{
                UINavigationController* nav = [MNAPI_Addition getViewControllerWithIdentifier:@"MYNSTU_NAVIGATION"];
                [nav pushViewController:d_choose animated:NO];
                [self presentViewController:nav animated:YES completion:^{
                    
                }];
            }
        });
    });
    
    
}

- (void) MNHTTPError
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Ошибка сети" message:@"Не удалось авторизоваться. Попробуйте позднее или проверьте сетевое соединение" delegate:self cancelButtonTitle:@"Хорошо" otherButtonTitles:nil];
    [alertView show];
}
@end
