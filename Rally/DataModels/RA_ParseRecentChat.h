//
//  RA_MessageObject.h
//  Rally
//
//  Created by Max de Vere on 24/09/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import <Parse/Parse.h>
#import "ChatView.h"

@interface RA_ParseRecentChat : PFObject<PFSubclassing>

+(NSString *)parseClassName;

// Which user
@property (strong, nonatomic) RA_ParseUser *user;
@property (strong, nonatomic) NSDate *dateUpdated;

// Cell data
@property (nonatomic) BOOL markAsSeen; // so we know whether to mark as read
@property (strong, nonatomic) NSString *fromName; // i.e. a profile name or @"The Rally Team"
@property (strong, nonatomic) PFFile *thumbnailFile;
@property (strong, nonatomic) NSString *messagePreview; // string to show user in RA_Messages

// Chatroom data
@property (strong, nonatomic) RA_ParseUser *fromUser; // the user that is associated with the message
@property (strong, nonatomic) NSString *chatroomId; // to identify chatroom
@property (strong, nonatomic) PFObject *chatroom; // direct link, not sure if we just use this instead

@end

