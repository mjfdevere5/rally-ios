//
//  RA_LadderSingleton.h
//  Rally
//
//  Created by Max de Vere on 19/09/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RA_ParseGamePreferences.h"
#import <CoreLocation/CoreLocation.h>


@interface RA_GamePrefConfig : NSObject

// Singleton instance
+(instancetype) gamePrefConfig;

// Hardcoded by self
@property (strong, nonatomic) NSArray *possibleDates;
@property (strong, nonatomic) NSArray *possibleTimes;

// Depends on RA_NextGamePrefOne context property
@property (strong, nonatomic) RA_ParseUser *userForPrivateChallenge;

// Selected by the user, game setup view
@property (strong, nonatomic) NSString *sport;
@property (strong, nonatomic) NSMutableArray *networks; // of RA_ParseNetwork objects
@property (nonatomic) BOOL simRanked;

// Selected by the user, game logistics view
@property (strong, nonatomic) NSMutableArray *dateTimePreferences; // of NSDate objects
@property (nonatomic) BOOL hasBackupPreference;

// Passed in from RA_ShoutMapView and RA_LocationSingleton
@property (strong, nonatomic) CLLocation *ladderLocation;
@property (strong, nonatomic) CLPlacemark *ladderLocationPlacemark;
@property (strong, nonatomic) NSString *ladderLocationString;
@property BOOL ladderLocationManuallySelected;

// View 1
-(void)resetToDefaults;
-(BOOL)containsNetwork:(RA_ParseNetwork *)network;
-(void)removeNetwork:(RA_ParseNetwork *)network;

// View 2
-(void)updateLadderLocationPlacemark;
-(BOOL)validDatesAndTimes;
-(BOOL)validLocation;
-(RA_ParseGamePreferences *)createParseGamePreferencesObject;

@end