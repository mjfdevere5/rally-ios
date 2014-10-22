//
//  RA_TabBar.m
//  Rally
//
//  Created by Max de Vere on 03/09/2014.
//  Copyright (c) 2014 NA. All rights reserved.
//

#import "RA_TabBar.h"
#import "AppConstants.h"
#import "RA_NetworkTests.h"


@interface RA_TabBar ()

@end



@implementation RA_TabBar


- (void)viewDidLoad
{
    [super viewDidLoad];

    self.delegate = self;

    // Set default tab bar selection to the middle tab
    self.selectedIndex = 0;

    // Set colour
    self.tabBar.barTintColor = RA_TEST_BLUE2;

    self.tabBar.selectedImageTintColor = RA_TEST_WHITE;

    // Badges
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        UITabBarItem *messagesTabBarItem = [self.tabBar.items objectAtIndex:3];
        messagesTabBarItem.badgeValue = [NSString stringWithFormat:@"%li",(long)currentInstallation.badge];
    }
}




#pragma mark -
#pragma mark - UITabViewControllerDelegate methods


-(BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    NSLog(@"%@ on thread %@", NSStringFromSelector(_cmd), [NSThread currentThread]);
    
    // Get index of toView
    NSUInteger newIndex = [tabBarController.viewControllers indexOfObjectIdenticalTo:viewController];
    
    NSLog(@"selectedIndex: %lu", (unsigned long)tabBarController.selectedIndex);
    NSLog(@"newIndex: %lu", (unsigned long)newIndex);
    
    // BOOL response
    return YES;
}



-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    // We always show the root view controller
    [(UINavigationController *)viewController popToRootViewControllerAnimated:NO];
}



#pragma mark -
#pragma mark - hide tab bar


//// Cool tab bar toggle. Not used here, but you can copy/paste this into other view controllers (couldn't figure out a better way to share this code)
//- (void)setTabBarVisible:(BOOL)visible animated:(BOOL)animated {
//    
//    NSLog(@"tabBarIsVisible? %i", [self tabBarIsVisible]);
//    
//    // Bail if the current state matches the desired state
//    if ([self tabBarIsVisible] == visible) {
//        return;
//    }
//    
//    // Get a frame calculation ready
//    CGRect frame = self.tabBarController.tabBar.frame;
//    CGFloat height = frame.size.height;
//    CGFloat offsetY = (visible)? -height : height;
//    
//    NSLog(@"frame.origin: %f, %f", frame.origin.x, frame.origin.y);
//    NSLog(@"frame.size.height: %f", frame.size.height);
//    
//    // Zero duration means no animation
//    CGFloat duration = (animated)? 0.3 : 0.0;
//    
//    // Execute
//    [UIView animateWithDuration:duration animations:^{
//        self.tabBar.frame = CGRectOffset(frame, 0, offsetY);
//    }];
//}
//// Know the current state
//- (BOOL)tabBarIsVisible
//{
//    return self.tabBar.frame.origin.y < CGRectGetMaxY(self.view.frame);
//}



@end

