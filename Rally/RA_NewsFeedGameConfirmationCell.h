//
//  RA_GameConfirmation.h
//  Rally
//
//  Created by Alex Brunicki on 17/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RA_ParseBroadcast.h"
#import "RA_NewsFeed.h"
#import "RA_NewsFeedBaseCell.h"

@interface RA_NewsFeedGameConfirmationCell : RA_NewsFeedBaseCell

// Storyboard stuff
@property (weak, nonatomic) IBOutlet UIImageView *leftConfirmed;
@property (weak, nonatomic) IBOutlet UIImageView *rightConfirmed;
@property (weak, nonatomic) IBOutlet UILabel *leftNameConfirmed;
@property (weak, nonatomic) IBOutlet UILabel *rightNameConfirmed;
@property (weak, nonatomic) IBOutlet UILabel *timeStamp;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *leftActivity;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *rightActivity;
@property (weak, nonatomic) IBOutlet UILabel *extraInfo;
@property (weak, nonatomic) IBOutlet UILabel *sport;

@end
