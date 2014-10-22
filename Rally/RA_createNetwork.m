//
//  RA_createNetwork.m
//  Rally
//
//  Created by Alex Brunicki on 10/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_createNetwork.h"
#import "RA_ParseUser.h"
#import "RA_ParseNetwork.h"
#import "GKImagePicker.h"
#import "UIImage+ProfilePicHandling.h"
#import "UIImage+Resize.h"
#import "AppConstants.h"

@interface RA_createNetwork () <GKImagePickerDelegate, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UIAlertViewDelegate, MBProgressHUDDelegate>


// BOOL values for username and passwords
@property BOOL correctName;
@property BOOL correctPass;
@property BOOL correctPassTwo;

// Strings for the sport type and game type
@property (nonatomic) NSString *chosenSport;
@property (nonatomic) NSString *leagueType;
@property (nonatomic) NSNumber *durationLength;


// Array for text values for duration of league
@property (nonatomic) NSArray *duration;

// Images that should get added to the parse network
@property (nonatomic) UIImage *largeLeaguePic;
@property (nonatomic) UIImage *mediumLeaguePic;

// Created some new images for our stock photos
@property (nonatomic) UIImage *largeStockSquash;
@property (nonatomic) UIImage *mediumStockSquash;
@property (nonatomic) UIImage *largeStockTennis;
@property (nonatomic) UIImage *mediumStockTennis;

// Integer values for our load up screens
@property (nonatomic) NSInteger *loadUpValue;

// Game type blurbs
@property (nonatomic) NSString* ladderBlurb;
@property (nonatomic) NSString* leagueBlurb;

@property (nonatomic, strong) GKImagePicker *imagePicker;

@end

@implementation RA_createNetwork

- (void)viewDidLoad
{
    [super viewDidLoad];
    
   // Adjust the colours of the cells and labels
    self.tableView.backgroundColor = RA_TEST_BLUE2;
    self.view.backgroundColor = RA_TEST_BLUE2;
    self.sportSelector.tintColor = RA_TEST_BLUE2;
    self.gameTypeSelector.tintColor = RA_TEST_BLUE2;
    self.lenthPicker.textColor = RA_TEST_BLUE2;
    
    self.leagueTitle.textColor = RA_TEST_BLUE2;
    self.leagueTitle.font = [UIFont fontWithName:@"Avenir-Medium" size:20.0];
    self.userName.textColor = RA_TEST_BLUE2;
    self.userName.tintColor = RA_TEST_BLUE2;
    self.durationTitle.textColor = RA_TEST_BLUE2;
    self.durationTitle.font = [UIFont fontWithName:@"Avenir-Medium" size:20.0];
    self.passwordTitle.textColor = RA_TEST_BLUE2;
    self.passwordField.font = [UIFont fontWithName:@"Avenir-Book" size:15.0];
    self.passwordTitle.font = [UIFont fontWithName:@"Avenir-Medium" size:20.0];
    self.passwordField.tintColor = RA_TEST_BLUE2;
    self.passwordField.textColor = RA_TEST_BLUE2;
    self.confirmPasswordTitle.textColor = RA_TEST_BLUE2;
    self.confirmPasswordTitle.font = [UIFont fontWithName:@"Avenir-Medium" size:20.0];
    self.passwordFieldTwo.font = [UIFont fontWithName:@"Avenir-Book" size:15.0];
    self.passwordFieldTwo.tintColor = RA_TEST_BLUE2;
    self.passwordFieldTwo.textColor = RA_TEST_BLUE2;
    self.gameTypeTitle.textColor = RA_TEST_BLUE2;
    self.gameTypeTitle.font = [UIFont fontWithName:@"Avenir-Medium" size:20.0];
    self.sportTitle.textColor = RA_TEST_BLUE2;
    self.sportTitle.font = [UIFont fontWithName:@"Avenir-Medium" size:20.0];
    self.photoTitle.textColor = RA_TEST_BLUE2;
    self.photoTitle.font = [UIFont fontWithName:@"Avenir-Medium" size:20.0];
    self.gameTypeBlurb.textColor = RA_TEST_BLUE2;
    self.gameTypeBlurb.font = [UIFont fontWithName:@"Avenir-Book" size:15.0];
    self.photoBlurb.textColor = RA_TEST_BLUE2;
    self.photoBlurb.font = [UIFont fontWithName:@"Avenir-Book" size:15.0];
    self.lenthPicker.textColor = RA_TEST_BLUE2;
    self.lenthPicker.font = [UIFont fontWithName:@"Avenir-Book" size:20.0];
    
    // Create duration array
    self.duration= @[@"No limit", @"1 week", @"2 weeks",
                     @"3 weeks", @"4 weeks", @"5 weeks",
                     @"6 weeks", @"7 weeks", @"8 weeks",
                     @"9 weeks", @"10 weeks", @"11 weeks", @"12 weeks"];
    
    // Prepare our stock images
    UIImage *squash = [UIImage imageNamed:@"squash_league_v04"];
    UIImage *tennis = [UIImage imageNamed:@"tennis_league_v04"];
    
   self.mediumStockSquash = [squash resizedImage:PF_USER_PIC_TEST_SIZE interpolationQuality:kCGInterpolationDefault];
   // self.mediumStockSquash = [self.largeStockSquash getImageResizedAndCropped:PF_USER_PIC_MEDIUM_SIZE];
    self.mediumStockTennis = [tennis resizedImage:PF_USER_PIC_TEST_SIZE interpolationQuality:kCGInterpolationDefault];
    //self.mediumStockTennis = [self.largeStockTennis getImageResizedAndCropped:PF_USER_PIC_MEDIUM_SIZE];
    
    // Create the blurb that explains how the different formats will be run
    // Could be in app constants but prefer to change it in here for now
    self.ladderBlurb = @"The competition will be run according to ladder rules. Click on the question mark for more info";
    self.leagueBlurb = @"The competition will be run according to league rules. Click on the question mark for more info";
    
    [self resetToDefault];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return 7;
}


