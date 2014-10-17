//
//  RA_NetworkTests.m
//  Rally
//
//  Created by Max de Vere on 16/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_NetworkTests.h"
#import "Reachability.h"

@implementation RA_NetworkTests



+(BOOL)hasConnection
{ COMMON_LOG
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    return (!(networkStatus == NotReachable));
}



+(void)showNoConnectionAlertOnMainThread
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No connection!"
                                                    message:@"Rally is not much fun to use without an active internet connection."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
}



@end
