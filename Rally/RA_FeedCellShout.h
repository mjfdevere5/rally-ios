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

@property (strong, nonatomic) RA_ParseBroadcast *broadcast;
@property (weak, nonatomic) IBOutlet UILabel *shout;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *timeStamp;
@property (weak, nonatomic) IBOutlet UIImageView *sportIcon;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnail;
@property (weak, nonatomic) IBOutlet UILabel *networkName;
@property (weak, nonatomic) IBOutlet UILabel *currentRank;


-(void)configureCellWithBroadcast;

@end