- (void)tableView: (UITableView*)tableView willDisplayCell: (UITableViewCell*)cell forRowAtIndexPath: (NSIndexPath*)indexPath
{
    cell.backgroundColor = RA_TEST_WHITE;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Text Color
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[UIColor whiteColor]];
    [header.textLabel setFont:[UIFont boldSystemFontOfSize:15]];
}


-(void) resetToDefault
{
    // Always clear the username and password fields
    self.userName.text = @"";
    self.passwordField.text = @"";
    self.passwordFieldTwo.text = @"";
    
    // Ensure sport selector and game selectors are at position 0
    [self.sportSelector setSelectedSegmentIndex:0];
    self.chosenSport = [self.sportSelector titleForSegmentAtIndex:0];
    [self.gameTypeSelector setSelectedSegmentIndex:0];
    self.gameTypeBlurb.text = self.ladderBlurb;
    self.leagueType = [self.gameTypeSelector titleForSegmentAtIndex:0];
    
    // Reset password and username checks to No
    self.correctName = NO;
    self.correctPass = NO;
    self.correctPassTwo = NO;
    
    // Correct the duration setter
    //[self.lengthSlide setValue:0];
    self.lenthPicker.text = self.duration[0];
    
    // Set default images to send parse
    self.mediumLeaguePic = self.mediumStockSquash;
    
    self.leagueImage.image = self.mediumStockSquash;

}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    // Username
    
    if(textField.tag == 1) {
        self.passwordField.text = @"";
        self.passwordFieldTwo.text = @"";
        self.userNameCorrect.image = nil;
        self.passwordCorrect.image = nil;
        self.passwordCorrectTwo.image = nil;
    }
    
    // Password
    else if(textField.tag == 2){
        self.passwordFieldTwo.text = @"";
        self.passwordCorrect.image = nil;
        self.passwordCorrectTwo.image = nil;
        
    }
    
    // Password confirm
    else {
        
    }
    
}



