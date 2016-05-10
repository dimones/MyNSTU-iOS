//
//  AppDelegate.m
//  MyNSTU
//
//  Created by Дмитрий Богомолов on 20.08.15.
//  Copyright (c) 2015 Дмитрий Богомолов. All rights reserved.
//

#import "AppDelegate.h"
#import "MNAPI+Addition.h"
#import "VKSdk.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "MNHTTPAPI.h"
//
#import "MNAuthViewController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //[YMMYandexMetrica startWithAPIKey:@"74261"];
    [VKSdk initializeWithDelegate:nil andAppId:@"4834072"];
    [application setStatusBarHidden:NO];
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    NSNumber *scheduleFinished = [MNAPI_Addition getObjectFROMNSUDWithKey:@"schedule_finished"];
    id sideController = [MNAPI_Addition getViewControllerWithIdentifier:@"SideController"];
    id contentViewController = [MNAPI_Addition getViewControllerWithIdentifier:@"NewsNavigation"];
    IQSideMenuController *sideMenuController = [[IQSideMenuController alloc] initWithMenuViewController:sideController
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
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                    didFinishLaunchingWithOptions:launchOptions];
}
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    if ([[FBSDKApplicationDelegate sharedInstance] application:application
                                                       openURL:url
                                             sourceApplication:sourceApplication
                                                    annotation:annotation]) {
        return YES;
    }
    if ([VKSdk processOpenURL:url fromApplication:sourceApplication]) {
        return YES;
    }
    return NO;
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
