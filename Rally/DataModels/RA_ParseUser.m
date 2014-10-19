//
//  RA_ParseUser.m
//  Rally
//
//  Created by Max de Vere on 06/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_ParseUser.h"
#import <Parse/PFObject+Subclass.h>
#import "RA_ParseNetwork.h"
#import "PFObject+Utilities.h"


@implementation RA_ParseUser


+(void)load
{
    [self registerSubclass];
}


// Direct from Facebook
@dynamic facebookID;
@dynamic firstName;
@dynamic lastName;
@dynamic email;
@dynamic gender;
@dynamic facebookLink;
@dynamic facebookImage;

// Basic stuff
@dynamic displayName;
@dynamic aboutMe;
@dynamic madeShoutBefore;
@dynamic madeLeagueRequestBefore;

// Images
@dynamic profilePicLarge;
@dynamic profilePicMedium;
@dynamic profilePicSmall;

// Other stuff
@dynamic networkMemberships;
@dynamic games;


// Methods
-(NSArray *)getNetworksInCommonWithMe // Must have fetched both users
{
    NSMutableArray *networksInCommonMut = [NSMutableArray array];
    for (RA_ParseNetwork *network in [RA_ParseUser currentUser].networkMemberships) {
        if ([self.networkMemberships containsObject:network.objectId]) {
            [networksInCommonMut addObject:network];
        }
    }
    NSArray *networksInCommon = [NSArray arrayWithArray:networksInCommonMut];
    return networksInCommon;
}

-(NSArray *)getNetworksInCommonWithMeForSport:(NSString *)sport // (BACKGROUND ONLY)
{
    NSMutableArray *networksInCommonMut = [NSMutableArray array];
    for (RA_ParseNetwork *network in [RA_ParseUser currentUser].networkMemberships) {
        [network fetchIfNeeded]; // This is why we are in background
        if ([network containedInArray:self.networkMemberships] &&
            [network.sport isEqualToString:sport]) {
            [networksInCommonMut addObject:network];
        }
    }
    NSArray *networksInCommon = [NSArray arrayWithArray:networksInCommonMut];
    return networksInCommon;
}


@end


