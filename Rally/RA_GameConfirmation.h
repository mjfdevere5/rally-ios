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



@interface RA_GameConfirmation : UITableViewCell

@property (strong, nonatomic) RA_NewsFeed *viewControllerDelegate;
@property (strong, nonatomic) RA_ParseBroadcast *broadcast;
@property (weak, nonatomic) IBOutlet PFImageView *leftConfirmed;
@property (weak, nonatomic) IBOutlet PFImageView *rightConfirmed;
@property (weak, nonatomic) IBOutlet UILabel *leftNameConfirmed;
@property (weak, nonatomic) IBOutlet UILabel *rightNameConfirmed;
@property (weak, nonatomic) IBOutlet UILabel *timeStamp;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *leftActivity;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *rightActivity;
@property (weak, nonatomic) IBOutlet UILabel *extraInfo;
@property (weak, nonatomic) IBOutlet UILabel *sport;

-(void)configureCellWithBroadcast;

@end
