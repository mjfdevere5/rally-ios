//
//  RA_ProposeGameDateTimeCell.h
//  Rally
//
//  Created by Max de Vere on 20/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_ProposeGameBaseCell.h"

@interface RA_ProposeGameDateTimeCell : RA_ProposeGameBaseCell

@property (weak, nonatomic) IBOutlet UILabel *dayOutlet;
@property (weak, nonatomic) IBOutlet UILabel *timeOutlet;

@property (weak, nonatomic) IBOutlet UIView *lineTopLeft;
@property (weak, nonatomic) IBOutlet UIView *lineTopRight;
@property (weak, nonatomic) IBOutlet UIView *lineBottomLeft;
@property (weak, nonatomic) IBOutlet UIView *lineBottomRight;

@property (weak, nonatomic) IBOutlet UIButton *earlierDayOutlet;
@property (weak, nonatomic) IBOutlet UIButton *laterDayOutlet;
@property (weak, nonatomic) IBOutlet UIButton *earlierTimeOutlet;
@property (weak, nonatomic) IBOutlet UIButton *laterTimeOutlet;

- (IBAction)earlierDayTapped:(id)sender;
- (IBAction)laterDayTapped:(id)sender;
- (IBAction)earlierTimeTapped:(id)sender;
- (IBAction)laterTimeTapped:(id)sender;

@end
