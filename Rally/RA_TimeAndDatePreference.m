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
    return (RA_TimeAndDatePreference *)[NSArray arrayWithObjects:date,[NSNumber numberWithInteger:timeInteger],nil];
}

-(NSDate *)day
{
    return self[0];
}

-(NSNumber *)timeNumber
{
    return self[1];
}


#pragma mark - cell stuff
// ******************** cell stuff ********************

-(NSString *)timeStringCapitalized
{
    NSInteger timeInteger = [[self timeNumber] integerValue];
    switch (timeInteger) {
        case RA_GamePrefPossibleTimesEarlyMorning:
            return @"Early Morning";
            break;
        case RA_GamePrefPossibleTimesLateMorning:
            return @"Late Morning";
            break;
        case RA_GamePrefPossibleTimesEarlyAfternoon:
            return @"Early Afternoon";
            break;
        case RA_GamePrefPossibleTimesLateAfternoon:
            return @"Late Afternoon";
            break;
        case RA_GamePrefPossibleTimesEvening:
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
    return ([[self day] isEqualToDateIgnoringTime:[NSDate date]] ||
            [[self day] isEarlierThanDate:[NSDate date]]);
}

-(BOOL)isMaxDay // we actually test for max or higher
{
    return ([[self day] isEqualToDateIgnoringTime:[[NSDate date] dateByAddingDays:14]] ||
            [[self day] isLaterThanDate:[[NSDate date] dateByAddingDays:14]]);
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
    return @[ [self day] , [self databaseStringRepresentation] ];
}

-(BOOL)bothActiveAndEqual:(RA_TimeAndDatePreference *)someOtherPreference
{
    return ([[self day] isEqualToDateIgnoringTime:[someOtherPreference day]] &&
            [[self timeNumber] isEqualToNumber:[someOtherPreference timeNumber]]);
}

@end


