//
//  RA_ParseUser.m
//  Rally
//
//  Created by Max de Vere on 06/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_ParseUser.h"
#import <Parse/PFObject+Subclass.h>


@implementation RA_ParseUser


+(void)load
{
    [self registerSubclass];
}


// Direct from Facebook
@dynamic facebookID;
@dynamic firstName;
@dynamic lastName;
@dynamic email;
@dynamic gender;
@dynamic facebookLink;
@dynamic facebookImage;

// Basic stuff
@dynamic displayName;
@dynamic aboutMe;
@dynamic madeShoutBefore;
@dynamic madeLeagueRequestBefore;

// Images
@dynamic profilePicLarge;
@dynamic profilePicMedium;
@dynamic profilePicSmall;

// Other stuff
@dynamic networkMemberships;
@dynamic games;





@end


