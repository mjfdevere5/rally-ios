//
//  RA_GameView.m
//  Rally
//
//  Created by Max de Vere on 10/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_GameView.h"
#import "NSDate+Utilities.h"
#import "RA_GameViewBaseCell.h"
#import "RA_GameViewConfirmNowCell.h"
#import "RA_GameViewCancelCell.h"
#import "NSDate+CoolStrings.h"
#import "RA_UserProfileDynamicTable.h"
#import "RA_ParseBroadcast.h"

@interface RA_GameView ()

// Stuff for loading up the table
@property (strong, nonatomic) NSArray *cellArray;
@property (nonatomic) BOOL isUpcoming;

// Keep references to cells
@property (strong, nonatomic) NSMutableDictionary *cells; // maps reuseIdentifiers to cell objects

@end


@implementation RA_GameView


#pragma mark - load up
// ******************** load up ********************


- (void)viewDidLoad
{
    COMMON_LOG
    
    [super viewDidLoad];
    
    // Error catching
    if (!self.game) {
        COMMON_LOG_WITH_COMMENT(@"ERROR: self.game not found")
        return;
    }
    
    // Navbar
    self.navigationItem.title = [NSString stringWithFormat:@"Game Manager"];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    
    // Initialise mutable properties
    self.cells = [NSMutableDictionary dictionary];
    
    // Table footer
    // Prevents unused rows from appearing
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView.backgroundColor = [UIColor clearColor];
    
    // Load cells into self.cellArray
    [self loadCellArray];
    
    // Reload tableView
    [self.tableView reloadData];
}



-(void)loadCellArray
{
    COMMON_LOG
    
    NSMutableArray *cellArrayMut = [NSMutableArray array];
    self.isUpcoming = [self.game isUpcoming];
    
    // Coloured status cell
    [cellArrayMut addObject:@"game_status_cell"]; // will display "Confirmed", "Pending confirmation", "Cancelled"
    
    // 'Tap to confirm'
    if ([self.game actionForUpcomingGameRequiredByMe]) {
        [cellArrayMut addObject:@"game_confirm_now_cell"];
    }
    
    // Datetime cell
    [cellArrayMut addObject:@"game_datetime_cell"];
    
    // Players cell
    if (self.isUpcoming) {
        [cellArrayMut addObject:@"game_players_upcoming_cell"];
    }
    else {
        [cellArrayMut addObject:@"game_players_historic_cell"];
    }
    
    // Cancel cell
    if ([[self.game gameStatus] isEqualToString:RA_GAME_STATUS_PROPOSED] ||
        [[self.game gameStatus] isEqualToString:RA_GAME_STATUS_CONFIRMED] ||
        [[self.game gameStatus] isEqualToString:RA_GAME_STATUS_UNCONFIRMED]) {
        [cellArrayMut addObject:@"game_cancel_cell"];
    }
    
    self.cellArray = [NSArray arrayWithArray:cellArrayMut];
}



#pragma mark - tableview
// ******************** tableview ********************


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.cellArray count];
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Dequeue
    NSString *reuseIdentifier = self.cellArray[indexPath.row];
    
    //    @"game_status_cell"
    //    @"game_confirm_now_cell"
    //    @"game_datetime_cell"
    //    @"game_players_upcoming_cell"
    //    @"game_players_historic_cell"
    //    @"game_facilities_cell"
    //    @"game_cancel_cell"
    
    CGFloat height;
    
    if ([reuseIdentifier isEqualToString:@"game_status_cell"]) {
        height = 40.0;
    }
    else if ([reuseIdentifier isEqualToString:@"game_confirm_now_cell"]) {
        height = 35.0;
    }
    else if ([reuseIdentifier isEqualToString:@"game_datetime_cell"]) {
        height = 55.0;
    }
    else if ([reuseIdentifier isEqualToString:@"game_players_upcoming_cell"]) {
        height = 165.0;
    }
    else if ([reuseIdentifier isEqualToString:@"game_players_historic_cell"]) {
        height = 130.0;
    }
    else if ([reuseIdentifier isEqualToString:@"game_facilities_cell"]) {
        height = 40.0;
    }
    else if ([reuseIdentifier isEqualToString:@"game_cancel_cell"]) {
        height = 40.0;
    }
    else {
        height = 44.0;
        COMMON_LOG_WITH_COMMENT(@"ERROR: Unexpected row identifier")
    }
    
    return height;
}



