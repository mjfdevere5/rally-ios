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
    
    // Game status view
    [self.verticalTextView configureForStatus:[self.game gameStatus]];
    
    // Score and warning stuff
    if ([[self.game gameStatus] isEqualToString:RA_GAME_STATUS_CANCELLED]) {
        self.scoreLabel.text = @"";
    }
    else if ([self.game hasScore]) {
        NSNumber *myScore = [self.game.scores objectForKey:[RA_ParseUser currentUser].objectId];
        NSNumber *theirScore = [self.game.scores objectForKey:[self.game opponent].objectId];
        NSString *scoreString = [NSString stringWithFormat:@"%@ - %@", [myScore stringValue], [theirScore stringValue]];
        self.scoreLabel.text = scoreString;
    }
    else {
        self.scoreLabel.text = @"TBD";
    }
    
    // Warning labels
    if (![self.game requiresActionOnScore]) {
        [self.warningIcon removeFromSuperview];
        [self.reportScoreLabel removeFromSuperview];
    }
    
    // Date label
    NSString *dateString = [self.game.datetime getCommonSpeechDayLong:NO dateOrdinal:NO monthLong:NO];
    NSString *timeString = [self.game.datetime getCommonSpeechClock];
    NSString *dateTimeString = [NSString stringWithFormat:@"%@ %@", dateString, timeString];
    self.dateLabel.text = dateTimeString;
    
    // Sport label
    self.sportLabel.text = self.game.sport;
    
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
