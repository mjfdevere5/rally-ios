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
@property (strong, nonatomic) RA_ParseNetwork *network;
@property (strong, nonatomic) NSString *sportName; // TO DO, make sure this gets uploaded
@property (strong, nonatomic) NSDate *dayFirstPref;
@property (strong, nonatomic) NSNumber *timeFirstPref;
@property (nonatomic) BOOL hasSecondPref;
@property (strong, nonatomic) NSDate *daySecondPref;
@property (strong, nonatomic) NSNumber *timeSecondPref;
@property (nonatomic) BOOL hasThirdPref;
@property (strong, nonatomic) NSDate *dayThirdPref;
@property (strong, nonatomic) NSNumber *timeThirdPref;
@property (strong, nonatomic) PFGeoPoint *location; // added for location of game
@property (strong, nonatomic) NSString *locationDesc; // added for location of game
@property (strong, nonatomic) NSString *playWho;
@property (nonatomic) BOOL bookingHelpWanted;
@property (strong, nonatomic) NSString *additionalInfo;

// Pointer to the full user object
@property (strong, nonatomic) RA_ParseUser *user;

// Some info about the user that it might be nice to have on hand
// Don't think we need to upload the thumbnail here
//@property (strong, nonatomic) NSString *userProfileName;
//@property (strong, nonatomic) NSString *userFullName; // Delete these

// Methods
-(NSInteger)getNumberOfPreferences;
-(NSString *)timeFirstPrefString;
-(NSString *)timeSecondPrefString;
-(NSString *)timeThirdPrefString;

@end


