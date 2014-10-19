//
//  RA_NextGameAddBackupCell.m
//  Rally
//
//  Created by Max de Vere on 17/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_NextGameAddBackupCell.h"
#import "RA_GamePrefConfig.h"

@implementation RA_NextGameAddBackupCell


-(void)configureCell
{ COMMON_LOG
    // Formatting
    // TO DO
    
    // Configure labels
    BOOL hasBackupPreference = [RA_GamePrefConfig gamePrefConfig].hasBackupPreference;
    self.textLabel.text = hasBackupPreference ? @"Remove backup?" : @"Add backup?" ;
    self.detailTextLabel.font = [UIFont systemFontOfSize:20.0];
    self.detailTextLabel.text = hasBackupPreference ? @"-" : @"+" ;
}


@end


