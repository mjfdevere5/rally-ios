//
//  RA_MyGames.m
//  Rally
//
//  Created by Max de Vere on 09/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_MyGames.h"
#import "Reachability.h"
#import "RA_ParseGame.h"
#import "RA_MyGamesUpcomingCell.h"
#import "RA_MyGamesHistoricCell.h"
#import "NSDate+Utilities.h"
#import "RA_GameView.h"


@interface RA_MyGames ()

// Refresher control
@property (strong, nonatomic) UIRefreshControl *refreshControl;

// Arrays of RA_ParseGame objects, one for each table
@property (strong, nonatomic) NSArray *upcomingGamesArray;
@property (strong, nonatomic) NSArray *upcomingGamesArrayTemp;
@property (strong, nonatomic) NSArray *historicGamesArray;
@property (strong, nonatomic) NSArray *historicGamesArrayTemp;

// BOOL to decide whether viewDidAppear should trigger an automatic reload
@property (nonatomic) BOOL shouldLoadInBackgroundInvisibly;

@end


@implementation RA_MyGames


#pragma mark - load up and refresh triggers
// ******************** load up and refresh triggers ********************


- (void)viewDidLoad
{
    COMMON_LOG
    
    [super viewDidLoad];
    
    // Navbar
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    
    // Initialise arrays
    self.upcomingGamesArray = [NSArray array];
    self.upcomingGamesArrayTemp = [NSArray array];
    self.historicGamesArray = [NSArray array];
    self.historicGamesArrayTemp = [NSArray array];
    
    // Don't let viewDidAppear trigger a reload
    self.shouldLoadInBackgroundInvisibly = NO;
    
    // Segment control
    [self setPropertiesForSegmentControl];
    
    // Prepare the refresher thing
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor redColor];
    [self.refreshControl addTarget:self action:@selector(prepareTableInBackground) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    // Content inset (tableView vertical distance from top)
    [self.tableView setContentInset:UIEdgeInsetsMake(6, 0, 0, 0)];
    
    // Background colour and footer view
    self.tableView.backgroundColor = UIColorFromRGB(GENERIC_BACKGROUND_COLOUR);
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // Load up the table
    [self fullRefresh];
    
    // Update badge counter
    [self updateBadges];
}



-(void)viewDidAppear:(BOOL)animated
{
    COMMON_LOG
    
    // We want to refresh in the background IF this is not the first time we are loading
    if (self.shouldLoadInBackgroundInvisibly) {
        [self prepareTableInBackground];
        
        // Update badges here
        // Not the slickest way to do this
        [self performSelectorInBackground:@selector(updateBadges) withObject:nil];
    }
}



#pragma mark - segment control stuff
// ******************** segment control stuff ********************


- (void)setPropertiesForSegmentControl
{
    COMMON_LOG
    
    // Delegate
    self.segmentControl.delegate = self;
    
    // Content
    self.segmentControl.items = @[@"Upcoming", @"Completed"];
    self.segmentControl.showsCount = YES;
    self.segmentControl.selectedSegmentIndex = 0;
    
    // Font, layout, colour scheme
    self.segmentControl.font = [UIFont fontWithName:@"EuphemiaUCAS" size:17.0];
    self.segmentControl.selectionIndicatorHeight = 2.5;
    self.segmentControl.backgroundColor = [UIColor whiteColor];
    self.segmentControl.tintColor = UIColorFromRGB(FORMS_DARK_RED);
    self.segmentControl.hairlineColor = UIColorFromRGB(FORMS_DARK_RED);
    
    // Animation bar thing
    self.segmentControl.autoAdjustSelectionIndicatorWidth = YES;
    self.segmentControl.bouncySelectionIndicator = YES;
    self.segmentControl.animationDuration = 0.125;
    
    [self.segmentControl addTarget:self action:@selector(selectedSegment) forControlEvents:UIControlEventValueChanged];
}


-(void)selectedSegment
{
    [self.tableView reloadData];
}



