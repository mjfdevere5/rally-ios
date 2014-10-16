//
//  RA_GameViewFacilitiesCell.m
//  Rally
//
//  Created by Max de Vere on 10/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_GameViewFacilitiesCell.h"

@implementation RA_GameViewFacilitiesCell


-(void)configureCell
{
    COMMON_LOG
    
    if (self.game.facilities) {
        self.textLabel.text = [NSString stringWithFormat:@"Court: %@",self.game.facilities.name];
    }
    else {
        self.textLabel.text = @"Court not confirmed";
    }
}



@end