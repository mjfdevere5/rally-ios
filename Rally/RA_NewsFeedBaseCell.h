//
//  RA_NewsFeedBaseCell.h
//  Rally
//
//  Created by Max de Vere on 18/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RA_NewsFeed.h"
#import "RA_ParseBroadcast.h"

@interface RA_NewsFeedBaseCell : UITableViewCell

// Passed in during cellForRowAtIndexPath
@property (strong, nonatomic) RA_NewsFeed *myViewController;
@property (strong, nonatomic) RA_ParseBroadcast *broadcast;

-(void)configureCell;

@end
