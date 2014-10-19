//
//  RA_ParseGame.h
//  Rally
//
//  Created by Max de Vere on 07/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import <Parse/Parse.h>
#import "RA_ParseFacilities.h"
#import "RA_ParseNetwork.h"


#define RA_GAME_STATUS_CONFIRMED    @"confirmed"
#define RA_GAME_STATUS_PROPOSED     @"proposed"
#define RA_GAME_STATUS_CANCELLED    @"cancelled"


@interface RA_ParseGame : PFObject<PFSubclassing>


+(NSString *)parseClassName;


// General
@property (strong, nonatomic) NSArray *players; // contains RA_ParseUser objects
@property (strong, nonatomic) NSDate *datetime;
@property (strong, nonatomic) NSString *sport;

// Status
@property (strong, nonatomic) NSMutableDictionary *playerStatuses; // userIDs to NSStrings, as defined above
@property (strong, nonatomic) NSMutableDictionary *reasonForCancellation; // userIDs to NSStrings

// Facilities
@property (nonatomic) BOOL playersWantFacilitiesBooked;
@property (nonatomic) BOOL facilitiesHaveBeenBooked;
@property (strong, nonatomic) NSString *facilitiesBookingReference;
@property (strong, nonatomic) RA_ParseFacilities *facilities;

// Post-game
@property (strong, nonatomic) NSDictionary *scores; // userIDs to NSNumbers
@property (nonatomic) BOOL resultConfirmedByBothPlayers;
@property (strong, nonatomic) NSMutableDictionary *postMortemQuotes; // userIDs to NSStrings
@property (strong, nonatomic) PFFile *photo;


// Methods
-(instancetype)initAsAcceptanceFromMeToOpponent:(RA_ParseUser *)myOpponent andSport:(NSString *)theSport andDatetime:(NSDate *)theDatetime;
-(instancetype)initAsProposalFromMeToOpponent:(RA_ParseUser *)myOpponent andSport:(NSString *)theSport andDatetime:(NSDate *)theDatetime;

-(RA_ParseUser *)getOpponentToPlayer:(RA_ParseUser *)player;
-(RA_ParseUser *)opponent;
-(NSArray *)getNetworksInCommonForPlayers; // (BACKGROUND ONLY)

-(BOOL)playerHasConfirmed:(RA_ParseUser *)player;
-(BOOL)playerHasProposed:(RA_ParseUser *)player;
-(BOOL)playerHasCancelled:(RA_ParseUser *)player;
-(BOOL)iHaveConfirmed;
-(BOOL)iHaveProposed;
-(BOOL)iHaveCancelled;
-(BOOL)opponentHasConfirmed;
-(BOOL)opponentHasProposed;
-(BOOL)opponentHasCancelled;

-(BOOL)actionRequiredByPlayer:(RA_ParseUser *)player;
-(BOOL)actionRequiredByMe;
-(BOOL)actionRequiredByOpponent;

-(BOOL)hasScore;
-(NSNumber *)myScore;
-(NSNumber *)opponentScore;
-(void)setMyScore:(NSNumber *)score;
-(void)setOpponentScore:(NSNumber *)score;

-(void)currentUserCancelGameWithReason:(NSString *)reason;

-(NSString *)gameStatus;

@end

