//
//  RA_LadderSingleton.h
//  Rally
//
//  Created by Max de Vere on 19/09/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RA_ParseGamePreferences.h"
#import "RA_TimeAndDatePreference.h"
#import <CoreLocation/CoreLocation.h>


@interface RA_GamePrefConfig : NSObject

// Singleton instance
+(instancetype) gamePrefConfig;

// Hardcoded by self
@property (strong, nonatomic) NSArray *possibleDates;
@property (strong, nonatomic) NSArray *possibleTimes;

// Selected by the user, game setup view
@property (strong, nonatomic) NSString *sport;
@property (strong, nonatomic) NSMutableArray *networks; // of RA_ParseNetwork objects
@property (strong, nonatomic) NSString *simRanked;

// Selected by the user, game logistics view
@property (strong, nonatomic) RA_TimeAndDatePreference *firstPreference; // NSArray
@property (nonatomic) BOOL hasBackupPreference;
@property (strong, nonatomic) RA_TimeAndDatePreference *backupPreference; // NSArray
@property (strong, nonatomic) NSDictionary *prefDictionary;

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