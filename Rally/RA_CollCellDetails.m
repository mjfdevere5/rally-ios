//
//  RA_CollCellDetails.m
//  Rally
//
//  Created by Alex Brunicki on 16/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_CollCellDetails.h"

@implementation RA_CollCellDetails

@synthesize name, image, action, network;


-(instancetype)initWithName:(NSString *)theName andImage:(UIImage *)theImage andAction:(NSString *)theAction andNetwork:(RA_ParseNetwork *)theNetwork
{
    self = [super init];
    if (self) {
        name = theName;
        image = theImage;
        action = theAction;
        network = theNetwork;
    }
    return self;
}



@end