// <UIBarPositioning> delegate method
- (UIBarPosition)positionForBar:(id <UIBarPositioning>)view
{
    return UIBarPositionBottom;
}



#pragma mark - query and populate table
// ******************** query and populate table ********************


-(IBAction)refresh:(UIBarButtonItem *)sender
{
    COMMON_LOG
    
    [self fullRefresh];
}



-(void)prepareTableInBackground
{
    COMMON_LOG
    
    [self performSelectorInBackground:@selector(prepareTable) withObject:nil];
}



-(void)fullRefresh
{
    COMMON_LOG
    
    // Prepare the progress HUD
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.delegate = self;
    [HUD showWhileExecuting:@selector(prepareTable) onTarget:self withObject:nil animated:YES];
}



#pragma mark - load the table
// ******************** load the table ********************


-(void)prepareTable
{
    COMMON_LOG
    
    // If offline, don't bother
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        [self performSelectorOnMainThread:@selector(showNetworkAlert) withObject:nil waitUntilDone:NO];
        return;
    }
    
    // Run query for games (order by date ascending, takes a while)
    NSArray * allGamesByDateDescending = [self runQueryForGames];
    
    // Logging
    NSString *logComment = [NSString stringWithFormat:@"%lu games in total", (unsigned long)[allGamesByDateDescending count]];
    COMMON_LOG_WITH_COMMENT(logComment)
    
    // Create two arrays, one for the first table, one for the second
    [self setTableRowArraysFromGamesOrderedByDateDescending:allGamesByDateDescending];
    
    // Now kick of the table reload on the main thread
    [self performSelectorOnMainThread:@selector(updateTable) withObject:nil waitUntilDone:YES];
    
    // Next time we see this view, we want to see the cached results but also refresh in the background
    self.shouldLoadInBackgroundInvisibly = YES;
    [self performSelectorInBackground:@selector(updateBadges) withObject:nil];
}



-(void)showNetworkAlert
{
    COMMON_LOG
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No internet connection!"
                                                    message:@"Rally isn't much good without an active internet connection\n:-("
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}



-(NSArray *)runQueryForGames
{
    COMMON_LOG
    
    // Define the query
    PFQuery *query = [RA_ParseGame query];
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    
    // Current user must be one of the players
    [query whereKey:@"players" equalTo:[RA_ParseUser currentUser]];
    
    // Order by date ascending, because we want 'TODAY' to be at the top
    [query orderByDescending:@"datetime"];
    
    // Fetch only 100
    query.limit = 100;
    
    // Include the user objects
    [query includeKey:@"players"];
    [query includeKey:@"network"];
    
    // Stay on this thread
    return [query findObjects];
}



-(void)setTableRowArraysFromGamesOrderedByDateDescending:(NSArray *)gamesByDateDescending
{
    NSMutableArray *upcomingGamesMut = [NSMutableArray array];
    NSMutableArray *historicGamesMut = [NSMutableArray array];
    for (RA_ParseGame *game in gamesByDateDescending) {
        [game fetchIfNeeded];
        if ([game.datetime isLaterThanDate:[[NSDate date] dateBySubtractingMinutes:30]]) {
            [upcomingGamesMut insertObject:game atIndex:0];
        }
        else {
            [historicGamesMut addObject:game];
        }
    }
    self.upcomingGamesArrayTemp = [NSArray arrayWithArray:upcomingGamesMut];
    self.historicGamesArrayTemp = [NSArray arrayWithArray:historicGamesMut];
}



-(void)updateTable
{
    // Now we're on the main thread, move these arrays into the main arrays
    self.upcomingGamesArray = [NSArray arrayWithArray:self.upcomingGamesArrayTemp];
    self.historicGamesArray = [NSArray arrayWithArray:self.historicGamesArrayTemp];
    
    // Update the counters in the segmentControl
    [self.segmentControl setCount:[NSNumber numberWithInteger:[self.upcomingGamesArray count]] forSegmentAtIndex:0];
    [self.segmentControl setCount:[NSNumber numberWithInteger:[self.historicGamesArray count]] forSegmentAtIndex:1];
    
    // Reload data
    [self.tableView reloadData];
    
    // Cancel the refresher if it is spinning
    [self.refreshControl endRefreshing];
}



