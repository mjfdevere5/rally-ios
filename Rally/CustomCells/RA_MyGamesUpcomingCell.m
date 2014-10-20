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
    NSString *dateString = [self.game.datetime getCommonSpeechDayLong:NO dateOrdinal:NO monthLong:NO];
    NSString *timeString = [self.game.datetime getCommonSpeechClock];
    NSString *dateTimeString = [NSString stringWithFormat:@"%@ at %@", dateString, timeString];
    self.dateLabel.text = dateTimeString;
    
    // Warning stuff
    if (![self.game actionForUpcomingGameRequiredByMe]) {
        [self.warningIcon removeFromSuperview];
        [self.warningLabel removeFromSuperview];
    }
    
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
