//
//  RA_ProposeGameSportCell.m
//  Rally
//
//  Created by Max de Vere on 20/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_ProposeGameSportCell.h"

typedef NS_ENUM(NSInteger, RA_SportPickerControlIndex) {
    RA_SportPickerControlIndexSquash,
    RA_SportPickerControlIndexTennis
};

@implementation RA_ProposeGameSportCell

-(void)configureCell
{ COMMON_LOG
    // Formatting
    // TO DO
    
    // Titles
    [self.sportPicker setTitle:@"Squash" forSegmentAtIndex:RA_SportPickerControlIndexSquash];
    [self.sportPicker setTitle:@"Tennis" forSegmentAtIndex:RA_SportPickerControlIndexTennis];
}

- (IBAction)userDidPickSport:(id)sender
{
    // Change the sport in the view controller
    switch (self.sportPicker.selectedSegmentIndex) {
        case RA_SportPickerControlIndexSquash:
            self.myViewController.sport = RA_SPORT_NAME_SQUASH;
            break;
        case RA_SportPickerControlIndexTennis:
            self.myViewController.sport = RA_SPORT_NAME_TENNIS;
            break;
        default:
            COMMON_LOG_WITH_COMMENT(@"ERROR: Unexpected selection")
            break;
    }
}

@end
