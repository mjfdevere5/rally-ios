//
//  RA_Networks.m
//  Rally
//
//  Created by Alex Brunicki on 16/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_Networks.h"
#import "RA_NetworksCell.h"
#import "RA_CollCellDetails.h"
#import "RA_NetworksCell.h"
#import "RA_GamePrefConfig.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+ProfilePicHandling.h"
#import "RA_LeagueTables.h"



@interface RA_Networks ()

@property (strong, nonatomic) NSArray *listOfNetworks;
@property (strong, nonatomic) NSArray *listOfNetworksTemp;
@property (strong, nonatomic) UIImage *leagueImage;

@end

@implementation RA_Networks

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"Got to view did load");
    
    // Navbar
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    
    // change the background colour
    self.view.backgroundColor = RA_TEST_WHITE;
    
    // Populate the table
    [self loadTableData];
    

}


- (IBAction)tappedRefreshBarButton:(UIBarButtonItem *)sender
{
    COMMON_LOG
    
    [self loadTableData];
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
    self.listOfNetworksTemp = [self getCollectionArray];
    
    // Now reload the table on the main thread
    [self performSelectorOnMainThread:@selector(loadUpTheTable) withObject:nil waitUntilDone:NO];
}


-(NSArray *)getCollectionArray
{
    COMMON_LOG
    
    // Initialise an array that we are going to populate
    // Each element of this cell will be dictionary to let us populate the cell
    NSMutableArray *rowsArrayMut = [NSMutableArray array];
    
    RA_CollCellDetails *detailsJoin = [[RA_CollCellDetails alloc] initWithName:@"Join a network"
                                                                      andImage:[UIImage imageNamed:@"add_button_v03"]
                                                                     andAction:@"join_button"
                                                                    andNetwork:nil];
    [rowsArrayMut addObject:detailsJoin];
    
    
    RA_CollCellDetails *detailsCreate = [[RA_CollCellDetails alloc] initWithName:@"Create a network"
                                                                      andImage:[UIImage imageNamed:@"add_button"]
                                                                     andAction:@"create_button"
                                                                    andNetwork:nil];
    [rowsArrayMut addObject:detailsCreate];
    
    
    
    [[RA_ParseUser currentUser] fetch];
    for (RA_ParseNetwork *network in [RA_ParseUser currentUser].networkMemberships) {
        
        NSLog(@"number of networks %lu", (unsigned long)[[RA_ParseUser currentUser].networkMemberships count]);
        
        
        [network fetch];
        
        if ([network.type isEqualToString:@"special"]) {
            if ([network.name isEqualToString:@"All Rally Squash"]) {
                RA_CollCellDetails *detailsOne = [[RA_CollCellDetails alloc]initWithName:network.name andImage:[UIImage imageNamed:@"squash_league_v04"] andAction:network.type andNetwork:network];
                [rowsArrayMut addObject:detailsOne];
                
                
                NSLog(@"%lu", (unsigned long)[rowsArrayMut count]);
            }
            else{
                RA_CollCellDetails *detailsTwo = [[RA_CollCellDetails alloc]initWithName:network.name andImage:[UIImage imageNamed:@"tennis_league_v04"] andAction:network.type andNetwork:network];
                [rowsArrayMut addObject:detailsTwo];
                
               
            }
        }
        else {
            
            RA_CollCellDetails *detailsThree = [[RA_CollCellDetails alloc] initWithName:network.name
                                                                             andImage:[self getImageForNetwork:network]
                                                                            andAction:network.type
                                                                           andNetwork:network];
            NSLog(@"network descriptions %@",[network description]);
            
            [rowsArrayMut addObject:detailsThree];
            
        }
    }
    
    // Append a special kind of cell: Add a network
    NSLog(@"how many in the row array %lu", (unsigned long)[rowsArrayMut count]);
    
    // Return the array
    NSArray *rowsArray = [NSArray arrayWithArray:rowsArrayMut];
    return rowsArray;
}