-(RA_GameViewBaseCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Dequeue
    RA_GameViewBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellArray[indexPath.row] forIndexPath:indexPath];
    
    // Configure the cell
    cell.game = self.game;
    cell.parentViewController = self;
    [cell configureCell];
    
    // Keep a reference to the cell
    [self.cells setValue:cell forKey:self.cellArray[indexPath.row]];
    
    // Return the cell
    return cell;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    COMMON_LOG
    
//    @"game_status_cell"
//    @"game_confirm_now_cell"
//    @"game_datetime_cell"
//    @"game_players_upcoming_cell"
//    @"game_players_historic_cell"
//    @"game_facilities_cell"
//    @"game_cancel_cell"
    
    NSString *cellIdentifier = self.cellArray[indexPath.row];
    if ([cellIdentifier isEqualToString:@"game_confirm_now_cell"]) {
        [self processConfirmation];
    }
    else if ([cellIdentifier isEqualToString:@"game_cancel_cell"]) {
        [self showCancelAlert];
    }
}



#pragma mark - taps of cells
// ******************** taps of cells ********************


-(void)processConfirmation
{
    COMMON_LOG
    
    RA_GameViewConfirmNowCell *cell = [self.cells objectForKey:@"game_confirm_now_cell"];
    [cell.activityWheel startAnimating];
    cell.tapToConfirmLabel.text = @"Saving";
    
    
    // Addition of broadcast code to save
    
    NSArray *array = [NSArray arrayWithObject:self.game.players];
    
    NSLog(@"count in the array %lu",(unsigned long)[array count]);
    
    NSLog(@"array description %@",[array[0]description]);
    
    RA_ParseBroadcast *broadcast = [RA_ParseBroadcast object];
    
    RA_ParseUser *one = self.game.players[0];
    
    RA_ParseUser *two = self.game.players[1];
    [one fetchIfNeeded];
    [two fetchIfNeeded];
    
    
    
    NSLog(@"log of parse user %@",[one description]);
    NSLog(@"left user id %@",one.objectId);
    NSLog(@"right user id %@", two.objectId);
    
    
    broadcast.userOne = one;
    broadcast.userTwo = two;
    
    NSMutableArray *visibility = [NSMutableArray arrayWithObject:one.networkMemberships];
    NSMutableArray *visibilityRight = [NSMutableArray arrayWithObject:two.networkMemberships];
    [visibility addObjectsFromArray:visibilityRight];
    
    broadcast.game = self.game;
    broadcast.type = @"game_confirmed";
    broadcast.visibility = visibility;
    
    NSLog(@"description of the broadcast %@",[broadcast description]);
    
    [broadcast saveInBackground];
    
    
    // End of broadcast code to save
    
    
    
    [self.game.playerStatuses setValue:RA_GAME_STATUS_CONFIRMED forKey:[RA_ParseUser currentUser].objectId];
    [self.game saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        // Send push
        NSString *pushText = [NSString stringWithFormat:@"%@ CONFIRMED your game %@ at %@",
                              [RA_ParseUser currentUser].displayName,
                              [self.game.datetime getCommonSpeechWithOnDayLong:NO dateOrdinal:NO monthLong:NO],
                              [self.game.datetime getCommonSpeechClock]];
        PFPush *push = [self configurePushWithText:pushText];
        [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            // Upload broadcast
            [self performSelectorInBackground:@selector(uploadBroadcastForGame:) withObject:self.game];
            
            // Delete cell
            [self loadCellArray]; // This modifies the array that drives the tableview methods. Important to prevent a crash.
            COMMON_LOG_WITH_COMMENT([self.cellArray description])
            
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            // Update all cells
            [self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.3];
        }];
    }];
}
// TO DO
//-(void)processConfirmation
//{
//    COMMON_LOG
//
//    RA_GameViewConfirmNowCell *cell = [self.cells objectForKey:@"game_confirm_now_cell"];
//    [cell.activityWheel startAnimating];
//    cell.tapToConfirmLabel.text = @"Saving";
//    
//    //create broadcast
//    RA_ParseGame *game = self.game;
//    
//    [game fetchIfNeeded];
//    
//    NSArray *array = [NSArray arrayWithObject:self.game.players];
//    
//    NSLog(@"count in the array %lu",(unsigned long)[array count]);
//    
//    NSLog(@"array description %@",[array[0]description]);
//    
//    
//    RA_ParseBroadcast *broadcast = [RA_ParseBroadcast object];
//    
//    RA_ParseUser *left = self.game.players[0];
//    
//    RA_ParseUser *right = self.game.players[1];
//    [left fetch];
//    [right fetch];
//    RA_ParseNetwork *network = self.game.network;
//    [network fetch];
//    
//    NSLog(@"log of parse user %@",[left description]);
//    NSLog(@"left user id %@",left.objectId);
//    NSLog(@"right user id %@", right.objectId);
//    
//    
//    broadcast.leftUser = left;
//    broadcast.rightUser = right;
//    
//    NSMutableArray *visibility = [NSMutableArray arrayWithObject:left.networkMemberships];
//    NSMutableArray *visibilityRight = [NSMutableArray arrayWithObject:right.networkMemberships];
//    [visibility addObjectsFromArray:visibilityRight];
//    
//    broadcast.sportName = network.sport;
//    broadcast.date = self.game.datetime;
//    broadcast.type = @"game_confirmed";
//    broadcast.visibility = visibility;
//    
//    NSLog(@"description of the broadcast %@",[broadcast description]);
//    
//    [self.game.playerStatuses setValue:RA_GAME_STATUS_CONFIRMED forKey:[RA_ParseUser currentUser].objectId];
//    
//    NSArray *toUpload = [NSArray arrayWithObjects:broadcast,self.game, nil];
//    [PFObject saveAllInBackground:toUpload block:^(BOOL succeeded, NSError *error) {
//        // Send push
//        NSString *pushText = [NSString stringWithFormat:@"%@ CONFIRMED your game %@ at %@",
//                              [RA_ParseUser currentUser].displayName,
//                              [self.game.datetime getCommonSpeechWithOnDayLong:NO dateOrdinal:NO monthLong:NO],
//                              [self.game.datetime getCommonSpeechClock]];
//        PFPush *push = [self configurePushWithText:pushText];
//        [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//            
//            // Delete cell
//            [self loadCellArray]; // This modifies the array that drives the tableview methods. Important to prevent a crash.
//            COMMON_LOG_WITH_COMMENT([self.cellArray description])
//            
//            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
//            
//            // Update all cells
//            [self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.4];
//        }];
//    }];
//    
//}




