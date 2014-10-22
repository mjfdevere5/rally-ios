//
//  RA_LadderForm.m
//  Rally
//
//  Created by Max de Vere on 19/09/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_NextGamePrefOne.h"
#import "RA_GamePrefConfig.h"
#import "RA_ParseGamePreferences.h"
#import "AppConstants.h"
#import "MBProgressHUD.h"
#import "RA_NextGameNetworkCheckmarkCell.h"


@interface RA_NextGamePrefOne ()<MBProgressHUDDelegate>
@property (strong, nonatomic) NSArray *cellArray;
@property (strong, nonatomic) NSArray *myNetworks;
@property (strong, nonatomic) NSString *loadedSport;
@end


@implementation RA_NextGamePrefOne


#pragma mark - load up
// ******************** load up ********************

- (void)viewDidLoad
{ COMMON_LOG
    [super viewDidLoad];
    
    // Navbar
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    self.navigationItem.title = @"Game setup";
    
    // Form formatting
    self.tableView.backgroundColor = RA_TEST_WHITE;
    self.view.backgroundColor = RA_TEST_WHITE;
    self.separatorLine.backgroundColor = RA_TEST_BLUE2;
    
    
    
    // Additional formatting
    CALayer *btnLayer = [self.button layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:0.0f];
    
    // Set the gamePrefConfig defaults
    [[RA_GamePrefConfig gamePrefConfig] resetToDefaults];
    
    // Set the loadedSport
    self.loadedSport = [RA_GamePrefConfig gamePrefConfig].sport; // Note, sets to nil initially
    
    // Show a HUD and load the table up
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.delegate = self;
    [HUD showAnimated:YES whileExecutingBlock:^{
        [self prepareTableRows]; // Note, searches for networks with sport nil initially (loads nothing)
    } completionBlock:^{
        [self.tableView reloadData];
    }];
}

-(void)prepareTableRows // (BACKGROUND ONLY)
{ COMMON_LOG
    // First make sure we have the network objects to hand
    [[RA_ParseUser currentUser] fetch];
    [PFObject fetchAllIfNeeded:[RA_ParseUser currentUser].networkMemberships];
    COMMON_LOG_WITH_COMMENT([[RA_ParseUser currentUser].networkMemberships description])
    // Use NSPredicate to filter the array
    NSMutableArray *filteredArray = [NSMutableArray array];
    for (RA_ParseNetwork *network in [RA_ParseUser currentUser].networkMemberships) {
        if ([network.sport isEqualToString:self.loadedSport]) {
            [filteredArray addObject:network];
        }
    }
    self.myNetworks  = [NSArray arrayWithArray:filteredArray];
    
    // Now build self.cellArray as an array of arrays (sections and rows)
    NSMutableArray *networkSectionMut = [NSMutableArray array];
    for (int i=0 ; i<[self.myNetworks count] ; i++) {
        [networkSectionMut addObject:@"nextgame_network_cell"];
    }
    [networkSectionMut addObject:@"nextgame_similarlyranked_cell"];
    NSArray *networkSection = [NSArray arrayWithArray:networkSectionMut];
    self.cellArray = @[@[@"nextgame_picksport_cell"], networkSection];
    COMMON_LOG_WITH_COMMENT([self.cellArray description])
}


