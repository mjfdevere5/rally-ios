//
//  RA_NextGameDateTimeCell.m
//  Rally
//
//  Created by Max de Vere on 17/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_NextGameDateTimeCell.h"
#import "RA_GamePrefConfig.h"
#import "RA_TimeAndDatePreference.h"
#import "NSDate+CoolStrings.h"
#import "NSDate+Utilities.h"


@interface RA_NextGameDateTimeCell()
@property (strong, nonatomic) RA_TimeAndDatePreference *timeAndDate;
@end


@implementation RA_NextGameDateTimeCell


#pragma mark - load up
// ******************** load up ********************

-(void)configureCell // Gets called on loadup and every time a button is tapped
{ COMMON_LOG
    // Formatting
    // TO DO
    
    // Get the RA_TimeAndDatePreference object we're working with
    if (self.preferenceNumber == 0) {
        self.timeAndDate = [RA_GamePrefConfig gamePrefConfig].firstPreference;
    }
    else if (self.preferenceNumber == 1) {
        self.timeAndDate = [RA_GamePrefConfig gamePrefConfig].backupPreference;
    }
    
    self.dayLabel.text = [[(RA_TimeAndDatePreference *)self.timeAndDate getDay] getCommonSpeechDayLong:NO dateOrdinal:NO monthLong:NO];
    [self.dayLabel sizeToFit]; // TO DO: is this correct?
    self.timeLabel.text = [(RA_TimeAndDatePreference *)self.timeAndDate timeStringCapitalized];
    [self.timeLabel sizeToFit]; // TO DO: is this correct?
    
    // Set buttons active/inactive
    [self.earlierDay setEnabled:(![self.timeAndDate isMinDay])];
    [self.laterDay setEnabled:(![self.timeAndDate isMaxDay])];
    [self.earlierTime setEnabled:(![self.timeAndDate isMinTime])];
    [self.laterTime setEnabled:(![self.timeAndDate isMaxTime])];
    
    // Layout
    [self layoutIfNeeded];
}


#pragma mark - taps
// ******************** taps ********************

- (IBAction)tappedEarlierDay:(id)sender
{
    NSDate *dateBeforeTap = [self.timeAndDate getDay];
    NSNumber *timeBeforeTap = [self.timeAndDate timeNumber];
    RA_TimeAndDatePreference *pref = [[RA_TimeAndDatePreference alloc] initWithDay:[dateBeforeTap dateBySubtractingDays:1]
                                                                    andTimeInteger:[timeBeforeTap integerValue]];
    // Not pretty but works
    if (self.preferenceNumber == 0) {
        [RA_GamePrefConfig gamePrefConfig].firstPreference = pref;
    }
    else if (self.preferenceNumber == 1) {
        [RA_GamePrefConfig gamePrefConfig].backupPreference = pref;
    }
    [self configureCell];
}

- (IBAction)tappedLaterDay:(id)sender
{
    NSDate *dateBeforeTap = [self.timeAndDate getDay];
    NSNumber *timeBeforeTap = [self.timeAndDate timeNumber];
    RA_TimeAndDatePreference *pref = [[RA_TimeAndDatePreference alloc] initWithDay:[dateBeforeTap dateByAddingDays:1]
                                                                    andTimeInteger:[timeBeforeTap integerValue]];
    // Not pretty but works
    if (self.preferenceNumber == 0) {
        [RA_GamePrefConfig gamePrefConfig].firstPreference = pref;
    }
    else if (self.preferenceNumber == 1) {
        [RA_GamePrefConfig gamePrefConfig].backupPreference = pref;
    }
    [self configureCell];
}

- (IBAction)tappedEarlierTime:(id)sender
{
    NSDate *dateBeforeTap = [self.timeAndDate getDay];
    NSNumber *timeBeforeTap = [self.timeAndDate timeNumber];
    RA_TimeAndDatePreference *pref = [[RA_TimeAndDatePreference alloc] initWithDay:dateBeforeTap
                                                                    andTimeInteger:([timeBeforeTap integerValue] - 1)];
    // Not pretty but works
    if (self.preferenceNumber == 0) {
        [RA_GamePrefConfig gamePrefConfig].firstPreference = pref;
    }
    else if (self.preferenceNumber == 1) {
        [RA_GamePrefConfig gamePrefConfig].backupPreference = pref;
    }
    [self configureCell];
}

- (IBAction)tappedLaterTime:(id)sender
{
    NSDate *dateBeforeTap = [self.timeAndDate getDay];
    NSNumber *timeBeforeTap = [self.timeAndDate timeNumber];
    RA_TimeAndDatePreference *pref = [[RA_TimeAndDatePreference alloc] initWithDay:dateBeforeTap
                                                                    andTimeInteger:([timeBeforeTap integerValue] + 1)];
    // Not pretty but works
    if (self.preferenceNumber == 0) {
        [RA_GamePrefConfig gamePrefConfig].firstPreference = pref;
    }
    else if (self.preferenceNumber == 1) {
        [RA_GamePrefConfig gamePrefConfig].backupPreference = pref;
    }
    [self configureCell];
}


@end