-(void)textFieldDidEndEditing:(UITextField *)textField
{
    // Username
    if(textField.tag == 1) {
        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:HUD];
        HUD.delegate = self;
        [HUD showWhileExecuting:@selector(checkUsername:) onTarget:self withObject:self.userName.text animated:YES];
    }
    
    // Password
    else if(textField.tag == 2){
        if ([self.passwordField.text length] < 6 || ![self isValidPassword:self.passwordField.text]) {
            self.passwordCorrect.image = [UIImage imageNamed:@"gray_cross_64x64"];
            self.passwordField.text = @"";
            self.correctPass = NO;
            [self showIncorrectPasswordAlert];
        }
        else {
            self.passwordCorrect.image = [UIImage imageNamed:@"green_check_64x64"];
            self.correctPass = YES;
        }
    }
    
    // Password confirm
    else {
        if ([self.passwordField.text isEqualToString:self.passwordFieldTwo.text]) {
            self.passwordCorrectTwo.image = [UIImage imageNamed:@"green_check_64x64"];
            self.correctPassTwo = YES;
        }
        else{
            self.passwordCorrectTwo.image = [UIImage imageNamed:@"gray_cross_64x64"];
            self.passwordFieldTwo.text = @"";
            self.correctPassTwo = NO;
            [self showNonMatchingPasswordAlert];
        }
    }
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[tableView cellForRowAtIndexPath:indexPath].reuseIdentifier isEqualToString:@"league_photo"]) {
        NSLog(@"league photo tapped");
        
        self.imagePicker = [[GKImagePicker alloc] init];
        
        self.imagePicker.cropSize = CGSizeMake(PF_USER_PIC_TEST_WIDTH, PF_USER_PIC_TEST_HEIGHT);
        self.imagePicker.delegate = self;
        [self presentViewController:self.imagePicker.imagePickerController animated:YES completion:nil];
    }

}


- (void)imagePicker:(GKImagePicker *)imagePicker pickedImage:(UIImage *)image
{

    
    //  Display the selected thumbnail image
    self.leagueImage.image = image;
    
    UIImage *picMedium = [image resizedImage:PF_USER_PIC_TEST_SIZE interpolationQuality:kCGInterpolationDefault];
    
  
    //UIImage *picMedium = [picLarge getImageResizedAndCropped:PF_USER_PIC_MEDIUM_SIZE];
    self.leagueImage.image = picMedium;
    
    //self.largeLeaguePic = picLarge;
    self.mediumLeaguePic = picMedium;
    
    // Hide image picker
    [self hideImagePicker];
    
}

- (void)hideImagePicker
{
    
    [self.imagePicker.imagePickerController dismissViewControllerAnimated:YES completion:nil];
}



- (IBAction)sportSwitch:(id)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl *) sender;
    NSInteger selectedSegment = segmentedControl.selectedSegmentIndex;
    
    if (selectedSegment == 0) {
        self.leagueImage.image = [UIImage imageNamed:@"squash_league_v04"];
        self.largeLeaguePic = self.largeStockSquash;
        self.mediumLeaguePic = self.mediumStockSquash;
        
    }
    else{
        self.leagueImage.image = [UIImage imageNamed:@"tennis_league_v04"];
        self.largeLeaguePic = self.largeStockTennis;
        self.mediumLeaguePic = self.mediumStockTennis;

        
    }
    self.chosenSport = [segmentedControl titleForSegmentAtIndex:segmentedControl.selectedSegmentIndex];
}

- (IBAction)leagueTypeSwitch:(id)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl *) sender;
    NSInteger selectedSegment = segmentedControl.selectedSegmentIndex;
    
    if (selectedSegment == 0) {
        self.gameTypeBlurb.text = self.ladderBlurb;
    }
    else{
        self.gameTypeBlurb.text = self.leagueBlurb;
        
    }
    self.leagueType = [segmentedControl titleForSegmentAtIndex:segmentedControl.selectedSegmentIndex];
}


