//
//  RA_SportsSelector_TableViewController.m
//  Rally
//
//  Created by Max de Vere on 27/08/2014.
//  Copyright (c) 2014 NA. All rights reserved.
//


#import "RA_PlayMenu.h"
#import "RA_GamePrefConfig.h"
#import "RA_ParseNetwork.h"
#import "RA_PlayMenuCell.h"
#import "RA_PlayMenuCellDetails.h"
#import "RA_ParseUser.h"
#import "UIImage+ProfilePicHandling.h"

@interface RA_PlayMenu ()<UIAlertViewDelegate>

@property (strong, nonatomic) NSArray *listOfNetworks;
@property (strong, nonatomic) NSArray *listOfNetworksTemp;
@property (strong, nonatomic) UIImage *leagueImage;

@property (nonatomic) BOOL shouldReloadInBackground;

@end



@implementation RA_PlayMenu


#pragma mark - load up
// ******************** load up ********************


- (void)viewDidLoad
{
    COMMON_LOG
    
    [super viewDidLoad];
    
    // Navbar customisation (to do: consider vertical height vs. other navbars)
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{ NSFontAttributeName: [UIFont fontWithName: @"Futura" size:20.0],
        NSForegroundColorAttributeName: [UIColor whiteColor] }]; // Redundant code, as all titles are white
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    
    // Prevent reload in background being triggered by viewDidAppear
    self.shouldReloadInBackground = NO;
    
    // Logo hidden in the background
    self.tableView.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(self.tableView.frame.origin.x,
                                                                             self.tableView.frame.origin.y,
                                                                             self.tableView.frame.size.width,
                                                                             self.tableView.frame.size.height)];
    UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"racquet_logo_v01"]];
    [self.tableView.backgroundView addSubview:logo];
    logo.center = CGPointMake(self.tableView.backgroundView.center.x, 100.0);
    
    // Remove separators from table
    [self.tableView setSeparatorStyle: UITableViewCellSeparatorStyleNone];
    
    // Populate the table
    [self loadTableData];
}



-(void)viewDidAppear:(BOOL)animated
{
    COMMON_LOG
    
    
    if (self.shouldReloadInBackground) {
        [self performSelectorInBackground:@selector(fireUpTable) withObject:nil];
        
    }
}



- (void) loadTableData
{
    COMMON_LOG
    
    // Start a HUD while we save user information
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.delegate = self;
    [HUD showWhileExecuting:@selector(fireUpTable) onTarget:self withObject:nil animated:YES];
}



// Should work on background thread
-(void)fireUpTable
{
    COMMON_LOG
    
    NSLog(@"%@ on thread %@", NSStringFromSelector(_cmd), [NSThread currentThread]);
    
    // Get self.listOfNetworksTemp
    self.listOfNetworksTemp = [self getRowsArray];
    
    // Now reload the table on the main thread
    [self performSelectorOnMainThread:@selector(loadUpTheTable) withObject:nil waitUntilDone:NO];
}



