//
//  RA_newsfeedShoutCell2.m
//  Rally
//
//  Created by Alex Brunicki on 25/09/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_FeedCellShout.h"
#import "NSDate+CoolStrings.h"
#import "UIImage+ProfilePicHandling.h"
#import "RA_ParseNetwork.h"
#import "NSDate+CoolStrings.h"
#import "NSIndexPath+Utilities.h"

@interface RA_FeedCellShout()
@property (strong, nonatomic) NSString *sportName;
@end

@implementation RA_FeedCellShout


#pragma mark - load up and configure
// ******************** load up and configure ********************

-(void)configureCell
{ COMMON_LOG
    [self configureEverythingExceptImages];
    [self configureImages];
}

-(void)configureEverythingExceptImages
{
    // Cell background // TO DO, load dynamically (if still live vs. if already matched)
    UIImage *backgroundImage = [UIImage imageNamed:@"newsfeed_cell_v03"];
    UIImageView *cellBackgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
    cellBackgroundView.image = backgroundImage;
    self.backgroundView = cellBackgroundView;
    
    // Name
    self.nameLabel.text = self.gamePref.user.displayName;
    COMMON_LOG_WITH_COMMENT(self.gamePref.user.displayName)
    COMMON_LOG_WITH_COMMENT([self.indexPath description])
    
    // Timestamp
    NSDate *createdAt = self.gamePref.createdAt;
    NSString *timeStamp = [createdAt getTimeStampNewsFeed];
    self.timeStamp.text = timeStamp;
    
    // Attributes
    UIFont *stdFont = [UIFont systemFontOfSize:17.0];
    NSDictionary *stdAttributes = [NSDictionary dictionaryWithObject:stdFont forKey:NSFontAttributeName];
    UIFont *boldFont = [UIFont boldSystemFontOfSize:17.0];
    NSDictionary *boldAttributes = [NSDictionary dictionaryWithObject:boldFont forKey:NSFontAttributeName];
    
    // 'Looking to play' label
    NSMutableAttributedString *lookingToPlayText = [[NSMutableAttributedString alloc] initWithString:@"Looking to play "
                                                                                          attributes:stdAttributes];
    NSAttributedString *sport = [[NSAttributedString alloc] initWithString:self.gamePref.sport
                                                               attributes:boldAttributes];
    [lookingToPlayText appendAttributedString:sport];
    self.lookingToPlayLabel.attributedText = lookingToPlayText;
    
    // 'Looking to play' bullets
    NSMutableAttributedString *preferenceBullets = [[NSMutableAttributedString alloc] init];
    NSAttributedString *lineBreak = [[NSAttributedString alloc] initWithString:@"\n"
                                                                    attributes:stdAttributes];
    NSAttributedString *dash = [[NSAttributedString alloc] initWithString:@"- "
                                                               attributes:stdAttributes];
    NSAttributedString *at = [[NSAttributedString alloc] initWithString:@" at "
                                                                attributes:stdAttributes];
    
    NSLog(@"[dateTimePreferences count] = %lu", [self.gamePref.dateTimePreferences count]);
    
    // > Bullet 1
    NSAttributedString *dayOne = [[NSAttributedString alloc] initWithString:[self.gamePref.dateTimePreferences[0] getCommonSpeechDayLong:YES dateOrdinal:YES monthLong:YES]
                                                                 attributes:boldAttributes];
    NSAttributedString *timeOne = [[NSAttributedString alloc] initWithString:[self.gamePref.dateTimePreferences[0] getCommonSpeechClock]
                                                                  attributes:boldAttributes];
    [preferenceBullets appendAttributedString:dash];
    [preferenceBullets appendAttributedString:dayOne];
    [preferenceBullets appendAttributedString:at];
    [preferenceBullets appendAttributedString:timeOne];

    // > Bullet 2
    if ([self.gamePref.dateTimePreferences count] > 1) {
        NSAttributedString *dayTwo = [[NSAttributedString alloc] initWithString:[self.gamePref.dateTimePreferences[1] getCommonSpeechDayLong:YES dateOrdinal:YES monthLong:YES]
                                                                     attributes:boldAttributes];
        NSAttributedString *timeTwo = [[NSAttributedString alloc] initWithString:[self.gamePref.dateTimePreferences[1] getCommonSpeechClock]
                                                                      attributes:boldAttributes];
        [preferenceBullets appendAttributedString:lineBreak];
        [preferenceBullets appendAttributedString:dash];
        [preferenceBullets appendAttributedString:dayTwo];
        [preferenceBullets appendAttributedString:at];
        [preferenceBullets appendAttributedString:timeTwo];
        
        // > Bullet 3
        if ([self.gamePref.dateTimePreferences count] > 2) {
            NSAttributedString *dayThree = [[NSAttributedString alloc] initWithString:[self.gamePref.dateTimePreferences[2] getCommonSpeechDayLong:YES dateOrdinal:YES monthLong:YES]
                                                                           attributes:boldAttributes];
            NSAttributedString *timeThree = [[NSAttributedString alloc] initWithString:[self.gamePref.dateTimePreferences[2] getCommonSpeechClock]
                                                                            attributes:boldAttributes];
            [preferenceBullets appendAttributedString:lineBreak];
            [preferenceBullets appendAttributedString:dash];
            [preferenceBullets appendAttributedString:dayThree];
            [preferenceBullets appendAttributedString:at];
            [preferenceBullets appendAttributedString:timeThree];
        }
    }
    self.preferenceBulletsLabel.attributedText = preferenceBullets;
}

