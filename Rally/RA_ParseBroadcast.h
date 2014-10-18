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
#import "RA_ParseGame.h"


#define     RA_BROADCAST_TYPE_RALLY_TEAM            @"rally_team"
#define     RA_BROADCAST_TYPE_SCORE                 @"score"
#define     RA_BROADCAST_TYPE_CONFIRMED             @"confirmed_game"


@interface RA_ParseBroadcast : PFObject<PFSubclassing>

+(NSString *)parseClassName;

// Not all properties are used, depending on the type
@property (strong, nonatomic) NSString *type; // @"rally_team", @"shout", etc. as per macros above
@property (strong, nonatomic) NSString *freeText;
@property (strong, nonatomic) RA_ParseUser *userOne;
@property (strong, nonatomic) RA_ParseUser *userTwo;
@property (strong, nonatomic) NSArray *visibility; // of type RA_ParseNetwork
@property (strong, nonatomic) RA_ParseGame *game;

@end