-(NSArray *)getRowsArray
{
    COMMON_LOG
    
    // Initialise an array that we are going to populate
    // Each element of this cell will be dictionary to let us populate the cell
    NSMutableArray *rowsArrayMut = [NSMutableArray array];
    
    // The first cell is the 'Rally Users Network' cell
    RA_PlayMenuCellDetails *detailsOne = [[RA_PlayMenuCellDetails alloc] initWithName:@"Rally Users Network"
                                                                             andImage:[UIImage imageNamed:@"rally_users_network"]
                                                                            andAction:@"rally_users_network"
                                                                           andNetwork:nil];
    [rowsArrayMut addObject:detailsOne];
    
    // Fetch current user networks and create a row for each one
    [[RA_ParseUser currentUser] fetchIfNeeded];
    for (RA_ParseNetwork *network in [RA_ParseUser currentUser].networkMemberships) {
        COMMON_LOG_WITH_COMMENT([network description])
        NSString *errorLog = [NSString stringWithFormat:@"network class = %@", [[network class] description]];
        COMMON_LOG_WITH_COMMENT(errorLog)
        [network fetchIfNeeded];
        if (![network.type isEqualToString:@"special"]) {
            RA_PlayMenuCellDetails *detailsTwo = [[RA_PlayMenuCellDetails alloc] initWithName:network.name
                                                                                     andImage:[self getImageForNetwork:network]
                                                                                    andAction:network.type
                                                                                   andNetwork:network];
            [rowsArrayMut addObject:detailsTwo];
        }
    }
    
    // Append a special kind of cell: Add a network
    RA_PlayMenuCellDetails *detailsThree = [[RA_PlayMenuCellDetails alloc] initWithName:@"Add a network"
                                                                               andImage:[UIImage imageNamed:@"add_button_v03"]
                                                                              andAction:@"add_button"
                                                                             andNetwork:nil];
    [rowsArrayMut addObject:detailsThree];
    
    // Return the array
    NSArray *rowsArray = [NSArray arrayWithArray:rowsArrayMut];
    return rowsArray;
}



-(UIImage *)getImageForNetwork:(RA_ParseNetwork *)network
{
    COMMON_LOG
    
    PFFile *file = network.leaguePicLarge;
    NSData *data = [file getData];
    
    if (data == nil) {
        self.leagueImage = [UIImage imageNamed:@"play_menu_placeholder"];
    }
    else{
        self.leagueImage = [UIImage imageWithData:data];
    }
    
    
    return self.leagueImage;
}



-(void)loadUpTheTable
{
    COMMON_LOG
    
    self.listOfNetworks = [NSArray arrayWithArray:self.listOfNetworksTemp];
    [self.tableView reloadData];
    self.shouldReloadInBackground = YES;
}



#pragma mark - table view methods
// ******************** table view methods ********************


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    COMMON_LOG
    
    return 1;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    COMMON_LOG
    
    return [self.listOfNetworks count];
}



//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    COMMON_LOG
//
////    RA_PlayMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:@"play_cell"];
////    return cell.sportImage.frame.size.height;
////
////    RA_PlayMenuCellDetails *details = self.listOfNetworks[indexPath.row];
////    UIImage *image = details.image;
////    return image.size.height;
//
//    return 180.0;
//}



- (RA_PlayMenuCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    COMMON_LOG
    
    // Dequeue
    RA_PlayMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:@"play_cell_trial" forIndexPath:indexPath];
    
    // Configure cell
    // TO DO: Make more dynamic, e.g. with a label for the network name, etc.
    RA_PlayMenuCellDetails *details = self.listOfNetworks[indexPath.row];
    
    cell.sportImage.image = details.image;
    
    //    UIImage *resizedImage = [details.image getImageResizedAndCropped:CGSizeMake(cell.sportImage.frame.size.width, cell.sportImage.frame.size.height)];
    //
    //    UIImageView *image = [[UIImageView alloc]initWithImage:resizedImage];
    //    cell.sportImage = image;
    
    //[cell.contentView addSubview:image];
    
    // Return cell
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    COMMON_LOG
    
    RA_PlayMenuCellDetails *details = self.listOfNetworks[indexPath.row];
    
    COMMON_LOG_WITH_COMMENT(details.action)
    
    if ([details.action isEqualToString:@"rally_users_network"]) {
        NSLog(@"the network details are %@",details.network);
        [self performSegueWithIdentifier:@"goto_rally_users_networks" sender:self];
    }
    
    else if ([details.action isEqualToString:@"League"] || [details.action isEqualToString:@"Ladder"]) {
        
//        [RA_GamePrefConfig gamePrefConfig]. = details.network; // TO DO FIX THIS
        
        [self performSegueWithIdentifier:@"goto_leaderboard" sender:self];
    }
    
    else if ([details.action isEqualToString:@"add_button"]) {
        [self performSegueWithIdentifier:@"add_network" sender:self];
    }
    
    else {
        NSLog(@"[%@, %@] ERROR: No action for tapped cell", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    }
}


@end


