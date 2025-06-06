//
//  RA_newsfeedShoutCell2.h
//  Rally
//
//  Created by Alex Brunicki on 25/09/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RA_FindGameHomeView.h"
#import "RA_ParseBroadcast.h"

@interface RA_FeedCellShout : UITableViewCell

@property (strong, nonatomic) RA_ParseGamePreferences *gamePref;
@property (strong, nonatomic) RA_FindGameHomeView *myViewController;
@property (strong, nonatomic) NSIndexPath *indexPath;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeStamp;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnail;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *thumbnailActivityWheel;
@property (weak, nonatomic) IBOutlet UILabel *lookingToPlayLabel;
@property (weak, nonatomic) IBOutlet UILabel *preferenceBulletsLabel;

-(void)configureCell;
-(void)configureEverythingExceptImages;

@end
