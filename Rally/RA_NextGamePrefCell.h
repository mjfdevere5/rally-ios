//
//  RA_LadderFormCell.h
//  Rally
//
//  Created by Max de Vere on 19/09/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RA_NextGamePrefOne.h"
#import "RA_NextGamePrefTwo.h"

@interface RA_NextGamePrefCell : UITableViewCell<UITextViewDelegate>

// Who is my tableView? Passed in by RA_LadderForm
@property (strong, nonatomic) RA_NextGamePrefOne *topViewOne;
@property (strong, nonatomic) RA_NextGamePrefTwo *topViewTwo;

// Of the three preference cells, which one am I?
// This gets set when RA_LadderForm loads this cell up in cellForRowAtIndexPath
@property (strong, nonatomic) NSString *preferenceKey;

// when_preference
@property (weak, nonatomic) IBOutlet UILabel *prefLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UISwitch *preferenceSwitch;
@property (weak, nonatomic) IBOutlet UIStepper *dateStepper;
@property (weak, nonatomic) IBOutlet UIStepper *timeStepper;
- (IBAction)prefToggled:(UISwitch *)sender;
- (IBAction)dateChanged:(UIStepper *)sender;
- (IBAction)timeChanged:(UIStepper *)sender;

// who preferences
@property (weak, nonatomic) IBOutlet UITextView *whoToPlayBlurb;

-(IBAction)whoToPlay:(UISegmentedControl *)sender;
@property (weak, nonatomic) IBOutlet UISegmentedControl *whoControl;


// location preferences
@property (weak, nonatomic) IBOutlet UILabel *comingFromStaticLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationOutlet;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingCircle;


// court_booking_preference
// TO DO: Do we need a switch outlet? So that we can set the default?
@property (weak, nonatomic) IBOutlet UILabel *courtBookingHelpBlurb;
@property (weak, nonatomic) IBOutlet UITextView *courtBookingSpiel;
@property (weak, nonatomic) IBOutlet UISwitch *courtBookingSwitch;
- (IBAction)courtBookingHelpSwitchChanged:(UISwitch *)sender;

// additional_info
@property (weak, nonatomic) IBOutlet UITextView *additionalInfoTextView;


// updateCell gets called by the RA_LadderForm view controller whenever something changes
-(void)updateCell;

@end