#pragma mark - tableview data source
// ******************** tableview data source ********************

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.cellArray count]; // Should be 2
    NSLog(@"%lu", (unsigned long) [self.cellArray count]);
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *rowsInSection = self.cellArray[section];
    NSInteger numberOfRows = [rowsInSection count];
    return numberOfRows;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title;
    switch (section) {
        case 0:
            title = @"Sport";
            break;
        case 1:
            title = @"Who do you challenge?";
            break;
        default:
            title = @"Hmm...";
            COMMON_LOG_WITH_COMMENT(@"ERROR: Unexpected section")
            break;
    }
    return title;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId = self.cellArray[indexPath.section][indexPath.row];
    if ([cellId isEqualToString:@"nextgame_picksport_cell"]) {
        return 65.0;
    }
    else if ([cellId isEqualToString:@"nextgame_network_cell"]) {
        return 44.0;
    }
    else if ([cellId isEqualToString:@"nextgame_similarlyranked_cell"]) {
        return 65.0; // TO DO
    }
    else {
        return 44.0;
        COMMON_LOG_WITH_COMMENT(@"ERROR: Unexpected cellId")
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{ COMMON_LOG_WITH_COMMENT([indexPath description])
    // Dequeue
    NSString *reuseIdentifier = self.cellArray[indexPath.section][indexPath.row];
    COMMON_LOG_WITH_COMMENT(@"Test: 0")
    RA_NextGameBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    COMMON_LOG_WITH_COMMENT(@"Test: 1")
    
    // Special case: network cells handled in here
    if ([cell isKindOfClass:[RA_NextGameNetworkCheckmarkCell class]]) {
        RA_ParseNetwork *network = self.myNetworks[indexPath.row];
        RA_NextGameNetworkCheckmarkCell *castCell = (RA_NextGameNetworkCheckmarkCell *)cell;
        castCell.network = network;
    }
    COMMON_LOG_WITH_COMMENT(@"Test: 2")
    
    // Configuration
    cell.viewControllerDelegate = self;
    COMMON_LOG_WITH_COMMENT(@"Test: 3")
    
    [cell configureCell];
    COMMON_LOG_WITH_COMMENT(@"Test: 4")
    
    // Return
    return cell;
}


#pragma mark - tableview delegate
// ******************** tableview delegate ********************

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{ COMMON_LOG
    RA_NextGameBaseCell *cell = (RA_NextGameBaseCell *)[tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[RA_NextGameNetworkCheckmarkCell class]]) {
        COMMON_LOG_WITH_COMMENT(@"Tapped cell is a network checkmark cell")
        RA_NextGameNetworkCheckmarkCell *castCell = (RA_NextGameNetworkCheckmarkCell *)cell;
        if ([[RA_GamePrefConfig gamePrefConfig] containsNetwork:castCell.network]) {
            [[RA_GamePrefConfig gamePrefConfig] removeNetwork:castCell.network];
        }
        else {
            [[RA_GamePrefConfig gamePrefConfig].networks addObject:castCell.network];
        }
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}


#pragma mark - cell delegate
// ******************** cell delegate ********************

-(void)didPickSport;
{ COMMON_LOG
    if (![[RA_GamePrefConfig gamePrefConfig].sport isEqualToString:self.loadedSport]) {
        // Update sport
        self.loadedSport = [RA_GamePrefConfig gamePrefConfig].sport;
        
        // Take a note of how many rows to delete
        NSInteger rowsToDelete = [self.myNetworks count];
        
        // Show a HUD
        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:HUD];
        HUD.delegate = self;
        [HUD showAnimated:YES whileExecutingBlock:^{
            // Recalculate which rows we need
            [self prepareTableRows];
        } completionBlock:^{
            // Take a note of how many rows to insert
            NSInteger rowsToInsert = [self.myNetworks count];
            
            // Update networks selected
            [RA_GamePrefConfig gamePrefConfig].networks = [NSMutableArray arrayWithArray:self.myNetworks];
            
            // Prepare for animation
            NSMutableArray *indexPathsToDelete = [NSMutableArray array];
            for (int row=0 ; row < rowsToDelete ; row++) {
                [indexPathsToDelete addObject:[NSIndexPath indexPathForRow:row inSection:1]];
            }
            NSMutableArray *indexPathsToInsert = [NSMutableArray array];
            for (int row=0 ; row < rowsToInsert ; row++) {
                [indexPathsToInsert addObject:[NSIndexPath indexPathForRow:row inSection:1]];
            }
            
            // Animation
            [self.tableView beginUpdates];
            [self.tableView deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:indexPathsToInsert withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView endUpdates];
        }];
    }
}


#pragma mark - move to next view
// ******************** move to next view ********************

-(IBAction)setPrefButtonPushed:(UIButton *)button
{ COMMON_LOG
    if (![RA_GamePrefConfig gamePrefConfig].sport) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not so fast!"
                                                        message:@"You haven't selected a sport"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    else if ([[RA_GamePrefConfig gamePrefConfig].networks count] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not so fast!"
                                                        message:@"You need to select at least one network"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    else {
        [self performSegueWithIdentifier:@"goto_preferences2" sender:self];
    }
}


@end



