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



#pragma mark - default values
// ******************** default values ********************


// resetToDefaults is called whenever the LadderForm loads up (viewDidLoad)
-(void)resetToDefaults
{
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
    
   
    self.ladderLocation = nil;
    self.ladderLocationPlacemark = nil;
    
    
    self.bookingHelpWanted = NO; // make sure switch defaults to 'off'
    self.additionalInfo = ADDITIONAL_INFO_DEFAULT;
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



#pragma mark - prep to upload config
// ******************** prep to upload config ********************


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
    
    config.network = self.network;
    
    config.dayFirstPref = self.firstPreference.date;
    config.timeFirstPref = self.firstPreference.time;
    
    config.hasSecondPref = self.secondPreference.isEnabled;
    config.daySecondPref = self.secondPreference.date;
    config.timeSecondPref = self.secondPreference.time;
    
    config.hasThirdPref = self.thirdPreference.isEnabled;
    config.dayThirdPref = self.thirdPreference.date;
    config.timeThirdPref = self.thirdPreference.time;
    
    config.playWho = self.playWho;
    
    config.location = [PFGeoPoint geoPointWithLocation:self.ladderLocation];
    config.locationDesc = self.ladderLocationString;
    config.bookingHelpWanted = self.bookingHelpWanted;
    config.additionalInfo = self.additionalInfo;
    
    config.user = [RA_ParseUser currentUser];
    
    return config;
}



-(RA_ParseBroadcast *)createParseBroadcastObjectWithPref:(RA_ParseGamePreferences *)pref
{
    COMMON_LOG
    
    RA_ParseBroadcast *broadcast = [RA_ParseBroadcast object];
    
    // Broadcast general
    broadcast.type = RA_BROADCAST_TYPE_SHOUT;
    broadcast.user = [RA_ParseUser currentUser];
    broadcast.userDisplayName = [RA_ParseUser currentUser].displayName;
    broadcast.freeText = nil;
    
    // Shout details
    broadcast.sportName = self.network.sport;
    broadcast.network = self.network;
    broadcast.date = self.firstPreference.date;
    broadcast.time = self.firstPreference.time;
    broadcast.timeDesc = [self.firstPreference getTimeString];
    broadcast.skill = nil;
    broadcast.skillDesc = nil;
    broadcast.location = [PFGeoPoint geoPointWithLocation:self.ladderLocation];;
    broadcast.locationDesc = self.ladderLocationString;
    broadcast.visibility = @[self.network];
    
    
    // Game pref
    broadcast.gamePrefObject = pref;
    broadcast.networkName = self.network.name;
    
    return broadcast;
}



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




@end


