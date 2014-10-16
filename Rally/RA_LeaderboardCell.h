//
//  RA_LadderRankingCellTableViewCell.h
//  Rally
//
//  Created by Alex Brunicki on 30/09/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RA_LeaderboardCell : UITableViewCell

@property (strong, nonatomic)IBOutlet UILabel *playerName;
@property (strong, nonatomic)IBOutlet UILabel *rankNumber;
@property (strong, nonatomic)IBOutlet PFImageView *playerPic;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityWheel;
@property (weak, nonatomic) IBOutlet UILabel *ladderScore;

@end

