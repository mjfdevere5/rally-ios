//
//  RA_newsfeedShoutCell2.m
//  Rally
//
//  Created by Alex Brunicki on 25/09/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_FeedCellShout.h"
#import "NSDate+CoolStrings.h"
#import "UIImage+ProfilePicHandling.h"
#import "RA_ParseNetwork.h"


@implementation RA_FeedCellShout


-(void)awakeFromNib
{
    // Cell background
    UIImage *backgroundImage = [UIImage imageNamed:@"newsfeed_cell_v03"];
    UIImageView *cellBackgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
    cellBackgroundView.image = backgroundImage;
    self.backgroundView = cellBackgroundView;
}



-(void)configureCellWithBroadcast
{
    // Timestamp
    RA_ParseUser *cUser = [RA_ParseUser currentUser];
    [cUser fetchIfNeeded];
    
    RA_ParseNetwork *network = self.broadcast.network;
    
    NSDate *createdAt = self.broadcast.createdAt;
    NSString *timeStamp = [createdAt getTimeStampNewsFeed];
    self.timeStamp.text = timeStamp;
    
    // Name
    NSLog(@"The first name");
    self.name.text = self.broadcast.userDisplayName;
    
    // Add network name
    self.networkName.text = self.broadcast.networkName;
    
    // Add rank
    
    if ([self.broadcast.user isEqual:cUser]) {
        NSInteger rank = [network getRankForPlayer:cUser andNetwork:self.broadcast.networkName];
        self.currentRank.text = [NSString stringWithFormat:@"Your network rank: %li",(long)rank];
    }
    else{
        NSInteger yourRank = [network getRankForPlayer:cUser andNetwork:self.broadcast.networkName];
        NSInteger opponentRank = [network getRankForPlayer:self.broadcast.user andNetwork:self.broadcast.networkName];
        self.currentRank.text = [NSString stringWithFormat:@"Your rank: %li vs their rank: %li",(long)yourRank, (long)opponentRank];
    }
    
    
    // Sports icon
    if ([self.broadcast.sportName isEqualToString:@"Squash"]) {
        self.sportIcon.image = [UIImage imageNamed:@"squash_ball"];
    }
    else if ([self.broadcast.sportName isEqualToString:@"Tennis"]) {
        self.sportIcon.image = [UIImage imageNamed: @"tennis_ball"];
    }
    
    // Shout text
    [self configureShoutText];
    
    // Thumbnail
    PFFile *file = self.broadcast.user.profilePicMedium;
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (error) {
            NSLog(@"[%@, %@] ERROR: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [error localizedDescription]);
        }
        else {
            UIImage *thumbnailRaw = [UIImage imageWithData:data];
            UIImage *thumbnailRoundedCorners = [thumbnailRaw getImageWithRoundedCorners:5];
            self.thumbnail.image = thumbnailRoundedCorners;
        }
    }];
}



-(void)configureShoutText
{
    // Attributed text
    UIFont *gameFont = [UIFont fontWithName:@"Helvetica" size:15];
    UIFont *introFont = [UIFont fontWithName:@"Helvetica" size:15];
    UIColor *gameColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    UIColor *introColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    
    
    NSString *location = [NSString stringWithFormat:@" near %@?",self.broadcast.locationDesc];
    NSAttributedString *attIntro = [[NSAttributedString alloc]initWithString:location
                                                                  attributes:@{NSFontAttributeName: introFont,
                                                                               NSForegroundColorAttributeName: introColor}];
    
    // Then append the dynamic bit
    // Get the time and sport
    NSString *timeSport = [NSString stringWithFormat:@"%@ %@ in the %@", self.broadcast.sportName,
                           [self.broadcast.date getDatePrettyStringFeed],self.broadcast.timeDesc];
    NSAttributedString *timeSportIntro = [[NSAttributedString alloc]initWithString:timeSport
                                                                        attributes:@{NSFontAttributeName: gameFont,
                                                                                     NSForegroundColorAttributeName: gameColor}];
    
    // Now append and display
    NSMutableAttributedString *shoutString = [[NSMutableAttributedString alloc]initWithAttributedString:timeSportIntro];
    [shoutString appendAttributedString:attIntro];
    self.shout.attributedText = shoutString;
}



@end


