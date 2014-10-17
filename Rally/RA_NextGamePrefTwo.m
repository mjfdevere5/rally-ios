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
    self.navigationItem.title = @"Logistics";
    
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
    NSLog(@"%@ on thread %@", NSStringFromSelector(_cmd), [NSThread currentThread]);
    
//    // Check valid before continuing
//    if (![[RA_GamePrefConfig gamePrefConfig] validDatesAndTimes]) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Something looks odd"
//                                                        message:@"Two of your preferences are the same!"
//                                                       delegate:nil
//                                              cancelButtonTitle:@"OK"
//                                              otherButtonTitles:nil];
//        [alert show];
//        return;
//    }
    
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



// TO DO
//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    switch (indexPath.section) {
//        case 0:
//            return 71;
//        case 1:
//            // Booking help
//            return [self getBookingHelpCellHeightForIndexPath:indexPath];
//            break;
//        case 2:
//            // Additional info
//            return [self getAdditionalInfoCellHeightForIndexPath:indexPath];
//            break;
//        default:
//            NSLog(@"ERROR in %@, %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
//            return 44.0;
//            break;
//    }
//}



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
    
//    if ([reuseIdentifier isEqualToString:@"when_preference"]) {
//        
//        // Set whether cell is first, second or third preference
//        NSArray *preferenceStrings = @[@"first", @"second", @"third"];
//        cell.preferenceKey = preferenceStrings[indexPath.row];
//        NSArray *preferenceOutput = @[@"First", @"Second", @"Third"];
//        cell.prefLabel.text = preferenceOutput[indexPath.row];
//        
//        // First pref cell is configured a bit differently
//        if ([cell.preferenceKey isEqualToString:@"first"]) {
//            cell.preferenceSwitch.enabled = NO;
//            cell.preferenceSwitch.hidden = YES;
//        }
//    }
}


#pragma mark - special inter-cell behaviour
// ******************** special inter-cell behaviour ********************


-(void)turnOnPrefTwo
{
    [RA_GamePrefConfig gamePrefConfig].secondPreference.isEnabled = YES;
    RA_NextGamePrefCell *cell = (RA_NextGamePrefCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    [cell updateCell];
}




-(void)turnOffPrefThree
{
    [RA_GamePrefConfig gamePrefConfig].thirdPreference.isEnabled = NO;
    RA_NextGamePrefCell *cell = (RA_NextGamePrefCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    [cell updateCell];
}



-(void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"[%@, %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    [super viewDidDisappear:animated];
    
    // Stop the locationSingleton from hunting down your address
    [RA_GamePrefConfig gamePrefConfig].ladderLocationManuallySelected = YES;
}



@end
