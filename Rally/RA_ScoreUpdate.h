//
//  RA_ScoreUpdate.h
//  Rally
//
//  Created by Alex Brunicki on 17/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RA_ParseBroadcast.h"
#import "RA_NewsFeed.h"

@interface RA_ScoreUpdate : UITableViewCell <UIGestureRecognizerDelegate>

@property (strong, nonatomic) RA_NewsFeed *viewControllerDelegate;
@property (strong, nonatomic) RA_ParseBroadcast *broadcast;
@property (weak, nonatomic) IBOutlet PFImageView *leftPlayerImage;
@property (weak, nonatomic) IBOutlet PFImageView *rightPlayerImage;
@property (weak, nonatomic) IBOutlet UILabel *leftPlayerName;
@property (weak, nonatomic) IBOutlet UILabel *rightPlayerName;
@property (weak, nonatomic) IBOutlet UILabel *leftPlayerScore;
@property (weak, nonatomic) IBOutlet UILabel *rightPlayerScore;
@property (weak, nonatomic) IBOutlet UILabel *timeStamp;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *leftActivity;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *rightActivity;

-(void)configureCellWithBroadcast;

@end
