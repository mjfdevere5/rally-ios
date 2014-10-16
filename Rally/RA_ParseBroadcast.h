//
//  RA_NewsFeed.h
//  Rally
//
//  Created by Alex Brunicki on 19/09/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import <Parse/Parse.h>
#import "RA_ParseNetwork.h"
#import "RA_ParseGamePreferences.h"


#define     RA_BROADCAST_TYPE_RALLY_TEAM            @"rally_team"
#define     RA_BROADCAST_TYPE_SHOUT                 @"shout"
#define     RA_BROADCAST_TYPE_GAME_PREF             @"game_pref"


@interface RA_ParseBroadcast : PFObject<PFSubclassing>

+(NSString *)parseClassName;

// General
@property (strong, nonatomic) NSString *type; // @"rally_team", @"shout"
@property (strong, nonatomic) RA_ParseUser *user;
@property (strong, nonatomic) NSString *userDisplayName;
@property (strong, nonatomic) NSString *freeText;

// Shout details (all of this is redundant)
@property (strong, nonatomic) NSString *sportName;
@property (strong, nonatomic) RA_ParseNetwork *network;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSNumber *time;
@property (strong, nonatomic) NSString *timeDesc;
@property (strong, nonatomic) NSNumber *skill;
@property (strong, nonatomic) NSString *skillDesc;
@property (strong, nonatomic) PFGeoPoint *location;
@property (strong, nonatomic) NSString *locationDesc;
@property (strong, nonatomic) NSArray *visibility;
@property (strong, nonatomic) NSString *networkName;

// Game preferences
@property (strong, nonatomic) RA_ParseGamePreferences *gamePrefObject;


@end
