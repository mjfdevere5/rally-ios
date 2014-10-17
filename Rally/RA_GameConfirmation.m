//
//  RA_GameConfirmation.m
//  Rally
//
//  Created by Alex Brunicki on 17/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_GameConfirmation.h"
#import "RA_ScoreUpdate.h"
#import "NSDate+CoolStrings.h"
#import "UIImage+ProfilePicHandling.h"
#import "RA_ParseNetwork.h"
#import "RA_GameConfirmation.h"
#import "RA_NewsFeed.h"
#import "RA_UserProfileDynamicTable.h"

@implementation RA_GameConfirmation


- (void)awakeFromNib {
    
    UIImage *backgroundImage = [UIImage imageNamed:@"newsfeed_cell_v03"];
    UIImageView *cellBackgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
    cellBackgroundView.image = backgroundImage;
    self.backgroundView = cellBackgroundView;
    
    
    [self.leftConfirmed setUserInteractionEnabled:YES];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(leftTapMethod)];
    [tap setNumberOfTouchesRequired:1];
    [tap setNumberOfTapsRequired:1];
    [self.leftConfirmed addGestureRecognizer:tap];
    
    [self.rightConfirmed setUserInteractionEnabled:YES];
    UITapGestureRecognizer *tapTwo = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rightTapMethod)];
    [tap setNumberOfTouchesRequired:1];
    [tap setNumberOfTapsRequired:1];
    [self.rightConfirmed addGestureRecognizer:tapTwo];

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
    self.leftNameConfirmed.text = self.broadcast.leftUserDisplayName;
    self.rightNameConfirmed.text = self.broadcast.rightUserDisplayName;
    
    // sport
    
    NSString *sportString = self.broadcast.sportName;
    
    self.sport.text = [NSString stringWithFormat:@"is playing %@ with...",sportString];
    
    
    // extra information
    
   // NSString *locationString = self.broadcast.locationDesc;
    NSString *dateString = [self.broadcast.date getDatePrettyStringFeed];
    
    self.extraInfo.text = [NSString stringWithFormat:@"...on %@",dateString];
    
    // Player image
    PFFile *file = self.broadcast.leftUser.profilePicMedium;
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (error) {
            NSLog(@"[%@, %@] ERROR: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [error localizedDescription]);
        }
        else {
            UIImage *thumbnailRaw = [UIImage imageWithData:data];
            UIImage *thumbnailRoundedCorners = [thumbnailRaw getImageWithRoundedCorners:5];
            self.leftConfirmed.image = thumbnailRoundedCorners;
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
            self.rightConfirmed.image = thumbnailRoundedCorners;
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
