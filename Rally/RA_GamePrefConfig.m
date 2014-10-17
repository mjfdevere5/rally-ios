//
//  RA_LadderSingleton.m
//  Rally
//
//  Created by Max de Vere on 19/09/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//


#import "RA_GamePrefConfig.h"
#import "AppConstants.h"
#import "NSDate+Utilities.h"
#import "NSDate+CoolStrings.h"


@interface RA_GamePrefConfig()
@end



@implementation RA_GamePrefConfig


#pragma mark - singleton load up
// ******************** singleton load up ********************


+(instancetype)gamePrefConfig
{
    static RA_GamePrefConfig *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return  instance;
}



-(instancetype)init
{
    COMMON_LOG
    return self;
}



#pragma mark - view 1
// ******************** view 1 ********************

-(void)resetToDefaults
{
    // Hardcoded by self
    self.possibleDates = [self getPossibleDates];
    self.possibleTimes = [self getPossibleTimes];
    
    // Selected by the user, game setup view
    self.sport = nil;
    self.networks = [NSMutableArray array];
    self.simRanked = nil;
    
    
    self.possibleDates = [self getPossibleDates];
    self.possibleTimes = @[@0, @1, @2]; // corresponds to Morning, Afternoon, Evening
    
    self.firstPreference = [[RA_DateAndTimePreference alloc] initWithDate:self.possibleDates[0]
                                                                  andTime:self.possibleTimes[0]
                                                                  andIsEnabled:YES];
    self.secondPreference = [[RA_DateAndTimePreference alloc] initWithDate:self.possibleDates[0]
                                                                   andTime:self.possibleTimes[0]
                                                                   andIsEnabled:NO];
    self.thirdPreference = [[RA_DateAndTimePreference alloc] initWithDate:self.possibleDates[0]
                                                                  andTime:self.possibleTimes[0]
                                                                  andIsEnabled:NO];
    
    self.preferencesDict = [NSDictionary dictionaryWithObjectsAndKeys:
                            self.firstPreference, @"first",
                            self.secondPreference, @"second",
                            self.thirdPreference, @"third", nil];
    
    // Location stuff
    self.ladderLocation = nil;
    self.ladderLocationPlacemark = nil;
}

-(NSArray *)getPossibleDates
{
    // Set possible days as the forthcoming Thursday through Sunday (weekdays 5, 6, 7 and 1)
    // These should change on the preceding SUNDAY
    // The desired effect is that users can always request a match for the following day (discouraged), however, on Sunday, it's too late and they can now only plan their matches for Thursday onwards.
    // Users will get a push on Sunday saying they can now express their preferences for matches for Thursday onwards
    // Note that the -weekday method gives Sunday as 1, Saturday as 7
    // Note that if today is Friday, we only want Saturday and Sunday to be options
    // Note that there will always be at least one option (the forthcoming Sunday)
    NSDate *today = [NSDate date];
    int todayWeekday = (int)[today weekday];
    NSMutableArray *possibleDatesMut = [[NSMutableArray alloc] init];
    for (int i = todayWeekday; i<= todayWeekday + 14; i++) {
        NSLog(@"%i", i);
        NSDate *possibleDate = [today dateByAddingDays:(NSInteger)(i-todayWeekday)];
        [possibleDatesMut addObject:possibleDate];
    }
    NSLog(@"possibleDates = %@", [possibleDatesMut description]);
    return (NSArray *)possibleDatesMut;
}

-(NSArray *)getPossibleTimes
{
    // TO DO
}

-(BOOL)containsNetwork:(RA_ParseNetwork *)network
{
    NSArray *networkIds = [self.networks valueForKeyPath:@"objectId"];
    if ([networkIds containsObject:network.objectId]) {
        return YES;
    }
    else {
        return NO;
    }
}

-(void)removeNetwork:(RA_ParseNetwork *)network
{
    for (RA_ParseNetwork *containedNetwork in self.networks) {
        if ([containedNetwork.objectId isEqualToString:network.objectId]) {
            [self.networks removeObject:containedNetwork];
            break;
        }
    }
}


#pragma mark - view 2
// ******************** view 2 ********************

-(void)updateLadderLocationPlacemark
{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [geocoder reverseGeocodeLocation:self.ladderLocation completionHandler:
     ^(NSArray *placemarks, NSError *error)
     {
         // Get placemark
         CLPlacemark *placemark = [placemarks objectAtIndex:0];
         
         // Update placemarks if not nil
         if (placemark) {
             NSLog(@"[%@, %@] Found placemark SUCCESS", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
             self.ladderLocationPlacemark = placemark;
         }
         else {
             NSLog(@"[%@, %@] ERROR: Did not find placemark", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
         }
     }];
}

-(BOOL)validDatesAndTimes
{
    return !([self.firstPreference bothActiveAndEqual:self.secondPreference] ||
             [self.firstPreference bothActiveAndEqual:self.thirdPreference] ||
             [self.secondPreference bothActiveAndEqual:self.thirdPreference]);
}

-(BOOL)validLocation
{
    if (self.ladderLocation) {
        return YES;
    }
    else {
        return NO;
    }
}

-(RA_ParseGamePreferences *)createParseGamePreferencesObject
{
    COMMON_LOG
    
    RA_ParseGamePreferences *config = [RA_ParseGamePreferences object];
    
//    config.network = self.network; // TO DO
    
    NSMutableArray *dateTimePreferencesMut = [NSMutableArray arrayWithObject:self.firstPreference.date];
    if (self.secondPreference.isEnabled) {
        [dateTimePreferencesMut addObject:self.secondPreference.date];
        if (self.thirdPreference.isEnabled) {
            [dateTimePreferencesMut addObject:self.thirdPreference.date];
        }
    }
    config.dateTimePreferences = [NSArray arrayWithArray:dateTimePreferencesMut];
    
    config.playWho = self.simRanked;
    
    config.location = [PFGeoPoint geoPointWithLocation:self.ladderLocation];
    config.locationDesc = self.ladderLocationString;
    
    config.user = [RA_ParseUser currentUser];
    
    return config;
}



@end


