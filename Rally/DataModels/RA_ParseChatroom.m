//
//  RA_ParseChatroom.m
//  Rally
//
//  Created by Max de Vere on 09/09/2014.
//  Copyright (c) 2014 NA. All rights reserved.
//

#import "RA_ParseChatroom.h"
#import <Parse/PFObject+Subclass.h>

@implementation RA_ParseChatroom


+(NSString *)parseClassName
{
    return @"Chatroom";
}


+(void)load
{
    [self registerSubclass];
}


@dynamic user1;
@dynamic user2;


// Call this once user1 and user2 have been set
-(void)autoSetACL
{
    PFACL *acl = [PFACL ACL];
    [acl setReadAccess:YES forUser:self.user1];
    [acl setReadAccess:YES forUser:self.user2];
    [acl setWriteAccess:YES forUser:self.user1];
    [acl setWriteAccess:YES forUser:self.user2];
    [self setACL:acl];
}



+(instancetype)objectWithAutoACLAndUser1:(RA_ParseUser *)user1 andUser2:(RA_ParseUser *)user2
{
    RA_ParseChatroom *chatroom = [self object];
    if (chatroom) {
        chatroom.user1 = user1;
        chatroom.user2 = user2;
        [chatroom autoSetACL];
    }
    return chatroom;
}


@end

