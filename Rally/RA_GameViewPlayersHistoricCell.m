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

@interface RA_GameViewPlayersHistoricCell()

// Players
@property (strong, nonatomic) RA_ParseUser *leftPlayer;
@property (strong, nonatomic) RA_ParseUser *rightPlayer;

// UIPickerView
@property (strong, nonatomic) NSArray *scoreArray; // Array of NSNumbers
@property (nonatomic) NSInteger leftSelection;
@property (nonatomic) NSInteger rightSelection;

@end

@implementation RA_GameViewPlayersHistoricCell


#pragma mark - load up and configure
// ******************** load up and configure ********************


-(void)viewDidLoad
{
    COMMON_LOG
    // Doesn't seem to run?
}


-(void)configureCell
{
    COMMON_LOG
    
    // Configure the score picker stuff
    [self configureScorePicker];
    
    // Set leftPlayer, rightPlayer properties
    [self assignPlayers];
    
    // Names
    self.leftName.text = self.leftPlayer.displayName;
    self.rightName.text = self.rightPlayer.displayName;
    
    // Score
    [self configureScores];
    
    // Score delegate
    self.scoreField.delegate = self;
    
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
{
    COMMON_LOG
    
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
{
    COMMON_LOG
    
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
{
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


// TO DO possibly: scroll the tableview when the inputview appears

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    COMMON_LOG
    
    return 2;
}



-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    COMMON_LOG
    
    return [self.scoreArray count];
}



-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    COMMON_LOG
    
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
    // Update scores for the game and save
    if (self.leftSelection || self.rightSelection) {
        [self.game.scores setValue:self.scoreArray[self.leftSelection] forKey:self.leftPlayer.objectId];
        [self.game.scores setValue:self.scoreArray[self.rightSelection] forKey:self.rightPlayer.objectId];
        [self.game saveInBackground];
        // TO DO: How does this impact the scores?
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
        COMMON_LOG_WITH_COMMENT(@"return NO")
        return NO;
    }
    else {
        COMMON_LOG_WITH_COMMENT(@"return YES")
        return YES;
    }
}



#pragma mark - segue
// ******************** segue ********************


-(void)segueToLeftPlayer:(id)sender
{
    COMMON_LOG
    
    RA_UserProfileDynamicTable *userProfile = [[RA_UserProfileDynamicTable alloc] initWithUser:self.leftPlayer
                                                                                    andContext:RA_UserProfileContextGameManager];
    [self.parentViewController.navigationController pushViewController:userProfile animated:YES];
}

-(void)segueToRightPlayer:(id)sender
{
    COMMON_LOG
    
    RA_UserProfileDynamicTable *userProfile = [[RA_UserProfileDynamicTable alloc] initWithUser:self.rightPlayer
                                                                                    andContext:RA_UserProfileContextGameManager];
    [self.parentViewController.navigationController pushViewController:userProfile animated:YES];
}



@end


