//
//  RA_GameConfirmation.m
//  Rally
//
//  Created by Alex Brunicki on 17/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_NewsFeedGameConfirmationCell.h"
#import "RA_NewsFeedScoreUpdateCell.h"
#import "NSDate+CoolStrings.h"
#import "UIImage+ProfilePicHandling.h"
#import "RA_ParseNetwork.h"
#import "RA_NewsFeed.h"
#import "RA_UserProfileDynamicTable.h"

@implementation RA_NewsFeedGameConfirmationCell


- (void)awakeFromNib
{ COMMON_LOG
    // Formatting
    UIImage *backgroundImage = [UIImage imageNamed:@"newsfeed_cell_v03"];
    UIImageView *cellBackgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
    cellBackgroundView.image = backgroundImage;
    self.backgroundView = cellBackgroundView;
    
    // Gesture recognizers
    // Left
    [self.leftConfirmed setUserInteractionEnabled:YES];
    UITapGestureRecognizer *tapOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(leftTapMethod)];
    [tapOne setNumberOfTouchesRequired:1];
    [tapOne setNumberOfTapsRequired:1];
    [self.leftConfirmed addGestureRecognizer:tapOne];
    
    // Right
    [self.rightConfirmed setUserInteractionEnabled:YES];
    UITapGestureRecognizer *tapTwo = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rightTapMethod)];
    [tapOne setNumberOfTouchesRequired:1];
    [tapOne setNumberOfTapsRequired:1];
    [self.rightConfirmed addGestureRecognizer:tapTwo];
}


-(void)configureCell
{ COMMON_LOG
    // Timestamp
    NSDate *createdAt = self.broadcast.createdAt;
    NSString *timeStamp = [createdAt getTimeStampNewsFeed];
    self.timeStamp.text = timeStamp;
    
    // Name
    self.leftNameConfirmed.text = self.broadcast.userOne.displayName;
    self.rightNameConfirmed.text = self.broadcast.userTwo.displayName;
    
    // Sport
    NSString *sportString = self.broadcast.game.sport;
    self.sport.text = [NSString stringWithFormat:@"is playing %@ with...",sportString];
    
    // Date
    NSString *dateString = [self.broadcast.game.datetime getDatePrettyStringFeed];
    self.extraInfo.text = [NSString stringWithFormat:@"...on %@",dateString];
    
    // Player images
    PFFile *file = self.broadcast.userOne.profilePicMedium;
    if (![file isDataAvailable]) {
        [self.leftActivity startAnimating];
    }
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (error) {
            COMMON_LOG_WITH_COMMENT([error localizedDescription])
        }
        else {
            UIImage *thumbnailRaw = [UIImage imageWithData:data];
            UIImage *rightSizedPic = [thumbnailRaw getImageResizedAndCropped:self.leftConfirmed.frame.size];
            UIImage *thumbnailRoundedCorners = [rightSizedPic getImageWithRoundedCorners:3];
            self.leftConfirmed.image = thumbnailRoundedCorners;
            [self.leftActivity stopAnimating];
        }
    }];
    PFFile *fileTwo = self.broadcast.userTwo.profilePicMedium;
    if (![file isDataAvailable]) {
        [self.rightActivity startAnimating];
    }
    [fileTwo getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (error) {
            COMMON_LOG_WITH_COMMENT([error localizedDescription])
        }
        else {
            UIImage *thumbnailRaw = [UIImage imageWithData:data];
            UIImage *rightSizedPic = [thumbnailRaw getImageResizedAndCropped:self.rightConfirmed.frame.size];
            UIImage *thumbnailRoundedCorners = [rightSizedPic getImageWithRoundedCorners:3];
            self.rightConfirmed.image = thumbnailRoundedCorners;
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
