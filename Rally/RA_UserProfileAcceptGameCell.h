//
//  RA_UserProfileAcceptGameCell.h
//  Rally
//
//  Created by Max de Vere on 14/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_UserProfileBaseCell.h"

@interface RA_UserProfileAcceptGameCell : RA_UserProfileBaseCell

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityWheel;
@property (weak, nonatomic) IBOutlet UILabel *textOutlet;

@property (nonatomic) NSInteger preferenceNumber;

@end


