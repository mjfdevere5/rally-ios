//
//  RA_LadderForm.h
//  Rally
//
//  Created by Max de Vere on 19/09/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface RA_NextGamePrefOne : UIViewController<UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, MBProgressHUDDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
-(IBAction)setPrefButtonPushed:(UIButton *)button;
@property (weak, nonatomic) IBOutlet UILabel *separatorLine;

-(void)turnOffPrefThree;
-(void)turnOnPrefTwo;

@end
