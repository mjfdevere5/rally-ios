//
//  RA_ParseGamePreferences.m
//  Rally
//
//  Created by Max de Vere on 20/09/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_ParseGamePreferences.h"
#import <Parse/PFObject+Subclass.h>


@implementation RA_ParseGamePreferences


+(NSString *)parseClassName
{
    return @"LadderGamePreferences";
}

+ (void)load {
    [self registerSubclass];
}


@dynamic network;
@dynamic sportName;
@dynamic dayFirstPref;
@dynamic timeFirstPref;
@dynamic hasSecondPref;
@dynamic daySecondPref;
@dynamic timeSecondPref;
@dynamic hasThirdPref;
@dynamic dayThirdPref;
@dynamic timeThirdPref;
@dynamic location;
@dynamic locationDesc;
@dynamic playWho;
@dynamic bookingHelpWanted;
@dynamic additionalInfo;
@dynamic user;



-(NSInteger)getNumberOfPreferences
{
    if (self.hasThirdPref) {
        return 3;
    }
    else if (self.hasSecondPref) {
        return 2;
    }
    else {
        return 1;
    }
}



-(NSString *)getTimeStringFor:(NSNumber *)time
{
    if ([time isEqualToNumber:@0]) {
        return @"morning";
    }
    else if ([time isEqualToNumber:@1]) {
        return @"afternoon";
    }
    else if ([time isEqualToNumber:@2]) {
        return @"evening";
    }
    else {
        COMMON_LOG_WITH_COMMENT(@"ERROR: Unexpected time")
        return @"...";
    }
}

-(NSString *)timeFirstPrefString
{
    return [self getTimeStringFor:self.timeFirstPref];
}

-(NSString *)timeSecondPrefString
{
    return [self getTimeStringFor:self.timeSecondPref];
}

-(NSString *)timeThirdPrefString
{
    return [self getTimeStringFor:self.timeThirdPref];
}



@end


