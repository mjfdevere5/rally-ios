//
//  RA_GameViewDateTimeCell.m
//  Rally
//
//  Created by Max de Vere on 10/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_GameViewDateTimeCell.h"
#import "NSDate+CoolStrings.h"

@implementation RA_GameViewDateTimeCell


-(void)configureCell
{
    self.dateTimeLabel.text = [[self.game.datetime getCommonSpeechDayLong:YES dateOrdinal:YES monthLong:YES] uppercaseString];
    self.networkLabel.text = self.game.sport;
}



@end