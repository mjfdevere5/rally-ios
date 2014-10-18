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
@property (nonatomic) NSNumber *rightNewElo;
@property (nonatomic) NSNumber *leftNewElo;
@property (nonatomic) NSNumber *resultLeft;
@property (nonatomic) NSNumber *resultRight;
@property (nonatomic) NSDictionary *updatedScores;

@property (nonatomic) RA_ParseBroadcast *broadcast;

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


#pragma mark - picker view and text field
// ******************** picker view and text field ********************

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

-(void)inputAccessoryViewDone
{
    // Update scores in the game object
    if (self.leftSelection || self.rightSelection) {
        self.game.scores = [NSDictionary dictionaryWithObjectsAndKeys:
                            self.scoreArray[self.leftSelection],self.leftPlayer.objectId,
                            self.scoreArray[self.rightSelection],self.rightPlayer.objectId, nil];
        
        // Bruno add code
        
        RA_ParseNetwork *network = self.game.network;
        
        NSLog(@"fetching network if needed");
        [network fetchIfNeeded];
        
        NSNumber *leftNumber = [NSNumber numberWithInteger:self.leftSelection];
        NSNumber *rightNumber = [NSNumber numberWithInteger:self.rightSelection];
        
        self.broadcast = [RA_ParseBroadcast object];
        
        NSMutableArray *visibilityArray = [NSMutableArray arrayWithArray:self.leftPlayer.networkMemberships];
        NSMutableArray *rightVisibilityArray = [NSMutableArray arrayWithArray:self.rightPlayer.networkMemberships];
        
        [visibilityArray addObjectsFromArray:rightVisibilityArray];
        
        self.broadcast.userOne = self.leftPlayer;
        self.broadcast.userTwo = self.rightPlayer;
        self.broadcast.leftUserDisplayName = self.leftPlayer.username;
        self.broadcast.rightUserDisplayName = self.rightPlayer.username;
        self.broadcast.leftUserScore = leftNumber;
        self.broadcast.rightUserScore = rightNumber;
        self.broadcast.visibility = rightVisibilityArray;
        self.broadcast.type = @"score";

        // Grab the current scores for the players
        
        NSDictionary *currentPlayerScores = [self getPlayerScoresWith:network.objectId];
        
        // Now get the updated scores
        
        if (self.leftSelection > self.rightSelection) {
            if ([self.game.network.type isEqualToString:@"Ladder"]) {
                self.resultLeft = [NSNumber numberWithDouble:1.0];
                self.resultRight = [NSNumber numberWithDouble:0.0];
                [self performEloScoreUpdate:currentPlayerScores];
            }
            else{
                self.resultLeft = [NSNumber numberWithBool:2.0];
                self.resultRight = [NSNumber numberWithBool:0.0];
                [self getScoreUpdateForLeague:currentPlayerScores];
            }
        }
        else if (self.leftSelection < self.rightSelection){
            if ([self.game.network.type isEqualToString:@"Ladder"]) {
                self.resultLeft = [NSNumber numberWithDouble:0.0];
                self.resultRight = [NSNumber numberWithDouble:1.0];
                [self performEloScoreUpdate:currentPlayerScores];
            }
            else{
                self.resultLeft = [NSNumber numberWithBool:0.0];
                self.resultRight = [NSNumber numberWithBool:2.0];
                [self getScoreUpdateForLeague:currentPlayerScores];
            }
        }
        else{
            if ([self.game.network.type isEqualToString:@"Ladder"]) {
                self.resultLeft = [NSNumber numberWithDouble:0.5];
                self.resultRight = [NSNumber numberWithDouble:0.5];
                [self performEloScoreUpdate:currentPlayerScores];
            }
            else{
                self.resultLeft = [NSNumber numberWithBool:1.0];
                self.resultRight = [NSNumber numberWithBool:1.0];
                [self getScoreUpdateForLeague:currentPlayerScores];
            }
        }
        
        [network.userIdsToScores setValue:[self.updatedScores objectForKey:self.leftPlayer.objectId] forKey:self.leftPlayer.objectId];
        
        [network.userIdsToScores setValue:[self.updatedScores objectForKey:self.rightPlayer.objectId] forKey:self.rightPlayer.objectId];
        
        [network saveInBackground];
        [self.broadcast saveInBackground];
        [self.game saveInBackground];
    
    }
    
    // Hide the keyboard
    [self.scoreField resignFirstResponder];
}

-(void)inputAccessoryViewCancel
{
    // Configure outlet
    [self configureScores];
    
    // Hide the keyboard
    [self.scoreField resignFirstResponder];
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([self.game hasScore]) {
        return NO;
    }
    else {
        return YES;
    }
}


