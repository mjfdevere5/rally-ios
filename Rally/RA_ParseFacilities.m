//
//  RA_ParseFacilities.m
//  Rally
//
//  Created by Max de Vere on 07/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_ParseFacilities.h"
#import <Parse/PFObject+Subclass.h>

@implementation RA_ParseFacilities


+(NSString *)parseClassName
{
    return @"Facilities";
}


+ (void)load
{
    [self registerSubclass];
}


@dynamic name;
@dynamic addressLine1;
@dynamic addressLine2;
@dynamic addressCity;
@dynamic addressCounty;
@dynamic addressPostcode;
@dynamic addressCountry;
@dynamic website;
@dynamic contactNumber;


@end
