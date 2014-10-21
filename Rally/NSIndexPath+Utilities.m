//
//  NSIndexPath+Utilities.m
//  Rally
//
//  Created by Max de Vere on 19/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "NSIndexPath+Utilities.h"

@implementation NSIndexPath (Utilities)

-(NSIndexPath *)indexPathKey
{
    if ([self class] == [NSIndexPath class]) {
        return self;
    }
    return [NSIndexPath indexPathForRow:self.row inSection:self.section];
}

@end
