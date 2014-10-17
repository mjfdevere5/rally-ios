//
//  RA_newsfeedShoutCell2.h
//  Rally
//
//  Created by Alex Brunicki on 25/09/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RA_ParseBroadcast.h"

@interface RA_FeedCellShout : UITableViewCell

@property (strong, nonatomic) RA_ParseGamePreferences *gamePref;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeStamp;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnail;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *thumbnailActivityWheel;
@property (weak, nonatomic) IBOutlet UILabel *lookingToPlayLabel;
@property (weak, nonatomic) IBOutlet UILabel *preferenceBulletsLabel;
@property (weak, nonatomic) IBOutlet UIView *dividerLineView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *networksActivityWheel;
@property (weak, nonatomic) IBOutlet UILabel *networksInCommonLabel;
@property (weak, nonatomic) IBOutlet UILabel *networkBulletsLabel;

-(void)configureCell;
-(void)configureCellForHeightPurposesOnly;

@end