#pragma mark - segue
// ******************** segue ********************

-(void)segueToLeftPlayer:(id)sender
{ COMMON_LOG
    RA_UserProfileDynamicTable *userProfile = [[RA_UserProfileDynamicTable alloc] initWithUser:self.leftPlayer
                                                                                    andContext:RA_UserProfileContextGameManager];
    [self.parentViewController.navigationController pushViewController:userProfile animated:YES];
}

-(void)segueToRightPlayer:(id)sender
{ COMMON_LOG
    RA_UserProfileDynamicTable *userProfile = [[RA_UserProfileDynamicTable alloc] initWithUser:self.rightPlayer
                                                                                    andContext:RA_UserProfileContextGameManager];
    [self.parentViewController.navigationController pushViewController:userProfile animated:YES];
}



-(NSDictionary *)getPlayerScoresWith:(NSString *)networkId
{
    NSLog(@"into getPlayerScorewWith");
    RA_ParseNetwork *network = [RA_ParseNetwork objectWithoutDataWithObjectId:networkId];
    [network fetch];
    NSNumber *leftPlayerUserScore = [network.userIdsToScores objectForKey:self.leftPlayer.objectId];
    NSNumber *rightPlayerUserScore = [network.userIdsToScores objectForKey:self.rightPlayer.objectId];
    
    NSDictionary *playerScores = [NSDictionary dictionaryWithObjectsAndKeys:leftPlayerUserScore,self.leftPlayer.objectId,rightPlayerUserScore,self.rightPlayer.objectId, nil];
    return playerScores;
}


-(void)performEloScoreUpdate:(NSDictionary *)currentPlayerScores
{
    NSLog(@"into Elo score update");
    int kValue = 32; // Perhaps this should go into app constants - Max I'll let you sort this out
    
    double resultNumber = [self.resultLeft doubleValue];
    double resultNumberRight = [self.resultRight doubleValue];
    
    
    NSNumber *leftCurrentScore = [currentPlayerScores objectForKey:self.leftPlayer.objectId];
    NSNumber *rightCurrentScore = [currentPlayerScores objectForKey:self.rightPlayer.objectId];
    
    // Turn the numbers into doubles for calculation
    
    double leftCScore = [leftCurrentScore doubleValue];
    double rightCScore = [rightCurrentScore doubleValue];
    
    // Work out left player updated Elo score
    
    double expectedWinLeft = 1 / ( 1 + pow(10, ((rightCScore - leftCScore) / 400 )));
    double newEloNumberLeft = leftCScore + (kValue * (resultNumber - expectedWinLeft));
    self.leftNewElo = [NSNumber numberWithInt:newEloNumberLeft];
    
    // Work out right player updated Elo score
    
    double expectedWinRight = 1 / ( 1 + pow(10, ((leftCScore - rightCScore) / 400 )));
    double newEloNumberRight = rightCScore + (kValue * (resultNumberRight - expectedWinRight));
    self.rightNewElo = [NSNumber numberWithInt:newEloNumberRight];
    
    // Put the scores back in a dictionary
    
    self.updatedScores = [NSDictionary dictionaryWithObjectsAndKeys:self.leftNewElo,self.leftPlayer.objectId, self.rightNewElo,self.rightPlayer.objectId, nil];
}

-(void)getScoreUpdateForLeague:(NSDictionary *)currentPlayerScores
{
    double resultNumber = [self.resultLeft doubleValue];
    double resultNumberRight = [self.resultRight doubleValue];
    double pointForTurningUp = 1.0;
    
    NSNumber *leftCurrentScore = [currentPlayerScores objectForKey:self.leftPlayer.objectId];
    NSNumber *rightCurrentScore = [currentPlayerScores objectForKey:self.rightPlayer.objectId];
    
    double leftCScore = [leftCurrentScore doubleValue];
    double rightCScore = [rightCurrentScore doubleValue];
    
    double updatedLeftScore = leftCScore + resultNumber + self.leftSelection + pointForTurningUp;
    double updatedRightScore = rightCScore + resultNumberRight + self.rightSelection + pointForTurningUp;
    
    NSNumber *updatedLScore = [NSNumber numberWithDouble:updatedLeftScore];
    NSNumber *updatedRScore = [NSNumber numberWithDouble:updatedRightScore];
    
    self.updatedScores = [NSDictionary dictionaryWithObjectsAndKeys:updatedLScore,self.leftPlayer.objectId, updatedRScore, self.rightPlayer.objectId, nil];
}



@end


