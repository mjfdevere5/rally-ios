//
//  RA_UserProfileBaseCell.h
//  Rally
//
//  Created by Max de Vere on 13/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RA_UserProfileDynamicTable.h"
#import "RA_ParseGamePreferences.h"

@interface RA_UserProfileBaseCell : UITableViewCell

@property (nonatomic) RA_UserProfileContext context;
@property (strong, nonatomic) RA_ParseUser *user;
@property (strong, nonatomic) RA_ParseGamePreferences *gamePref;
@property (strong, nonatomic) NSIndexPath *indexPath;

-(void)configureCell;

@end
