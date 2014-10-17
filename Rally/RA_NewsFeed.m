//
//  RA_NewsFeedForm.m
//  Rally
//
//  Created by Alex Brunicki on 19/09/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_NewsFeed.h"
#import "AppConstants.h"
#import "NSDate+Utilities.h"
#import "NSDate+CoolStrings.h"
#import "RA_FeedCellRallyBroadcast.h"
#import "RA_FeedCellShout.h"
#import "Reachability.h"
#import "RA_ParseBroadcast.h"
#import "RA_ParseUser.h"
#import "RA_UserProfileDynamicTable.h"


@interface RA_NewsFeed ()

// Array for number of sections and section headings
@property NSArray *sectionMain;
@property NSArray *sectionTemp;

// For <key> sectionHeading, gives <value> array of objects
@property NSDictionary *objectsInSectionsMain;
@property NSMutableDictionary *objectsInSectionsTemp;

// Tells the view whether it should refresh the table in the background
@property BOOL shouldRefreshInBackground;

@end


@implementation RA_NewsFeed


#pragma mark - load up
// ******************** load up ********************

-(void)viewDidLoad
{
    COMMON_LOG
    
    // Navbar
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    
    // Setting some early styles for the table
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = UIColorFromRGB(GENERIC_BACKGROUND_COLOUR);
    
    // Initializing properties to avoid problems later on
    self.sectionMain = [NSArray array];
    self.sectionTemp = [NSArray array];
    self.objectsInSectionsMain = [NSDictionary dictionary];
    self.objectsInSectionsTemp = [NSMutableDictionary dictionary];
    
    // Refresher control thing
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor redColor];
    [refreshControl addTarget:self action:@selector(refreshInBackground) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    // Load the table
    self.shouldRefreshInBackground = NO; // Prevents loading the table twice upon first load
    [self refreshTableWithHUD];
}



-(void)viewDidAppear:(BOOL)animated
{
    COMMON_LOG
    
    if (self.shouldRefreshInBackground) {
        [self refreshInBackground];
    }
}



-(void)refreshInBackground
{
    COMMON_LOG
    
    [self performSelectorInBackground:@selector(createTable) withObject:nil];
}



-(void)refreshTableWithHUD
{
    COMMON_LOG
    
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.delegate = self;
    [HUD showWhileExecuting:@selector(createTable) onTarget:self withObject:nil animated:YES];
}



#pragma mark - load the table
// ******************** load the table ********************


-(void)createTable;
{
    COMMON_LOG
    
    // If offline, don't bother
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        [self performSelectorOnMainThread:@selector(showNetworkAlert) withObject:nil waitUntilDone:NO];
        return;
    }
    
    // Run the query to get the news feed items, takes a while
    NSArray *newsItems = [self runNewsFeedQuery];
    NSString *logComment = [NSString stringWithFormat:@"Query results = %lu", (unsigned long)[newsItems count]];
    COMMON_LOG_WITH_COMMENT(logComment)
    
    // Create the sections from the createdAt parse column
    self.sectionTemp = [self buildSections: newsItems];
    
    // Now kick of the table reload on the main thread
    [self performSelectorOnMainThread:@selector(updateTable) withObject:nil waitUntilDone:YES];
    
    // Next time we see this view, we want to see the cached results but also refresh in the background
    self.shouldRefreshInBackground = YES;
}



-(void)showNetworkAlert
{
    COMMON_LOG
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No internet connection!"
                                                    message:@"The news feed isn't much good without an active internet connection :-("
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}


    
- (IBAction)refresh:(UIBarButtonItem *)sender
{
    COMMON_LOG
    
    [self refreshTableWithHUD];
}



-(NSArray *)runNewsFeedQuery
{
    COMMON_LOG
    
    // Define the newsfeed query
    PFQuery *query = [RA_ParseBroadcast query];
    query.cachePolicy = kPFCachePolicyNetworkOnly;
    [query setLimit:50];
    
    // Interested in shouts only for future dates
    [query whereKey:@"date" greaterThanOrEqualTo:[[NSDate date] dateAtStartOfDay]];
    
    // Only what's been made visible to me
    [query whereKey:@"visibility" containedIn:[RA_ParseUser currentUser].networkMemberships];
    // The above seems unusual ("array contained in array") but actually returns all results where any item in PF_SHOUT_VISIBILITY is contained in the user's networks. See https://www.parse.com/questions/query-where-relation-contains-any-object-from-array
    
    // Order by created descending
    [query orderByDescending:@"createdAt"];
    
    // Bring back the user as well;
    [query includeKey:@"user"];
    [query includeKey:@"gamePrefObject"]; // Ensures we have this info ready to go when the user clicks on a cell
    
    return [query findObjects];
}



