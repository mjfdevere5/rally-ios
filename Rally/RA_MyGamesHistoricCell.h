//
//  RA_MyGamesHistoricCell.h
//  Rally
//
//  Created by Max de Vere on 09/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RA_ParseGame.h"
#import "RA_GameStatusVerticalTextView.h"

@interface RA_MyGamesHistoricCell : UITableViewCell

@property (strong, nonatomic) RA_ParseGame *game;

@property (weak, nonatomic) IBOutlet RA_GameStatusVerticalTextView *verticalTextView;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *sportLabel;
@property (weak, nonatomic) IBOutlet UIImageView *warningIcon;
@property (weak, nonatomic) IBOutlet UILabel *reportScoreLabel;
@property (weak, nonatomic) IBOutlet UIImageView *opponentImage;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityWheel;

-(void)configureCellForGame;

@end


