//
//  RA_NextGameNetworkCheckmarkCell.m
//  Rally
//
//  Created by Max de Vere on 16/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_NextGameNetworkCheckmarkCell.h"
#import "RA_GamePrefConfig.h"

@implementation RA_NextGameNetworkCheckmarkCell


#pragma mark - configure
// ******************** configure ********************

-(void)configureCell
{ COMMON_LOG
    // Formatting
    // TO DO
    
    // Text
    self.textLabel.text = self.network.name;
    
    // Checkmark on/off
    BOOL checkmarkOn = [[RA_GamePrefConfig gamePrefConfig] containsNetwork:self.network];
    self.accessoryType = checkmarkOn ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
}



@end


