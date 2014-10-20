//
//  RA_Login.h
//  Rally
//
//  Created by Max de Vere on 02/09/2014.
//  Copyright (c) 2014 NA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RA_FacebookLoginComms.h"

@interface RA_Login : UIViewController <RA_LoginLogoutDelegate>

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *button;
- (IBAction)loginButtonTouchHandler:(id)sender;

@end
