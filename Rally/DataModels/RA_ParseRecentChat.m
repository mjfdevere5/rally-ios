//
//  RA_MessageObject.m
//  Rally
//
//  Created by Max de Vere on 24/09/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_ParseRecentChat.h"
#import <Parse/PFObject+Subclass.h>


@implementation RA_ParseRecentChat


+(NSString *)parseClassName
{
    return @"MessageObject";
}


+ (void)load
{
    [self registerSubclass];
}


@dynamic user;
@dynamic fromUser;
@dynamic dateUpdated;
@dynamic messagePreview;
@dynamic chatroom;
@dynamic markAsSeen;

@end


