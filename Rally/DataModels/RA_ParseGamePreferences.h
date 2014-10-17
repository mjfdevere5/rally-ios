//
//  RA_ParseGamePreferences.h
//  Rally
//
//  Created by Max de Vere on 20/09/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import <Parse/Parse.h>
#import "RA_ParseNetwork.h"

@interface RA_ParseGamePreferences : PFObject<PFSubclassing>

+(NSString *)parseClassName;

@property (strong, nonatomic) RA_ParseUser *user;
// Everything else if from RA_GamePrefConfig -createParseGamePreferencesObject
@property (strong, nonatomic) NSString *sport;
@property (strong, nonatomic) NSArray *networks; // of RA_ParseNetwork objects
@property (nonatomic) BOOL simRanked;
@property (strong, nonatomic) NSArray *dateTimePreferences; // nested arrays of type @[NSDate, NSString]
@property (strong, nonatomic) PFGeoPoint *location; // added for location of game
@property (strong, nonatomic) NSString *locationDesc; // added for location of game

@end


