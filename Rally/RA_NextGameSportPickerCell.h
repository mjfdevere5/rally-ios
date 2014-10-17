//
//  RA_NextGameSportPickerCell.h
//  Rally
//
//  Created by Max de Vere on 16/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_NextGameBaseCell.h"

@interface RA_NextGameSportPickerCell : RA_NextGameBaseCell

@property (weak, nonatomic) IBOutlet UISegmentedControl *sportPickerControl;
- (IBAction)userPickedSport:(id)sender;

@end


