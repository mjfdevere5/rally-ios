//
//  RA_ProposeGame.h
//  Rally
//
//  Created by Max de Vere on 20/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RA_ParseGame.h"

@interface RA_ProposeGame : UIViewController<UITableViewDataSource, UITableViewDelegate>

// Game we are creating
@property (strong, nonatomic) RA_ParseUser *opponent;
@property (strong, nonatomic) NSString *sport;
@property (strong, nonatomic) NSDate *dateTime;

// Storyboard stuff
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *separatorLine;
@property (weak, nonatomic) IBOutlet UIButton *setPrefButton;
- (IBAction)setPrefButtonTapped:(id)sender;

@end
