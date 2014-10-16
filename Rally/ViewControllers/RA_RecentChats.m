//
//  RA_Messages.m
//  Rally
//
//  Created by Max de Vere on 24/09/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_RecentChats.h"
#import "RA_ParseRecentChat.h"
#import "RA_RecentChatCell.h"
#import "NSDate+CoolStrings.h"
#import "Reachability.h"

// Basic idea here is that we want to:

// 1. First prepare the data we need, i.e. the sections we need ("Today", "Tomorrow", etc.), the shouts (rows) in each section, and the actual text content that we need for each shout/row

// 2. We do this in a background thread, because we want to show the progress HUD in the main thread. MBProgressHUD says you have to run stuff in the background and run the HUD on the main thread. This is a constraint we have to work with.

// 3. Once we've run the queries and prepared the data we need (which has all happened on a background thread), we go back to the main thread, assign the main properties (i.e. the ones that don't have 'Temp' in the name) to be copies of the Temp copies

// 4. Still on the main thread, we call reloadData

// This is obviously complicated and difficult to read, so I'm sure there's a smarter way to do all this, but this is the only way I've been able to do it without crashing because of threading issues.


@interface RA_RecentChats ()<UIAlertViewDelegate>

// The sections
@property NSArray *rowArray;
@property NSArray *rowArrayTemp;

// The text for the outlets in each cell
@property NSDictionary *contentForCells;
@property NSDictionary *contentForCellsTemp;

// This tells the VC whether to upload in the background or not (unintrusively)
@property BOOL shouldLoadInBackgroundInvisibly;

// Chat tapped on
@property (strong, nonatomic) RA_ParseRecentChat *messageObjectTapped;

// The badge count (messages not yet seen or dealt with)
@property (strong,nonatomic) NSString *badgeCount;

@end



@implementation RA_RecentChats


#pragma mark - load up and refresh triggers
// ******************** load up and refresh triggers ********************


-(void)viewDidLoad
{
    COMMON_LOG

    [super viewDidLoad];

    // Initialize properties
    self.rowArray = [NSArray array];
    self.rowArrayTemp = [NSArray array];
    self.contentForCells = [NSDictionary dictionary];
    self.contentForCellsTemp = [NSDictionary dictionary];
    self.shouldLoadInBackgroundInvisibly = NO;

    // Navbar
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;

    // The title for this table in the Navigation Controller.
    self.navigationItem.title = @"My messages";

    // Prepare the refresher thing
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor redColor];
    [refreshControl addTarget:self action:@selector(prepareTableInBackground) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
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
        [self performSelectorInBackground:@selector(prepareTable) withObject:nil];
        
        // Update badges here
        // Not the slickest way to do this
        [self performSelectorInBackground:@selector(updateBadges) withObject:nil];
    }
}



- (IBAction)refresh:(UIBarButtonItem *)sender
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
    
    // Run query for shouts (order by date ascending, takes a while)
    NSArray *queryResults = [self runQueryForMessages];
    NSLog(@"[queryResults count] = %lu", (unsigned long)[queryResults count]);
    
    // Prune out duplicate chatroom results (and delete from Parse)
    self.rowArrayTemp = [self pruneFromArrayAndCleanDatabaseOfDuplicates:queryResults];
    NSLog(@"[self.rowArrayTemp count] = %lu", (unsigned long)[self.rowArrayTemp count]);
    
    // Fetch objects if needed
    for (RA_ParseRecentChat *message in self.rowArrayTemp) {
        [message fetchIfNeeded];
    }
    
    // Get the contents for the contentForCells Dictionary
    [self prepareContentsForCells];
    
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
                                                    message:@"The messages view isn't much good without an active internet connection :-("
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}



-(NSArray *)runQueryForMessages
{
    COMMON_LOG
    
    // Define the query
    PFQuery *query = [RA_ParseRecentChat query];
    query.cachePolicy = kPFCachePolicyNetworkOnly;
    
    // Shouts must belong to current user
    [query whereKey:@"user" equalTo:[RA_ParseUser currentUser]];
    
    // Order by date ascending
    [query orderByDescending:@"dateUpdated"];
    
    // Fetch only 40. We are going to prune down to 20 for the view
    query.limit = 40;
    
    // Stay on this thread
    return [query findObjects];
}



