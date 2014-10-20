//
//  RA_GameViewBaseCell.h
//  Rally
//
//  Created by Max de Vere on 12/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RA_ParseGame.h"
#import "RA_ParseGamePreferences.h"
#import "RA_GameView.h"

@interface RA_GameViewBaseCell : UITableViewCell

// Let the cells have access to the game or game preference in question
@property (strong, nonatomic) RA_ParseGame *game;
@property (strong, nonatomic) RA_ParseGamePreferences *gamePref;

// Used to store a reference to the parent view controller
@property (strong, nonatomic) RA_GameView *parentViewController;

// Every cell must override this
-(void)configureCell;

@end
