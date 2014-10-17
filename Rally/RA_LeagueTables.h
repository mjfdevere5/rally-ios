//
//  RA_LeagueTables.h
//  Rally
//
//  Created by Alex Brunicki on 16/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RA_ParseNetwork.h"
#import "MBProgressHUD.h"


@interface RA_LeagueTables : UITableViewController <UIAlertViewDelegate, MBProgressHUDDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) RA_ParseNetwork *network;
-(IBAction)refresh:(UIBarButtonItem *)sender;

@end