//
//  RA_ScoreUpdate.m
//  Rally
//
//  Created by Alex Brunicki on 17/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_NewsFeedScoreUpdateCell.h"
#import "NSDate+CoolStrings.h"
#import "UIImage+ProfilePicHandling.h"
#import "RA_ParseNetwork.h"
#import "RA_NewsFeedGameConfirmationCell.h"
#import "RA_UserProfileDynamicTable.h"
#import "RA_NewsFeed.h"


@implementation RA_NewsFeedScoreUpdateCell

- (void)awakeFromNib
{ COMMON_LOG
    // Formatting
    UIImage *backgroundImage = [UIImage imageNamed:@"newsfeed_cell_v03"];
    UIImageView *cellBackgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
    cellBackgroundView.image = backgroundImage;
    self.backgroundView = cellBackgroundView;
    
    // Tap gesture recognisers
    // Left
    [self.leftPlayerImage setUserInteractionEnabled:YES];
    UITapGestureRecognizer *tapLeft = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(leftTapMethod)];
    [tapLeft setNumberOfTouchesRequired:1];
    [tapLeft setNumberOfTapsRequired:1];
    [self.leftPlayerImage addGestureRecognizer:tapLeft];
    
    // Right
    [self.rightPlayerImage setUserInteractionEnabled:YES];
    UITapGestureRecognizer *tapRight = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rightTapMethod)];
    [tapLeft setNumberOfTouchesRequired:1];
    [tapLeft setNumberOfTapsRequired:1];
    [self.rightPlayerImage addGestureRecognizer:tapRight];
}

-(void)configureCell
{ COMMON_LOG
    // Timestamp
    NSDate *createdAt = self.broadcast.createdAt;
    NSString *timeStamp = [createdAt getTimeStampNewsFeed];
    self.timeStamp.text = timeStamp;
    
    // Name
    self.leftPlayerName.text = self.broadcast.userOne.displayName;
    self.rightPlayerName.text = self.broadcast.userTwo.displayName;
    
    // Get scores
    NSNumber *leftScore = [self.broadcast.game.scores objectForKey:self.broadcast.userOne.objectId];
    NSNumber *rightScore = [self.broadcast.game.scores objectForKey:self.broadcast.userTwo.objectId];
    self.leftPlayerScore.text = [NSString stringWithFormat:@"%@",leftScore];
    self.rightPlayerScore.text = [NSString stringWithFormat:@"%@", rightScore];
    
    NSLog(@"left score: %@ and right score: %@",leftScore, rightScore);
    NSLog(@"game score description: %@",[self.broadcast.game.scores description]);
    NSLog(@"game: %@",[self.broadcast.game description]);
    
    // Format the text
    if ([leftScore integerValue] > [rightScore integerValue]) {
        self.leftPlayerName.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
        self.leftPlayerScore.backgroundColor = UIColorFromRGB(0xff6100);
        self.leftPlayerScore.textColor = [UIColor whiteColor];
        self.rightPlayerScore.textColor = [UIColor whiteColor];
    }
    else if ([leftScore integerValue] < [rightScore integerValue]) {
        self.rightPlayerName.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
        self.rightPlayerScore.backgroundColor = UIColorFromRGB(0xff6100);
        self.leftPlayerScore.textColor = [UIColor whiteColor];
        self.rightPlayerScore.textColor = [UIColor whiteColor];
        
        }
    
    else {
       
    }
    
    // Player images
    PFFile *fileLeft = self.broadcast.userOne.profilePicMedium;
    if (![fileLeft isDataAvailable]) {
        [self.leftActivity startAnimating];
    }
    [fileLeft getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (error) {
            COMMON_LOG_WITH_COMMENT([error localizedDescription])
        }
        else {
            UIImage *thumbnailRaw = [UIImage imageWithData:data];
            UIImage *thumbnailRoundedCorners = [thumbnailRaw getImageWithRoundedCorners:5];
            self.leftPlayerImage.image = thumbnailRoundedCorners;
            [self.leftActivity stopAnimating];
        }
    }];
    PFFile *fileRight = self.broadcast.userTwo.profilePicMedium;
    if (![fileRight isDataAvailable]) {
        [self.rightActivity startAnimating];
    }
    [fileRight getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (error) {
            COMMON_LOG_WITH_COMMENT([error localizedDescription])
        }
        else {
            UIImage *thumbnailRaw = [UIImage imageWithData:data];
            UIImage *thumbnailRoundedCorners = [thumbnailRaw getImageWithRoundedCorners:5];
            self.rightPlayerImage.image = thumbnailRoundedCorners;
            [self.rightActivity stopAnimating];
        }
    }];
}

-(void)leftTapMethod
{ COMMON_LOG
    // Get the user
    RA_ParseUser *user = self.broadcast.userOne;
    
    // Segue to user profile
    RA_UserProfileDynamicTable *userView = [[RA_UserProfileDynamicTable alloc] initWithUser:user andContext:RA_UserProfileContextNewsFeed];
    [self.myViewController.navigationController pushViewController:userView animated:YES];
}

-(void)rightTapMethod
{ COMMON_LOG
    // Get the user
    RA_ParseUser *user = self.broadcast.userTwo;
    
    // Segue to user profile
    RA_UserProfileDynamicTable *userView = [[RA_UserProfileDynamicTable alloc] initWithUser:user andContext:RA_UserProfileContextNewsFeed];
    [self.myViewController.navigationController pushViewController:userView animated:YES];
}



@end
