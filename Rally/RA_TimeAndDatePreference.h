//
//  RA_TimeAndDatePreference.h
//  Rally
//
//  Created by Max de Vere on 17/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, RA_GamePrefPossibleTimes) {
    RA_GamePrefPossibleTimesEarlyMorning,
    RA_GamePrefPossibleTimesLateMorning,
    RA_GamePrefPossibleTimesEarlyAfternoon,
    RA_GamePrefPossibleTimesLateAfternoon,
    RA_GamePrefPossibleTimesEvening,
    RA_GamePrefPossibleTimesCOUNT // Always have this as the last one
};

// Strings to upload to Parse
// For now, these seem to be the best ways to represent this data
// TO DO: Alternative might be some concept of a range, i.e. a from_time and a to_time
#define     RA_GAME_TIME_EARLY_MORNING          @"early_morning"
#define     RA_GAME_TIME_LATE_MORNING           @"late_morning"
#define     RA_GAME_TIME_EARLY_AFTERNOON        @"early_afternoon"
#define     RA_GAME_TIME_LATE_AFTERNOON         @"late_afternoon"
#define     RA_GAME_TIME_EVENING                @"evening"


// These are arrays with two values: 0. an NSDate, 1. an NSNumber value
@interface RA_TimeAndDatePreference : NSArray

// General
-(instancetype)initWithDay:(NSDate *)date andTimeInteger:(RA_GamePrefPossibleTimes)timeInteger;
-(NSDate *)day;
-(NSNumber *)timeNumber;

// Cell
-(NSString *)timeStringCapitalized; // e.g. @"Early Morning"
-(BOOL)isMinDay;
-(BOOL)isMaxDay;
-(BOOL)isMinTime;
-(BOOL)isMaxTime;

// Parse stuff
-(NSString *)databaseStringRepresentation; // e.g. the macros above
-(NSArray *)databaseArray; // e.g. @[ NSDate, the macros above ]
-(BOOL)bothActiveAndEqual:(RA_TimeAndDatePreference *)someOtherPreference;

@end


