//
//  RA_ProposeGameSportCell.h
//  Rally
//
//  Created by Max de Vere on 20/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_ProposeGameBaseCell.h"

@interface RA_ProposeGameSportCell : RA_ProposeGameBaseCell

@property (weak, nonatomic) IBOutlet UISegmentedControl *sportPicker;
- (IBAction)userDidPickSport:(id)sender;

@end
