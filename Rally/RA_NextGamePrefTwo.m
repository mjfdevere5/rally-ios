//
//  RA_LadderFormTwo.m
//  Rally
//
//  Created by Max de Vere on 23/09/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_NextGamePrefTwo.h"
#import "RA_ParseGamePreferences.h"
#import "RA_GamePrefConfig.h"
#import "AppConstants.h"
#import "RA_NextGamePrefCell.h"
#import "RA_LocationSingleton.h"
#import "RA_NextGamePrefCell.h"
#import "RA_ParseBroadcast.h"



@interface RA_NextGamePrefTwo ()

// For loading the table
@property (strong, nonatomic) NSArray *formCellArray;

// For uploading to Parse
@property (strong, nonatomic) RA_ParseGamePreferences *ladderPref;
@property (strong, nonatomic) RA_ParseBroadcast *broadcast;

// Switchers
@property (nonatomic) BOOL hasAddInfoCell;
@property (nonatomic) BOOL hasBookingCell;

@end


@implementation RA_NextGamePrefTwo


#pragma mark - load up
// ******************** load up ********************


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Navbar
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    self.navigationItem.title = @"Your next game";
    
    // Form formatting
    self.tableView.backgroundColor = UIColorFromRGB(FORMS_DARK_RED);
    self.view.backgroundColor = UIColorFromRGB(FORMS_DARK_RED);
    self.separatorLine.backgroundColor = UIColorFromRGB(FORMS_LIGHT_RED);
    
    // Set to auto-location-update and start updating location
    [RA_GamePrefConfig gamePrefConfig].ladderLocationManuallySelected = NO;
    [[RA_LocationSingleton locationSingleton] stopUpdatingLocation];
    [[RA_LocationSingleton locationSingleton] startUpdatingLocationIfAuto];

    
    // Set the formCellArray
    self.formCellArray = @[@[@"location_pref"], @[@"court_booking_preference"], @[@"additional_info"]];
    
    // Max's weird variable
    self.hasAddInfoCell = NO;
    
    // Reload
    [self.tableView reloadData];
}



#pragma mark - upload config
// ******************** upload config ********************


-(IBAction)setPrefButtonPushed:(UIButton *)button
{
    if (![[RA_GamePrefConfig gamePrefConfig] validLocation]) {
        NSLog(@"[%@, %@] not enough params", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hey!"
                                                        message:[NSString stringWithFormat:@"Please select a location"]
                                                       delegate:nil
                                              cancelButtonTitle:@"Done"
                                              otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    
    
    // Prepare the ladder config
    self.ladderPref = [[RA_GamePrefConfig gamePrefConfig] createParseGamePreferencesObject];
    self.broadcast = [[RA_GamePrefConfig gamePrefConfig] createParseBroadcastObjectWithPref:self.ladderPref];
    
    // Prepare the progress HUD
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.delegate = self;
    [HUD show:YES];
    
    // Upload // TO DO fix this etc.
    NSArray *toUpload = @[self.ladderPref, self.broadcast];
    [PFObject saveAllInBackground:toUpload block:^(BOOL succeeded, NSError *error) {
        // Hide HUD whatever the outcome
        [HUD hide:YES];
        
        if (succeeded) { [self configUploadedSuccessfully]; }
        else { [self configFailedToUploadWithError:error]; }
    }];
}



-(void)configUploadedSuccessfully
{
    // Throw a 'success' alert
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!"
                                                    message:[NSString stringWithFormat:@"We read you loud and clear. We'll be in touch regarding your next game."]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles: nil];
    [alert show];
    
    [RA_GamePrefConfig gamePrefConfig].ladderLocationManuallySelected = YES;
    
    // Unwind completely
    [self.navigationController popToRootViewControllerAnimated:YES];
}



-(void)configFailedToUploadWithError:(NSError *)error
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



-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Try again"]) {
        
        // This code is copied from the -setPrefButtonPushed method
        // Gives user an opportunity to try again
        
        // Prepare the HUD
        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
        HUD.delegate = self;
        [HUD show:YES];
        
        // Upload
        [self.ladderPref saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            // Hide HUD whatever the outcome
            [HUD hide:YES];
            
            if (succeeded) { [self configUploadedSuccessfully]; }
            else { [self configFailedToUploadWithError:error]; }
            
        }];
    }
}



#pragma mark - tableview delegate
// ******************** tableview delegate methods ********************


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.formCellArray count];
}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *rowsInSection = self.formCellArray[section];
    NSInteger numberOfRows = [rowsInSection count];
    return numberOfRows;
}



