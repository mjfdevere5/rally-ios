//
//  NSDate+CoolStrings.h
//  Rally
//
//  Created by Max de Vere on 04/09/2014.
//  Copyright (c) 2014 NA. All rights reserved.
//

// TO DO: This needs a rethink, using the built-in stuff.

#import <Foundation/Foundation.h>

@interface NSDate (CoolStrings)

// Utilities
-(NSString *)get24HourClockString;
-(NSString *)getCommonSpeechClock;
-(NSString *)getDayLong:(BOOL)dayLong;
-(NSString *)getEnglishOrdinalForUnsignedInteger:(NSInteger)theInteger;
-(NSString *)getDateOrdinal:(BOOL)dateOrdinal;
-(NSString *)getMonthLong:(BOOL)monthLong;
-(NSString *)getYearLong:(BOOL)yearLong;
-(NSString *)getDayLong:(BOOL)dayLong dateOrdinal:(BOOL)dateOrdinal monthLong:(BOOL)monthLong;

// Special outputs
-(NSString *)getCommonSpeechDayLong:(BOOL)dayLong dateOrdinal:(BOOL)dateOrdinal monthLong:(BOOL)monthLong;
-(NSString *)getCommonSpeechWithOnDayLong:(BOOL)dayLong dateOrdinal:(BOOL)dateOrdinal monthLong:(BOOL)monthLong;
-(NSString *)getTimeStampNewsFeed;

// For tidy up
-(NSString *)getDatePrettyString;
-(NSString *)getDatePrettyStringOn;
-(NSString *)getDatePrettyStringFeed;
-(NSString *)getDatePrettyStringPast;
-(NSString *)getDatePrettyStringMessages;


@end


