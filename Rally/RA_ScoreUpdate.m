//
//  RA_ScoreUpdate.m
//  Rally
//
//  Created by Alex Brunicki on 17/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_ScoreUpdate.h"
#import "NSDate+CoolStrings.h"
#import "UIImage+ProfilePicHandling.h"
#import "RA_ParseNetwork.h"
#import "RA_GameConfirmation.h"
#import "RA_UserProfileDynamicTable.h"
#import "RA_NewsFeed.h"

@implementation RA_ScoreUpdate

- (void)awakeFromNib {
    
    UIImage *backgroundImage = [UIImage imageNamed:@"newsfeed_cell_v03"];
    UIImageView *cellBackgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
    cellBackgroundView.image = backgroundImage;
    self.backgroundView = cellBackgroundView;
    
    [self.leftPlayerImage setUserInteractionEnabled:YES];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(leftTapMethod)];
    [tap setNumberOfTouchesRequired:1];
    [tap setNumberOfTapsRequired:1];
    [self.leftPlayerImage addGestureRecognizer:tap];
    
    [self.rightPlayerImage setUserInteractionEnabled:YES];
    UITapGestureRecognizer *tapTwo = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rightTapMethod)];
    [tap setNumberOfTouchesRequired:1];
    [tap setNumberOfTapsRequired:1];
    [self.rightPlayerImage addGestureRecognizer:tapTwo];
    
}


-(void)configureCellWithBroadcast
{
    // Timestamp
    [self.leftActivity startAnimating];
    [self.rightActivity startAnimating];
    
    RA_ParseUser *cUser = [RA_ParseUser currentUser];
    [cUser fetchIfNeeded];
    
    RA_ParseNetwork *network = self.broadcast.network;
    [network fetchIfNeeded];
    
    NSDate *createdAt = self.broadcast.createdAt;
    NSString *timeStamp = [createdAt getTimeStampNewsFeed];
    self.timeStamp.text = timeStamp;
    
    // Name
    NSLog(@"The first name");
    self.leftPlayerName.text = self.broadcast.leftUserDisplayName;
    self.rightPlayerName.text = self.broadcast.rightUserDisplayName;
    
    // Scores
    
    NSNumber *leftScore = self.broadcast.leftUserScore;
    NSNumber *rightScore = self.broadcast.rightUserScore;
    
    int lScore = [leftScore intValue];
    int rScore = [rightScore intValue];
    
    self.leftPlayerScore.text = [NSString stringWithFormat:@"%i",lScore];
    self.rightPlayerScore.text = [NSString stringWithFormat:@"%i", rScore];
    
    if (lScore > rScore) {
        self.leftPlayerScore.textColor = [UIColor whiteColor];
        self.rightPlayerScore.textColor = [UIColor whiteColor];
        self.leftPlayerScore.backgroundColor = [UIColor greenColor];
        self.rightPlayerScore.backgroundColor = [UIColor redColor];
    }
    else if( rScore > lScore){
        self.leftPlayerScore.textColor = [UIColor whiteColor];
        self.rightPlayerScore.textColor = [UIColor whiteColor];
        self.leftPlayerScore.backgroundColor = [UIColor redColor];
        self.rightPlayerScore.backgroundColor = [UIColor greenColor];
    }
    else{
        self.leftPlayerScore.textColor = [UIColor blackColor];
        self.rightPlayerScore.textColor = [UIColor blackColor];
        self.leftPlayerScore.backgroundColor = [UIColor orangeColor];
        self.rightPlayerScore.backgroundColor = [UIColor orangeColor];
    }
    

    
    // Player image
    PFFile *file = self.broadcast.leftUser.profilePicMedium;
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (error) {
            NSLog(@"[%@, %@] ERROR: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [error localizedDescription]);
        }
        else {
            UIImage *thumbnailRaw = [UIImage imageWithData:data];
            UIImage *thumbnailRoundedCorners = [thumbnailRaw getImageWithRoundedCorners:5];
            self.leftPlayerImage.image = thumbnailRoundedCorners;
            [self.leftActivity stopAnimating];
        }
    }];
    
    PFFile *fileTwo = self.broadcast.rightUser.profilePicMedium;
    [fileTwo getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (error) {
            NSLog(@"[%@, %@] ERROR: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [error localizedDescription]);
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
{
        COMMON_LOG
        
        // Get the user
        RA_ParseUser *user = self.broadcast.leftUser;
        
        // Segue to user profile
        RA_UserProfileDynamicTable *userView = [[RA_UserProfileDynamicTable alloc] initWithUser:user andContext:RA_UserProfileContextShoutOut];
        userView.gamePref = self.broadcast.gamePrefObject;
        [self.viewControllerDelegate.navigationController pushViewController:userView animated:YES];

}

-(void)rightTapMethod
{
    COMMON_LOG
    
    // Get the user
    RA_ParseUser *user = self.broadcast.rightUser;
    
    // Segue to user profile
    RA_UserProfileDynamicTable *userView = [[RA_UserProfileDynamicTable alloc] initWithUser:user andContext:RA_UserProfileContextShoutOut];
    userView.gamePref = self.broadcast.gamePrefObject;
    [self.viewControllerDelegate.navigationController pushViewController:userView animated:YES];
}



@end
