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

// Everything from RA_GamePrefConfig -createParseGamePreferencesObject
@property (strong, nonatomic) NSString *sport;
@property (strong, nonatomic) NSArray *networks; // of RA_ParseNetwork objects
@property (strong, nonatomic) NSArray *dateTimePreferences; // of NSDate objects
@property (strong, nonatomic) PFGeoPoint *location; // added for location of game
@property (strong, nonatomic) NSString *locationDesc; // added for location of game
@property (strong, nonatomic) NSString *playWho;

// Pointer to the full user object
@property (strong, nonatomic) RA_ParseUser *user;

@end


