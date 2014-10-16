//
//  RA_ParseFacilities.h
//  Rally
//
//  Created by Max de Vere on 07/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import <Parse/Parse.h>

@interface RA_ParseFacilities : PFObject<PFSubclassing>

+(NSString *)parseClassName;

@property (strong, nonatomic) NSString *name;

@property (strong, nonatomic) NSString *addressLine1;
@property (strong, nonatomic) NSString *addressLine2;
@property (strong, nonatomic) NSString *addressCity;
@property (strong, nonatomic) NSString *addressCounty;
@property (strong, nonatomic) NSString *addressPostcode;
@property (strong, nonatomic) NSString *addressCountry;

@property (strong, nonatomic) NSString *website;
@property (strong, nonatomic) NSString *contactNumber;

@end
