//
//  RA_MyGames.h
//  Rally
//
//  Created by Max de Vere on 09/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DZNSegmentedControl.h"
#import "MBProgressHUD.h"

@interface RA_MyGames : UIViewController<MBProgressHUDDelegate, UITableViewDelegate, UITableViewDataSource, DZNSegmentedControlDelegate>

@property (strong, nonatomic) IBOutlet DZNSegmentedControl *segmentControl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
-(IBAction)refresh:(UIBarButtonItem *)sender;

@end


