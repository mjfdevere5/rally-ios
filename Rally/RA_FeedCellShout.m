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
#import "RA_TimeAndDatePreference.h"
#import "NSIndexPath+Utilities.h"

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
    RA_TimeAndDatePreference *prefOne = [[RA_TimeAndDatePreference alloc] initWithDatabaseArray:self.gamePref.dateTimePreferences[0]];
    NSMutableString *preferenceBullets = [NSMutableString stringWithFormat:@"- %@ in the %@",
                                          [[prefOne getDay] getCommonSpeechDayLong:YES dateOrdinal:YES monthLong:YES],
                                          [[prefOne timeStringCapitalized] lowercaseString]];
    if ([self.gamePref.dateTimePreferences count] > 1) {
        RA_TimeAndDatePreference *prefTwo = [[RA_TimeAndDatePreference alloc] initWithDatabaseArray:self.gamePref.dateTimePreferences[1]];
        NSString *preferenceTwo = [NSString stringWithFormat:@"\n- %@ in the %@",
                                   [[prefTwo getDay] getCommonSpeechDayLong:YES dateOrdinal:YES monthLong:YES],
                                   [[prefTwo timeStringCapitalized] lowercaseString]];
        [preferenceBullets appendString:preferenceTwo];
        if ([self.gamePref.dateTimePreferences count] > 2) {
            RA_TimeAndDatePreference *prefThree = [[RA_TimeAndDatePreference alloc] initWithDatabaseArray:self.gamePref.dateTimePreferences[2]];
            NSString *preferenceThree = [NSString stringWithFormat:@"\n- %@ in the %@",
                                       [[prefThree getDay] getCommonSpeechDayLong:YES dateOrdinal:YES monthLong:YES],
                                       [[prefThree timeStringCapitalized] lowercaseString]];
            [preferenceBullets appendString:preferenceThree];
        }
    }
    self.preferenceBulletsLabel.text = preferenceBullets;
    [self.preferenceBulletsLabel sizeToFit]; // TO DO: is this correct?
    [self layoutIfNeeded];
    
    // Network in common (TEMPORARY)
    self.networksInCommonLabel.text = [NSString stringWithFormat:@"Finding networks in common..."];
    [self.networksActivityWheel startAnimating];
    self.networkBulletsLabel.text = nil;
    [self.networkBulletsLabel sizeToFit]; // TO DO: is this correct?
}

-(void)configureCellPartTwo
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
    
    // Network bullets (WITH RANKINGS, ASYNC), since we may not have all networks yet
    [self performSelectorInBackground:@selector(findAndPrintNetworksInCommon) withObject:nil];
}

-(void)findAndPrintNetworksInCommon // (BACKGROUND ONLY)
{
    // Create the text for the outlets
    NSArray *networksInCommon = [self.gamePref.user getNetworksInCommonWithMeForSport:self.gamePref.sport]; // Takes a while, so we are in background
    COMMON_LOG_WITH_COMMENT([networksInCommon description])
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
            NSString *bullet = [NSString stringWithFormat:@"- %@ (#%lu)", network.name, (unsigned long)rank];
            [networkBulletsWithRanks appendString:bullet];
        }
    }
    
    // Update outlets
    [self.networksActivityWheel stopAnimating];
    self.networksInCommonLabel.text = [NSString stringWithFormat:@"%@ networks in common:", [self.gamePref.sport capitalizedString]];
    self.networkBulletsLabel.text = networkBulletsWithRanks;
    COMMON_LOG_WITH_COMMENT(networkBulletsWithRanks)
    
    // Resize the cell
    [self performSelectorOnMainThread:@selector(resizeInTableView) withObject:nil waitUntilDone:NO];
}

-(void)resizeInTableView // (BACK ON MAIN THREAD)
{
    [self.networkBulletsLabel sizeToFit]; // TO DO: is this correct?
    [self layoutIfNeeded];
    CGSize size = [self.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    [self.myViewController.heights setObject:[NSNumber numberWithFloat:size.height] forKey:[self.indexPath indexPathKey]];
    
    NSString *previousSize = [NSString stringWithFormat:@"Previous size: %f", self.frame.size.height];
    COMMON_LOG_WITH_COMMENT(previousSize)
    NSString *newSize = [NSString stringWithFormat:@"New size: %f", size.height];
    COMMON_LOG_WITH_COMMENT(newSize)
    
    [self.myViewController.tableView beginUpdates];
    [self.myViewController.tableView endUpdates];
}


@end


