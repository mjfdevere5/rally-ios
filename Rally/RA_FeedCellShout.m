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

@interface RA_FeedCellShout()
@property (strong, nonatomic) NSString *sportName;
@end

@implementation RA_FeedCellShout


#pragma mark - load up and configure
// ******************** load up and configure ********************

-(void)configureCell
{ COMMON_LOG
    [self configureCellPartOne];
    [self configureCellPartTwo];
}

-(void)configureCellForHeightPurposesOnly
{ COMMON_LOG
    [self configureCellPartOne];
}

-(void)configureCellPartOne
{
    // Cell background // TO DO, load dynamically (if still live vs. if already matched)
    UIImage *backgroundImage = [UIImage imageNamed:@"newsfeed_cell_v03"];
    UIImageView *cellBackgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
    cellBackgroundView.image = backgroundImage;
    self.backgroundView = cellBackgroundView;
    
    // Name
    self.nameLabel.text = self.gamePref.user.displayName;
    
    // Timestamp
    NSDate *createdAt = self.gamePref.createdAt;
    NSString *timeStamp = [createdAt getTimeStampNewsFeed];
    self.timeStamp.text = timeStamp;
    
    // Looking to play label
    UIFont *stdFont = [UIFont systemFontOfSize:17.0];
    NSDictionary *stdAttributes = [NSDictionary dictionaryWithObject:stdFont forKey:NSFontAttributeName];
    UIFont *boldFont = [UIFont boldSystemFontOfSize:17.0];
    NSDictionary *boldAttributes = [NSDictionary dictionaryWithObject:boldFont forKey:NSFontAttributeName];
    NSMutableAttributedString *lookingToPlayText = [[NSMutableAttributedString alloc] initWithString:@"Looking to play "
                                                                                          attributes:stdAttributes];
    NSAttributedString *sport = [[NSAttributedString alloc]initWithString:self.gamePref.sport
                                                               attributes:boldAttributes];
    [lookingToPlayText appendAttributedString:sport];
    self.lookingToPlayLabel.attributedText = lookingToPlayText;
    
    // Preference bullets
    NSMutableString *preferenceBullets = [NSMutableString stringWithFormat:@"- %@ at %@",
                                          [self.gamePref.dateTimePreferences[0] getCommonSpeechDayLong:YES dateOrdinal:YES monthLong:YES],
                                          [self.gamePref.dateTimePreferences[0] getCommonSpeechClock]];
    if ([self.gamePref.dateTimePreferences count] > 1) {
        NSString *preferenceTwo = [NSString stringWithFormat:@"\n- %@ at %@",
                                   [self.gamePref.dateTimePreferences[1] getCommonSpeechDayLong:YES dateOrdinal:YES monthLong:YES],
                                   [self.gamePref.dateTimePreferences[1] getCommonSpeechClock]];
        [preferenceBullets appendString:preferenceTwo];
        if ([self.gamePref.dateTimePreferences count] > 2) {
            NSString *preferenceThree = [NSString stringWithFormat:@"\n- %@ at %@",
                                         [self.gamePref.dateTimePreferences[2] getCommonSpeechDayLong:YES dateOrdinal:YES monthLong:YES],
                                         [self.gamePref.dateTimePreferences[2] getCommonSpeechClock]];
            [preferenceBullets appendString:preferenceThree];
        }
    }
    self.preferenceBulletsLabel.text = preferenceBullets;
    [self.preferenceBulletsLabel sizeToFit]; // Is this correct?
    
    // Network in common
    self.networksInCommonLabel.text = [NSString stringWithFormat:@"%@ networks in common:",
                                       [self.gamePref.sport capitalizedString]];
    
    // Network bullets (WITHOUT RANKINGS, TEMPORARY)
    NSArray *networksInCommon = [self.gamePref.user getNetworksInCommonWithMeForSport:self.gamePref.sport];
    if ([networksInCommon count] == 0) {
        COMMON_LOG_WITH_COMMENT(@"ERROR: No networks in common?")
    }
    NSMutableString *networkBullets = [NSMutableString string];
    for (int i=0 ; i<[networksInCommon count] ; i++) {
        if (i > 0) {
            [networkBullets appendString:@"\n"];
        }
        RA_ParseNetwork *network = networksInCommon[i];
        NSString *bullet = [NSString stringWithFormat:@"- %@ (getting rank...)", network.name];
        [networkBullets appendString:bullet];
    }
    self.networkBulletsLabel.text = networkBullets;
}

-(void)configureCellPartTwo
{
    // Network bullets (WITH RANKINGS, ASYNC), since we may not have all networks yet
    NSArray *networksInCommon = [self.gamePref.user getNetworksInCommonWithMeForSport:self.gamePref.sport];
    [self.networksActivityWheel startAnimating];
    [PFObject fetchAllIfNeededInBackground:networksInCommon block:^(NSArray *objects, NSError *error) {
        NSMutableString *networkBulletsWithRanks = [NSMutableString string];
        for (int i=0 ; i<[networksInCommon count] ; i++) {
            if (i > 0) {
                [networkBulletsWithRanks appendString:@"\n"];
            }
            RA_ParseNetwork *network = networksInCommon[i];
            NSInteger rank = [network getRankForPlayer:self.gamePref.user];
            if (rank == 0) {
                NSString *bullet = [NSString stringWithFormat:@"- %@ (%@)", network.name, @"not yet ranked"];
                [networkBulletsWithRanks appendString:bullet];
            }
            else {
                NSString *bullet = [NSString stringWithFormat:@"- %@ (%lu)", network.name, (unsigned long)rank];
                [networkBulletsWithRanks appendString:bullet];
            }
        }
        [self.networksActivityWheel stopAnimating];
        self.networkBulletsLabel.text = networkBulletsWithRanks;
    }];
    
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



@end


