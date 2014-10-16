//
//  RA_DateAndTimePreference.h
//  Rally
//
//  Created by Max de Vere on 22/09/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RA_DateAndTimePreference : NSObject

@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSNumber *time;
@property (nonatomic) BOOL isEnabled;

-(instancetype)initWithDate:(NSDate *)theDate andTime:(NSNumber *)theTime andIsEnabled:(BOOL)theIsEnabled;

-(NSString *)getDateString;
-(NSString *)getTimeString;

-(BOOL)bothActiveAndEqual:(RA_DateAndTimePreference *)pref;

@end
