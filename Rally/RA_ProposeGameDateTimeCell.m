//
//  RA_ProposeGameDateTimeCell.m
//  Rally
//
//  Created by Max de Vere on 20/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_ProposeGameDateTimeCell.h"
#import "NSDate+Utilities.h"
#import "NSDate+CoolStrings.h"

@implementation RA_ProposeGameDateTimeCell

-(void)configureCell // Gets called on loadup and every time a button is tapped
{ COMMON_LOG
    // Formatting
    // TO DO
    
    self.dayOutlet.text = [self.myViewController.dateTime getCommonSpeechDayLong:NO dateOrdinal:NO monthLong:NO];
    [self.dayOutlet sizeToFit]; // TO DO: is this correct?
    self.timeOutlet.text = [self.myViewController.dateTime getCommonSpeechClock];
    [self.timeOutlet sizeToFit]; // TO DO: is this correct?
    
    // Set buttons active/inactive
    BOOL earlierDayEnabled = [[self.myViewController.dateTime dateBySubtractingDays:1] isLaterThanDate:[NSDate date]];
    BOOL laterDayEnabled = [[self.myViewController.dateTime dateByAddingDays:1] isEarlierThanDate:[[NSDate date] dateByAddingDays:14]];
    BOOL earlierTimeEnabled = [[self.myViewController.dateTime dateBySubtractingHours:1] isLaterThanDate:[NSDate date]];
    BOOL laterTimeEnabled = [[self.myViewController.dateTime dateByAddingHours:1] isEarlierThanDate:[[NSDate date] dateByAddingDays:14]];
    [self.earlierDayOutlet setEnabled:earlierDayEnabled];
    [self.laterDayOutlet setEnabled:laterDayEnabled];
    [self.earlierTimeOutlet setEnabled:earlierTimeEnabled];
    [self.laterTimeOutlet setEnabled:laterTimeEnabled];
    
    // Layout
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (IBAction)earlierDayTapped:(id)sender
{
    self.myViewController.dateTime = [self.myViewController.dateTime dateBySubtractingDays:1];
    [self configureCell];
}

- (IBAction)laterDayTapped:(id)sender
{
    self.myViewController.dateTime = [self.myViewController.dateTime dateByAddingDays:1];
    [self configureCell];
}

- (IBAction)earlierTimeTapped:(id)sender
{
    self.myViewController.dateTime = [self.myViewController.dateTime dateBySubtractingHours:1];
    [self configureCell];
}

- (IBAction)laterTimeTapped:(id)sender
{
    self.myViewController.dateTime = [self.myViewController.dateTime dateByAddingHours:1];
    [self configureCell];
}

@end


