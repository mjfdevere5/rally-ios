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
#import "RA_LocationSingleton.h"
#import <CoreLocation/CoreLocation.h>

#import "RA_NextGameDateTimeCell.h"

#import "MBProgressHUD.h"


@interface RA_NextGamePrefTwo ()<MBProgressHUDDelegate>
@property (strong, nonatomic) NSArray *cellArray;
@property (strong, nonatomic) RA_ParseGamePreferences *ladderPref;
@end


@implementation RA_NextGamePrefTwo


#pragma mark - load up
// ******************** load up ********************

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Navbar
    self.navigationItem.title = @"Logistics";
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    
    // Form formatting
    self.tableView.backgroundColor = UIColorFromRGB(FORMS_DARK_RED);
    self.view.backgroundColor = UIColorFromRGB(FORMS_DARK_RED);
    self.separatorLine.backgroundColor = UIColorFromRGB(FORMS_LIGHT_RED);
    
    // Set to auto-location-update and start updating location
    [RA_GamePrefConfig gamePrefConfig].ladderLocationManuallySelected = NO;
    [[RA_LocationSingleton locationSingleton] stopUpdatingLocation];
    [[RA_LocationSingleton locationSingleton] startUpdatingLocationIfAuto];
    
    // Set the formCellArray
    self.cellArray = @[@[@"nextgame_datetime_cell", @"nextgame_addbackup_cell"], @[@"nextgame_location_cell"]];
    
    // Reload
    [self.tableView reloadData];
}


#pragma mark - tableview data source
// ******************** tableview data source methods ********************

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.cellArray count]; // Should be 2
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *rowsInSection = self.cellArray[section];
    NSInteger numberOfRows = [rowsInSection count];
    return numberOfRows;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"When";
            break;
        case 1:
            return @"Where";
            break;
        default:
            return @"...";
            COMMON_LOG_WITH_COMMENT(@"ERROR: Unexpected section")
            break;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId = self.cellArray[indexPath.section][indexPath.row];
    if ([cellId isEqualToString:@"nextgame_datetime_cell"]) {
        return 90.0;
    }
    else if ([cellId isEqualToString:@"nextgame_addbackup_cell"]) {
        return 44.0;
    }
    else if ([cellId isEqualToString:@"nextgame_location_cell"]) {
        return 70.0;
    }
    else {
        COMMON_LOG_WITH_COMMENT(@"Unexpected cellId")
        return 44.0;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{ COMMON_LOG
    // Dequeue
    NSString *reuseIdentifier = self.cellArray[indexPath.section][indexPath.row];
    COMMON_LOG_WITH_COMMENT(reuseIdentifier)
    RA_NextGameBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    COMMON_LOG_WITH_COMMENT(@"1")
    // Special case: need to know which preference we are
    if ([cell isKindOfClass:[RA_NextGameDateTimeCell class]]) {
        RA_NextGameDateTimeCell *castCell = (RA_NextGameDateTimeCell *)cell;
        if (indexPath.row == 0) {
            castCell.preferenceNumber = 0;
        }
        else {
            castCell.preferenceNumber = 1;
        }
    }
    COMMON_LOG_WITH_COMMENT(@"2")
    // Configure
    cell.viewControllerDelegate = self;
    [cell configureCell];
    
    // Return
    return cell;
}


#pragma mark - tableview delegate
// ******************** tableview delegate ********************

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RA_NextGameBaseCell *cell = (RA_NextGameBaseCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    if ([cell.reuseIdentifier isEqualToString:@"nextgame_addbackup_cell"]) {
        // Toggle whether the user wants a backup or not
        [RA_GamePrefConfig gamePrefConfig].hasBackupPreference = ![RA_GamePrefConfig gamePrefConfig].hasBackupPreference;
        
        // Delete or insert cell
        NSIndexPath *pathToInsertOrDelete = [NSIndexPath indexPathForRow:(indexPath.row + 1) inSection:indexPath.section];
        if ([RA_GamePrefConfig gamePrefConfig].hasBackupPreference) {
            self.cellArray = @[@[@"nextgame_datetime_cell", @"nextgame_addbackup_cell", @"nextgame_datetime_cell"],
                               @[@"nextgame_location_cell"]];
            [tableView insertRowsAtIndexPaths:@[pathToInsertOrDelete]
                             withRowAnimation:UITableViewRowAnimationFade];
        }
        else {
            self.cellArray = @[@[@"nextgame_datetime_cell", @"nextgame_addbackup_cell"],
                               @[@"nextgame_location_cell"]];
            [tableView deleteRowsAtIndexPaths:@[pathToInsertOrDelete]
                             withRowAnimation:UITableViewRowAnimationFade];
        }
        // Change the outlets in the 'Add/remove backup' cell
        [cell configureCell];
    }
}


#pragma mark - upload config
// ******************** upload config ********************

-(IBAction)setPrefButtonPushed:(UIButton *)button
{ COMMON_LOG
    // Check valid before continuing
    if (![[RA_GamePrefConfig gamePrefConfig] validDatesAndTimes]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Something looks odd"
                                                        message:@"Your backup is the same as your first preference. Either remove the backup, or submit two different slots."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
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
    
    // Prepare the Parse object for upload
    self.ladderPref = [[RA_GamePrefConfig gamePrefConfig] createParseGamePreferencesObject];
    
    // Prepare the progress HUD
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.delegate = self;
    [HUD show:YES];
    
    // Upload
    [self.ladderPref saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [HUD hide:YES];
        if (succeeded) { [self configUploadedSuccessfully]; }
        else { [self configFailedToUploadWithError:error]; }
    }];
}

-(void)configUploadedSuccessfully
{
    // Throw a 'success' alert
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!"
                                                    message:[NSString stringWithFormat:@"We read you loud and clear. You'll get a ping when your match is confirmed."]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles: nil];
    [alert show];
    
    // Stop the location manager
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
        [self setPrefButtonPushed:nil];
    }
}


#pragma mark - navigation
// ******************** navigation ********************

-(void)viewDidDisappear:(BOOL)animated
{ COMMON_LOG
    [super viewDidDisappear:animated];
    
    // Stop the locationSingleton from hunting down your address
    [RA_GamePrefConfig gamePrefConfig].ladderLocationManuallySelected = YES;
}



@end
