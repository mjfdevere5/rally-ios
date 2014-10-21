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
    COMMON_LOG_WITH_COMMENT(@"1")
    
    // Parse credentials
    [Parse setApplicationId:@"GC47Noqr8CDojxqdBTPPr5tBVHl6d5DlqO01URpf"
                  clientKey:@"Top3pQFivnsXSnpGuHuYJEryqZkZHjcQYmoHoHbJ"];
    COMMON_LOG_WITH_COMMENT(@"2")
    // Used for Parse tracking
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    COMMON_LOG_WITH_COMMENT(@"3")
    // Hack to avoid Parse bug, 'Unknown class PFImageView in Interface Builder file.'
    // See http://stackoverflow.com/a/20933480/3364933
    [PFImageView class];
    COMMON_LOG_WITH_COMMENT(@"4")
    // Parse's Facebook Utilities singleton
    [PFFacebookUtils initializeFacebook];
    COMMON_LOG_WITH_COMMENT(@"5")
    // Register for Push Notitications, if running iOS 8
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        COMMON_LOG_WITH_COMMENT(@"6")
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                        UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                 categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    } else {
        COMMON_LOG_WITH_COMMENT(@"7")
        // Register for Push Notifications before iOS 8
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                         UIRemoteNotificationTypeAlert |
                                                         UIRemoteNotificationTypeSound)];
    }
    COMMON_LOG_WITH_COMMENT(@"8")
    // Set appearance of navigation bar(s) and status bar for whole app:
    [[UINavigationBar appearance] setBarTintColor:RA_TEST_BLUE1];
    [[UINavigationBar appearance] setTintColor:UIColorFromRGB(RA_NAVBAR_TEXT_COLOUR)];
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           UIColorFromRGB(RA_NAVBAR_TEXT_COLOUR), NSForegroundColorAttributeName,
                                                           [UIFont fontWithName:@"Gill Sans" size:20.0], NSFontAttributeName, nil]];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    COMMON_LOG_WITH_COMMENT(@"9")
    // If responding to a notification
    NSDictionary *notificationPayload = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    COMMON_LOG_WITH_COMMENT(@"10")
    NSString *viewString = [notificationPayload objectForKey:@"view"];
    COMMON_LOG_WITH_COMMENT(@"11")
    if ([viewString isEqualToString:@"game_manager"]) {
        COMMON_LOG_WITH_COMMENT(@"game_manager")
        // TO DO: Take user to the Game Manager
    }
    else if ([viewString isEqualToString:@"recent_chats"]) {
        COMMON_LOG_WITH_COMMENT(@"recent_chats")
        // TO DO: Take user to the Chat View
    }
    COMMON_LOG_WITH_COMMENT(@"12")
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
    if ([RA_ParseUser currentUser]) {
        currentInstallation[@"user"] = [RA_ParseUser currentUser];
    }
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
    
    // Badge counter
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}



- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    // Facebook boilerplate
    [[PFFacebookUtils session] close];
    COMMON_LOG
}



// Two methods required for app to handle URL callbacks that are part of OAuth authentication
// These simply call the PFFacebookUtils helper method that takes care of the rest
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
    COMMON_LOG
}



@end
