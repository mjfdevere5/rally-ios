//
//  RA_FindGameHomeView.h
//  Rally
//
//  Created by Max de Vere on 16/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface RA_FindGameHomeView : UIViewController<UITableViewDataSource, UITableViewDelegate, MBProgressHUDDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *freshGameButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshBarButton;
- (IBAction)tappedRefreshBarButton:(id)sender;


@end


