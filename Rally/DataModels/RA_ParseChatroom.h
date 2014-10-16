//
//  RA_ParseChatroom.h
//  Rally
//
//  Created by Max de Vere on 09/09/2014.
//  Copyright (c) 2014 NA. All rights reserved.
//

#import <Parse/Parse.h>
#import "RA_ParseUser.h"

@interface RA_ParseChatroom : PFObject<PFSubclassing>

+(NSString *)parseClassName;

@property (strong, nonatomic) RA_ParseUser *user1;
@property (strong, nonatomic) RA_ParseUser *user2;

-(void)autoSetACL;

+(instancetype)objectWithAutoACLAndUser1:(RA_ParseUser *)user1 andUser2:(RA_ParseUser *)user2;

@end


