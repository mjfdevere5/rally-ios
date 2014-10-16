//
//  RA_GameViewConfirmNowCell.h
//  Rally
//
//  Created by Max de Vere on 10/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RA_GameViewBaseCell.h"

@interface RA_GameViewConfirmNowCell : RA_GameViewBaseCell

@property (weak, nonatomic) IBOutlet UILabel *tapToConfirmLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityWheel;

@end
