//
//  RA_GameViewStatusCell.m
//  Rally
//
//  Created by Max de Vere on 10/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_GameViewStatusCell.h"
#import "NSDate+Utilities.h"

@implementation RA_GameViewStatusCell


-(void)configureCell
{ COMMON_LOG
    if ([[self.game gameStatus] isEqualToString:RA_GAME_STATUS_COMPLETED]) {
        self.textLabel.text = @"Completed";
        self.textLabel.textColor = [UIColor whiteColor];
        self.backgroundColor = CO_GREEN_CONFIRMED;
    }
    else if ([[self.game gameStatus] isEqualToString:RA_GAME_STATUS_UNCONFIRMED]) {
        self.textLabel.text = @"Never confirmed";
        self.textLabel.textColor = [UIColor whiteColor];
        self.backgroundColor = CO_AMBER_UNCONFIRMED;
    }
    else if ([[self.game gameStatus] isEqualToString:RA_GAME_STATUS_CANCELLED]) {
        self.textLabel.text = @"Cancelled";
        self.textLabel.textColor = [UIColor whiteColor];
        self.backgroundColor = CO_GRAY_CANCELLED;
    }
    else if ([[self.game gameStatus] isEqualToString:RA_GAME_STATUS_CONFIRMED]) {
        self.textLabel.text = @"Confirmed";
        self.textLabel.textColor = [UIColor whiteColor];
        self.backgroundColor = CO_GREEN_CONFIRMED;
    }
    else if ([[self.game gameStatus] isEqualToString:RA_GAME_STATUS_PROPOSED]) {
        self.textLabel.text = @"PENDING CONFIRMATION";
        self.textLabel.textColor = [UIColor whiteColor];
        self.backgroundColor = CO_AMBER_UNCONFIRMED;
    }
}


@end


