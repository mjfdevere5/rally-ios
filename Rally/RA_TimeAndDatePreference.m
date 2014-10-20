//
//  RA_TimeAndDatePreference.m
//  Rally
//
//  Created by Max de Vere on 17/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_TimeAndDatePreference.h"
#import "NSDate+Utilities.h"


@implementation RA_TimeAndDatePreference


#pragma mark - init/getter/setter
// ******************** init/getter/setter ********************

-(instancetype)initWithDay:(NSDate *)date andTimeInteger:(RA_GamePrefPossibleTimes)timeInteger
{
    self = [super init];
    if (self) {
        self.valuesArray = @[ date, [NSNumber numberWithInteger:timeInteger] ];
    }
    return self;
}

-(instancetype)initWithDatabaseArray:(NSArray *)array
{ COMMON_LOG
    self = [super init];
    if (self) {
        NSDate *date = array[0];
        NSString *timeString = array[1];
        NSNumber *timeNumber;
        if ([timeString isEqualToString:RA_GAME_TIME_EARLY_MORNING]) {
            timeNumber = [NSNumber numberWithInteger:RA_GamePrefPossibleTimesEarlyMorning];
        }
        else if ([timeString isEqualToString:RA_GAME_TIME_LATE_MORNING]) {
            timeNumber = [NSNumber numberWithInteger:RA_GamePrefPossibleTimesLateMorning];
        }
        else if ([timeString isEqualToString:RA_GAME_TIME_EARLY_AFTERNOON]) {
            timeNumber = [NSNumber numberWithInteger:RA_GamePrefPossibleTimesEarlyAfternoon];
        }
        else if ([timeString isEqualToString:RA_GAME_TIME_LATE_AFTERNOON]) {
            timeNumber = [NSNumber numberWithInteger:RA_GamePrefPossibleTimesLateAfternoon];
        }
        else if ([timeString isEqualToString:RA_GAME_TIME_EVENING]) {
            timeNumber = [NSNumber numberWithInteger:RA_GamePrefPossibleTimesEvening];
        }
        else {
            COMMON_LOG_WITH_COMMENT(@"ERROR: Unexpected timeString")
        }
        self.valuesArray = @[ date, timeNumber ];
    }
    return self;
}

-(NSDate *)getDay
{
    return self.valuesArray[0];
}

-(NSNumber *)timeNumber
{
    return self.valuesArray[1];
}


#pragma mark - cell stuff
// ******************** cell stuff ********************

-(NSString *)timeStringCapitalized
{
    NSString *commentNumber = [NSString stringWithFormat:@"timeNumber = %@", [self timeNumber]];
    COMMON_LOG_WITH_COMMENT(commentNumber)
    
    NSInteger timeInteger = [[self timeNumber] integerValue];
    
    NSString *comment = [NSString stringWithFormat:@"timeInteger = %li", (long)timeInteger];
    COMMON_LOG_WITH_COMMENT(comment)
    
    switch (timeInteger) {
        case RA_GamePrefPossibleTimesEarlyMorning:
            COMMON_LOG_WITH_COMMENT(@"0")
            return @"Early Morning";
            break;
        case RA_GamePrefPossibleTimesLateMorning:
            COMMON_LOG_WITH_COMMENT(@"1")
            return @"Late Morning";
            break;
        case RA_GamePrefPossibleTimesEarlyAfternoon:
            COMMON_LOG_WITH_COMMENT(@"2")
            return @"Early Afternoon";
            break;
        case RA_GamePrefPossibleTimesLateAfternoon:
            COMMON_LOG_WITH_COMMENT(@"3")
            return @"Late Afternoon";
            break;
        case RA_GamePrefPossibleTimesEvening:
            COMMON_LOG_WITH_COMMENT(@"4")
            return @"Evening";
            break;
        default:
            COMMON_LOG_WITH_COMMENT(@"ERROR: Unexpected timeInteger")
            return @"...";
            break;
    }
}

-(BOOL)isMinDay // we actually test for min or lower
{
    return ([[self getDay] isEqualToDateIgnoringTime:[NSDate date]] ||
            [[self getDay] isEarlierThanDate:[NSDate date]]);
}

-(BOOL)isMaxDay // we actually test for max or higher
{
    return ([[self getDay] isEqualToDateIgnoringTime:[[NSDate date] dateByAddingDays:14]] ||
            [[self getDay] isLaterThanDate:[[NSDate date] dateByAddingDays:14]]);
}

-(BOOL)isMinTime // we actually test for min or lower
{
    return ([[self timeNumber] integerValue] <= 0);
}

-(BOOL)isMaxTime // we actually test for max or higher
{
    return ([[self timeNumber] integerValue] >= (RA_GamePrefPossibleTimesCOUNT - 1));
}


#pragma mark - Parse stuff
// ******************** Parse stuff ********************

-(NSString *)databaseStringRepresentation
{
    NSInteger timeInteger = [[self timeNumber] integerValue];
    switch (timeInteger) {
        case RA_GamePrefPossibleTimesEarlyMorning:
            return RA_GAME_TIME_EARLY_MORNING;
            break;
        case RA_GamePrefPossibleTimesLateMorning:
            return RA_GAME_TIME_LATE_MORNING;
            break;
        case RA_GamePrefPossibleTimesEarlyAfternoon:
            return RA_GAME_TIME_EARLY_AFTERNOON;
            break;
        case RA_GamePrefPossibleTimesLateAfternoon:
            return RA_GAME_TIME_LATE_AFTERNOON;
            break;
        case RA_GamePrefPossibleTimesEvening:
            return RA_GAME_TIME_EVENING;
            break;
        default:
            COMMON_LOG_WITH_COMMENT(@"ERROR: Unexpected timeInteger")
            return @"...";
            break;
    }
}

-(NSArray *)databaseArray
{
    return @[ [self getDay] , [self databaseStringRepresentation] ];
}

-(BOOL)bothActiveAndEqual:(RA_TimeAndDatePreference *)someOtherPreference
{
    return ([[self getDay] isEqualToDateIgnoringTime:[someOtherPreference getDay]] &&
            [[self timeNumber] isEqualToNumber:[someOtherPreference timeNumber]]);
}

@end


