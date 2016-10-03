//
//  AppDelegate.m
//  MyNSTU
//
//  Created by Дмитрий Богомолов on 20.08.15.
//  Copyright (c) 2015 Дмитрий Богомолов. All rights reserved.
//

#import "AppDelegate.h"
#import "MNAPI+Addition.h"


#import "MNHTTPAPI.h"
//
#import "MNAuthViewController.h"
@interface AppDelegate ()
{
    IQSideMenuController *sideMenuController;
}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    NSUserDefaults *myDefaults = [[NSUserDefaults alloc]
                                  initWithSuiteName:@"2F289RM9P6.group.com.mynstu.schedule"];
    [myDefaults setObject:@"ТЕСТОВОЕ СООБЩЕНИЕ" forKey:@"TEST"];
    [myDefaults synchronize];
    NSLog(@"COM YOPTA: %@", [myDefaults objectForKey:@"TEST"]);
    //[YMMYandexMetrica startWithAPIKey:@"74261"];
//    [VKSdk initializeWithDelegate:nil andAppId:@"4834072"];
    [application setStatusBarHidden:NO];
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    NSNumber *scheduleFinished = [MNAPI_Addition getObjectFROMNSUDWithKey:@"schedule_finished"];
    id sideController = [MNAPI_Addition getViewControllerWithIdentifier:@"SideController"];
    id contentViewController = [MNAPI_Addition getViewControllerWithIdentifier:@"NewsNavigation"];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(scheduleDismissed)
     name:@"ScheduleControllerDismissed"
     object:nil];
    sideMenuController = [[IQSideMenuController alloc] initWithMenuViewController:sideController
                                                                               andContentViewController:contentViewController];
    [MNAPI_Addition setObjectTONSUD:[NSNumber numberWithBool:YES] withKey:@"schedule_finished"];
    [self setWindow:[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]]];
    [[self window] setRootViewController:sideMenuController];
    [[self window] makeKeyAndVisible];
    if (![MNHTTPAPI isAuthed]){
    //if (scheduleFinished.boolValue) {
        MNAuthViewController *authContr = [MNAPI_Addition getViewControllerWithIdentifier:@"AuthController"];
        authContr.delegate = sideController;
        [sideMenuController presentViewController:authContr animated:YES completion:nil];
        authContr._wind = [self window];
    }
    
    sideMenuController.view.hidden = NO;
    return YES;
//    return [[FBSDKApplicationDelegate sharedInstance] application:application
//                                    didFinishLaunchingWithOptions:launchOptions];
}
- (void) scheduleDismissed{
    [sideMenuController dismissViewControllerAnimated:YES completion:nil];
}
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
//    if ([[FBSDKApplicationDelegate sharedInstance] application:application
//                                                       openURL:url
//                                             sourceApplication:sourceApplication
//                                                    annotation:annotation]) {
//        return YES;
//    }
//    if ([VKSdk processOpenURL:url fromApplication:sourceApplication]) {
//        return YES;
//    }
    return NO;
}
- (void) application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    
}
- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

@end
