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

// TO DO, add others



-(NSInteger)getRankForPlayer:(RA_ParseUser *)player andNetwork:(NSString *)network
{
    PFQuery *query = [RA_ParseNetwork query];
    [query whereKey:@"name" equalTo:network];
    [query selectKeys:@[@"userIdsToScores"]];
    
    NSDictionary *scoreDictionary = [query findObjects][0];
    
    NSArray *scoreIds = [scoreDictionary keysSortedByValueUsingComparator:
                           ^NSComparisonResult(id obj1, id obj2) {
                               return [obj2 compare:obj1];
                           }];
    NSMutableArray *orderedIds = [NSMutableArray arrayWithArray:scoreIds];
    NSInteger rank = [orderedIds indexOfObject:player.objectId];
    return rank;
}


@end


