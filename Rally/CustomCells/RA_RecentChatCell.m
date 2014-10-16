//
//  RA_MessageCell.m
//  Rally
//
//  Created by Max de Vere on 24/09/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_RecentChatCell.h"
#import "AppConstants.h"
#import "UIImage+ProfilePicHandling.h"

@implementation RA_RecentChatCell


-(void)awakeFromNib
{
    self.activitySpinner.tintColor = [UIColor grayColor];
    [self.activitySpinner startAnimating];
}



-(void)configureWithContent:(NSDictionary *)cellContent
{
    // TO DO
    self.fromName.text = [cellContent objectForKey:@"fromName"];
    self.messagePreview.text = [cellContent objectForKey:@"messagePreview"];
    self.dateString.text = [cellContent objectForKey:@"dateString"];
    
    if ([[cellContent objectForKey:@"new"] isEqual:@"YES"]) {
        NSLog(@"Make bold etc.");
        [self.fromName setFont:[UIFont boldSystemFontOfSize:17.0]];
        [self.messagePreview setFont:[UIFont boldSystemFontOfSize:14.0]];
        [self.messagePreview setTintColor:[UIColor grayColor]];
    }
    else if ([[cellContent objectForKey:@"new"] isEqual:@"NO"]) {
        NSLog(@"Make bold etc.");
        [self.fromName setFont:[UIFont systemFontOfSize:17.0]];
        [self.messagePreview setFont:[UIFont systemFontOfSize:
                                      14.0]];
        [self.messagePreview setTintColor:[UIColor grayColor]];
    }
    
    RA_ParseUser *fromUser = [cellContent objectForKey:@"fromUser"];
    
    [fromUser.profilePicMedium getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (error) {
            NSLog(@"ERROR in %@, %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        }
        else {
            UIImage *rawImage = [UIImage imageWithData:data];
            UIImage *circularImage = [rawImage getImageCircularWithRadius:((self.thumbnail.frame.size.width)/2)];
            self.thumbnail.image = circularImage;
            [self.activitySpinner stopAnimating];
        }
    }];
}



@end


