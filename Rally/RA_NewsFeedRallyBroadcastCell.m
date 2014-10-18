//
//  RA_newsfeedTeamCell.m
//  Rally
//
//  Created by Alex Brunicki on 19/09/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_NewsFeedRallyBroadcastCell.h"
#import "NSDate+CoolStrings.h"

@implementation RA_NewsFeedRallyBroadcastCell


-(void)awakeFromNib
{
    // Cell background
    UIImage *backgroundImage = [UIImage imageNamed:@"newsfeed_cell_v03_team"];
    UIImageView *cellBackgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
    cellBackgroundView.image = backgroundImage;
    self.backgroundView = cellBackgroundView;
}

-(void)configureCell
{
    // Timestamp
    NSDate *createdAt = self.broadcast.createdAt;
    NSString *timeStamp = [createdAt getTimeStampNewsFeed];
    self.timeStamp.text = timeStamp;
    
    // Name
    self.name.text = self.broadcast.userOne.displayName;
    
    // Free text attributes
    [self.freeText setScrollEnabled:YES];
    self.freeText.text = self.broadcast.freeText;
    [self.freeText sizeToFit];
    [self.freeText setScrollEnabled:NO];
}


@end


