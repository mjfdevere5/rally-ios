//
//  RA_LadderForm.h
//  Rally
//
//  Created by Max de Vere on 19/09/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RA_NextGameBaseCell.h"

@interface RA_NextGamePrefOne : UIViewController<UITableViewDelegate, UITableViewDataSource, RA_NextGameCellDelegate>

// Storyboard stuff
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *button;

@property (weak, nonatomic) IBOutlet UILabel *separatorLine;
-(IBAction)setPrefButtonPushed:(UIButton *)button;

// Optional cell delegate methods
-(void)didPickSport;

@end


