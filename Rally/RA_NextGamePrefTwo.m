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
    self.tableView.backgroundColor = RA_TEST_WHITE;
    self.view.backgroundColor = RA_TEST_WHITE;
    self.separatorLine.backgroundColor = RA_TEST_BLUE2;
    
    // Set to auto-location-update and start updating location
    [RA_GamePrefConfig gamePrefConfig].ladderLocationManuallySelected = NO;
    [[RA_LocationSingleton locationSingleton] stopUpdatingLocation];
    [[RA_LocationSingleton locationSingleton] startUpdatingLocationIfAuto];
    
    // Set the formCellArray
    self.cellArray = @[@[@"nextgame_datetime_cell", @"nextgame_addbackup_cell"], @[@"nextgame_location_cell"]];
    
    CALayer *btnLayer = [self.button layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:0.0f];

    
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
    
    [self performSelectorInBackground:@selector(sendPushNotifications) withObject:self];
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



-(void)sendPushNotifications
{
    NSMutableArray *channels = [NSMutableArray array];
    
    for(RA_ParseNetwork *network in self.ladderPref.networks){
        NSLog(@"network name is %@",network.name);
        if ([network.name isEqualToString:@"All Rally Squash"] || [network.name isEqualToString:@"All Rally Tennis"]) {
            NSLog(@"only all rally squash or tennis selected");
        }
        else{
            NSString *stringToAdd = [NSString stringWithFormat:@"A%@",network.objectId];
            [channels addObject:stringToAdd];
            NSLog(@"channels description %@",[channels description]);
        }
        
    }
    if ([channels count] > 0) {
       
        if (!self.ladderPref.simRanked) {
            PFPush *push = [[PFPush alloc] init];
            
            [push setChannels:channels];
            
            NSString *message;
            message = [NSString stringWithFormat: @"%@ has sent his networks a %@ game request",self.ladderPref.user.displayName, self.ladderPref.sport]; // TO DO add more information in push request
            
            [push setMessage:message];
            NSLog(@"Breaking 4");
            NSLog(@"push description %@",[push description]);
            [push sendPushInBackground];
            NSLog(@"Breaking 5");
        }
        else{
            PFQuery *pushQuery = [PFInstallation query];
            
            NSLog(@"creating similarly ranked push");
            
            [pushQuery whereKey:@"user" matchesQuery:[self getUserArrayForPush]];
            
            PFPush *push = [[PFPush alloc] init];
            [push setQuery:pushQuery];
            
            NSString *message;
            message = [NSString stringWithFormat: @"%@ has requested a game of %@",self.ladderPref.user.displayName, self.ladderPref.sport]; // TO DO add more information in push request
            
            [push setMessage:message];
            [push sendPushInBackground];
            NSLog(@"push sent in background");
        }

    }
    
}


-(PFQuery *)getUserArrayForPush
{
    NSLog(@"In user array for push");
    
    RA_ParseUser *cUser = [RA_ParseUser currentUser];
    
    [cUser fetch];
    
    NSMutableArray *userArrays = [NSMutableArray array];
    NSMutableArray *idArray = [NSMutableArray array];
    
    for(RA_ParseNetwork *network in self.ladderPref.networks){
        [network fetch];
        
        if ([network.type isEqualToString:@"special"]) {
            NSLog(@"network is classified as special - no push sent");
        }
        else{
            NSLog(@"added network to idArray");
            [idArray addObject:network];
        }
    }
    
    for(RA_ParseNetwork *network in idArray){
        
        NSLog(@"going through the ranking stuff now");
        
        NSInteger myRank = [[network.userIdsToRanks valueForKey:cUser.objectId]integerValue];
        
        NSLog(@"my rank is %li",(long)myRank);
        
        NSMutableArray *newArray = [NSMutableArray array];
        for(NSString *key in [network.userIdsToScores allKeys]){
        [newArray addObject:key];
        }
        NSLog(@"newArray description %@",newArray);
        NSLog(@"newArray count %lu",(unsigned long)[newArray count]);
        
        NSMutableArray *membersMut = [NSMutableArray array];
        
        if ([newArray count] < 10) {
            NSLog(@"newArray is less than 10 people");
            [userArrays addObjectsFromArray:newArray];
        }
        else if([newArray count] > 10 && [newArray count] <21){
            for (id key in network.userIdsToRanks) {
                
                NSInteger ranks = [[network.userIdsToRanks valueForKey:key]integerValue];
                if (ranks < myRank + 5 || ranks > myRank -5 ) {
                    [membersMut addObject:key];
                }
                else{
                    NSLog(@"Do nothing since he's not in the right ranking area");
                }
            }
            [userArrays addObjectsFromArray:membersMut];
        }
        else if ([newArray count] > 20 && [newArray count] <31){
            for (id key in network.userIdsToRanks) {
                
                NSInteger ranks = [[network.userIdsToRanks valueForKey:key]integerValue];
                if (ranks < myRank + 8 || ranks > myRank -8 ) {
                    [membersMut addObject:key];
                }
                else{
                    NSLog(@"Do nothing since he's not in the right ranking area");
                }
            }
            [userArrays addObjectsFromArray:membersMut];
        }
        else if ([newArray count] > 30 && [newArray count] <51){
            for (id key in network.userIdsToRanks) {
                
                NSInteger ranks = [[network.userIdsToRanks valueForKey:key]integerValue];
                if (ranks < myRank + 12 || ranks > myRank -12 ) {
                    [membersMut addObject:key];
                }
                else{
                    NSLog(@"Do nothing since he's not in the right ranking area");
                }
            }
            [userArrays addObjectsFromArray:membersMut];
        }
        else if ([newArray count] > 50){
            for (id key in network.userIdsToRanks) {
                
                NSInteger ranks = [[network.userIdsToRanks valueForKey:key]integerValue];
                if (ranks < myRank + 15 || ranks > myRank -15 ) {
                    [membersMut addObject:key];
                }
                else{
                    NSLog(@"Do nothing since he's not in the right ranking area");
                }
            }
            [userArrays addObjectsFromArray:membersMut];
        }
        NSLog(@"userArrays description again %@",[userArrays description]);

    }
    
    NSLog(@"running query");
    PFQuery *query = [RA_ParseUser query];
    query.cachePolicy = kPFCachePolicyNetworkOnly;
    [query whereKey:@"objectId" containedIn:userArrays];
    
    [query findObjects];
    NSLog(@"query description %@",[query description]);
    return query;
}



@end
