//
//  RA_NextGameDateTimeCell.h
//  Rally
//
//  Created by Max de Vere on 17/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_NextGameBaseCell.h"

@interface RA_NextGameDateTimeCell : RA_NextGameBaseCell

@property (nonatomic) NSInteger preferenceNumber; // 0 is first, 1 is backup, so forth

@property (weak, nonatomic) IBOutlet UIButton *earlierDay;
@property (weak, nonatomic) IBOutlet UIButton *laterDay;
@property (weak, nonatomic) IBOutlet UIButton *earlierTime;
@property (weak, nonatomic) IBOutlet UIButton *laterTime;

@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UIView *lineViewTopLeft;
@property (weak, nonatomic) IBOutlet UIView *lineViewTopRight;
@property (weak, nonatomic) IBOutlet UIView *lineViewBottomLeft;
@property (weak, nonatomic) IBOutlet UIView *lineViewBottomRight;

- (IBAction)tappedEarlierDay:(id)sender;
- (IBAction)tappedLaterDay:(id)sender;
- (IBAction)tappedEarlierTime:(id)sender;
- (IBAction)tappedLaterTime:(id)sender;

@end
