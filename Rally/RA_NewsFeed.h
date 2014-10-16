//
//  RA_NewsFeedForm.h
//  Rally
//
//  Created by Alex Brunicki on 19/09/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import <Parse/Parse.h>
#import "MBProgressHUD.h"

@interface RA_NewsFeed : UITableViewController <MBProgressHUDDelegate>

-(IBAction)refresh:(UIBarButtonItem *)sender;
-(void)refreshTableWithHUD;

@end
