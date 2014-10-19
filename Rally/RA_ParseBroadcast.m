


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


@dynamic type;
@dynamic freeText;
@dynamic userOne;
@dynamic userTwo;
@dynamic visibility;
@dynamic game;


@end

