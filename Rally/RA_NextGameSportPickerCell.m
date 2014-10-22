//
//  RA_NextGameSportPickerCell.m
//  Rally
//
//  Created by Max de Vere on 16/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_NextGameSportPickerCell.h"
#import "RA_GamePrefConfig.h"

typedef NS_ENUM(NSInteger, RA_SportPickerControlIndex) {
    RA_SportPickerControlIndexSquash,
    RA_SportPickerControlIndexTennis
};

@implementation RA_NextGameSportPickerCell


#pragma mark - configure
// ******************** configure ********************

-(void)configureCell
{ COMMON_LOG
    // Formatting
    // TO DO
    
    // Titles
    [self.sportPickerControl setTitle:@"Squash" forSegmentAtIndex:RA_SportPickerControlIndexSquash];
    [self.sportPickerControl setTitle:@"Tennis" forSegmentAtIndex:RA_SportPickerControlIndexTennis];
    
    self.sportPickerControl.tintColor = RA_TEST_BLUE2;
    
    UIFont *font = [UIFont fontWithName:@"Avenir-Book" size:15.0];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:font
                                                           forKey:NSFontAttributeName];
    [self.sportPickerControl setTitleTextAttributes:attributes
                                    forState:UIControlStateNormal];
}


#pragma mark - user interaction
// ******************** user interaction ********************

- (IBAction)userPickedSport:(id)sender
{
    // Change the RA_GamePrefConfig
    switch (self.sportPickerControl.selectedSegmentIndex) {
        case RA_SportPickerControlIndexSquash:
            [RA_GamePrefConfig gamePrefConfig].sport = RA_SPORT_NAME_SQUASH;
            break;
        case RA_SportPickerControlIndexTennis:
            [RA_GamePrefConfig gamePrefConfig].sport = RA_SPORT_NAME_TENNIS;
            break;
        default:
            COMMON_LOG_WITH_COMMENT(@"ERROR: Unexpected selection")
            break;
    }
    
    // Get RA_NextGamePrefOne to act
    if ([self.viewControllerDelegate respondsToSelector:@selector(didPickSport)]) {
        [self.viewControllerDelegate didPickSport];
    }
}


@end
