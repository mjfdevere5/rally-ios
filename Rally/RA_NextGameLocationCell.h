//
//  RA_NextGameLocationCell.h
//  Rally
//
//  Created by Max de Vere on 17/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_NextGameBaseCell.h"

@interface RA_NextGameLocationCell : RA_NextGameBaseCell

@property (weak, nonatomic) IBOutlet UILabel *iWillBeComingFromLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityWheel;

@end
