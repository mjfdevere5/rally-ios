//
//  RA_NextGameSimilarlyRankedCell.m
//  Rally
//
//  Created by Max de Vere on 16/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_NextGameSimilarlyRankedCell.h"
#import "RA_GamePrefConfig.h"


typedef NS_ENUM(NSInteger, RA_SimilarlyRankedTitle) {
    RA_SimilarlyRankedTitleAnyone,
    RA_SimilarlyRankedTitleSimilarlyRanked
};

@implementation RA_NextGameSimilarlyRankedCell

-(void)configureCell
{ COMMON_LOG
    // Formatting
    // TO DO
    
    // Segment titles
    [self.similarlyRankedControl setTitle:@"Everyone" forSegmentAtIndex:RA_SimilarlyRankedTitleAnyone];
    [self.similarlyRankedControl setTitle:@"Similarly ranked" forSegmentAtIndex:RA_SimilarlyRankedTitleSimilarlyRanked];
    
    // Default selection
    if ([[RA_GamePrefConfig gamePrefConfig].simRanked isEqualToString:RA_SIMRANKED_EVERYONE]) {
        self.similarlyRankedControl.selectedSegmentIndex = RA_SimilarlyRankedTitleAnyone;
    }
    else if ([[RA_GamePrefConfig gamePrefConfig].simRanked isEqualToString:RA_SIMRANKED_SIMRANKED_ONLY]) {
        self.similarlyRankedControl.selectedSegmentIndex = RA_SimilarlyRankedTitleSimilarlyRanked;
    }
    else {
        COMMON_LOG_WITH_COMMENT(@"ERROR: Unexpected simRanked value")
    }
}

- (IBAction)userPickedSimilarlyRankedPreference:(id)sender
{
    switch (self.similarlyRankedControl.selectedSegmentIndex) {
        case RA_SimilarlyRankedTitleAnyone:
            [RA_GamePrefConfig gamePrefConfig].simRanked = RA_SIMRANKED_EVERYONE;
            break;
        case RA_SimilarlyRankedTitleSimilarlyRanked:
            [RA_GamePrefConfig gamePrefConfig].simRanked = RA_SIMRANKED_SIMRANKED_ONLY;
            break;
        default:
            COMMON_LOG_WITH_COMMENT(@"ERROR: Unexpected index")
            break;
    }
}


@end
