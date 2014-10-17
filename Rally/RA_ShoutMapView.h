//
//  RA_ShoutMapView.h
//  Rally
//
//  Created by Max de Vere on 01/09/2014.
//  Copyright (c) 2014 NA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface RA_ShoutMapView : UIViewController <MKMapViewDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UILabel *areaLabel;
-(IBAction)moveToCurrentLocation:(id)sender;

@end


