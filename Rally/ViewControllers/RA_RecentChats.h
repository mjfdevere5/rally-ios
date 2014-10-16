//
//  RA_Messages.h
//  Rally
//
//  Created by Max de Vere on 24/09/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface RA_RecentChats : UITableViewController<MBProgressHUDDelegate>

- (IBAction)refresh:(UIBarButtonItem *)sender;

@end


