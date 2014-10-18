


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
@dynamic visibility;
@dynamic freeText;

// added by bruno
@dynamic userOne;
@dynamic userTwo;
@dynamic leftUserScore;
@dynamic rightUserScore;


@end

