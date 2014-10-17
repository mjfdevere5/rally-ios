//
//  RA_MyGamesUpcomingCell.m
//  Rally
//
//  Created by Max de Vere on 09/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_MyGamesUpcomingCell.h"
#import "NSDate+CoolStrings.h"
#import "UIImage+ProfilePicHandling.h"

@implementation RA_MyGamesUpcomingCell


-(void)configureCellForGame
{
    // Game status view
    [self.verticalTextView configureForStatus:[self.game gameStatus]];
    
    // Date label
    NSString *dateString = [self.game.datetime getDatePrettyString];
    NSString *timeString = [self.game.datetime get24HourClockString];
    NSString *dateTimeString = [NSString stringWithFormat:@"%@ at %@", dateString, timeString];
    self.dateLabel.text = dateTimeString;
    
    // Network label
//    self.networkLabel.text = self.game.network.name; // TO DO
    
    // Warning stuff
    if (![self.game actionRequiredByMe]) {
        [self.warningIcon removeFromSuperview];
        [self.warningLabel removeFromSuperview];
    }
    
    // Sport icon
    if ([self.game.sport isEqualToString:RA_SPORT_NAME_SQUASH]) {
        self.sportIcon.image = [UIImage imageNamed:@"squash_ball"];
    }
    else if ([self.game.sport isEqualToString:RA_SPORT_NAME_TENNIS]) {
        self.sportIcon.image = [UIImage imageNamed:@"tennis_ball"];
    }
    else {
        NSString *comment = [NSString stringWithFormat:@"ERROR: Unexpected game.sport: '%@'", self.game.sport];
        COMMON_LOG_WITH_COMMENT(comment)
    }
    
    // Opponent image and activity wheel
    PFFile *opponentPicFile = [self.game opponent].profilePicMedium;
    if (!opponentPicFile.isDataAvailable) {
        [self.activityWheel startAnimating];
    }
    [opponentPicFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        UIImage *opponentPicRaw = [UIImage imageWithData:data];
        UIImage *opponentPicCircular = [opponentPicRaw getImageCircularWithRadius:(self.opponentImage.frame.size.width/2)];
        self.opponentImage.image = opponentPicCircular;
        [self.activityWheel stopAnimating];
    }];
}



@end
