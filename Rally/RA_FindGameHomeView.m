//
//  RA_FindGameHomeView.m
//  Rally
//
//  Created by Max de Vere on 16/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_FindGameHomeView.h"
#import "RA_NetworkTests.h"
#import "RA_ParseGamePreferences.h"
#import "RA_FeedCellShout.h"
#import "RA_NextGamePrefOne.h"
#import "RA_UserProfileDynamicTable.h"
#import "RA_TimeAndDatePreference.h"
#import "NSDate+Utilities.h"
#import "NSIndexPath+Utilities.h"



@interface RA_FindGameHomeView ()

// Array that drives the tableview. Contains RA_ParseGamePreferences objects
@property NSArray *arrayOfBroadcastsMain;
@property NSArray *arrayOfBroadcastsBackground;

// Tells the view whether it should refresh the table in the background
@property BOOL shouldRefreshInBackground;

// Reference to the refresh controller
@property UIRefreshControl *refreshControl;

// For calculating row height dynamically
@property (strong, nonatomic) RA_FeedCellShout *prototypeCell;

@end


@implementation RA_FindGameHomeView

#pragma mark - load up and refresh
// ******************** load up and refresh ********************

- (void)viewDidLoad
{ COMMON_LOG
    // Super
    [super viewDidLoad];
    
    // Navbar
    self.navigationItem.title = @"Find your next game";
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    
    // Setting some styles for the table
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = UIColorFromRGB(GENERIC_BACKGROUND_COLOUR);
    
    // Cell height dictionary
    self.heights = [NSMutableDictionary dictionary];
    
    // Prepare a prototypeCell
    self.prototypeCell = [self.tableView dequeueReusableCellWithIdentifier:@"shout_broadcast_cell"];
    
    // Configure refresher control thing
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor redColor]; // TO DO
    [self.refreshControl addTarget:self action:@selector(refreshInBackground) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    // Load the table
    self.shouldRefreshInBackground = NO; // Prevents loading the table twice upon first load
    [self refreshTableWithHUD];
}

-(void)viewDidAppear:(BOOL)animated
{ COMMON_LOG
    if (self.shouldRefreshInBackground) {
        [self refreshInBackground];
    }
}

- (IBAction)tappedRefreshBarButton:(id)sender
{ COMMON_LOG
    [self refreshTableWithHUD];
}

-(void)refreshInBackground
{ COMMON_LOG
    [self performSelectorInBackground:@selector(refreshTable) withObject:nil];
}

-(void)refreshTableWithHUD
{ COMMON_LOG
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.delegate = self;
    [HUD showWhileExecuting:@selector(refreshTable) onTarget:self withObject:nil animated:YES];
}


#pragma mark - table creation
// ******************** table creation ********************

-(void)refreshTable; // (BACKGROUND ONLY)
{ COMMON_LOG
    // If offline, don't bother
    if (![RA_NetworkTests hasConnection]) {
        [RA_NetworkTests showNoConnectionAlertOnMainThread];
        return;
    }
    
    // Run the query to get the news feed items, takes a while
    NSArray *queryResults = [self getShoutsFromParse];
    
    self.arrayOfBroadcastsBackground = [self pruneResults:queryResults];
    
    // Now move onto the main thread
    [self performSelectorOnMainThread:@selector(reloadTableViewWithBroadcasts) withObject:nil waitUntilDone:YES];
    
    // Next time we see this view, we want to see the cached results but also refresh in the background
    self.shouldRefreshInBackground = YES;
}

-(NSArray *)getShoutsFromParse // (BACKGROUND ONLY)
{ COMMON_LOG
    // Define the query
    PFQuery *query = [RA_ParseGamePreferences query];
    query.cachePolicy = kPFCachePolicyNetworkOnly;
    [query setLimit:50];

    // Only what's been made visible to me
    [query whereKey:@"networks" containedIn:[RA_ParseUser currentUser].networkMemberships];
    // The above seems unusual ("array contained in array") but actually returns all results where any item in PF_SHOUT_VISIBILITY is contained in the user's networks. See https://www.parse.com/questions/query-where-relation-contains-any-object-from-array

    // Order by created descending
    [query orderByDescending:@"createdAt"];

    // Bring back the user as well;
    [query includeKey:@"user"]; // we'll want to look into the user's network memberships, for the cell configuration
    [query includeKey:@"network"]; // we are going to look into the network's scores dictionary, for the cell configuration
    
    // Run the query
    NSArray *results = [query findObjects];
    
    // Logging
    NSString *logComment = [NSString stringWithFormat:@"%lu results from query", (unsigned long)[results count]];
    COMMON_LOG_WITH_COMMENT(logComment)
    
    // Return
    return results;
}