-(NSArray *)buildSections:(NSArray *)newsItems
{
    COMMON_LOG
    
    // We are going to populate an array with section headings
    NSMutableArray *sectionArrayMut = [NSMutableArray array];
    
    // Special case: nothing to show
    if ([newsItems count] == 0) {
        [sectionArrayMut addObject:@"No recent activity"];
    }
    
    // For each newsItem, see if we need to add a new section or just add the newsItem to an existing sections
    for(RA_ParseBroadcast *newsItem in newsItems) {
        NSDate *dateCreated = newsItem.createdAt;
    	NSString *prettydate = [dateCreated getDatePrettyStringPast];
        
        if ([sectionArrayMut containsObject:prettydate]) {
            NSMutableArray *objects = [self.objectsInSectionsTemp valueForKey:prettydate];
            [objects addObject:newsItem];
        }
        
        else {
            [sectionArrayMut addObject:prettydate];
            NSMutableArray *objects = [NSMutableArray arrayWithObject:newsItem];
            [self.objectsInSectionsTemp setObject:objects forKey:prettydate];
        }
    }
    
    // Return the resulting array
    NSArray *sectionArrayResult = [NSArray arrayWithArray:sectionArrayMut];
    return sectionArrayResult;
}



-(void)updateTable
{
    COMMON_LOG
    
    // Move the temp properties into the ones that the table depends on
    self.sectionMain = [NSArray arrayWithArray:self.sectionTemp];
    self.objectsInSectionsMain = [NSDictionary dictionaryWithDictionary:self.objectsInSectionsTemp];
    
    // Reload data
    [self.tableView reloadData];
    
    // Cancel the refresher
    [self.refreshControl endRefreshing];
    
    // Next time, refresh in background on viewDidAppear
    self.shouldRefreshInBackground = YES;
}



#pragma mark - tableview load
// ******************** tableview load ********************


// Helper method
-(RA_ParseBroadcast *)getFeedFromIndexPath:(NSIndexPath *)indexPath
{
    NSString *sectionString = [self.sectionMain objectAtIndex:indexPath.section];
    NSMutableArray *objectsForSection = [self.objectsInSectionsMain valueForKey:sectionString];
    RA_ParseBroadcast *feed = [objectsForSection objectAtIndex:indexPath.row];
    return feed;
}



-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    COMMON_LOG
    
    return [self.sectionMain count];
}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    COMMON_LOG
    
    NSString *sectionNames = self.sectionMain [section];
    NSArray *sectionValues = [self.objectsInSectionsMain objectForKey:sectionNames];
    return [sectionValues count];
}



-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    COMMON_LOG
    
    return self.sectionMain[section];
}



-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    COMMON_LOG
    
    [view setTintColor:UIColorFromRGB(0xFFF5F5)];
    [view setBackgroundColor:UIColorFromRGB(0xFFF5F5)]; // has no effect
    view.opaque = YES; // doesn't work
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    COMMON_LOG_WITH_COMMENT([indexPath description])
    
    RA_ParseBroadcast *broadcast = [self getFeedFromIndexPath:indexPath];
    
    // Case: rally_team
    if ([broadcast.type isEqualToString:@"rally_team"]) {
        RA_FeedCellRallyBroadcast *cell = [tableView dequeueReusableCellWithIdentifier:@"news_feed_rally_broadcast" forIndexPath:indexPath];
        cell.broadcast = broadcast;
        [cell configureCellWithBroadcast];
        return cell;
    }
    
    // Catch-all: ERROR
    else {
        NSString *logError = [NSString stringWithFormat:@"ERROR: tag is '%@'", broadcast.type];
        COMMON_LOG_WITH_COMMENT(logError)
        UITableViewCell *cell = [UITableViewCell new];
        return cell;
    }
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    COMMON_LOG
    
    // Get the user
    RA_ParseBroadcast *broadcast = [self getFeedFromIndexPath:self.tableView.indexPathForSelectedRow];
    RA_ParseUser *user = broadcast.user;
    
    // Segue to user profile
    RA_UserProfileDynamicTable *userView = [[RA_UserProfileDynamicTable alloc] initWithUser:user andContext:RA_UserProfileContextShoutOut];
    userView.gamePref = broadcast.gamePrefObject;
    [self.navigationController pushViewController:userView animated:YES];
}



// TO DO: FIX THIS
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    COMMON_LOG
    
    RA_ParseBroadcast *feed = [self getFeedFromIndexPath:indexPath];
    
    if ([feed.type isEqualToString:@"shout"]) {
        return 155.0;
    }
    
    else if ([feed.type isEqualToString:@"rally_team"]) {
        UIFont *font = [UIFont fontWithName:@"Helvetica" size:14.0f];
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
        NSAttributedString *attString = [[NSAttributedString alloc]initWithString:feed.freeText attributes:attrsDictionary];
        CGFloat textViewWidth = 219.0;
        
        CGFloat height = [self textViewHeightForAttributedText:attString andWidth:textViewWidth];
        CGFloat margins = 25.0;
        return height + margins;
    }
    
    else {
        NSString *logError = [NSString stringWithFormat:@"ERROR: tag is '%@'", feed.type];
        COMMON_LOG_WITH_COMMENT(logError)
        return 44.0;
    }
}



- (CGFloat)textViewHeightForAttributedText: (NSAttributedString*)text andWidth: (CGFloat)width
{
    COMMON_LOG
    
    UITextView *calculationView = [[UITextView alloc] init];
    [calculationView setAttributedText:text];
    CGSize size = [calculationView sizeThatFits:CGSizeMake(width, FLT_MAX)];
    return size.height;
}



@end
