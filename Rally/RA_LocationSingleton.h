//
//  RA_LocationSingleton.h
//  Rally
//
//  Created by Max de Vere on 31/08/2014.
//  Copyright (c) 2014 NA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


@interface RA_LocationSingleton : NSObject <CLLocationManagerDelegate>

// Single shared instance
+(instancetype) locationSingleton;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) CLPlacemark *bestCurrentPlacemark; // don't use this

-(void)startUpdatingLocationIfAuto;
-(void)stopUpdatingLocation;

@end