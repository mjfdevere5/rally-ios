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
#import "NSDate+UtilitiesMax.h"
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
    // Selected by the user, game setup view
    self.sport = nil;
    self.networks = [NSMutableArray array];
    self.simRanked = NO;
    
    // Selected by the user, game logistics view
    self.dateTimePreferences = [NSMutableArray arrayWithObjects:[[NSDate date] upcomingHour],[[NSDate date] upcomingHour],nil];
    self.hasBackupPreference = NO;
    
    // Location stuff
    self.ladderLocation = nil;
    self.ladderLocationPlacemark = nil;
    self.ladderLocationString = @"...";
    self.ladderLocationManuallySelected = NO;
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
    NSMutableArray *newArray = [NSMutableArray arrayWithArray:self.networks];
    for (RA_ParseNetwork *containedNetwork in newArray) {
        if ([containedNetwork.objectId isEqualToString:network.objectId]) {
            [newArray removeObject:containedNetwork];
            break;
        }
    }
    self.networks = newArray;
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
    return !([self.dateTimePreferences[0] isEqualToDate:self.dateTimePreferences[1]] &&
             self.hasBackupPreference);
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
{ COMMON_LOG
    RA_ParseGamePreferences *gamePref = [RA_ParseGamePreferences object];
    
    gamePref.user = [RA_ParseUser currentUser];
    gamePref.sport = self.sport;
    gamePref.networks = [NSArray arrayWithArray:self.networks];
    gamePref.simRanked = self.simRanked;
    
    if (self.hasBackupPreference) {
        gamePref.dateTimePreferences = [NSArray arrayWithArray:self.dateTimePreferences];
    }
    else {
        gamePref.dateTimePreferences = @[ self.dateTimePreferences[0] ];
    }
    
    gamePref.location = [PFGeoPoint geoPointWithLocation:self.ladderLocation];
    gamePref.locationDesc = self.ladderLocationString;
    
    return gamePref;
}



@end