-(NSArray *)pruneFromArrayAndCleanDatabaseOfDuplicates:(NSArray *)queryResults
{
    COMMON_LOG
    
    NSMutableArray *filteredResults = [NSMutableArray array];
    
    // We also use a blackList to keep track of which chatrooms we've already included in filteredResults...
    // ... because we don't want the same chatroom to appear in this table twice
    NSMutableArray *blackList = [NSMutableArray array];
    
    for (RA_ParseRecentChat *message in queryResults) {
        if (![blackList containsObject:message.chatroomId]) {
            // We have not added this chatroom yet
            NSLog(@"Loop: new chatroom, add as a row");
            [blackList addObject:message.chatroomId];
            [filteredResults addObject:message];
        }
        else {
            // We already have a more up-to-date message for this chatroom
            // We never require this message object again
            NSLog(@"Loop: existing chatroom, delete forever");
            [message deleteEventually];
        }
    }
    
    NSArray *rowArray = [NSArray arrayWithArray:filteredResults];
    return rowArray; // will now be moved into self.rowArrayTemp by -prepareTable
}



-(void)prepareContentsForCells
{
    COMMON_LOG
    
    NSMutableDictionary *contentForCellsMut = [NSMutableDictionary new];
    
    for (RA_ParseRecentChat *message in self.rowArrayTemp) {
        
        NSLog(@"prepareContentsForCells loop: message: %@", [message description]);
        
        // Shouldn't be needed by this point
        [message fetchIfNeeded];
        
        // But this *is* needed
        [message.fromUser fetchIfNeeded];
        
        // Define the cell config for this shout
        NSString *fromName = message.fromUser.displayName;
        NSString *messagePreview = message.messagePreview;
        NSString *dateString = [message.dateUpdated getDatePrettyStringMessages];
        RA_ParseUser *fromUser = message.fromUser;
        NSString *new = message.markAsSeen ? @"NO": @"YES";
        NSDictionary *cellConfiguration = [NSDictionary dictionaryWithObjectsAndKeys:
                                           fromName,@"fromName",
                                           messagePreview,@"messagePreview",
                                           dateString,@"dateString",
                                           fromUser,@"fromUser",
                                           new,@"new",
                                           nil];
        
        // Add to the cellContentForShoutMut
        [contentForCellsMut setObject:cellConfiguration forKey:message.objectId];
    }

    self.contentForCellsTemp = contentForCellsMut;
}



-(void)updateTable
{
    COMMON_LOG
    
    // Move the temp properties into the ones that the table depends on
    self.rowArray = [NSArray arrayWithArray:self.rowArrayTemp];
    self.contentForCells = [NSDictionary dictionaryWithDictionary:self.contentForCellsTemp];
    
    // Reload data
    [self.tableView reloadData];
    
    // Cancel the refresher
    [self.refreshControl endRefreshing];
}



#pragma mark - tableview
// ******************** tableview ********************


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    COMMON_LOG
    
    return 1;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    COMMON_LOG
    
    return [self.rowArray count];
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    COMMON_LOG
    
    return 76.0;
}



- (RA_RecentChatCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    COMMON_LOG
    
    RA_RecentChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"default_message_cell" forIndexPath:indexPath];
    
    RA_ParseRecentChat *message = self.rowArray[indexPath.row];
    NSDictionary *cellContent = [self.contentForCells objectForKey:message.objectId];
    [cell configureWithContent:cellContent];
    cell.backgroundColor = UIColorFromRGB(GENERIC_BACKGROUND_COLOUR);
    return cell;
}



#pragma mark - select row
// ******************** select row ********************


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    COMMON_LOG
    
    RA_ParseRecentChat *message = self.rowArray[indexPath.row];
    
    // Update the badges
    [self performSelectorInBackground:@selector(updateBadges) withObject:nil];
    
    // Prepare the HUD
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.delegate = self;
    
    // Mark as seen
    message.markAsSeen = YES;
    [message saveEventually];
    
    // Run the HUD while establishing the chatroom ID and loading the messages, etc.
    [HUD showWhileExecuting:@selector(segueToChatRoomForMessage:) onTarget:self withObject:message animated:YES];
}



-(void)segueToChatRoomForMessage:(RA_ParseRecentChat *)message
{
    COMMON_LOG
    
    RA_ParseChatroom *room = (RA_ParseChatroom *)message.chatroom;
    ChatView *chatView = [[ChatView alloc] initWith:room.objectId];
    chatView.chatRoomObject = room;
    [self.navigationController pushViewController:chatView animated:YES];
}



#pragma mark - badges
// ******************** badges ********************


-(void)updateBadges
{
    COMMON_LOG
    
    int i = 0;
    
    for (RA_ParseRecentChat *message in self.rowArray) {
        [message fetchIfNeeded];
        i = message.markAsSeen ? i : i+1;
    }
    
    // Update the tab bar badge number
    if (i != 0) {
        self.navigationController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%i",i];
    } else {
        self.navigationController.tabBarItem.badgeValue = nil;
    }
    
    // Also update the app badge number
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:(NSInteger)i];
    
    // And do it with the PFInstallation
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    currentInstallation.badge = (NSInteger)i;
    [currentInstallation saveEventually];
    
    NSLog(@"applicationIconBadgeNumber = %i", i);
}



@end




