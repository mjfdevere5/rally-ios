//
//  RA_MessageCell.h
//  Rally
//
//  Created by Max de Vere on 24/09/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RA_RecentChatCell : UITableViewCell

@property (weak, nonatomic) IBOutlet PFImageView *thumbnail;
@property (weak, nonatomic) IBOutlet UILabel *fromName;
@property (weak, nonatomic) IBOutlet UITextView *messagePreview;
@property (weak, nonatomic) IBOutlet UILabel *dateString;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activitySpinner;

-(void)configureWithContent:(NSDictionary *)cellContent;

@end
