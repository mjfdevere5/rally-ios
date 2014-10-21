//
//  NSDate+CoolStrings.m
//  Rally
//
//  Created by Max de Vere on 04/09/2014.
//  Copyright (c) 2014 NA. All rights reserved.
//

#import "NSDate+CoolStrings.h"
#import "NSDate+Utilities.h"


@implementation NSDate (CoolStrings)


#pragma mark - utilities
// ******************** utilities ********************



-(NSString *)get24HourClockString
{
    NSDateFormatter *clockFormatter;
    [clockFormatter setDateFormat:@"HH:mm"];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [clockFormatter setTimeZone:gmt];
    return [clockFormatter stringFromDate:self];
}



-(NSString *)getCommonSpeechClock
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    if ([self minute] == 0) {
        [dateFormatter setDateFormat:@"h"];
    }
    else {
        [dateFormatter setDateFormat:@"h:mm"];
    }
    NSString *numberPart = [dateFormatter stringFromDate:self];
    
    NSString *amOrPm;
    if ([self hour] < 12) {
        amOrPm = @"am";
    }
    else {
        amOrPm = @"pm";
    }
    
    return [numberPart stringByAppendingString:amOrPm];
}



-(NSString *)getDayLong:(BOOL)dayLong
{
    NSArray *weekdaysLong = @[@"Sunday", @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday"];
    NSArray *weekdaysShort = @[@"Sun", @"Mon", @"Tues", @"Weds", @"Thurs", @"Fri", @"Sat"];
    NSInteger index = [self weekday] - 1;
    return dayLong ? weekdaysLong[index] : weekdaysShort[index];
}



-(NSString *)getEnglishOrdinalForUnsignedInteger:(NSInteger)theInteger
{
    // Declare suffix, which will be the 'th' or 'st', etc.
    NSString *suffix;
    
    // Special cases, numbers ending with 11, 12, or 13
    if (NSLocationInRange(theInteger % 100, NSMakeRange(11, 3))) {
        suffix = @"th";
    }
    
    // Other cases
    switch (theInteger % 10) {
        case 1:
            suffix = @"st";
        case 2:
            suffix = @"nd";
        case 3:
            suffix = @"rd";
        default:
            suffix = @"th";
    }
    
    // Now append the suffix to the number and return the whole string
    return [NSString stringWithFormat:@"%li%@", (long)theInteger, suffix];
}



-(NSString *)getDateOrdinal:(BOOL)dateOrdinal
{
    return dateOrdinal ? [self getEnglishOrdinalForUnsignedInteger:[self day]] : [NSString stringWithFormat:@"%lu",(unsigned long)[self day]];
}



-(NSString *)getMonthLong:(BOOL)monthLong
{
    return monthLong ? [self stringWithFormat:@"MMMM"] : [self stringWithFormat:@"MMM"];
}



-(NSString *)getYearLong:(BOOL)yearLong
{
    return yearLong ? [self stringWithFormat:@"y"] : [NSString stringWithFormat:@"'%@",[self stringWithFormat:@"yy"]];
}



-(NSString *)getDayLong:(BOOL)dayLong dateOrdinal:(BOOL)dateOrdinal monthLong:(BOOL)monthLong
{
    NSString *dayString = [self getDayLong:dayLong];
    NSString *dateString = [self getDateOrdinal:dateOrdinal];
    NSString *monthString = [self getMonthLong:monthLong];
    
    return [NSString stringWithFormat:@"%@ %@ %@", dayString, dateString, monthString];
}



#pragma mark - special outputs
// ******************** special outputs ********************


-(NSString *)getCommonSpeechDayLong:(BOOL)dayLong dateOrdinal:(BOOL)dateOrdinal monthLong:(BOOL)monthLong
{
    NSString *result;
    if ([self isYesterday]) {
        result = @"Yesterday";
    }
    else if ([self isToday]) {
        result = @"Today";
    }
    else if ([self isTomorrow]) {
        result = @"Tomorrow";
    }
    else if ([self isInFuture] && [self isThisWeek]) {
        result = [NSString stringWithFormat:@"This %@", [self getDayLong:dayLong]];
    }
    else if ([self isNextWeek]) {
        if ([self weekday]==1) {
            // Case: Sunday
            result = @"This Sunday";
        }
        else {
            // Case: Next week but not Sunday
            result = [NSString stringWithFormat:@"Next %@", [self getDayLong:dayLong]];
        }
    }
    else {
        // Case: Some other day, either in the future or the past
        result = [self getDayLong:dayLong dateOrdinal:dateOrdinal monthLong:monthLong];
    }
    
    return result;
}



-(NSString *)getCommonSpeechWithOnDayLong:(BOOL)dayLong dateOrdinal:(BOOL)dateOrdinal monthLong:(BOOL)monthLong
{
    NSString *result;
    if ([self isYesterday]) {
        result = @"yesterday";
    }
    else if ([self isToday]) {
        result = @"today";
    }
    else if ([self isTomorrow]) {
        result = @"tomorrow";
    }
    else if ([self isInFuture] && [self isThisWeek]) {
        result = [NSString stringWithFormat:@"this %@", [self getDayLong:dayLong]];
    }
    else if ([self isNextWeek]) {
        if ([self weekday]==1) {
            // Case: Sunday
            result = @"this Sunday";
        }
        else {
            // Case: Next week but not Sunday
            result = [NSString stringWithFormat:@"next %@", [self getDayLong:dayLong]];
        }
    }
    else {
        // Case: Some other day, either in the future or the past
        result = [NSString stringWithFormat:@"on %@",[self getDayLong:YES dateOrdinal:YES monthLong:YES]];
    }
    
    return result;
}



-(NSString *)getTimeStampNewsFeed
{
    NSString *timeStamp;
    
    NSDate *timeNow = [NSDate date];
    NSTimeInterval interval = [timeNow timeIntervalSinceDate: self];
    interval = fabs(interval);
    
    if (interval <= 120) {
        timeStamp = @"Just a moment ago";
    }
    else if (interval <= 3600) {
        int minutes = floor(interval/60);
        timeStamp = [NSString stringWithFormat:@"About %i minutes ago", minutes];
    }
    else if (interval <= 7200) {
        int hours = floor(interval/3600);
        //int minutes = trunc(interval - hours*60);
        timeStamp = [NSString stringWithFormat:@"About %i hour ago", hours];
    }
    else if (interval < 86400) {
        int hours = floor(interval / 3600);
        timeStamp = [NSString stringWithFormat:@"About %i hours ago", hours];
    }
    
    else {
        // "Yesterday at XX:XX"
        // "Sunday at XX:XX"
        // "Thurs 28 Nov at XX:XX"
        
        // Get the clock bit
        NSString *clockString = [self get24HourClockString];
        NSString *dayString = [self getCommonSpeechDayLong:NO dateOrdinal:NO monthLong:NO];
        timeStamp = [NSString stringWithFormat:@"%@ at %@", dayString, clockString];
    }
    
    // Return the timeStamp
    return timeStamp;
}



#pragma mark - TO DO tidy up
// ******************** TO DO TIDY UP ********************



// For the shoutForm
-(NSString *)getDatePrettyString
{
    NSString *dayPrettyString;
    
    if ([self isEarlierThanDate: [NSDate dateYesterday]])
        dayPrettyString = @"In the past?";
    else if ([self isYesterday])
        dayPrettyString = @"Yesterday?";
    else if ([self isToday])
        dayPrettyString = @"Today";
    else if ([self isTomorrow])
        dayPrettyString = @"Tomorrow";
    else if ([self isThisWeek])
        dayPrettyString = [NSString stringWithFormat: @"This %@", [self getDayLong:NO]];
    else if ([self isNextWeek] && [self weekday]==1) // case 'Sunday'
        dayPrettyString = @"Sunday";
    else if ([self isNextWeek])
        dayPrettyString = [NSString stringWithFormat: @"Next %@", [self getDayLong:NO]];
    else if ([self isLaterThanDate: [NSDate date]]) // double-check date is in future
        dayPrettyString = [NSString stringWithFormat: @"%@ %li %@",
                           [self getDayLong:NO],
                           (long) [self day],
                           [self stringWithFormat: @"MMM"]];
    else
        dayPrettyString = @"???"; // hopefully you won't ever see this
    
    return dayPrettyString;
}


// For the recMatches navbar
-(NSString *)getDatePrettyStringOn
{
    NSArray *weekdayStrings = @[@"Sun", @"Mon", @"Tues", @"Weds", @"Thurs", @"Fri", @"Sat"];
    NSString *dayPrettyString;
    
    if ([self isEarlierThanDate: [NSDate dateYesterday]])
        dayPrettyString = @"In the past?";
    else if ([self isYesterday])
        dayPrettyString = @"Yesterday?";
    else if ([self isToday])
        dayPrettyString = @"today";
    else if ([self isTomorrow])
        dayPrettyString = @"tomorrow";
    else if ([self isThisWeek])
        dayPrettyString = [NSString stringWithFormat: @"this %@", [self getDayLong:NO]];
    else if ([self isNextWeek] && [self weekday]==1) // case 'Sunday'
        dayPrettyString = @"on Sunday";
    else if ([self isNextWeek])
        dayPrettyString = [NSString stringWithFormat: @"next %@", [self getDayLong:NO]];
    else if ([self isLaterThanDate: [NSDate date]]) // double-check date is in future
        dayPrettyString = [NSString stringWithFormat: @"on %@ %li %@",
                           weekdayStrings[ [self weekday]-1 ],
                           (long) [self day],
                           [self stringWithFormat: @"MMM"]];
    else
        dayPrettyString = @"???"; // hopefully you won't ever see this
    
    return dayPrettyString;
}



-(NSString *)getDatePrettyStringFeed
{
    NSString *dayPrettyString;
    
    if ([self isEarlierThanDate: [NSDate dateYesterday]])
        dayPrettyString = @"in the past???";
    else if ([self isYesterday])
        dayPrettyString = @"yesterday???";
    else if ([self isToday])
        dayPrettyString = [NSString stringWithFormat:@"today (%@)", [self getDayLong:NO]];
    else if ([self isTomorrow])
        dayPrettyString = [NSString stringWithFormat:@"tomorrow (%@)", [self getDayLong:NO]];
    else if ([self isThisWeek])
        dayPrettyString = [NSString stringWithFormat: @"this %@", [self getDayLong:NO]];
    else if ([self isNextWeek] && [self weekday]==1) // case 'Sunday'
        dayPrettyString = @"on Sunday";
    else if ([self isNextWeek])
        dayPrettyString = [NSString stringWithFormat: @"next %@", [self getDayLong:NO]];
    else if ([self isLaterThanDate: [NSDate date]]) // double-check date is in future
        dayPrettyString = [self getDayLong:NO dateOrdinal:NO monthLong:NO];
    else
        dayPrettyString = @"???"; // hopefully you won't ever see this
    
    return dayPrettyString;
}



-(NSString *)getDatePrettyStringPast
{
    NSString *dayPrettyString;
    
    if ([self isYesterday])
        dayPrettyString = @"Yesterday";
    else if ([self isToday])
        dayPrettyString = @"Today";
    else if ([self isThisWeek])
        dayPrettyString = [NSString stringWithFormat: @"On %@", [self getDayLong:NO]];
    else if ([self isLastWeek])
        dayPrettyString = [NSString stringWithFormat: @"Last week %@", [self getDayLong:NO]];
    else
        dayPrettyString = @"???"; // hopefully you won't ever see this
    
    return dayPrettyString;
}



-(NSString *)getDatePrettyStringMessages
{
    NSString *dayPrettyString;
    
    if ([self isEarlierThanDate: [NSDate dateYesterday]])
        dayPrettyString = [self getDayLong:NO dateOrdinal:NO monthLong:NO];
    else if ([self isYesterday])
        dayPrettyString = @"Yesterday";
    else if ([self isToday])
        dayPrettyString = @"Today";
    else if ([self isTomorrow])
        dayPrettyString = @"Tomorrow?";
    else
        dayPrettyString = @"???"; // hopefully you won't ever see this
    
    return dayPrettyString;
}



@end


