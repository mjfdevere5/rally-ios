//
//  RA_GameView.h
//  Rally
//
//  Created by Max de Vere on 10/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RA_ParseGame.h"
#import "RA_ParseGamePreferences.h"

@interface RA_GameView : UITableViewController<UIAlertViewDelegate>

// If context is 'GamePref', then we need an RA_ParseGamePrererences object
@property (strong, nonatomic) RA_ParseGamePreferences *gamePref;

// If context is 'GameManager', then we need to configure using an RA_ParseGame object
@property (strong, nonatomic) RA_ParseGame *game;

// Double picker for the score
@property (nonatomic,retain)  UIPickerView *doublePicker;

@end