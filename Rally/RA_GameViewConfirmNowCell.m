//
//  RA_GameViewConfirmNowCell.m
//  Rally
//
//  Created by Max de Vere on 10/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_GameViewConfirmNowCell.h"

@implementation RA_GameViewConfirmNowCell


-(void)configureCell
{
    if ([[self.game gameStatus] isEqualToString:RA_GAME_STATUS_PROPOSED] ||
        [[self.game gameStatus] isEqualToString:RA_GAME_STATUS_UNCONFIRMED]) {
        self.tapToConfirmLabel.textColor = [UIColor whiteColor];
        self.backgroundColor = CO_AMBER_UNCONFIRMED_LIGHTER;
    }
    else {
        COMMON_LOG_WITH_COMMENT(@"ERROR: Unexpected game.status")
    }
}


@end