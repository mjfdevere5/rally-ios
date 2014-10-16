//
//  RA_LoginLogout.h
//  Rally
//
//  Created by Max de Vere on 03/09/2014.
//  Copyright (c) 2014 NA. All rights reserved.
//


#import <Foundation/Foundation.h>


@protocol RA_LoginLogoutDelegate <NSObject>
@optional
-(void)didLoginWithFacebook:(BOOL)loggedIn withError:(NSError *)error;
@end


@interface RA_FacebookLoginComms : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

// Single shared instance
+ (instancetype)commsManager;

- (void)loginWithFacebook:(id<RA_LoginLogoutDelegate>)delegate;

@end