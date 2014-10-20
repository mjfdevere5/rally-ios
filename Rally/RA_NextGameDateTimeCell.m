//
//  RA_NextGameDateTimeCell.m
//  Rally
//
//  Created by Max de Vere on 17/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_NextGameDateTimeCell.h"
#import "RA_GamePrefConfig.h"
#import "NSDate+CoolStrings.h"
#import "NSDate+Utilities.h"


@interface RA_NextGameDateTimeCell()
@property (strong, nonatomic) NSDate *dateTime;
@end


@implementation RA_NextGameDateTimeCell


#pragma mark - load up
// ******************** load up ********************

-(void)configureCell // Gets called on loadup and every time a button is tapped
{ COMMON_LOG
    // Formatting
    // TO DO
    
    // Get the RA_TimeAndDatePreference object we're working with
    self.dateTime = [RA_GamePrefConfig gamePrefConfig].dateTimePreferences[self.preferenceNumber];
    
    self.dayLabel.text = [self.dateTime getCommonSpeechDayLong:NO dateOrdinal:NO monthLong:NO];
    [self.dayLabel sizeToFit]; // TO DO: is this correct?
    self.timeLabel.text = [self.dateTime getCommonSpeechClock];
    [self.timeLabel sizeToFit]; // TO DO: is this correct?
    
    // Set buttons active/inactive
    BOOL earlierDayEnabled = [[self.dateTime dateBySubtractingDays:1] isLaterThanDate:[NSDate date]];
    BOOL laterDayEnabled = [[self.dateTime dateByAddingDays:1] isEarlierThanDate:[[NSDate date] dateByAddingDays:14]];
    BOOL earlierTimeEnabled = [[self.dateTime dateBySubtractingHours:1] isLaterThanDate:[NSDate date]];
    BOOL laterTimeEnabled = [[self.dateTime dateByAddingHours:1] isEarlierThanDate:[[NSDate date] dateByAddingDays:14]];
    [self.earlierDay setEnabled:earlierDayEnabled];
    [self.laterDay setEnabled:laterDayEnabled];
    [self.earlierTime setEnabled:earlierTimeEnabled];
    [self.laterTime setEnabled:laterTimeEnabled];
    
    // Layout
    [self setNeedsLayout];
    [self layoutIfNeeded];
}


#pragma mark - taps
// ******************** taps ********************

- (IBAction)tappedEarlierDay:(id)sender
{
    [RA_GamePrefConfig gamePrefConfig].dateTimePreferences[self.preferenceNumber] = [[RA_GamePrefConfig gamePrefConfig].dateTimePreferences[self.preferenceNumber] dateBySubtractingDays:1];
    [self configureCell];
}

- (IBAction)tappedLaterDay:(id)sender
{
    [RA_GamePrefConfig gamePrefConfig].dateTimePreferences[self.preferenceNumber] = [[RA_GamePrefConfig gamePrefConfig].dateTimePreferences[self.preferenceNumber] dateByAddingDays:1];
    [self configureCell];
}

- (IBAction)tappedEarlierTime:(id)sender
{
    [RA_GamePrefConfig gamePrefConfig].dateTimePreferences[self.preferenceNumber] = [[RA_GamePrefConfig gamePrefConfig].dateTimePreferences[self.preferenceNumber] dateBySubtractingHours:1];
    [self configureCell];
}

- (IBAction)tappedLaterTime:(id)sender
{
    [RA_GamePrefConfig gamePrefConfig].dateTimePreferences[self.preferenceNumber] = [[RA_GamePrefConfig gamePrefConfig].dateTimePreferences[self.preferenceNumber] dateByAddingHours:1];
    [self configureCell];
}


@end


