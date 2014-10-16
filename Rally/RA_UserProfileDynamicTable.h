//
//  RA_UserProfileDynamicTable.h
//  Rally
//
//  Created by Max de Vere on 13/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "JPBFloatingTextViewController.h"
#import "RA_ParseGame.h"
#import "RA_ParseGamePreferences.h"
#import "MBProgressHUD.h"


typedef NS_ENUM(NSInteger, RA_UserProfileContext) {
    RA_UserProfileContextGameManager,
    RA_UserProfileContextShoutOut,
    RA_UserProfileContextLeaderboard
    // Add others here, separated by a comma
};


@interface RA_UserProfileDynamicTable : JPBFloatingTextViewController<MBProgressHUDDelegate>

@property (strong, nonatomic) RA_ParseUser *user;
@property (strong, nonatomic) RA_ParseGamePreferences *gamePref;
@property (nonatomic) RA_UserProfileContext context;

-(instancetype)initWithUser:(RA_ParseUser *)user andContext:(RA_UserProfileContext)context;

@end


