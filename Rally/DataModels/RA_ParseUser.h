//
//  RA_ParseUser.h
//  Rally
//
//  Created by Max de Vere on 06/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//


// Note special considerations for subclassing the special type PFUser:
// https://www.parse.com/questions/subclass-pfuser


#import <Parse/Parse.h>

@interface RA_ParseUser : PFUser<PFSubclassing>

// Direct from Facebook
@property (strong, nonatomic) NSString *facebookID;
@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *gender;
@property (strong, nonatomic) NSString *facebookLink;
@property (strong, nonatomic) PFFile *facebookImage;

// Basic stuff
@property (strong, nonatomic) NSString *displayName;
@property (strong, nonatomic) NSString *aboutMe;
@property (nonatomic) BOOL madeShoutBefore;
@property (nonatomic) BOOL madeLeagueRequestBefore;

// Images
@property (strong, nonatomic) PFFile *profilePicLarge;
@property (strong, nonatomic) PFFile *profilePicMedium;
@property (strong, nonatomic) PFFile *profilePicSmall;

// Other stuff
@property (strong, nonatomic) NSMutableArray *networkMemberships;
@property (strong, nonatomic) PFRelation *games;



@end


