//
//  RA_LadderQuery.h
//  Rally
//
//  Created by Alex Brunicki on 29/09/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import <Parse/Parse.h>

@interface RA_ParseNetwork : PFObject<PFSubclassing>

+(NSString *)parseClassName;

@property (nonatomic, strong) NSString *name; // e.g. "MBB squash"
@property (nonatomic, strong) NSString *sport; // e.g. "squash", "tennis"
@property (nonatomic, strong) NSString *type; // e.g. "league", "ladder", "tournament", "friendly", "special"
@property (nonatomic, strong) NSString *accessCode;
@property (nonatomic, strong) NSMutableDictionary *userIdsToScores;
@property (nonatomic, strong) NSMutableDictionary *userIdsToLastWeekScores; // TO DO think about this
@property (strong, nonatomic) RA_ParseUser *administrator;
@property (strong, nonatomic) NSString *adminDisplayName;
@property (strong, nonatomic) PFFile *leaguePicLarge;
@property (strong, nonatomic) PFFile *leaguePicMedium;
@property (strong, nonatomic) NSNumber *duration;

+(instancetype)rallyUsersNetwork;
-(NSInteger)getRankForPlayer:(RA_ParseUser *)player;

@end


