//
//  RAAppDelegate.m
//  Rally
//
//  Created by Max de Vere on 27/08/2014.
//  Copyright (c) 2014 NA. All rights reserved.
//



#import "RAAppDelegate.h"
#import "RA_ParseUser.h"
#import "RA_LocationSingleton.h"
#import "RA_FacebookLoginComms.h"
#import "RA_GamePrefConfig.h"



@implementation RAAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    COMMON_LOG
    
    // Parse credentials
    [Parse setApplicationId:@"GC47Noqr8CDojxqdBTPPr5tBVHl6d5DlqO01URpf"
                  clientKey:@"Top3pQFivnsXSnpGuHuYJEryqZkZHjcQYmoHoHbJ"];
    
    // Used for Parse tracking
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    // Hack to avoid Parse bug, 'Unknown class PFImageView in Interface Builder file.'
    // See http://stackoverflow.com/a/20933480/3364933
    [PFImageView class];
    
    // Parse's Facebook Utilities singleton
    [PFFacebookUtils initializeFacebook];
    
    // Register for Push Notitications, if running iOS 8
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                        UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                 categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    } else {
        // Register for Push Notifications before iOS 8
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                         UIRemoteNotificationTypeAlert |
                                                         UIRemoteNotificationTypeSound)];
    }

    // Other singletons
    // No need really to do this here, as these will initialise just fine one first calling anyway
    [RA_FacebookLoginComms commsManager];
    [RA_LocationSingleton locationSingleton];
    [RA_GamePrefConfig gamePrefConfig];
    
    // Set appearance of navigation bar(s) and status bar for whole app:
    [[UINavigationBar appearance] setBarTintColor:UIColorFromRGB(RA_NAVBAR_COLOUR)];
    [[UINavigationBar appearance] setTintColor:UIColorFromRGB(RA_NAVBAR_TEXT_COLOUR)];
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                        UIColorFromRGB(RA_NAVBAR_TEXT_COLOUR), NSForegroundColorAttributeName,
                    [UIFont fontWithName:@"Gill Sans" size:20.0], NSFontAttributeName, nil]];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // Determine initial view
    // http://stackoverflow.com/a/12799462/3364933
    BOOL isLoggedIn = ([RA_ParseUser currentUser] &&
                       [PFFacebookUtils isLinkedWithUser:[RA_ParseUser currentUser]]);
    NSString *storyboardId = isLoggedIn ? @"initialtabview" : @"loginview";
    self.window.rootViewController = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:storyboardId];
    
    // Required BOOL response
    return YES;
}



// Pasted from parse.com
-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[ @"global" ];
    currentInstallation[@"user"] = [RA_ParseUser currentUser];
    [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"%@ %@: Saved currentInstallation", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        }
    }];
}



// Pasted from parse.com
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [PFPush handlePush:userInfo];
}



-(void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}



- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}



- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}



- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    // Facebook boilerplate
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}



- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    // Facebook boilerplate
    [[PFFacebookUtils session] close];
}



// Two methods required for app to handle URL callbacks that are part of OAuth authentication
// These simply call the PFFacebookUtils helper method that takes care of the rest
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}



@end
