//
//  RA_Login.m
//  Rally
//
//  Created by Max de Vere on 02/09/2014.
//  Copyright (c) 2014 NA. All rights reserved.
//

#import "RA_Login.h"
#import "RAAppDelegate.h"
#import "AppConstants.h"
#import "RA_TabBar.h"


@interface RA_Login ()

@end



@implementation RA_Login

-(void)viewWillAppear:(BOOL)animated
{
    BOOL isLoggedIn = ([RA_ParseUser currentUser] &&
                       [PFFacebookUtils isLinkedWithUser:[RA_ParseUser currentUser]]);
    if (isLoggedIn) {
        [self.button setHidden:YES];
        self.activityIndicator.hidden = YES;
    }
    else {
        self.button.hidden = NO;
        self.button.enabled = YES;
        self.activityIndicator.hidden = NO;
        [self.activityIndicator stopAnimating];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    BOOL isLoggedIn = ([RA_ParseUser currentUser] &&
                       [PFFacebookUtils isLinkedWithUser:[RA_ParseUser currentUser]]);
    if (isLoggedIn) {
        COMMON_LOG_WITH_COMMENT(@"logged in")
        UIStoryboard *myStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        RA_TabBar *tabBarController = [myStoryboard instantiateViewControllerWithIdentifier:@"tab_bar_controller"];
        COMMON_LOG_WITH_COMMENT([tabBarController description])
        [self presentViewController:tabBarController animated:YES completion:nil];
    }
}


- (IBAction)loginButtonTouchHandler:(id)sender
{
    // Disable the button
    self.button = (UIButton *)sender;
    self.button.enabled = NO;
    
    // Start the wheel
    [self.activityIndicator startAnimating];
    
    // Get the Facebook login comms moving
    [[RA_FacebookLoginComms commsManager] loginWithFacebook:self];
}


-(void)didLoginWithFacebook:(BOOL)loggedIn withError:(NSError *)error
{
    if(loggedIn)
    {
        // Transition to tab view controller (segue configured in storyboard)
        [self performSegueWithIdentifier:@"loggedin" sender:self];
    }
    
    else
    {
        NSString *errorMessage = nil;
        if (!error) {
            NSLog(@"Uh oh. The user cancelled the Facebook login.");
            errorMessage = @"Uh oh. The user cancelled the Facebook login.";
        } else {
            NSLog(@"Uh oh. An error occurred: %@", error);
            errorMessage = [error localizedDescription];
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error"
                                                        message:errorMessage
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"Dismiss", nil];
        [alert show];
        
        self.button.enabled = YES;
        [self.activityIndicator stopAnimating];
    }
}



@end


