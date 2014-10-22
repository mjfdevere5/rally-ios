//
//  RA_GameViewPlayersHistoricCell.m
//  Rally
//
//  Created by Max de Vere on 10/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_GameViewPlayersHistoricCell.h"
#import "UIImage+ProfilePicHandling.h"
#import "RA_UserProfileDynamicTable.h"
#import "RA_ParseBroadcast.h"

@interface RA_GameViewPlayersHistoricCell()

// Players
@property (strong, nonatomic) RA_ParseUser *leftPlayer;
@property (strong, nonatomic) RA_ParseUser *rightPlayer;

// UIPickerView
@property (strong, nonatomic) NSArray *scoreArray; // Array of NSNumbers
@property (nonatomic) NSInteger leftSelection;
@property (nonatomic) NSInteger rightSelection;

// New properties from Bruno
@property (nonatomic) double resultLeft;
@property (nonatomic) double resultRight;

@end


@implementation RA_GameViewPlayersHistoricCell


#pragma mark - load up and configure
// ******************** load up and configure ********************

-(void)viewDidLoad
{ COMMON_LOG
    // Doesn't seem to run?
}

-(void)configureCell
{ COMMON_LOG
    // Configure the score picker stuff
    [self configureScorePicker];
    
    // Set leftPlayer, rightPlayer properties
    [self assignPlayers];
    
    // Names
    self.leftName.text = self.leftPlayer.displayName;
    self.rightName.text = self.rightPlayer.displayName;
    
    // Score
    [self configureScores];
    if (![[self.game gameStatus] isEqualToString:RA_GAME_STATUS_COMPLETED]) {
        [self.scoreField removeFromSuperview];
    }
    
    // Profile pics and activity wheels
    PFFile *leftPlayerPicFile = self.leftPlayer.profilePicMedium;
    if (!leftPlayerPicFile.isDataAvailable) {
        [self.leftActivityWheel startAnimating];
    }
    [leftPlayerPicFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        UIImage *leftPlayerPicRaw = [UIImage imageWithData:data];
        UIImage *leftPlayerPicCircular = [leftPlayerPicRaw getImageCircularWithRadius:self.leftPic.frame.size.width];
        self.leftPic.image = leftPlayerPicCircular;
        [self.leftActivityWheel stopAnimating];
    }];
    PFFile *rightPlayerPicFile = self.rightPlayer.profilePicMedium;
    if (!rightPlayerPicFile.isDataAvailable) {
        [self.rightActivityWheel startAnimating];
    }
    [rightPlayerPicFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        UIImage *rightPlayerPicRaw = [UIImage imageWithData:data];
        UIImage *rightPlayerPicCircular = [rightPlayerPicRaw getImageCircularWithRadius:self.rightPic.frame.size.width];
        self.rightPic.image = rightPlayerPicCircular;
        [self.rightActivityWheel stopAnimating];
    }];
    
    // Make images respond to touches
    UITapGestureRecognizer *leftPicTap = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(segueToLeftPlayer:)];
    UITapGestureRecognizer *rightPicTap = [[UITapGestureRecognizer alloc]
                                           initWithTarget:self action:@selector(segueToRightPlayer:)];
    self.leftPic.userInteractionEnabled = YES;
    [self.leftPic addGestureRecognizer:leftPicTap];
    self.rightPic.userInteractionEnabled = YES;
    [self.rightPic addGestureRecognizer:rightPicTap];
}

-(void)configureScorePicker
{ COMMON_LOG
    // Assign a picker view to the textfield's input view
    UIPickerView *doublePicker = [[UIPickerView alloc] init];
    doublePicker.delegate = self;
    self.scoreField.inputView = doublePicker;
    
    // Set the data source stuff
    self.scoreArray = @[@0, @1, @2, @3, @4, @5, @6];
    
    // Assign a toolbar to the textfield's input accessory view
    UIToolbar *myToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0, 320, 44)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self
                                                                                action:@selector(inputAccessoryViewDone)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                  target:self
                                                                                  action:@selector(inputAccessoryViewCancel)];
    [myToolbar setItems:[NSArray arrayWithObjects: cancelButton, doneButton, nil] animated:NO];
    self.scoreField.inputAccessoryView = myToolbar;
}

-(void)assignPlayers
{ COMMON_LOG
    // See if current user is a member
    // Using if([cUser.networkMemberships containsObject:network]) does not work, so we have to use the objectId
    NSArray *playerIds = [self.game.players valueForKeyPath:@"objectId"];
    if ([playerIds containsObject:[RA_ParseUser currentUser].objectId]) {
        self.leftPlayer = [RA_ParseUser currentUser];
        self.rightPlayer = [self.game opponent];
    }
    else {
        self.leftPlayer = self.game.players[0];
        self.rightPlayer = self.game.players[1];
    }
}

