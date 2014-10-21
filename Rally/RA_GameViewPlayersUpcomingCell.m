//
//  RA_GameViewPlayersCell.m
//  Rally
//
//  Created by Max de Vere on 10/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_GameViewPlayersUpcomingCell.h"
#import "UIImage+ProfilePicHandling.h"
#import "RA_UserProfileDynamicTable.h"

@interface RA_GameViewPlayersUpcomingCell()
@property (strong, nonatomic) RA_ParseUser *leftPlayer;
@property (strong, nonatomic) RA_ParseUser *rightPlayer;
@end


@implementation RA_GameViewPlayersUpcomingCell


-(void)configureCell
{
    COMMON_LOG
    
    // Set leftPlayer, rightPlayer properties
    [self assignPlayers];
    
    // Names
    self.leftName.text = self.leftPlayer.displayName;
    self.rightName.text = self.rightPlayer.displayName;
    
    // Status label
    // Remember, this cell only appears for upcoming games...
    NSString *leftPlayerStatus = [self.game.playerStatuses objectForKey:self.leftPlayer.objectId];
    NSString *rightPlayerStatus = [self.game.playerStatuses objectForKey:self.rightPlayer.objectId];
    [self setStatusLabel:self.leftStatus toStatus:leftPlayerStatus];
    [self setStatusLabel:self.rightStatus toStatus:rightPlayerStatus];
    
    // Profile pics and activity wheels
    [self.leftActivityWheel startAnimating];
    [self.rightActivityWheel startAnimating];
    PFFile *leftPlayerPicFile = self.leftPlayer.profilePicMedium;
    [leftPlayerPicFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        UIImage *leftPlayerPicRaw = [UIImage imageWithData:data];
        UIImage *leftPlayerPicCircular = [leftPlayerPicRaw getImageCircularWithRadius:self.leftPic.frame.size.width];
        self.leftPic.image = leftPlayerPicCircular;
        [self.leftActivityWheel stopAnimating];
    }];
    PFFile *rightPlayerPicFile = self.rightPlayer.profilePicMedium;
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



-(void)setStatusLabel:(UILabel *)label toStatus:(NSString *)status
{
    if ([status isEqualToString:RA_GAME_STATUS_CONFIRMED]) {
        label.text = @"Confirmed";
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = CO_GREEN_CONFIRMED;
    }
    else if ([status isEqualToString:RA_GAME_STATUS_PROPOSED]) {
        label.text = @"Proposer";
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = CO_GREEN_CONFIRMED;
    }
    else if ([status isEqualToString:RA_GAME_STATUS_CANCELLED]) {
        label.text = @"Cancelled";
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = CO_GRAY_CANCELLED;
    }
    else {
        label.text = @"Unconfirmed";
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = CO_AMBER_UNCONFIRMED;
    }
}



-(void)segueToLeftPlayer:(id)sender
{
    COMMON_LOG
    if (![self.leftPlayer.objectId isEqualToString:[RA_ParseUser currentUser].objectId]) {
        RA_UserProfileDynamicTable *userProfile = [[RA_UserProfileDynamicTable alloc] initWithUser:self.leftPlayer
                                                                                        andContext:RA_UserProfileContextGameManager];
        [self.parentViewController.navigationController pushViewController:userProfile animated:YES];
    }
}

-(void)segueToRightPlayer:(id)sender
{
    COMMON_LOG
    if (![self.rightPlayer.objectId isEqualToString:[RA_ParseUser currentUser].objectId]) {
        RA_UserProfileDynamicTable *userProfile = [[RA_UserProfileDynamicTable alloc] initWithUser:self.rightPlayer
                                                                                        andContext:RA_UserProfileContextGameManager];
        [self.parentViewController.navigationController pushViewController:userProfile animated:YES];
    }
}



@end
