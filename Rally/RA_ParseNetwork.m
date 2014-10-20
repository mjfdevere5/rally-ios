//
//  RA_LadderQuery.m
//  Rally
//
//  Created by Alex Brunicki on 29/09/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_ParseNetwork.h"
#import <Parse/PFObject+Subclass.h>

@implementation RA_ParseNetwork


+(NSString *)parseClassName
{
    return @"Network";
}


+ (void)load {
    [self registerSubclass];
}


@dynamic name;
@dynamic sport;
@dynamic type;
@dynamic accessCode;
@dynamic userIdsToScores;
@dynamic userIdsToLastWeekScores;
@dynamic leaguePicLarge;
@dynamic leaguePicMedium;
@dynamic duration;
@dynamic administrator;
@dynamic adminDisplayName;



+(instancetype)rallyUsersNetwork
{
    return [RA_ParseNetwork objectWithoutDataWithObjectId:@"E2wWMqQTtY"];
}

+(instancetype)allRallySquashNetwork
{
    return [RA_ParseNetwork objectWithoutDataWithObjectId:@"Utu5aSM2ke"];
}

+(instancetype)allRallyTennisNetwork
{
    return [RA_ParseNetwork objectWithoutDataWithObjectId:@"Y2IHHx2uu4"];
}

+(instancetype)networkWithName:(NSString *)theName andSport:(NSString *)theSport andType:(NSString *)theType andAccessCode:(NSString *)theAccessCode andAdmin:(RA_ParseUser *)theAdmin andDuration:(NSNumber *)theDuration
{
    // Initialize
    RA_ParseNetwork *network = [[self class] object];
    
    // Add params
    network.name = theName;
    network.sport = theSport;
    network.type = theType;
    network.accessCode = theAccessCode;
    network.administrator = theAdmin;
    network.duration = theDuration;
    
    // Inferred
    network.adminDisplayName = theAdmin.displayName;
    
    // Other initializations
    network.userIdsToScores = [NSMutableDictionary dictionary];
    network.userIdsToLastWeekScores = [NSMutableDictionary dictionary];
    
    // Return
    return network;
}

-(NSInteger)getRankForPlayer:(RA_ParseUser *)player // (BACKGROUND ONLY)
{
    [self fetchIfNeeded];
    if (self.userIdsToScores == nil) {
        COMMON_LOG_WITH_COMMENT(@"ERROR")
        return 0;
    }
    else {
        NSArray *orderedIds = [self.userIdsToScores keysSortedByValueUsingComparator:
                               ^NSComparisonResult(NSNumber *obj1, NSNumber *obj2) {
                                   return [obj2 compare:obj1];
                               }];
        
        NSInteger rank;
        if ([orderedIds containsObject:player.objectId]) {
            rank = [orderedIds indexOfObject:player.objectId] + 1;
        }
        else {
            rank = 0; // Unranked
        }
        return rank;
    }
}


@end


