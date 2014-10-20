//
//  RA_UserProfileAcceptGameCell.h
//  Rally
//
//  Created by Max de Vere on 14/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_UserProfileBaseCell.h"

@interface RA_UserProfileAcceptGameCell : RA_UserProfileBaseCell

// Passed in from the table view controller
@property (nonatomic) NSInteger preference;

@property (weak, nonatomic) IBOutlet UIImageView *leftImage;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityWheel;
@property (weak, nonatomic) IBOutlet UILabel *textOutlet;

@property (nonatomic) NSInteger preferenceNumber;

@end


