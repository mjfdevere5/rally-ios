//
//  RA_newsfeedTeamCell.m
//  Rally
//
//  Created by Alex Brunicki on 19/09/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_FeedCellRallyBroadcast.h"
#import "NSDate+CoolStrings.h"

@implementation RA_FeedCellRallyBroadcast


-(void)awakeFromNib
{
    // Cell background
    UIImage *backgroundImage = [UIImage imageNamed:@"newsfeed_cell_v03_team"];
    UIImageView *cellBackgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
    cellBackgroundView.image = backgroundImage;
    self.backgroundView = cellBackgroundView;
}



-(void)configureCellWithBroadcast
{
    // Timestamp
    NSDate *createdAt = self.broadcast.createdAt;
    NSString *timeStamp = [createdAt getTimeStampNewsFeed];
    self.timeStamp.text = timeStamp;
    
    // Name
    self.name.text = self.broadcast.userDisplayName;
    
    // Free text attributes
    [self.freeText setScrollEnabled:YES];
    self.freeText.text = self.broadcast.freeText;
    [self.freeText sizeToFit];
    [self.freeText setScrollEnabled:NO];
    
    // Thumbnail
//    self.thumbnail.layer.cornerRadius = 5; // We have set this in Main.storyboard
}


@end


