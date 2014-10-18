//
//  RA_newsfeedTeamCell.h
//  Rally
//
//  Created by Alex Brunicki on 19/09/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RA_ParseBroadcast.h"
#import "RA_NewsFeedBaseCell.h"

@interface RA_NewsFeedRallyBroadcastCell : RA_NewsFeedBaseCell

// Storyboard stuff
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UITextView *freeText;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnail;
@property (weak, nonatomic) IBOutlet UILabel *timeStamp;

@end


