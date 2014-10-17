//
//  RA_createNetwork.h
//  Rally
//
//  Created by Alex Brunicki on 10/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface RA_createNetwork : UITableViewController<UITextFieldDelegate, MBProgressHUDDelegate>

// Username
@property (weak, nonatomic) IBOutlet UILabel *leagueTitle;
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *userNameActivity;
@property (weak, nonatomic) IBOutlet UIImageView *userNameCorrect;

// Password
@property (weak, nonatomic) IBOutlet UILabel *passwordTitle;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@property (weak, nonatomic) IBOutlet UIImageView *passwordCorrect;

// Confirm Password
@property (weak, nonatomic) IBOutlet UILabel *confirmPasswordTitle;
@property (weak, nonatomic) IBOutlet UITextField *passwordFieldTwo;
@property (weak, nonatomic) IBOutlet UIImageView *passwordCorrectTwo;

@property (weak, nonatomic) IBOutlet UILabel *sportTitle;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sportSelector;

// Sport type
@property (weak, nonatomic) IBOutlet UILabel *photoTitle;
@property (weak, nonatomic) IBOutlet UILabel *photoBlurb;

// League image
@property (weak, nonatomic) IBOutlet PFImageView *leagueImage;

// Game type
@property (weak, nonatomic) IBOutlet UILabel *gameTypeTitle;
@property (weak, nonatomic) IBOutlet UISegmentedControl *gameTypeSelector;
@property (weak, nonatomic) IBOutlet UILabel *gameTypeBlurb;

// Game duration
@property (weak, nonatomic) IBOutlet UILabel *durationTitle;
@property (weak, nonatomic) IBOutlet UILabel *lenthPicker;
@property (weak, nonatomic) IBOutlet UISlider *lengthSlide;
@property (weak, nonatomic) IBOutlet UILabel *durationBlurb;

// Button

-(IBAction)sportSwitch:(id)sender;
-(IBAction)leagueTypeSwitch:(id)sender;
- (IBAction)lengthChanged:(id)sender;
- (IBAction)createNetworkPushed:(id)sender;
-(IBAction)cancelPushed:(id)sender;


@end
