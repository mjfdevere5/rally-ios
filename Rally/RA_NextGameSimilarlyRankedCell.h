//
//  RA_NextGameSimilarlyRankedCell.h
//  Rally
//
//  Created by Max de Vere on 16/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_NextGameBaseCell.h"

@interface RA_NextGameSimilarlyRankedCell : RA_NextGameBaseCell

@property (weak, nonatomic) IBOutlet UISegmentedControl *similarlyRankedControl;
- (IBAction)userPickedSimilarlyRankedPreference:(id)sender;

@end