-(NSArray *)pruneResults:(NSArray *)results
{ COMMON_LOG
    NSMutableArray *prunedResultsMut = [NSMutableArray array];
    for (RA_ParseGamePreferences *gamePref in results) {
        // See if first pref is still in date
        BOOL firstPrefIsInDate = NO;
        RA_TimeAndDatePreference *timeAndDatePrefFirst;
        timeAndDatePrefFirst = [[RA_TimeAndDatePreference alloc] initWithDatabaseArray:gamePref.dateTimePreferences[0]];
        firstPrefIsInDate = ([[timeAndDatePrefFirst getDay] isEqualToDateIgnoringTime:[NSDate date]] ||
                             [[timeAndDatePrefFirst getDay] isLaterThanDate:[NSDate date]]);
        
        // See if second pref is still in date
        BOOL secondPrefIsInDate = NO;
        RA_TimeAndDatePreference *timeAndDatePrefSecond;
        if ([gamePref.dateTimePreferences count] >1) {
            timeAndDatePrefSecond = [[RA_TimeAndDatePreference alloc] initWithDatabaseArray:gamePref.dateTimePreferences[1]];
            secondPrefIsInDate = ([[timeAndDatePrefSecond getDay] isEqualToDateIgnoringTime:[NSDate date]] ||
                                  [[timeAndDatePrefSecond getDay] isLaterThanDate:[NSDate date]]);
        }
        
        // Overwrite the gamePref with which ones are in date
        if (firstPrefIsInDate) {
            if (secondPrefIsInDate) {
                gamePref.dateTimePreferences = @[[timeAndDatePrefFirst databaseArray], [timeAndDatePrefSecond databaseArray]];
                [prunedResultsMut addObject:gamePref];
            }
            else {
                gamePref.dateTimePreferences = @[[timeAndDatePrefFirst databaseArray]];
                [prunedResultsMut addObject:gamePref];
            }
        }
        else {
            if (secondPrefIsInDate) {
                gamePref.dateTimePreferences = @[[timeAndDatePrefSecond databaseArray]];
                [prunedResultsMut addObject:gamePref];
            }
            else {
                // Do nothing, and this result therefore is not shown to the user
            }
        }
    }
    NSString *comment = [NSString stringWithFormat:@"%lu results to show to user", (unsigned long) [prunedResultsMut count]];
    COMMON_LOG_WITH_COMMENT(comment)
    return [NSArray arrayWithArray:prunedResultsMut];
}

-(void)reloadTableViewWithBroadcasts // Back on the main thread now
{ COMMON_LOG
    // Move the temp properties into the ones that the table depends on
    // We make sure we are in the main thread, so as to prevent a crash
    self.arrayOfBroadcastsMain = [NSArray arrayWithArray:self.arrayOfBroadcastsBackground];
    
    // Reload data
    [self.tableView reloadData];
    
    // Cancel the refresher
    [self.refreshControl endRefreshing];
    
    // Next time, refresh in background on viewDidAppear
    self.shouldRefreshInBackground = YES;
}


#pragma mark - tableview data source
// ******************** tableview data source ********************

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{ COMMON_LOG
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{ COMMON_LOG
    return [self.arrayOfBroadcastsMain count];
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 230.0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{ COMMON_LOG
    // Configure
    NSNumber *height = [self.heights objectForKey:[indexPath indexPathKey]];
    if (height) {
        return [height floatValue];
    }
    else {
        RA_ParseGamePreferences *gamePref = self.arrayOfBroadcastsMain[indexPath.row];
        self.prototypeCell.gamePref = gamePref;
        [self.prototypeCell configureCellForHeightPurposesOnly];
        [self.prototypeCell layoutIfNeeded];
        CGSize size = [self.prototypeCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        return size.height;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{ COMMON_LOG_WITH_COMMENT([indexPath description])
    // Dequeue
    RA_FeedCellShout *cell = [tableView dequeueReusableCellWithIdentifier:@"shout_broadcast_cell" forIndexPath:indexPath];
    
    // Configure
    RA_ParseGamePreferences *gamePref = self.arrayOfBroadcastsMain[indexPath.row];
    cell.gamePref = gamePref;
    cell.myViewController = self;
    cell.indexPath = indexPath;
    [cell configureCell];
    
    // Return
    return cell;
}


#pragma mark - tableview delegate
// ******************** tableview delegate ********************

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{ COMMON_LOG
    // Get the user and the gamePref objects
    RA_ParseGamePreferences *gamePref = self.arrayOfBroadcastsMain[indexPath.row];
    RA_ParseUser *user = gamePref.user;
    
    // Segue to user profile
    RA_UserProfileDynamicTable *userView = [[RA_UserProfileDynamicTable alloc] initWithUser:user andContext:RA_UserProfileContextShoutOut];
    userView.gamePref = gamePref;
    [self.navigationController pushViewController:userView animated:YES];
}


#pragma mark - navigation
// ******************** navigation ********************

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{ COMMON_LOG
    if ([segue.destinationViewController isKindOfClass:[RA_NextGamePrefOne class]]) {
        // Pass forward ... anything?
        // Don't think we need to
    }
}



@end
