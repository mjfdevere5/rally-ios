//
//  RA_LadderFormTwo.h
//  Rally
//
//  Created by Max de Vere on 23/09/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import <CoreLocation/CoreLocation.h>

@interface RA_NextGamePrefTwo : UIViewController<UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, MBProgressHUDDelegate>


@property (weak, nonatomic) IBOutlet UITableView *tableView;
-(IBAction)setPrefButtonPushed:(UIButton *)button;
@property (weak, nonatomic) IBOutlet UILabel *separatorLine;

-(void)turnOffPrefThree;
-(void)turnOnPrefTwo;

@end
