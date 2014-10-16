//
//  RA_GameViewPlayersHistoricCell.h
//  Rally
//
//  Created by Max de Vere on 10/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RA_GameViewBaseCell.h"

@interface RA_GameViewPlayersHistoricCell : RA_GameViewBaseCell<UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *leftPic;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *leftActivityWheel;
@property (weak, nonatomic) IBOutlet UILabel *leftName;
@property (weak, nonatomic) IBOutlet UIImageView *rightPic;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *rightActivityWheel;
@property (weak, nonatomic) IBOutlet UILabel *rightName;
@property (weak, nonatomic) IBOutlet UITextField *scoreField;

// Needs to be accessible by the RA_GameView table view controller
-(void)configureScores;

@end
