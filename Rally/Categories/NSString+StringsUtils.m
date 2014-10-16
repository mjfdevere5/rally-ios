//
//  NSString+StringsUtils.m
//  Rally
//
//  Created by Max de Vere on 26/09/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "NSString+StringsUtils.h"


@implementation NSString (StringsUtils)


-(NSString *)getMessagePreview
{
    NSLog(@"%@, %@", NSStringFromSelector(_cmd), [NSThread currentThread]);
    NSString *preview;
    if ([self length] < 50) {
        preview = [NSString stringWithString:self];
    }
    else {
        preview = [[self substringToIndex:40] stringByAppendingString:@"..."];
    }
    return preview;
}


@end