-(void)showCancelAlert
{
    COMMON_LOG
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
                                                    message:@"Cancelling games is considered bad form, and will count against your score."
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"Yes, cancel the game", @"No", nil];
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    COMMON_LOG
    
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Yes, cancel the game"]) {
        RA_GameViewCancelCell *cell = [self.cells objectForKey:@"game_cancel_cell"];
        [cell.activityWheel startAnimating];
        [self.game.playerStatuses setValue:RA_GAME_STATUS_CANCELLED forKey:[RA_ParseUser currentUser].objectId];
        [self.game saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            // Send push to opponent
            NSString *pushText = [NSString stringWithFormat:@"%@ CANCELLED your game %@ at %@",
                                  [RA_ParseUser currentUser].displayName,
                                  [self.game.datetime getCommonSpeechWithOnDayLong:NO dateOrdinal:NO monthLong:NO],
                                  [self.game.datetime getCommonSpeechClock]];
            PFPush *push = [self configurePushWithText:pushText];
            [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                // Refresh the view
                [self loadCellArray];
                [self.tableView reloadData];
            }];
        }];
    }
}

-(void)uploadBroadcastForGame:(RA_ParseGame *)game // (BACKGROUND ONLY)
{
    RA_ParseBroadcast *broadcast = [RA_ParseBroadcast object];
    broadcast.type = RA_BROADCAST_TYPE_CONFIRMED;
    broadcast.userOne = [RA_ParseUser currentUser];
    broadcast.userTwo = [game opponent];
    
    broadcast.visibility = [game getNetworksInCommonForPlayers];
    broadcast.game = game;
    [broadcast save];
}



-(PFPush *)configurePushWithText:(NSString *)text
{
    COMMON_LOG
    
    // Initialise our push
    PFPush *push = [[PFPush alloc] init];
    
    // Push query
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"user" equalTo:[self.game opponent]];
    [push setQuery:pushQuery];
    
    // Push config
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          text, @"alert",
                          @"cheering.caf", @"sound",
                          @"Increment", @"badge",
                          nil];
    [push setData:data];
    
    // Return
    return push;
}



#pragma mark - text field delegate (scores)
// ******************** text field delegate (scores) ********************

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([self.game requiresActionOnScore]) {
        COMMON_LOG_WITH_COMMENT(@"yes")
        return YES;
    }
    else {
        COMMON_LOG_WITH_COMMENT(@"no")
        return NO;
    }
}




@end


