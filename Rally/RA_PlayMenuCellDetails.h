//
//  RA_PlayMenuCellObject.h
//  Rally
//
//  Created by Max de Vere on 08/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_ParseNetwork.h"

@interface RA_PlayMenuCellDetails : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *action;
@property (strong, nonatomic) RA_ParseNetwork *network;

-(instancetype)initWithName:(NSString *)theName andImage:(UIImage *)theImage andAction:(NSString *)theAction andNetwork:(RA_ParseNetwork *)theNetwork;

@end