-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"Game location";
            break;
        case 1:
            return @"Court booking";
            break;
        case 2:
            return @"Anything else?";
            break;
        default:
            return @"Hmm...";
            NSLog(@"ERROR in %@, %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
            break;
    }
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            return 71;
        case 1:
            // Booking help
            return [self getBookingHelpCellHeightForIndexPath:indexPath];
            break;
        case 2:
            // Additional info
            return [self getAdditionalInfoCellHeightForIndexPath:indexPath];
            break;
        default:
            NSLog(@"ERROR in %@, %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
            return 44.0;
            break;
    }
}



- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Text Color
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[UIColor whiteColor]];
}



-(RA_NextGamePrefCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%@ on thread %@", NSStringFromSelector(_cmd), [NSThread currentThread]);
    
    if (!self.formCellArray) {
        // Case included just in case
        NSLog(@"ERROR in %@, %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        return nil;
    }
    
    else {
        NSString *reuseIdentifier = self.formCellArray[indexPath.section][indexPath.row];
        RA_NextGamePrefCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
        
        cell.topViewTwo = self;
        
        [cell updateCell];
        
        return cell;
    }
}



#pragma mark - cell height
// ******************** cell height ********************


-(CGFloat) getAdditionalInfoCellHeightForIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%@ on thread %@", NSStringFromSelector(_cmd), [NSThread currentThread]);
    
    if (!self.hasAddInfoCell) {
        return 44.0;
    }
    
    UITextView *textView = [UITextView new];
    textView.text = [RA_GamePrefConfig gamePrefConfig].additionalInfo;
    
    CGFloat textViewWidth = 220.0;
    NSLog(@"self.aboutMeTextView.frame.size.width: %f", textViewWidth);
    NSLog(@"self.aboutMeTextView.frame.size.height: %f", textView.frame.size.height);
    
    CGSize textViewSize = [textView sizeThatFits:CGSizeMake(textViewWidth, FLT_MAX)];
    NSLog(@"textViewSize: width %f, height: %f", textViewSize.width, textViewSize.height);
    // Note, I don't think sizeThatFits guarantees the width we pass in, so in theory the returned height could jump around, but it seems to work fine...
    
    // Other vertical spaces. These should agree with the constraints specified in the storyboard
    CGFloat topMargin = 4.0;
    CGFloat bottomMargin = 4.0;
    CGFloat totalHeight = (textViewSize.height
                           + topMargin
                           + bottomMargin);
    return totalHeight;
}



-(CGFloat)getBookingHelpCellHeightForIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%@ on thread %@", NSStringFromSelector(_cmd), [NSThread currentThread]);
    
    UITextView *textView = [UITextView new];
    BOOL bookingHelpWanted = [RA_GamePrefConfig gamePrefConfig].bookingHelpWanted;
    if (bookingHelpWanted) { textView.text = BOOKING_HELP_ON_SPIEL; }
    else { textView.text = BOOKING_HELP_OFF_SPIEL; }
    
    CGFloat textViewWidth = 220.0;
    
    CGSize textViewSize = [textView sizeThatFits:CGSizeMake(textViewWidth, FLT_MAX)];
    
    CGFloat topMargin = 10.0;
    CGFloat stepperHeight = 31.0;
    CGFloat middleMargin = 8.0;
    CGFloat bottomMargin = 14.0;
    CGFloat totalSize = (topMargin +
                         stepperHeight +
                         middleMargin +
                         textViewSize.height +
                         bottomMargin);
    return totalSize;
}



#pragma mark - text view delegate methods
// ******************** text view delegate methods ********************


- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"Tap to provide additional info"]) {
        textView.text = @"";
        [textView setFont:[UIFont systemFontOfSize:14.0]];
        textView.textColor = [UIColor whiteColor];
    }
    [textView becomeFirstResponder];
}



- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        [textView setFont:[UIFont italicSystemFontOfSize:14.0]];
        textView.textColor = [UIColor whiteColor];
        textView.text = @"Tap to provide additional info";
    }
    
    [textView resignFirstResponder];
}



- (void)textViewDidChange:(UITextView *)textView
{
    NSLog(@"%@ on thread %@", NSStringFromSelector(_cmd), [NSThread currentThread]);
    
    self.hasAddInfoCell = YES;
    
    [RA_GamePrefConfig gamePrefConfig].additionalInfo = textView.text;
    
    [self.tableView beginUpdates]; // This will cause an animated update of
    [self.tableView endUpdates];   // the height of your UITableViewCell
}



// This dismisses the keyboard when user taps 'Done'
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}


-(void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"[%@, %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    [super viewDidDisappear:animated];
    
    // Stop the locationSingleton from hunting down your address
    [RA_GamePrefConfig gamePrefConfig].ladderLocationManuallySelected = YES;
}



@end
