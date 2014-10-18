//
//  RA_Networks.h
//  Rally
//
//  Created by Alex Brunicki on 16/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface RA_Networks : UICollectionViewController <UICollectionViewDataSource, UICollectionViewDelegate, MBProgressHUDDelegate>

- (IBAction)tappedRefreshBarButton:(UIBarButtonItem *)sender;

@end