-(IBAction)lengthChanged:(id)sender
{

// Get skill
NSNumber *length = [self getLengthFromSlider:sender];

// Convert skill to cool string for outlet
NSString *lengthString = [self getLengthStringFrom:length];

// Send to outlet
self.lenthPicker.text = lengthString;
}



-(NSNumber *)getLengthFromSlider:(UISlider *)slider
{
    NSNumber *length = [NSNumber numberWithFloat:slider.value];
    return length;
}

-(NSString *)getLengthStringFrom: (NSNumber *)length
{
    float tempFloat = [length floatValue]*([self.duration count]-1) + 0.99;
    // tempFloat ranges from min=0.99 to max=4.95 if count=5
    
    int skillIndex = (int) tempFloat;
    NSString *lengthString = self.duration[skillIndex];
    
    return lengthString;
}


-(void)checkUsername: (NSString *)username
{
    PFQuery *query = [RA_ParseNetwork query];
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    [query whereKey:@"name" equalTo:username];
    NSArray *usernameList = [query findObjects];
    if ([usernameList count] > 0) {
    [self performSelectorOnMainThread:@selector(showIncorrectUsername) withObject:nil waitUntilDone:NO];
    }
    else{
    [self performSelectorOnMainThread:@selector(showCorrectUsername) withObject:nil waitUntilDone:NO];
    }
    
}

-(void)showCorrectUsername
{
    self.userNameCorrect.image = [UIImage imageNamed:@"green_check_64x64"];
    self.correctName = YES;
}

-(void)showIncorrectUsername
{
    self.userNameCorrect.image = [UIImage imageNamed:@"gray_cross_64x64"];
    [self showIncorrectUsernameAlert];
    self.correctName = NO;
}


- (BOOL)isValidPassword:(NSString *)string
{
    return [string rangeOfCharacterFromSet:[NSCharacterSet uppercaseLetterCharacterSet]].location != NSNotFound &&
    [string rangeOfCharacterFromSet:[NSCharacterSet lowercaseLetterCharacterSet]].location != NSNotFound &&
    [string rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location != NSNotFound;
}



- (IBAction)createNetworkPushed:(id)sender
{
    NSLog(@"create network button pushed");
    if (self.correctName && self.correctPass && self.correctPassTwo) {
        NSString *sportForNetwork;
        if ([self.chosenSport isEqualToString:@"Tennis"]) {
            sportForNetwork = RA_SPORT_NAME_TENNIS;
        }
        else if ([self.chosenSport isEqualToString:@"Squash"]) {
            sportForNetwork = RA_SPORT_NAME_SQUASH;
        }
        else {
            COMMON_LOG_WITH_COMMENT(@"ERROR")
        }
        
        NSLog(@"about to create the parse network object");
        
        // Create the network object. Note this method initializes the scores dictionaries
        RA_ParseNetwork *network = [RA_ParseNetwork networkWithName:self.userName.text
                                                           andSport:sportForNetwork
                                                            andType:self.leagueType
                                                      andAccessCode:self.passwordField.text
                                                           andAdmin:[RA_ParseUser currentUser]
                                                        andDuration:[NSNumber numberWithFloat:self.lengthSlide.value]];
        NSLog(@"created the parse object");
        
        // Add the photos
        network.leaguePicMedium = [PFFile fileWithData:UIImageJPEGRepresentation(self.mediumLeaguePic, 0.9f)];
        
        // Save this network to admin's user account
        RA_ParseUser *cUser = [RA_ParseUser currentUser];
        [cUser.networkMemberships addObject:network];
        
        NSLog(@"Break point 2");
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:1] forKey:cUser.objectId];
        NSLog(@"Break point 3");
        network.userIdsToRanks = dictionary;
        NSLog(@"Break point 4");
        
        NSLog(@"Break point 1");
        
        // Add Bruno new code
        if ([network.type isEqualToString:@"Ladder"]) {
            network.userIdsToScores = [NSMutableDictionary dictionary];
            NSNumber *initialScore = [NSNumber numberWithFloat:1200.0];
            [network.userIdsToScores setObject:initialScore forKey:cUser.objectId];
            
            NSLog(@"about to create player ranks");
         
        }
        else if ([network.type isEqualToString:@"League"]) {
            network.userIdsToScores = [NSMutableDictionary dictionary];
            NSNumber *initialScore = [NSNumber numberWithFloat:0.0];
            [network.userIdsToScores setObject:initialScore forKey:cUser.objectId];

        }
        else {
            COMMON_LOG_WITH_COMMENT(@"ERROR: Unexpected network type")
        }
        
        // Save all objects at once
        NSArray *objectsToSave = [NSArray arrayWithObjects:network,cUser, nil];
        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
        HUD.delegate = self;
        [HUD show:YES];
        [PFObject saveAllInBackground:objectsToSave block:^(BOOL succeeded, NSError *error) {
            // Hide HUD whatever the outcome
            [HUD hide:YES];
            if (succeeded) { [self networkUploadedSuccessfully:network]; }
            else { [self networkFailedToUploadWithError:error]; }
        }];
    }
    else {
        [self showMissingNetworkCredentials];
    }
}