-(void)configureScores
{ COMMON_LOG
    NSString *output = nil;
    
    if ([self.game hasScore]) {
        NSNumber *leftScore = [self.game.scores objectForKey:self.leftPlayer.objectId];
        NSString *leftScoreString = [leftScore stringValue];
        NSNumber *rightScore = [self.game.scores objectForKey:self.rightPlayer.objectId];
        NSString *rightScoreString = [rightScore stringValue];
        output = [NSString stringWithFormat:@"%@ - %@", leftScoreString, rightScoreString];
    }
    
    self.scoreField.text = output;
}


#pragma mark - text field delegate and picker view date source
// ******************** text field delegate and picker view date source ********************

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.scoreArray count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self.scoreArray[row] stringValue];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.leftSelection = [pickerView selectedRowInComponent:0];
    self.rightSelection = [pickerView selectedRowInComponent:1];
    self.scoreField.text = [NSString stringWithFormat:@"%@ - %@",
                            [self.scoreArray[self.leftSelection] stringValue],
                            [self.scoreArray[self.rightSelection] stringValue]];
}


#pragma mark - score is uploaded
// ******************** score is uploaded ********************

-(void)inputAccessoryViewDone
{ COMMON_LOG
    // Hide the keyboard
    [self.scoreField resignFirstResponder];
    if (self.leftSelection || self.rightSelection) // Prevents accidental lock-in for nil-nil draw
    {
        // This is all going to take some time so we'll show the HUD
        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.parentViewController.navigationController.view];
        [self.parentViewController.navigationController.view addSubview:HUD];
        [HUD showAnimated:YES whileExecutingBlock:^{
            NSMutableArray *objectsToBeSaved = [NSMutableArray array];
            
            // Update and save game object
            self.game.scores = [NSDictionary dictionaryWithObjectsAndKeys:
                                self.scoreArray[self.leftSelection],self.leftPlayer.objectId,
                                self.scoreArray[self.rightSelection],self.rightPlayer.objectId, nil];
            [objectsToBeSaved addObject:self.game];
            
            // Calculate and save ELO movements
            NSArray *networks = [self.game getNetworksInCommonForPlayers]; // Takes a while
            for (RA_ParseNetwork *network in networks) {
                [self executeScoreMovementsForNetwork:network];
                [objectsToBeSaved addObject:network];
            }
            
            // Create and save broadcast
            RA_ParseBroadcast *broadcast = [RA_ParseBroadcast object];
            NSMutableArray *visibilityArray = [NSMutableArray arrayWithArray:self.leftPlayer.networkMemberships];
            NSMutableArray *rightVisibilityArray = [NSMutableArray arrayWithArray:self.rightPlayer.networkMemberships];
            [visibilityArray addObjectsFromArray:rightVisibilityArray];
            broadcast.userOne = self.leftPlayer;
            broadcast.userTwo = self.rightPlayer;
            broadcast.visibility = rightVisibilityArray;
            broadcast.type = RA_BROADCAST_TYPE_SCORE;
            broadcast.game = self.game;
            [objectsToBeSaved addObject:broadcast];
            
            // Upload everything
            [PFObject saveAll:objectsToBeSaved];
        }];
        
        MBProgressHUD *HUDTWO = [[MBProgressHUD alloc] initWithView:self.parentViewController.navigationController.view];
        [self.parentViewController.navigationController.view addSubview:HUD];
        [HUDTWO showAnimated:YES whileExecutingBlock:^{
        
            NSArray *networks = [self.game getNetworksInCommonForPlayers]; // Takes a while
            for (RA_ParseNetwork *network in networks) {
                [self updateRanksForPlayers:network];
                [network save];
            }
        }];

    }
}

-(void)executeScoreMovementsForNetwork:(RA_ParseNetwork *)network // (BACKGROUND ONLY)
{ COMMON_LOG
    [network fetch];
    if ([network.type isEqualToString:@"Ladder"]) {
        if (self.leftSelection > self.rightSelection) {
            self.resultLeft = 1.0;
            self.resultRight = 0.0;
        }
        else if (self.rightSelection > self.leftSelection) {
            self.resultLeft = 0.0;
            self.resultRight = 1.0;
        }
        else {
            self.resultLeft = 0.5;
            self.resultRight = 0.5;
        }
        [self updateEloScores:network.userIdsToScores];
    }
    else if ([network.type isEqualToString:@"League"]) {
        if (self.leftSelection > self.rightSelection) {
            self.resultLeft = 2.0;
            self.resultRight = 0.0;
        }
        else if (self.rightSelection > self.leftSelection) {
            self.resultLeft = 0.0;
            self.resultRight = 2.0;
        }
        else {
            self.resultLeft = 1.0;
            self.resultRight = 1.0;
        }
        [self updateLeagueScores:network.userIdsToScores];
    }
    else {
        COMMON_LOG_WITH_COMMENT(@"ERROR: Unexpected network.type")
    }
}

