//
//  RA_NewsFeedForm.m
//  Rally
//
//  Created by Alex Brunicki on 19/09/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_NewsFeed.h"

#import "RA_NetworkTests.h"
#import "AppConstants.h"
#import "NSDate+Utilities.h"
#import "NSDate+CoolStrings.h"

#import "RA_ParseBroadcast.h"
#import "RA_ParseUser.h"
#import "RA_UserProfileDynamicTable.h"
#import "RA_NewsFeedBaseCell.h"


@interface RA_NewsFeed ()

// Array for number of sections and section headings
@property NSArray *cellArray;
@property NSArray *cellArrayTemp;

// Tells the view whether it should refresh the table in the background
@property BOOL shouldRefreshInBackground;

@end


@implementation RA_NewsFeed


#pragma mark - load up and/or refresh
// ******************** load up and/or refresh ********************

-(void)viewDidLoad
{ COMMON_LOG
    // Navbar
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    
    // Setting some early styles for the table
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = RA_TEST_WHITE;
    
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
{ COMMON_LOG
    if (self.shouldRefreshInBackground) {
        [self refreshInBackground];
    }
}

-(void)refreshInBackground
{ COMMON_LOG
    [self performSelectorInBackground:@selector(createTable) withObject:nil];
}

- (IBAction)tappedRefreshBarButton:(UIBarButtonItem *)sender
{ COMMON_LOG
    [self refreshTableWithHUD];
}

-(void)refreshTableWithHUD
{ COMMON_LOG
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.delegate = self;
    [HUD showWhileExecuting:@selector(createTable) onTarget:self withObject:nil animated:YES];
}


#pragma mark - query and prepare cell array
// ******************** query and prepare cell array ********************

-(void) createTable; // (BACKGROUND ONLY)
{ COMMON_LOG
    // If offline, don't bother
    if (![RA_NetworkTests hasConnection]) {
        [RA_NetworkTests showNoConnectionAlertOnMainThread];
        return;
    }
    
    // Run the query to get the news feed items, takes a while
    self.cellArrayTemp = [self runNewsFeedQuery];
    
    // Now kick of the table reload on the main thread
    [self performSelectorOnMainThread:@selector(prepareToReloadData) withObject:nil waitUntilDone:YES];
    
    // Next time we see this view, we want to see the cached results but also refresh in the background
    self.shouldRefreshInBackground = YES;
}

-(NSArray *)runNewsFeedQuery // (BACKGROUND ONLY)
{ COMMON_LOG
    // Define the newsfeed query
    PFQuery *query = [RA_ParseBroadcast query];
    query.cachePolicy = kPFCachePolicyNetworkOnly;
    [query setLimit:50];
    
    // Only what's been made visible to me
    [query whereKey:@"visibility" containedIn:[RA_ParseUser currentUser].networkMemberships];
    // The above seems unusual ("array contained in array") but actually returns all results where any item in PF_SHOUT_VISIBILITY is contained in the user's networks. See https://www.parse.com/questions/query-where-relation-contains-any-object-from-array
    
    // Order by created descending
    [query orderByDescending:@"createdAt"];
    
    // Bring back all the users
    [query includeKey:@"userOne"];
    [query includeKey:@"userTwo"];
    [query includeKey:@"game"];
    
    // Run query
    NSArray *results = [query findObjects];
    
    NSLog(@"results count %lu",(unsigned long)[results count]);
    
    // Logging
    NSString *logComment = [NSString stringWithFormat:@"Query results = %lu", (unsigned long)[results count]];
    COMMON_LOG_WITH_COMMENT(logComment)
    
    // Return
    return results;
}

-(void)prepareToReloadData
{ COMMON_LOG
    // Move the temp properties into the ones that the table depends on
    self.cellArray = [NSArray arrayWithArray:self.cellArrayTemp];
    
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
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.cellArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Dequeue
    RA_NewsFeedBaseCell *cell;
    RA_ParseBroadcast *broadcast = self.cellArray[indexPath.row];
    
    if([broadcast.type isEqualToString:RA_BROADCAST_TYPE_SCORE]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"score_update" forIndexPath:indexPath];
    }
    else if ([broadcast.type isEqualToString:RA_BROADCAST_TYPE_CONFIRMED]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"match_confirmed" forIndexPath:indexPath];
    }
    else if ([broadcast.type isEqualToString:RA_BROADCAST_TYPE_RALLY_TEAM]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"news_feed_rally_broadcast" forIndexPath:indexPath];
    }
    else {
        NSString *logError = [NSString stringWithFormat:@"ERROR: Unexpected broadcast type: %@", broadcast.type];
        COMMON_LOG_WITH_COMMENT(logError)
        cell = [RA_NewsFeedBaseCell new];
    }
    
    // Configure
    cell.broadcast = broadcast;
    cell.myViewController = self;
    [cell configureCell];
    
    // Return
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{ COMMON_LOG
    RA_ParseBroadcast *broadcast = self.cellArray[indexPath.row];
    
    if ([broadcast.type isEqualToString:RA_BROADCAST_TYPE_SCORE]) {
        return 172.0;
    }
    else if ([broadcast.type isEqualToString:RA_BROADCAST_TYPE_CONFIRMED]) {
        return 191.0; // TO DO
    }
    else if ([broadcast.type isEqualToString:RA_BROADCAST_TYPE_RALLY_TEAM]) {
        UIFont *font = [UIFont fontWithName:@"Helvetica" size:14.0f];
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
        NSAttributedString *attString = [[NSAttributedString alloc]initWithString:broadcast.freeText attributes:attrsDictionary];
        CGFloat textViewWidth = 219.0;
        CGFloat height = [self textViewHeightForAttributedText:attString andWidth:textViewWidth];
        CGFloat margins = 25.0;
        return height + margins;
    }
    else {
        NSString *logError = [NSString stringWithFormat:@"ERROR: tag is '%@'", broadcast.type];
        COMMON_LOG_WITH_COMMENT(logError)
        return 44.0;
    }
}

- (CGFloat)textViewHeightForAttributedText: (NSAttributedString*)text andWidth: (CGFloat)width
{ COMMON_LOG
    UITextView *calculationView = [[UITextView alloc] init];
    [calculationView setAttributedText:text];
    CGSize size = [calculationView sizeThatFits:CGSizeMake(width, FLT_MAX)];
    return size.height;
}



@end
