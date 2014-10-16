


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

// Shout details
@dynamic sportName;
@dynamic network;
@dynamic date;
@dynamic time;
@dynamic timeDesc;
@dynamic skill;
@dynamic skillDesc;
@dynamic location;
@dynamic locationDesc;
@dynamic visibility;
@dynamic networkName;

// Game pref
@dynamic gamePrefObject;


@end

