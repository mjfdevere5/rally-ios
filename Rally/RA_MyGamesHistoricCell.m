//
//  RA_MyGamesHistoricCell.m
//  Rally
//
//  Created by Max de Vere on 09/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_MyGamesHistoricCell.h"
#import "UIImage+ProfilePicHandling.h"
#import "NSDate+CoolStrings.h"

@implementation RA_MyGamesHistoricCell


-(void)configureCellForGame
{
    COMMON_LOG
    
    // Score
    if ([self.game.scores count] > 1) {
        NSNumber *myScore = [self.game.scores objectForKey:[RA_ParseUser currentUser].objectId];
        NSNumber *theirScore = [self.game.scores objectForKey:[self.game opponent].objectId];
        NSString *scoreString = [NSString stringWithFormat:@"%@ - %@", [myScore stringValue], [theirScore stringValue]];
        self.scoreLabel.text = scoreString;
    }
    else {
        self.scoreLabel.text = @"TBD";
    }
    
    // Date label
    NSString *dateString = [self.game.datetime getDatePrettyString];
    NSString *timeString = [self.game.datetime get24HourClockString];
    NSString *dateTimeString = [NSString stringWithFormat:@"%@ at %@", dateString, timeString];
    self.dateLabel.text = dateTimeString;
    
    // Warning stuff
    // TO DO some way of knowing if we require action from this player on reporting/ confirming the score
    [self.warningIcon removeFromSuperview];
    [self.reportScoreLabel removeFromSuperview];
    
    // Network label
    self.networkLabel.text = self.game.network.name;
    
    // Sport icon
    if ([self.game.network.sport isEqualToString:RA_SPORT_NAME_SQUASH]) {
        self.sportIcon.image = [UIImage imageNamed:@"squash_ball"];
    }
    else if ([self.game.network.sport isEqualToString:RA_SPORT_NAME_TENNIS]) {
        self.sportIcon.image = [UIImage imageNamed:@"tennis_ball"];
    }
    else {
        COMMON_LOG_WITH_COMMENT(@"ERROR: game.network.sport was not one we expected")
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
