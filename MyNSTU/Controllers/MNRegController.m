//
//  MNRegController.m
//  MyNSTU
//
//  Created by Дмитрий Богомолов on 09.05.16.
//  Copyright © 2016 Дмитрий Богомолов. All rights reserved.
//

#import "MNRegController.h"
#import "MNHTTPAPI.h"
#import "MNAPI+Addition.h"
#import "MNAuthTextField.h"
#define multiplier 667.f/[[UIScreen mainScreen] bounds].size.height
@interface MNRegController ()<UITextFieldDelegate,UIScrollViewDelegate,MNAPIHTTPDelegate>
{
    CGFloat offsetHeight;
    CGRect kbRect;
    CGFloat kbHeight;
    bool validUsername;
    MNHTTPAPI *api;
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet MNAuthTextField *nameField;
@property (weak, nonatomic) IBOutlet MNAuthTextField *surnameField;
@property (weak, nonatomic) IBOutlet MNAuthTextField *emailField;

@end

@implementation MNRegController
@synthesize scrollView;


- (void)viewDidLoad {
    [super viewDidLoad];
    api = [MNHTTPAPI new];
    api.delegate = self;
    self.nameField.delegate = self;
    self.surnameField.delegate = self;
    self.emailField.delegate = self;
    [self registerForKeyboardNotifications];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(screenTapped:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.scrollView addGestureRecognizer:tapGestureRecognizer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkForEmail:) name:UITextFieldTextDidChangeNotification object:self.emailField];
}
- (IBAction)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)reg:(id)sender {
    [api regUser:_username andPassword:_password  andName:self.nameField.text andSurname:self.surnameField.text andEmail:self.emailField.text];
    [MNAPI_Addition setObjectTONSUD:@"close" withKey:@"sch"];
    UINavigationController *nav = [MNAPI_Addition getViewControllerWithIdentifier:@"SchedulePrep"];
    [self presentViewController:nav animated:YES completion:^{
//        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
}
- (void) screenTapped: (id) sender{
    [[self view] endEditing:YES];
    [scrollView setContentOffset:CGPointMake(0,0) animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) checkForEmail:(NSNotification *)notification
{
    if (self.emailField.text.length >= 3) {
        NSLog(@"email check: %d",self.emailField.text.isValidEmail);
    }
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
#pragma mark - MNHTTPAPI delegate
- (void) MNHTTPError
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Ошибка сети" message:@"Не удалось зарегестрироваться. Попробуйте поздее или проверьте сетевое соединение" delegate:self cancelButtonTitle:@"Хорошо" otherButtonTitles:nil];
    [alertView show];
}

- (void) MNHTTPDidRecieveRegFail:(MNHTTPAPI *)api andReason:(NSString *)reason
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Ошибка регистрации" message:reason delegate:self cancelButtonTitle:@"Хорошо" otherButtonTitles:nil];
    [alertView show];
}

- (void) MNHTTPDidRecieveRegSuccess:(MNHTTPAPI *)api andToken:(NSString *)token
{
    [MNAPI_Addition setObjectTONSUD:token withKey:@"device_token"];
    [MNAPI_Addition setObjectTONSUD:@true withKey:@"authed"];
}


@end
