//
//  RA_GameViewCancelCell.h
//  Rally
//
//  Created by Max de Vere on 12/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_GameViewBaseCell.h"

@interface RA_GameViewCancelCell : RA_GameViewBaseCell

@property (weak, nonatomic) IBOutlet UILabel *cancelGameLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityWheel;

@end
