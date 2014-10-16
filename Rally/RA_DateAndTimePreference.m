//
//  RA_DateAndTimePreference.m
//  Rally
//
//  Created by Max de Vere on 22/09/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_DateAndTimePreference.h"
#import "NSDate+CoolStrings.h"
#import "NSDate+Utilities.h"
#import "AppConstants.h"


@implementation RA_DateAndTimePreference


#pragma mark - load up
// ******************** load up ********************


-(instancetype)initWithDate:(NSDate *)theDate andTime:(NSNumber *)theTime andIsEnabled:(BOOL)theIsEnabled
{
    self = [super init];
    if (self) {
        self.date = theDate;
        self.time = theTime;
        self.isEnabled = theIsEnabled;
    }
    return self;
}



#pragma mark - get cell output strings
// ******************** get cell output strings ********************


-(NSString *)getDateString
{
    if (!self.isEnabled) {
        return LADDER_FORM_NON_APPLIC;
    }
    return [self.date getDatePrettyString];
}



-(NSString *)getTimeString
{
    if (!self.isEnabled) {
        return LADDER_FORM_NON_APPLIC;
    }
    else {
        if ([self.time isEqualToNumber:@0]) {
            return @"Morning";
        }
        else if ([self.time isEqualToNumber:@1]) {
            return @"Afternoon";
        }
        else if ([self.time isEqualToNumber:@2]) {
            return @"Evening";
        }
        else {
            NSLog(@"ERROR in %@, %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
            return @"Hmm...";
        }
    }
}



#pragma mark - object equality
// ******************** object equality ********************


-(BOOL)bothActiveAndEqual:(RA_DateAndTimePreference *)pref
{
    return ([self.date isEqualToDateIgnoringTime:pref.date] &&
            [self.time isEqualToNumber:pref.time] &&
            self.isEnabled &&
            pref.isEnabled);
}



@end


