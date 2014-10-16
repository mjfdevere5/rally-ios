//
//  RA_ladderView.h
//  Rally
//
//  Created by Alex Brunicki on 29/09/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "MBProgressHUD.h"
#import "RA_GamePrefConfig.h"

@interface RA_Leaderboard : UIViewController <UIAlertViewDelegate, MBProgressHUDDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
-(IBAction)refresh:(UIBarButtonItem *)sender;

@end


