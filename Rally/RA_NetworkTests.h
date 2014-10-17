//
//  RA_NetworkTests.h
//  Rally
//
//  Created by Max de Vere on 16/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RA_NetworkTests : NSObject

+(BOOL)hasConnection;
+(void)showNoConnectionAlertOnMainThread;

@end
