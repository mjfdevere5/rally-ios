//
//  RA_ParseGame.m
//  Rally
//
//  Created by Max de Vere on 07/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_ParseGame.h"
#import <Parse/PFObject+Subclass.h>


@implementation RA_ParseGame


+(NSString *)parseClassName
{
    return @"Game";
}


+ (void)load
{
    [self registerSubclass];
}


@dynamic players;
@dynamic datetime;
@dynamic sport;
@dynamic playerStatuses;
@dynamic reasonForCancellation;
@dynamic playersWantFacilitiesBooked;
@dynamic facilitiesHaveBeenBooked;
@dynamic facilitiesBookingReference;
@dynamic facilities;
@dynamic scores;
@dynamic resultConfirmedByBothPlayers;
@dynamic postMortemQuotes;
@dynamic photo;



-(instancetype)initAsAcceptanceFromMeToOpponent:(RA_ParseUser *)myOpponent andSport:(NSString *)theSport andDatetime:(NSDate *)theDatetime
{
    self = [super init];
    if (self) {
        // Passed vars
        self.players = @[[RA_ParseUser currentUser], myOpponent];
        self.datetime = theDatetime;
        self.sport = theSport;
        
        // Initialise the mutable arrays etc.
        self.playerStatuses = [NSMutableDictionary dictionary];
        self.reasonForCancellation = [NSMutableDictionary dictionary];
        self.scores = [NSMutableDictionary dictionary];
        self.postMortemQuotes = [NSMutableDictionary dictionary];
        
        // Other
        [self.playerStatuses setValue:RA_GAME_STATUS_PROPOSED forKey:myOpponent.objectId];
        [self.playerStatuses setValue:RA_GAME_STATUS_CONFIRMED forKey:[RA_ParseUser currentUser].objectId];
    }
    return self;
}



-(instancetype)initAsProposalFromMeToOpponent:(RA_ParseUser *)myOpponent andSport:(NSString *)theSport andDatetime:(NSDate *)theDatetime
{
    self = [super init];
    if (self) {
        // Passed vars
        self.players = @[[RA_ParseUser currentUser], myOpponent];
        self.datetime = theDatetime;
        self.sport = theSport;
        
        // Initialise the mutable arrays etc.
        self.playerStatuses = [NSMutableDictionary dictionary];
        self.reasonForCancellation = [NSMutableDictionary dictionary];
        self.scores = [NSMutableDictionary dictionary];
        self.postMortemQuotes = [NSMutableDictionary dictionary];
        
        // Other
        [self.playerStatuses setValue:RA_GAME_STATUS_PROPOSED forKey:[RA_ParseUser currentUser].objectId];
    }
    return self;
}



-(RA_ParseUser *)getOpponentToPlayer:(RA_ParseUser *)player
{
    RA_ParseUser *opponent;
    opponent = [RA_ParseUser currentUser]; // Max needed this for testing purposes (games vs. himself)
    for (RA_ParseUser *user in self.players) {
        if (![user.objectId isEqualToString:player.objectId]) {
            opponent = user;
        }
    }
    return opponent;
}

-(RA_ParseUser *)opponent
{
    return [self getOpponentToPlayer:[RA_ParseUser currentUser]];
}



-(BOOL)playerHasConfirmed:(RA_ParseUser *)player
{
    return [[self.playerStatuses objectForKey:player.objectId] isEqualToString:RA_GAME_STATUS_CONFIRMED];
}
-(BOOL)playerHasProposed:(RA_ParseUser *)player
{
    return [[self.playerStatuses objectForKey:player.objectId] isEqualToString:RA_GAME_STATUS_PROPOSED];
}
-(BOOL)playerHasCancelled:(RA_ParseUser *)player
{
    return [[self.playerStatuses objectForKey:player.objectId] isEqualToString:RA_GAME_STATUS_CANCELLED];
}