-(void)networkUploadedSuccessfully: (RA_ParseNetwork *)network
{
    NSLog(@"about to create the pfinstallation");
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    
    NSString *stringForNetwork = [NSString stringWithFormat:@"A%@",network.objectId];
    
    [currentInstallation addUniqueObject:stringForNetwork forKey:@"channels"];
    
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.delegate = self;
    [HUD show:YES];
    
    [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [HUD hide:YES];
        if(succeeded){[self showPositiveMessage];}
        else{[self networkFailedToUploadWithError:error];}
    }];
}

-(void)showPositiveMessage
{
    // Throw a 'success' alert
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!"
                                                    message:[NSString stringWithFormat:@"Your network has been created successfully."]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles: nil];
    [alert show];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}



-(void)networkFailedToUploadWithError:(NSError *)error
{
    NSLog(@"%@ on thread %@", NSStringFromSelector(_cmd), [NSThread currentThread]);
    NSLog(@"ERROR uploading shout in background: %@", [error localizedDescription]);
    
    // Throw a 'uh oh' alert
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh oh!"
                                                    message:[NSString stringWithFormat:@"Seems like something went wrong with the connection - your preferences were not sent to the Rally team."]
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Try again", nil];
    [alert show];
}

-(void) showMissingNetworkCredentials
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network not created - form is missing some key elements"
                                                    message:nil
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
    if (self.correctName) {
        self.userNameCorrect.image = [UIImage imageNamed:@"green_check_64x64"];
    }
    else{
        self.userNameCorrect.image = [UIImage imageNamed:@"gray_cross_64x64"];
    }
    
    if (self.correctPass) {
        self.passwordCorrect.image = [UIImage imageNamed:@"green_check_64x64"];
    }
    else{
        self.passwordCorrect.image = [UIImage imageNamed:@"gray_cross_64x64"];
    }
    
    if (self.correctPassTwo) {
        self.passwordCorrectTwo.image = [UIImage imageNamed:@"green_check_64x64"];
    }
    else{
        self.passwordCorrectTwo.image = [UIImage imageNamed:@"gray_cross_64x64"];
    }

}



-(void)showIncorrectUsernameAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry, that League Name already exists. Please try another one."
                                                  message:nil
                                                 delegate:nil
                                        cancelButtonTitle:@"OK"
                                        otherButtonTitles:nil];
    [alert show];

}


-(void)showIncorrectPasswordAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Your password needs to be more than 5 characters in length and contain at least one capital letter and one number."
                                                    message:nil
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];

}


-(void)showNonMatchingPasswordAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Your passwords don't match!"
                                                    message:nil
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];

}

-(IBAction)cancelPushed:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}





@end
