//
//  PFObject+Utilities.m
//  Rally
//
//  Created by Max de Vere on 19/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "PFObject+Utilities.h"

@implementation PFObject (Utilities)

-(BOOL)containedInArray:(NSArray *)array
{
    for (PFObject *item in array) {
        if ([item.objectId isEqualToString:self.objectId]) {
            return YES;
            break;
        }
    }
    return NO;
}

@end