-(BOOL)iHaveConfirmed
{
    return [self playerHasConfirmed:[RA_ParseUser currentUser]];
}
-(BOOL)iHaveProposed
{
    return [self playerHasProposed:[RA_ParseUser currentUser]];
}
-(BOOL)iHaveCancelled
{
    return [self playerHasCancelled:[RA_ParseUser currentUser]];
}



-(BOOL)opponentHasConfirmed
{
    return [self playerHasConfirmed:[self opponent]];
}

-(BOOL)opponentHasProposed
{
    return [self playerHasProposed:[self opponent]];
}

-(BOOL)opponentHasCancelled
{
    return [self playerHasCancelled:[self opponent]];
}



-(BOOL)actionRequiredByPlayer:(RA_ParseUser *)player
{
    // Game has either been proposed by us (both players need to confirm/cancel)...
    // ...or proposed by a player (other player needs to confirm/cancel).
    
    // If user has confirmed, cancelled, or is the original proposer, then no action required:
    if ([self playerHasConfirmed:player] || [self playerHasProposed:player] || [self playerHasCancelled:player]) {
        return NO;
    }
    // Else, if the OTHER player has cancelled, then no action required
    else if ([self playerHasCancelled:[self getOpponentToPlayer:player]]) {
        return NO;
    }
    // Otherwise, we need an action
    else {
        return YES;
    }
}
-(BOOL)actionRequiredByMe
{
    return [self actionRequiredByPlayer:[RA_ParseUser currentUser]];
}
-(BOOL)actionRequiredByOpponent
{
    return [self actionRequiredByPlayer:[self opponent]];
}



-(BOOL)hasScore
{
    return ([self.scores count] > 0);
}

-(NSNumber *)myScore
{
    return [self.scores objectForKey:[RA_ParseUser currentUser].objectId];
}

-(NSNumber *)opponentScore
{
    return [self.scores objectForKey:[self opponent].objectId];
}



-(void)setMyScore:(NSNumber *)score
{
    [self.scores setValue:score forKey:[RA_ParseUser currentUser].objectId];
}

-(void)setOpponentScore:(NSNumber *)score
{
    [self.scores setValue:score forKey:[RA_ParseUser currentUser].objectId];
}



-(void)currentUserCancelGameWithReason:(NSString *)reason
{
    [self.playerStatuses setValue:RA_GAME_STATUS_CANCELLED forKey:[RA_ParseUser currentUser].objectId];
    [self.reasonForCancellation setValue:reason forKey:[RA_ParseUser currentUser].objectId];
}



// Should only be called for a game in the future
-(NSString *)gameStatus
{
    NSString *status;
    
    RA_ParseUser *playerOne = self.players[0];
    RA_ParseUser *playerTwo = self.players[1];
    NSString *playerOneStatus = [self.playerStatuses objectForKey:playerOne.objectId];
    NSString *playerTwoStatus = [self.playerStatuses objectForKey:playerTwo.objectId];
    
    if (([playerOneStatus isEqualToString:RA_GAME_STATUS_CONFIRMED] ||
         [playerOneStatus isEqualToString:RA_GAME_STATUS_PROPOSED]) &&
        ([playerTwoStatus isEqualToString:RA_GAME_STATUS_CONFIRMED] ||
         [playerTwoStatus isEqualToString:RA_GAME_STATUS_PROPOSED])) {
        // Both players have confirmed, therefore the game is cancelled
        status = RA_GAME_STATUS_CONFIRMED;
    }
    else if ([playerOneStatus isEqualToString:RA_GAME_STATUS_CANCELLED] ||
             [playerTwoStatus isEqualToString:RA_GAME_STATUS_CANCELLED]) {
        // At least one player has cancelled, therefore the game is cancelled
        status = RA_GAME_STATUS_CANCELLED;
    }
    else {
        // Any other status for a future game is "proposed"
        status = RA_GAME_STATUS_PROPOSED;
    }
    
    return status;
}



@end

