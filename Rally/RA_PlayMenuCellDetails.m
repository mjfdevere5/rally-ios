//
//  RA_PlayMenuCellObject.m
//  Rally
//
//  Created by Max de Vere on 08/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_PlayMenuCellDetails.h"

@implementation RA_PlayMenuCellDetails


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


