


#import "RA_ParseBroadcast.h"
#import <Parse/PFObject+Subclass.h>


@implementation RA_ParseBroadcast


+(NSString *)parseClassName
{
    return @"Broadcast";
}


+ (void)load {
    [self registerSubclass];
}


// General
@dynamic type;
@dynamic user;
@dynamic userDisplayName;
@dynamic freeText;


@end

