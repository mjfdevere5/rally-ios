//
//  RA_Settings.h
//  Rally
//
//  Created by Max de Vere on 12/09/2014.
//  Copyright (c) 2014 NA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface RA_Settings : UITableViewController<UITextViewDelegate, MBProgressHUDDelegate>

@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet PFImageView *profileImage;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityWheel;
@property (weak, nonatomic) IBOutlet UILabel *versionOutlet;

@end
