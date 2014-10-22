//
//  RA_LadderFormTwo.h
//  Rally
//
//  Created by Max de Vere on 23/09/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RA_NextGameBaseCell.h"

@interface RA_NextGamePrefTwo : UIViewController<UITableViewDelegate, UITableViewDataSource, RA_NextGameCellDelegate>

// Storyboard stuff
@property (weak, nonatomic) IBOutlet UITableView *tableView;
-(IBAction)setPrefButtonPushed:(UIButton *)button;
@property (weak, nonatomic) IBOutlet UILabel *separatorLine;
@property (weak, nonatomic) IBOutlet UIButton *button;

// Optional cell delegate methods
//-(void)turnOffPrefThree; // TO DO
//-(void)turnOnPrefTwo;

@end