-(void)updateEloScores:(NSMutableDictionary *)scores
{ COMMON_LOG
    int kValue = 32; // Perhaps this should go into app constants - Max I'll let you sort this out
    
    // Turn scores into doubles
    double leftCScore = [[scores objectForKey:self.leftPlayer.objectId] doubleValue];
    double rightCScore = [[scores objectForKey:self.rightPlayer.objectId] doubleValue];
    
    // Calculate updated scores
    double expectedWinLeft = 1 / ( 1 + pow(10, ((rightCScore - leftCScore) / 400 )));
    double newEloNumberLeft = leftCScore + (kValue * (self.resultLeft - expectedWinLeft));
    NSNumber *leftNewElo = [NSNumber numberWithInt:newEloNumberLeft];
    double expectedWinRight = 1 / ( 1 + pow(10, ((leftCScore - rightCScore) / 400 )));
    double newEloNumberRight = rightCScore + (kValue * (self.resultRight - expectedWinRight));
    NSNumber *rightNewElo = [NSNumber numberWithInt:newEloNumberRight];
    
    // Put the scores back in a dictionary
    [scores setValue:leftNewElo forKey:self.leftPlayer.objectId];
    [scores setValue:rightNewElo forKey:self.rightPlayer.objectId];
}

-(void)updateLeagueScores:(NSMutableDictionary *)scores
{ COMMON_LOG
    double pointForTurningUp = 1.0;
    
    // Turn scores into doubles
    double leftCScore = [[scores objectForKey:self.leftPlayer.objectId] doubleValue];
    double rightCScore = [[scores objectForKey:self.rightPlayer.objectId] doubleValue];
    
    // Calculate updated scores
    double updatedLeftScore = leftCScore + self.resultLeft + self.leftSelection + pointForTurningUp;
    double updatedRightScore = rightCScore + self.resultRight + self.rightSelection + pointForTurningUp;
    
    // Turn back into NSNumber
    NSNumber *updatedLScore = [NSNumber numberWithDouble:updatedLeftScore];
    NSNumber *updatedRScore = [NSNumber numberWithDouble:updatedRightScore];
    
    // Put into dictionary
    [scores setValue:updatedLScore forKey:self.leftPlayer.objectId];
    [scores setValue:updatedRScore forKey:self.rightPlayer.objectId];
}

-(void)inputAccessoryViewCancel
{
    // Configure outlet
    [self configureScores];
    
    // Hide the keyboard
    [self.scoreField resignFirstResponder];
}


#pragma mark - segue
// ******************** segue ********************

-(void)segueToLeftPlayer:(id)sender
{ COMMON_LOG
    if (![self.leftPlayer.objectId isEqualToString:[RA_ParseUser currentUser].objectId]) {
        RA_UserProfileDynamicTable *userProfile = [[RA_UserProfileDynamicTable alloc] initWithUser:self.leftPlayer
                                                                                        andContext:RA_UserProfileContextGameManager];
        [self.parentViewController.navigationController pushViewController:userProfile animated:YES];
    }
}

-(void)segueToRightPlayer:(id)sender
{ COMMON_LOG
    if (![self.rightPlayer.objectId isEqualToString:[RA_ParseUser currentUser].objectId]) {
        RA_UserProfileDynamicTable *userProfile = [[RA_UserProfileDynamicTable alloc] initWithUser:self.rightPlayer
                                                                                        andContext:RA_UserProfileContextGameManager];
        [self.parentViewController.navigationController pushViewController:userProfile animated:YES];
    }
}



-(void)updateRanksForPlayers: (RA_ParseNetwork *)network
{
    [network fetch];
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    dictionary = network.userIdsToScores;
    NSArray *orderedIds = [dictionary keysSortedByValueUsingComparator:
                           ^NSComparisonResult(id obj1, id obj2) {
                               return [obj2 compare:obj1];
                           }];
    for(NSString *userIds in orderedIds){
        unsigned long rank;
        rank = [orderedIds indexOfObject:userIds] + 1;
        NSNumber *rankNumber = [NSNumber numberWithLong:rank];
        [network.userIdsToRanks setValue:rankNumber forKey:userIds];
    }
}


@end


