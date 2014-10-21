//
//  RA_ProposeGameBaseCell.h
//  Rally
//
//  Created by Max de Vere on 20/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RA_ProposeGame.h"

@interface RA_ProposeGameBaseCell : UITableViewCell

@property (strong, nonatomic) RA_ProposeGame *myViewController;
-(void)configureCell; // To be overriden

@end
