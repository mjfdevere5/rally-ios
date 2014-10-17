//
//  RA_CollCellDetails.h
//  Rally
//
//  Created by Alex Brunicki on 16/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_ParseNetwork.h"
#import <Foundation/Foundation.h>

@interface RA_CollCellDetails : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *action;
@property (strong, nonatomic) RA_ParseNetwork *network;

-(instancetype)initWithName:(NSString *)theName andImage:(UIImage *)theImage andAction:(NSString *)theAction andNetwork:(RA_ParseNetwork *)theNetwork;

@end

