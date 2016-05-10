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

#define multiplier 667.f/[[UIScreen mainScreen] bounds].size.height
@interface MNAuthViewController ()<UITextFieldDelegate,MNSchedulePreparingDelegate,UIScrollViewDelegate,MNAPIHTTPDelegate>
{
    CGFloat offsetHeight;
    CGRect kbRect;
    CGFloat kbHeight;
    bool validUsername;
    MNHTTPAPI *api;
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
    [api authUser:self.loginField.text andPassword:self.passField.text];
}
- (IBAction)reg_button:(id)sender {
    MNRegController *regContr = [MNAPI_Addition getViewControllerWithIdentifier:@"RegController"];
    regContr.username = self.loginField.text;
    regContr.password = self.passField.text;
    [self presentViewController:regContr animated:YES completion:^{
        [api getInfo];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    CGFloat t = multiplier;
    CGFloat tt = t <= 1 ? t : t * 2.3;
    offsetHeight = textField.bounds.origin.y + textField.bounds.size.height + 60 * tt;
    [scrollView setContentOffset:CGPointMake(0,offsetHeight) animated:YES];
}
- (void) textFieldDidChange:(NSNotification *)notification
{
    if (self.loginField.text.length >= 3) {
        [api checkUsername:self.loginField.text];
    }
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
- (void) MNHTTPDidRecieveAuthSuccess:(MNHTTPAPI *)aapi andToken:(NSString *)token
{
    [MNAPI_Addition setObjectTONSUD:token withKey:@"device_token"];
    [MNAPI_Addition setObjectTONSUD:@true withKey:@"authed"];
    [api getInfo];
    [self dismissViewControllerAnimated:NO completion:^{
        
    }];
}
- (void) MNHTTPError
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Ошибка сети" message:@"Не удалось авторизоваться. Попробуйте позднее или проверьте сетевое соединение" delegate:self cancelButtonTitle:@"Хорошо" otherButtonTitles:nil];
    [alertView show];
}
@end
