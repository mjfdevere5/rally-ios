//
//  RA_SportsSelector_TableViewController.h
//  Rally
//
//  Created by Max de Vere on 27/08/2014.
//  Copyright (c) 2014 NA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface RA_PlayMenu : UITableViewController<MBProgressHUDDelegate>

-(void)loadTableData;

@end
