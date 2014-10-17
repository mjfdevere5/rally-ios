//
//  RA_NextGameLocationCell.m
//  Rally
//
//  Created by Max de Vere on 17/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_NextGameLocationCell.h"
#import "RA_GamePrefConfig.h"

static void * const MyClassKVOContext = (void*)&MyClassKVOContext;

@implementation RA_NextGameLocationCell


-(void)configureCell
{
    // Formatting
    // TO DO
    
    // Outlet defaults
    self.locationLabel.text = @"...";
    [self.activityWheel startAnimating];
    
    // Register to be notified of updates
    [[RA_GamePrefConfig gamePrefConfig] addObserver:self
                                         forKeyPath:@"ladderLocationPlacemark"
                                            options:NSKeyValueObservingOptionNew
                                            context:MyClassKVOContext];
}

-(void)dealloc
{
    [[RA_GamePrefConfig gamePrefConfig] removeObserver:self
                                            forKeyPath:@"ladderLocationPlacemark"
                                               context:MyClassKVOContext];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{ COMMON_LOG
    if (![RA_GamePrefConfig gamePrefConfig].ladderLocationPlacemark.subLocality)
    {
        COMMON_LOG_WITH_COMMENT(@"Did not find a value for ladderLocationPlacemark.subLocality")
        // Make user think we're still looking for a location, even if we have one
        self.locationLabel.text = @"...";
    }
    else {
        // Stop the wheel, update the outlet, update the singleton
        [self.activityWheel stopAnimating];
        CLPlacemark *placemark = [RA_GamePrefConfig gamePrefConfig].ladderLocationPlacemark;
        NSString *locationPrettyString = placemark.subLocality;
        self.locationLabel.text = locationPrettyString;
        [RA_GamePrefConfig gamePrefConfig].ladderLocationString = locationPrettyString;
    }
}



@end


