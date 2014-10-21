//
//  RA_LeagueTables.m
//  Rally
//
//  Created by Alex Brunicki on 16/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_LeagueTables.h"
#import "RA_NewsFeed.h"
#import "NSDate+Utilities.h"
#import "NSDate+CoolStrings.h"
#import "RA_ParseBroadcast.h"
#import "RA_NewsFeedRallyBroadcastCell.h"
#import "RA_FeedCellShout.h"
#import "RA_ParseNetwork.h"
#import "RA_NextGamePrefOne.h"
#import "UIImage+ProfilePicHandling.h"
#import "RA_UserProfileDynamicTable.h"
#import "RA_LeagueCell.h"
#import "RA_LeagueCellHeader.h"


@interface RA_LeagueTables ()

// Array of RA_ParseUser objects
@property (strong, nonatomic) NSArray *orderedPlayersMain;
@property (strong, nonatomic) NSArray *orderedPlayersTemp;
@property (strong, nonatomic) NSDictionary *scoresToIds;

@property (nonatomic) BOOL shouldReloadInBackground;


@end

@implementation RA_LeagueTables


- (void)viewDidLoad
{
    NSLog(@"%@ on thread %@", NSStringFromSelector(_cmd), [NSThread currentThread]);
    [super viewDidLoad];
    
    
    NSLog(@"in view did load for league tables view");
    
    // Navbar
    self.navigationItem.title = self.network.name;
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    
    self.tableView.separatorColor = [UIColor clearColor];
    
    // Formatting
    self.view.backgroundColor = RA_TEST_WHITE;
    self.tableView.backgroundColor = RA_TEST_WHITE;
    
    // Initiate arrays to prevent problems later on
    self.orderedPlayersMain = [NSArray array];
    self.orderedPlayersTemp = [NSArray array];
    
    // Prevents unused rows from appearing
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView.backgroundColor = [UIColor clearColor];
    
    // Prevent background loadup on first load up
    self.shouldReloadInBackground = NO;
    
    // Load up
    [self refreshTable];
}



-(void)viewDidAppear:(BOOL)animated
{
    if (self.shouldReloadInBackground) {
        [self performSelectorInBackground:@selector(createTable) withObject:nil];
    }
}



#pragma mark - load table
// ******************** load table ********************


- (IBAction)refresh:(UIBarButtonItem *)sender
{
    NSLog(@"%@ on thread %@", NSStringFromSelector(_cmd), [NSThread currentThread]);
    [self refreshTable];
}



-(void) refreshTable
{
    NSLog(@"refresh table in progress");
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    
//    NSLog(@"Does it get that far");
//    
//    MBProgressHUD *HUD;
//    
//    HUD = [[MBProgressHUD alloc] initWithView:self.view];
//    [self.view addSubview:HUD];
    
    [self.navigationController.view addSubview:HUD];
    
    HUD.delegate = self;
    [HUD showWhileExecuting:@selector(createTable) onTarget:self withObject:nil animated:YES];
}



// Should be run in background thread
-(void) createTable;
{
    NSLog(@"In create table");
    // Run the query
    self.orderedPlayersTemp = [self getOrderedUserIds];
    
    
    
    // Now kick of the table reload on the main thread
    [self performSelectorOnMainThread:@selector(updateTable) withObject:nil waitUntilDone:YES];
}



-(NSArray *)getOrderedUserIds;
{
    NSLog(@"In getOrderedUserIds");
    
    // Get all users in this network
    PFQuery *query = [RA_ParseUser query];
    query.cachePolicy = kPFCachePolicyNetworkOnly;
    [query whereKey:@"networkMemberships" equalTo:self.network];
    NSArray *networkMembers = [query findObjects];
    NSString *comment = [NSString stringWithFormat:@"%lu", (unsigned long)[networkMembers count]];
    COMMON_LOG_WITH_COMMENT(comment)
    
    // Get user scores from the network scores dictionary
    self.scoresToIds = self.network.userIdsToScores;
    NSArray *orderedIds = [self.scoresToIds keysSortedByValueUsingComparator:
                           ^NSComparisonResult(id obj1, id obj2) {
                               return [obj2 compare:obj1];
                           }];
    NSMutableArray *orderedIdsMut = [NSMutableArray arrayWithArray:orderedIds];
    
    // Append any users that don't have scores (not played any games) to the end of our orderedIdsMut array
    for (RA_ParseUser *user in networkMembers) {
        if (![orderedIdsMut containsObject:user.objectId]) {
            [orderedIdsMut addObject:user];
        }
    }
    
    // For convenience, we want this orderedIdsMut array but containing actual users, not just their Id strings
    NSMutableArray *orderedMembersMut = [NSMutableArray array];
    for (NSString *userId in orderedIdsMut) {
        for (RA_ParseUser *user in networkMembers) {
            if ([user.objectId isEqualToString:userId]) {
                [orderedMembersMut addObject:user];
                break;
            }
        }
    }
    
    // Return array
    NSArray *orderedMembers = [NSArray arrayWithArray:orderedMembersMut];
    return orderedMembers;
}