-(void)configureImages
{
    // Load thumbnail
    PFFile *picFile = self.gamePref.user.profilePicSmall;
    if (![picFile isDataAvailable]) {
        [self.thumbnailActivityWheel startAnimating];
    }
    [picFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (error) {
            COMMON_LOG_WITH_COMMENT([error localizedDescription])
        }
        else {
            UIImage *pic = [UIImage imageWithData:data];
            UIImage *rightSizedPic = [pic getImageResizedAndCropped:self.thumbnail.frame.size];
            UIImage *rightSizedPicWithRoundedCorners = [rightSizedPic getImageWithRoundedCorners:3];
            [self.thumbnailActivityWheel stopAnimating];
            self.thumbnail.image = rightSizedPicWithRoundedCorners;
        }
    }];
}

//-(void)findAndPrintNetworksInCommon
//{ COMMON_LOG
//    // Let the user know we're working on it and resize the label to occupy just one line
//    [self.networksActivityWheel startAnimating];
//    self.networksInCommonLabel.text = @"Finding networks in common...";
//    [self.networksInCommonLabel sizeToFit];
//    
//    // Do the network querying etc in the background
//    [self performSelectorInBackground:@selector(findAndPrintNetworksInCommonBackground) withObject:nil];
//}
//
//-(void)findAndPrintNetworksInCommonBackground // (BACKGROUND ONLY)
//{
//    // Create the text for the outlets
//    NSArray *networksInCommon = [self.gamePref.user getNetworksInCommonWithMeForSport:self.gamePref.sport]; // Takes a while, so we are in background
//    COMMON_LOG_WITH_COMMENT([networksInCommon description])
//    NSMutableString *networkBulletsWithRanks = [NSMutableString string];
//    for (int i=0 ; i<[networksInCommon count] ; i++) {
//        if (i > 0) {
//            [networkBulletsWithRanks appendString:@"\n"];
//        }
//        RA_ParseNetwork *network = networksInCommon[i];
//        NSInteger rank = [network getRankForPlayer:self.gamePref.user];
//        if (rank == 0) {
//            NSString *bullet = [NSString stringWithFormat:@"- %@ (%@)", network.name, @"not yet ranked"];
//            [networkBulletsWithRanks appendString:bullet];
//        }
//        else {
//            NSString *bullet = [NSString stringWithFormat:@"- %@ (#%lu)", network.name, (unsigned long)rank];
//            [networkBulletsWithRanks appendString:bullet];
//        }
//    }
//    
//    // Update outlets
//    [self.networksActivityWheel stopAnimating];
//    self.networksInCommonLabel.text = [NSString stringWithFormat:@"%@ networks in common:", [self.gamePref.sport capitalizedString]];
//    self.networkBulletsLabel.text = networkBulletsWithRanks;
//    COMMON_LOG_WITH_COMMENT(networkBulletsWithRanks)
//    
//    // Resize the cell
//    [self performSelectorOnMainThread:@selector(resizeInTableView) withObject:nil waitUntilDone:NO];
//}
//
//-(void)resizeInTableView // (BACK ON MAIN THREAD)
//{
//    [self.networkBulletsLabel sizeToFit];
//    [self layoutIfNeeded];
//    CGSize size = [self.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
//    [self.myViewController.heights setObject:[NSNumber numberWithFloat:size.height] forKey:[self.indexPath indexPathKey]];
//    
//    NSString *previousSize = [NSString stringWithFormat:@"Previous size: %f", self.frame.size.height];
//    COMMON_LOG_WITH_COMMENT(previousSize)
//    NSString *newSize = [NSString stringWithFormat:@"New size: %f", size.height];
//    COMMON_LOG_WITH_COMMENT(newSize)
//    
//    [self.myViewController.tableView beginUpdates];
//    [self.myViewController.tableView endUpdates];
//}


@end


