//
//  RA_MessageObject.h
//  Rally
//
//  Created by Max de Vere on 24/09/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import <Parse/Parse.h>
#import "RA_ParseChatroom.h"

@interface RA_ParseRecentChat : PFObject<PFSubclassing>

+(NSString *)parseClassName;

@property (strong, nonatomic) RA_ParseUser *user;
@property (strong, nonatomic) RA_ParseUser *fromUser; // the user that is associated with the message
@property (strong, nonatomic) NSDate *dateUpdated;
@property (strong, nonatomic) NSString *messagePreview; // string to show user in RA_Messages
@property (strong, nonatomic) RA_ParseChatroom *chatroom; // direct link, not sure if we just use this instead
@property (nonatomic) BOOL markAsSeen; // so we know whether to mark as read

@end

