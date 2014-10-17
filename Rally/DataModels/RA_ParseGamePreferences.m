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


@dynamic sport;
@dynamic networks;
@dynamic dateTimePreferences;
@dynamic location;
@dynamic locationDesc;
@dynamic playWho;
@dynamic user;



@end


