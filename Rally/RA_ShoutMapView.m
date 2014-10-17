//
//  RA_ShoutMapView.m
//  Rally
//
//  Created by Max de Vere on 01/09/2014.
//  Copyright (c) 2014 NA. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "RA_ShoutMapView.h"
#import "RA_LocationSingleton.h"
#import "RA_GamePrefConfig.h"


// Unique variable used as context for KVO for @"shoutLocationPlacemark"
static void * const MyClassKVOContext = (void*)&MyClassKVOContext;

@interface RA_ShoutMapView ()
@property BOOL gettingLocation; // used only as a tag during initial loadup
@end


@implementation RA_ShoutMapView


#pragma mark - load up
// ******************** load up ********************

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Turn off the locationSingleton updates
    [[RA_LocationSingleton locationSingleton] stopUpdatingLocation];
    
    // We're in manual location mode now
    [RA_GamePrefConfig gamePrefConfig].ladderLocationManuallySelected = YES;
    
    // Configure map
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    
    // Move to Location if there is one
    if ([RA_GamePrefConfig gamePrefConfig].ladderLocation) {
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance([RA_GamePrefConfig gamePrefConfig].ladderLocation.coordinate, 2500, 2500);
        [self.mapView setRegion:viewRegion animated:NO];
        self.gettingLocation = NO;
    }
    // Else just show London
    else {
        CLLocation *piccadilly = [[CLLocation alloc] initWithLatitude:51.5096918
                                                             longitude:-0.1330765];
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(piccadilly.coordinate, 20000, 20000);
        [self.mapView setRegion:viewRegion animated:NO];
        
        // Set this to the shoutLocation
        [RA_GamePrefConfig gamePrefConfig].ladderLocation = piccadilly;
        self.areaLabel.text = @"Getting location...";
        self.gettingLocation = YES;
    }
    
    // Start off with the best placemark we already have
    CLPlacemark *placemark = [RA_GamePrefConfig gamePrefConfig].ladderLocationPlacemark;
    [self updateAreaLabelIfValidPlacemark:placemark];
    
    // Register for updates to the placemark
    [[RA_GamePrefConfig gamePrefConfig] addObserver:self
                                          forKeyPath:@"ladderLocationPlacemark"
                                             options:NSKeyValueObservingOptionNew
                                             context:MyClassKVOContext];
}


#pragma mark - KVO and placemark
// ******************** KVO and placemark ********************

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@"observeValueForKeyPath called for: %@", keyPath);
    
    if ([keyPath isEqualToString:@"ladderLocationPlacemark"])
    {
        [self updateAreaLabelIfValidPlacemark:[RA_GamePrefConfig gamePrefConfig].ladderLocationPlacemark];
    }
}

-(void)updateAreaLabelIfValidPlacemark:(CLPlacemark *)placemark
{
    if (placemark && placemark.subLocality) {
        self.areaLabel.text = placemark.subLocality;
    }
    else if (placemark && placemark.subAdministrativeArea) {
        self.areaLabel.text = placemark.subAdministrativeArea;
    }
    else {
        self.areaLabel.text = @"(No description)";
    }
}

// Unregister for KVO on deallocation
-(void)dealloc
{
    [[RA_GamePrefConfig gamePrefConfig] removeObserver:self
                                             forKeyPath:@"ladderLocationPlacemark"
                                                context:MyClassKVOContext];
    
    // [super dealloc] // called automatically by ARC
}


#pragma mark - buttons
// ******************** buttons ********************

-(IBAction)moveToCurrentLocation:(id)sender
{
    // Get currentLocation and bestCurrentPlacemark from the map view
    CLLocation *currentLocation = [[CLLocation alloc]
                                   initWithLatitude:self.mapView.userLocation.coordinate.latitude
                                          longitude:self.mapView.userLocation.coordinate.longitude];
    
    // If current location is not system default of <0,0>...
    if (currentLocation.coordinate.longitude > 0.1
        || currentLocation.coordinate.longitude < -0.1
        || currentLocation.coordinate.latitude > 0.1
        || currentLocation.coordinate.latitude < -0.1)
    {
        
        // then update the singleton
        [RA_GamePrefConfig gamePrefConfig].ladderLocation = currentLocation;
        [[RA_GamePrefConfig gamePrefConfig] updateLadderLocationPlacemark];
        
        // move to this location
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(currentLocation.coordinate, 2500, 2500);
        [self.mapView setRegion:viewRegion animated:YES];
    }
    
    // To do: drop pin once animation complete
    // Put in another method because we should do that on viewDidLoad as well.
}


#pragma mark - map delegate
// ******************** map delegate ********************

// Pick up the new location from the centre coordinate as the user drags the map
-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    NSLog(@"regionDidChangeAnimated: method called");
    
    // Get the centre point and make it the new shoutLocation
    CLLocation *newLocation = [[CLLocation alloc]
                               initWithLatitude:self.mapView.region.center.latitude
                                      longitude:self.mapView.region.center.longitude];
    [RA_GamePrefConfig gamePrefConfig].ladderLocation = newLocation;
    
    // Update the shoutLocationPlacemark
    [[RA_GamePrefConfig gamePrefConfig] updateLadderLocationPlacemark];
    
    // It will take a while for the placemark to get updated so don't try to update the placemark label
    // Instead, we have registered this class to be notified of changes to the placemark
}

// User's current location moved
-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (self.gettingLocation)
    {
        [self moveToCurrentLocation:nil];
    }
}

// Mapview failed to load
-(void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error
{
    // I think this reloads the mapview...
    [self.mapView setRegion:self.mapView.region animated:TRUE];
}



@end


