//
//  RA_UserProfileAcceptGameCell.m
//  Rally
//
//  Created by Max de Vere on 14/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_UserProfileAcceptGameCell.h"
#import "NSDate+CoolStrings.h"

@implementation RA_UserProfileAcceptGameCell


-(void)configureCell
{
    COMMON_LOG
    
    // Formatting
    self.backgroundColor = CO_AMBER_UNCONFIRMED_LIGHTER;
    self.textLabel.textColor = [UIColor whiteColor];
    
    // Set the image (say, to a squash ball)
    if ([self.gamePref.sport isEqualToString:RA_SPORT_NAME_SQUASH]) {
        self.leftImage.image = [UIImage imageNamed:@"squash_ball"];
    }
    else if ([self.gamePref.sport isEqualToString:RA_SPORT_NAME_TENNIS]) {
        self.leftImage.image = [UIImage imageNamed:@"tennis_ball"];
    }
    else {
        COMMON_LOG_WITH_COMMENT(@"ERROR: Unexpected sport name")
    }
    
    // Set the text
    NSString *whenString = [NSString stringWithFormat:@"%@ at %@",
                            [self.gamePref.dateTimePreferences[self.preferenceNumber] getCommonSpeechDayLong:NO dateOrdinal:NO monthLong:NO],
                            [self.gamePref.dateTimePreferences[self.preferenceNumber] getCommonSpeechClock]];
    self.textLabel.text = [NSString stringWithFormat:@"Confirm: %@", whenString];
}


@end