#pragma mark - table view delegate
// ******************** table view delegate ********************


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    COMMON_LOG
    
    return 1;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.segmentControl.selectedSegmentIndex == 0) {
        // Case: upcoming games
        NSInteger i = [self.upcomingGamesArray count];
        NSString *comment = [NSString stringWithFormat:@"%lu", (unsigned long) i];
        COMMON_LOG_WITH_COMMENT(comment)
        return i;
    }
    
    else if (self.segmentControl.selectedSegmentIndex == 1) {
        // Case: historic games
        NSInteger i = [self.historicGamesArray count];
        NSString *comment = [NSString stringWithFormat:@"%lu", (unsigned long) i];
        COMMON_LOG_WITH_COMMENT(comment)
        return i;
    }
    
    else {
        COMMON_LOG_WITH_COMMENT(@"ERROR: selectedSegmentIndex not 0 or 1")
        return 0;
    }
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    COMMON_LOG_WITH_COMMENT([indexPath description])
    
    UITableViewCell *cell;
    
    if (self.segmentControl.selectedSegmentIndex == 0) {
        // Case: upcoming games
        cell = [tableView dequeueReusableCellWithIdentifier:@"upcoming_game" forIndexPath:indexPath];
        RA_ParseGame *game = self.upcomingGamesArray[indexPath.row];
        ((RA_MyGamesUpcomingCell *)cell).game = game;
        [(RA_MyGamesUpcomingCell *)cell configureCellForGame];
        
    }
    
    else if (self.segmentControl.selectedSegmentIndex == 1) {
        // Case: historic games
        cell = (RA_MyGamesHistoricCell *)[tableView dequeueReusableCellWithIdentifier:@"historic_game" forIndexPath:indexPath];
        RA_ParseGame *game = self.historicGamesArray[indexPath.row];
        ((RA_MyGamesHistoricCell *)cell).game = game;
        [(RA_MyGamesHistoricCell *)cell configureCellForGame];
    }
    
    else {
        COMMON_LOG_WITH_COMMENT(@"ERROR: selectedSegmentIndex not 0 or 1")
    }
    
    return cell;
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.segmentControl.selectedSegmentIndex == 0) {
        COMMON_LOG_WITH_COMMENT(@"Upcoming")
        // Case: upcoming games
        return 100.0;
    }
    
    else if (self.segmentControl.selectedSegmentIndex == 1) {
        COMMON_LOG_WITH_COMMENT(@"Historic")
        // Case: historic games
        return 85.0;
    }
    
    else {
        COMMON_LOG_WITH_COMMENT(@"ERROR: selectedSegmentIndex not 0 or 1")
        return 44.0;
    }
}



#pragma mark - badges
// ******************** badges ********************


-(void)updateBadges
{
    COMMON_LOG
    
    // TO DO
}



#pragma mark - navigation
// ******************** navigation ********************


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    COMMON_LOG
    
    // Get the destViewController
    RA_GameView *destViewController = (RA_GameView *)[segue destinationViewController];
    
    // Decalre a game we are going to pass forward
    RA_ParseGame *game;
    
    // Get the correct game
    if (self.segmentControl.selectedSegmentIndex == 0) {
        // Case: Upcoming game
        game = self.upcomingGamesArray[self.tableView.indexPathForSelectedRow.row];
    }
    else if (self.segmentControl.selectedSegmentIndex == 1) {
        // Case: Historic game
        game = self.historicGamesArray[self.tableView.indexPathForSelectedRow.row];
    }
    else {
        COMMON_LOG_WITH_COMMENT(@"ERROR: Unexpected self.segmentControl.selectedSegmentIndex")
    }
                                
    // Pass it forward
    destViewController.game = game;
    destViewController.context = RA_GameViewContextGameManager;
}



@end


