//
//  NSDate+UtilitiesMax.m
//  Rally
//
//  Created by Max de Vere on 20/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "NSDate+UtilitiesMax.h"
#import "NSDate+Utilities.h"

@implementation NSDate (UtilitiesMax)

-(NSDate *)upcomingHour
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components: NSEraCalendarUnit|NSYearCalendarUnit| NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit fromDate: self];
    if ([comps hour] < 23) {
        [comps setHour: [comps hour]+1];
    }
    return [calendar dateFromComponents:comps];
}

@end
