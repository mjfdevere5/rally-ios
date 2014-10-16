//
//  RA_GameViewStatusCell.m
//  Rally
//
//  Created by Max de Vere on 10/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_GameViewStatusCell.h"

@implementation RA_GameViewStatusCell


-(void)configureCell
{
    COMMON_LOG

    if ([[self.game gameStatus] isEqualToString:RA_GAME_STATUS_CONFIRMED]) {
        self.textLabel.text = @"CONFIRMED";
        self.textLabel.textColor = [UIColor whiteColor];
        self.backgroundColor = CO_GREEN_CONFIRMED;
    }
    
    else if ([[self.game gameStatus] isEqualToString:RA_GAME_STATUS_PROPOSED]) {
        self.textLabel.text = @"PENDING CONFIRMATION";
        self.textLabel.textColor = [UIColor whiteColor];
        self.backgroundColor = CO_AMBER_UNCONFIRMED;
    }
    
    else if ([[self.game gameStatus] isEqualToString:RA_GAME_STATUS_CANCELLED]) {
        self.textLabel.text = @"CANCELLED";
        self.textLabel.textColor = [UIColor whiteColor];
        self.backgroundColor = CO_GRAY_CANCELLED;
    }
    
    // Note, we'll probably decide not to even load this cell if the status is completed
    else if ([[self.game gameStatus] isEqualToString:@"completed"]) { // TO DO, this isn't quite right
        self.textLabel.text = @"Completed";
        self.textLabel.textColor = [UIColor whiteColor];
        self.backgroundColor = UIColorFromRGB(FORMS_LIGHT_RED);
    }
    
    else {
        COMMON_LOG_WITH_COMMENT(@"ERROR: Unexpected game.status")
    }
}


@end


