//
//  RA_LadderSingleton.h
//  Rally
//
//  Created by Max de Vere on 19/09/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RA_ParseNetwork.h"
#import "RA_ParseGamePreferences.h"
#import "RA_ParseBroadcast.h"
#import "RA_DateAndTimePreference.h"
#import <CoreLocation/CoreLocation.h>


@interface RA_GamePrefConfig : NSObject

// Single shared instance
+(instancetype) gamePrefConfig;

@property (strong, nonatomic) RA_ParseNetwork *network;
@property (strong, nonatomic) NSArray *possibleDates;
@property (strong, nonatomic) NSArray *possibleTimes;
@property (strong, nonatomic) RA_DateAndTimePreference *firstPreference;
@property (strong, nonatomic) RA_DateAndTimePreference *secondPreference;
@property (strong, nonatomic) RA_DateAndTimePreference *thirdPreference;
@property (strong, nonatomic) NSDictionary *preferencesDict;
@property (nonatomic) BOOL bookingHelpWanted;
@property (strong, nonatomic) NSString *additionalInfo;

// who to play information
@property (strong, nonatomic) NSString *playWho;

// Passed in from RA_ShoutMapView and RA_LocationSingleton
@property (strong, nonatomic) CLLocation *ladderLocation;
@property (strong, nonatomic) CLPlacemark *ladderLocationPlacemark;
@property (strong, nonatomic) NSString *ladderLocationString;
@property BOOL ladderLocationManuallySelected;


// Called by RA_LadderForm -viewDidLoad
-(void)resetToDefaults;

// Creates the Parse object in preparation for upload
-(RA_ParseGamePreferences *)createParseGamePreferencesObject;
-(RA_ParseBroadcast *)createParseBroadcastObjectWithPref:(RA_ParseGamePreferences *)pref;

// Valid dates/times?
-(BOOL)validDatesAndTimes;

// Valid location entry

-(BOOL)validLocation;

//
-(void)updateLadderLocationPlacemark;

@end