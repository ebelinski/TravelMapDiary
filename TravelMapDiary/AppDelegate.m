//
//  AppDelegate.m
//  TravelMapDiary
//
//  Created by HHWS on 14/2/15.
//  Copyright (c) 2015 Eugene Belinski. All rights reserved.
//

#import "AppDelegate.h"
#import "MapViewController.h"
#import "SettingsViewController.h"
#import "ExploreViewController.h"
#import "Parse/Parse.h"

@interface AppDelegate () 

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    self.globalColor1 = [UIColor colorWithRed:0.533 green:0.769 blue:0.145 alpha:1];
    
    self.globalBarStyle = UIBarStyleDefault;
    
    [Parse setApplicationId:@"rzeegJPeQW2LJ58oZCqdgDOuZN6kiMGEgi6oA5pq"
                  clientKey:@"J0ruJpPz0XlQoKE3zA0CmBxFIlL25a6tq7tUzFyx"];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    NSUUID *oNSUUID = [[UIDevice currentDevice] identifierForVendor];
    self.userDeviceID = [NSString stringWithString:[oNSUUID UUIDString]];
    
    // Login to Parse
    self.currentUser = [PFUser currentUser];
    if (!self.currentUser) {
        PFUser *user = [PFUser user];
        
        user.username = self.userDeviceID;
        user.password = @"password";
        
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                // Assume the error is because the user already existed.
                [PFUser logInWithUsername:self.userDeviceID password:@"password"];
            } else {
                self.currentUser = [PFUser currentUser];
            }
        }];
    }
    
    MapViewController *map = [[MapViewController alloc] init];
    UINavigationController *mapNav = [[UINavigationController alloc] initWithRootViewController:map];
    
    ExploreViewController *explore = [[ExploreViewController alloc] init];
    UINavigationController *exploreNav = [[UINavigationController alloc] initWithRootViewController:explore];
    
    SettingsViewController *settings = [[SettingsViewController alloc] init];
    UINavigationController *settingsNav = [[UINavigationController alloc] initWithRootViewController:settings];
    
    [mapNav.navigationBar setBarStyle:self.globalBarStyle];
    [exploreNav.navigationBar setBarStyle:self.globalBarStyle];
    [settingsNav.navigationBar setBarStyle:self.globalBarStyle];
    
    
    [mapNav.navigationBar setTintColor:self.globalColor1];
    [exploreNav.navigationBar setTintColor:self.globalColor1];
    [settingsNav.navigationBar setTintColor:self.globalColor1];
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers = @[mapNav, exploreNav, settingsNav];
    
    
    [tabBarController.tabBar setTintColor:self.globalColor1];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = tabBarController;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