-(void)updateTable
{
    NSLog(@"%@ on thread %@", NSStringFromSelector(_cmd), [NSThread currentThread]);
    
    // Move the temp properties into the ones that the table depends on
    self.orderedPlayersMain = [NSArray arrayWithArray:self.orderedPlayersTemp];
    
    NSLog(@"About to reload the table now");
    
    // Reload data
    [self.tableView reloadData];
    
    
    // Next time, load silently in background
    self.shouldReloadInBackground = YES;
}



#pragma mark - tableview delegate
// ******************** tableview delegate ********************


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSLog(@"getting to sections in table view");
    
    return 2;
}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    NSLog(@"how many in the rows? %lu",(unsigned long)[self.orderedPlayersMain count]);
    NSLog(@"number of players in the league %lu",(unsigned long)[self.orderedPlayersMain count]);
    return [self.orderedPlayersMain count];
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    
    NSInteger section = indexPath.section;
    
    if (section == 0) {
        RA_LeagueCellHeader *cell = [tableView dequeueReusableCellWithIdentifier:@"table_header" forIndexPath:indexPath];
        
        NSLog(@"dequeing the table_header cell");
        return cell;
    }
    else{
        
        // Dequeue
        RA_LeagueCell *cell = [tableView dequeueReusableCellWithIdentifier:@"table_ladder_cell" forIndexPath:indexPath];
        
        NSLog(@"dequeing the table_ladder_cell");
        
        // Alternating colour
        if ([indexPath row] % 2) { [cell setBackgroundColor:RA_TEST_BLUE3]; }
        else { [cell setBackgroundColor:RA_TEST_BLUE2]; }
        
        if ([indexPath row] % 2) {
            cell.rankNo.textColor = [UIColor blackColor];
            cell.playerName.textColor = [UIColor blackColor];
            cell.playerScore.textColor = [UIColor blackColor];
        }
        else {
            cell.rankNo.textColor = [UIColor whiteColor];
            cell.playerName.textColor = [UIColor whiteColor];
            cell.playerScore.textColor = [UIColor whiteColor];
        }

        
        // Rank
        NSString *rankNumber = [NSString stringWithFormat:@"%i",(int)(indexPath.row + 1)];
        cell.rankNo.text = rankNumber;
        
        NSLog(@"cell.ranNO.text is %@",rankNumber);
        
        // If cell gets more complex, let's manage the configuration in the cell class. For now, this is fine.
        // Get user for row
        RA_ParseUser *user = self.orderedPlayersMain[indexPath.row];
        
        // User display name
        cell.playerName.text = user.displayName;
        
        NSLog(@"cell.playerName.text is %@",user.displayName);
        
        cell.playerScore.text = [NSString stringWithFormat:@"%@",[self.scoresToIds objectForKey:user.objectId]];
        
        // Profile pic
        [cell.activityWheel startAnimating];
        PFFile *profilePicFile = user.profilePicSmall;
        [profilePicFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (error) {
                NSLog(@"getDataInBackground error: %@", [error localizedDescription]);
            }
            else {
                UIImage *profilePicRaw = [UIImage imageWithData:data];
                UIImage *profilePicResized = [profilePicRaw getImageResizedAndCropped:cell.playerPic.frame.size];
                UIImage *profilePicRounded = [profilePicResized getImageWithRoundedCorners:3];
                cell.playerPic.image = profilePicRounded;
                [cell.activityWheel stopAnimating];
            }
        }];
        
        return cell;
        
    }
    
}


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"Table standings";
    }
    else{
        return @"";
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 35.0;
    }
    else{
        return 0.0;
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RA_UserProfileDynamicTable *userProfile = [[RA_UserProfileDynamicTable alloc] initWithUser:self.orderedPlayersMain[indexPath.row] andContext:RA_UserProfileContextLeaderboard];
    [self.navigationController pushViewController:userProfile animated:YES];
}



#pragma mark - navigation
// ******************** navigation ********************


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue destinationViewController] isKindOfClass:[RA_NextGamePrefOne class]]) {
        // Not sure there is anything to do here?
    }
}

@end