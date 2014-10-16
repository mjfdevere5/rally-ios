//
//  RA_LocationSingleton.m
//  Rally
//
//  Created by Max de Vere on 31/08/2014.
//  Copyright (c) 2014 NA. All rights reserved.
//

// Tutorial: http://derpturkey.com/cllocationmanager-singleton/

#import "RA_LocationSingleton.h"
#import "RA_GamePrefConfig.h"

@interface RA_LocationSingleton ()
@end


@implementation RA_LocationSingleton



+(instancetype)locationSingleton
{
    static RA_LocationSingleton *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return  instance;
}



-(instancetype)init
{
    COMMON_LOG
    
    self = [super init];
    if (self) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.distanceFilter = 300; // metres
    }
    
    return self;
}



-(void)startUpdatingLocationIfAuto
{
    if(![RA_GamePrefConfig gamePrefConfig].ladderLocationManuallySelected)
    {
        NSLog(@"Starting location update");
        [self.locationManager startUpdatingLocation];
    }
}



-(void)stopUpdatingLocation
{
    NSLog(@"Stopping location update");
    [self.locationManager stopUpdatingLocation];
}



// CLLocationManagerDelegate methods, I think
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Location service failed with error: %@", error);
    [self startUpdatingLocationIfAuto];
}



-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *locationJustReturned = locations.lastObject;
    
    if ((locationJustReturned.horizontalAccuracy < 150)
        && (locationJustReturned.verticalAccuracy < 150))
    {
        // Decent location, let's use this
        
        self.currentLocation = locationJustReturned;
        NSLog(@"New currentLocation: %@", [self.currentLocation description]);
        
        [self stopUpdatingLocation];
        
        [self updateConfigLocationIfAuto];
        
        if ((locationJustReturned.horizontalAccuracy > 50)
            || (locationJustReturned.verticalAccuracy > 50))
        {
            // Good location, but see if it can be better after 2 seconds
            NSLog(@"locationSingleton will try again in %i seconds", 2);
            [self performSelector:@selector(startUpdatingLocationIfAuto) withObject:nil afterDelay:2.0];
        }
        else
        {
            // Great location, but see if it can be better after 10 seconds
            NSLog(@"locationSingleton will try again in %i seconds", 10);
            [self performSelector:@selector(startUpdatingLocationIfAuto) withObject:nil afterDelay:10.0];
        }
        
    }
    
    else {
        // Inaccurate location, try again straight away
        NSLog(@"Inaccurate location, try again straight away");
        [self startUpdatingLocationIfAuto];
    }
}



// Called by didUpdateLocations
-(void) updateConfigLocationIfAuto
{
    if (![RA_GamePrefConfig gamePrefConfig].ladderLocationManuallySelected) {
        NSLog(@"Updating shoutLocation with the new currentLocation");
        [RA_GamePrefConfig gamePrefConfig].ladderLocation = self.currentLocation;
        
        NSLog(@"Updating shoutLocationPlacemark");
        [[RA_GamePrefConfig gamePrefConfig] updateLadderLocationPlacemark];
    }
}


@end