-(UIImage *)getImageForNetwork:(RA_ParseNetwork *)network
{
    COMMON_LOG
    
    PFFile *file = network.leaguePicMedium;
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
    
    NSLog(@"Are you loading the table?");
    
    self.listOfNetworks = [NSArray arrayWithArray:self.listOfNetworksTemp];
    [self.collectionView reloadData];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return [self.listOfNetworks count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
   RA_NetworksCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"network_cell" forIndexPath:indexPath];
    
    RA_CollCellDetails *details = self.listOfNetworks[indexPath.row];
    
    UIImage *imageForResize = [details.image getImageResizedAndCropped:cell.ladderImage.frame.size];
    UIImage *imageForRounding = [imageForResize getImageWithRoundedCorners:0];
    
//    cell.ladderImage.layer.masksToBounds = YES;
//    cell.ladderImage.layer.cornerRadius = 10.0;
    
    cell.ladderImage.image = imageForRounding;
    cell.ladderName.text = details.name;
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    RA_CollCellDetails *details = self.listOfNetworks[indexPath.row];
    
    COMMON_LOG_WITH_COMMENT(details.action)
    
    if ([details.action isEqualToString:@"special"] || [details.action isEqualToString:@"League"] || [details.action isEqualToString:@"Ladder"]) {
        
        [self performSegueWithIdentifier:@"goto_leaderboard" sender:details.network];
        
//        RA_LeagueTables *view = [RA_LeagueTables new];
//        NSLog(@"fetching network to pass forward %@",details.network);
//        view.network = details.network;
//        [self presentViewController:view animated:YES completion:^{
//            NSLog(@"trying to fetch the new view controller");
    }
    
    else if ([details.action isEqualToString:@"create_button"]) {
        [self performSegueWithIdentifier:@"create_network" sender:self];
    }
    else if ([details.action isEqualToString:@"join_button"]) {
        [self addLadder];
    }

    
    else {
        NSLog(@"[%@, %@] ERROR: No action for tapped cell", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    }

    
}

#pragma mark - add ladder code


-(void)addLadder
{
    COMMON_LOG
    
    UIAlertView *alert = [[UIAlertView alloc] init];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.title = @"Access code";
    [alert addButtonWithTitle:@"Cancel"];
    [alert addButtonWithTitle:@"Join"];
    alert.delegate = self;
    [alert show];
}



-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    COMMON_LOG
    
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Join"]) {
        
        // Get the code entered
        NSString *accessCode = [alertView textFieldAtIndex:0].text;
        
        // Show HUD while adding network
        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:HUD];
        HUD.delegate = self;
        [HUD showWhileExecuting:@selector(addNetworkWithAccessCode:) onTarget:self withObject:accessCode animated:YES];
    }
}



// This is run the background while the HUD spins
-(void)addNetworkWithAccessCode:(NSString *)accessCode
{
    COMMON_LOG
    
    // Query for networks with this accessCode
    PFQuery *query = [RA_ParseNetwork query];
    query.cachePolicy = kPFCachePolicyNetworkOnly;
    [query whereKey:@"accessCode" equalTo:accessCode];
    NSArray *results = [query findObjects];
    
    if ([results count] == 0) {
        [self performSelectorOnMainThread:@selector(showIncorrectCodeAlert) withObject:nil waitUntilDone:NO];
        return;
    }
    else if ([results count] == 1) {
        RA_ParseNetwork *network = results[0];
        RA_ParseUser *cUser = [RA_ParseUser currentUser];
        [cUser fetch];
        
        // We need to test whether we are already a member
        // Using if([cUser.networkMemberships containsObject:network]) does not work, so we have to use the objectId
        NSArray *networkMembershipIds = [cUser.networkMemberships valueForKeyPath:@"objectId"];
        if ([networkMembershipIds containsObject:network.objectId]) {
            [self performSelectorOnMainThread:@selector(showAlreadyAMemberAlert:) withObject:network waitUntilDone:NO];
            return;
        }
        else {
            [cUser.networkMemberships addObject:network];
            
            //Add Bruno code
            if ([network.type isEqualToString:@"Ladder"]) {
                NSNumber *initialScore = [NSNumber numberWithFloat:1200.0];
                [network.userIdsToScores setObject:initialScore forKey:cUser.objectId];
                [network save];
            }
            else{
                NSNumber *initialScore = [NSNumber numberWithFloat:0.0];
                [network.userIdsToScores setObject:initialScore forKey:cUser.objectId];
                [network save];
            }
            
            [cUser save];
            [self performSelectorOnMainThread:@selector(returnToPlayMenu) withObject:nil waitUntilDone:YES];
            [self performSelectorOnMainThread:@selector(showYoureInAlert) withObject:nil waitUntilDone:NO];
        }
    }
    
    else {
        NSLog(@"[%@, %@] ERROR: There are %lu results from the accessCode query!",
              NSStringFromClass([self class]), NSStringFromSelector(_cmd), (unsigned long)[results count]);
    }
}



-(void)showIncorrectCodeAlert
{
    COMMON_LOG
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry, incorrect code"
                                                    message:nil
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}



-(void)showAlreadyAMemberAlert:(RA_ParseNetwork *)network
{
    COMMON_LOG
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Already a member!"
                                                    message:[NSString stringWithFormat:@"You typed in the access code for %@; you already belong to this network.", network.name]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}



-(void)showYoureInAlert
{
    COMMON_LOG
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You're in!"
                                                    message:@"You should now see the ladder appear in this menu."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

-(void)returnToPlayMenu
{
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"goto_leaderboard"]) {
        RA_LeagueTables *leagueTable = [segue destinationViewController];
        leagueTable.network = sender;
    }
}


@end
