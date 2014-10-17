//
//  RA_LeagueCell.h
//  Rally
//
//  Created by Alex Brunicki on 16/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RA_LeagueCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *rankNo;
@property (weak, nonatomic) IBOutlet UILabel *playerName;
@property (weak, nonatomic) IBOutlet UILabel *playerScore;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityWheel;
@property (weak, nonatomic) IBOutlet PFImageView *playerPic;

@end
