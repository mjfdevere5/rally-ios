//
//  RA_joinNetwork.m
//  Rally
//
//  Created by Alex Brunicki on 10/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_joinNetwork.h"
#import "RA_ParseNetwork.h"
#import "RA_ParseUser.h"
#import "RA_PlayMenu.h"

@interface RA_joinNetwork ()

@end

@implementation RA_joinNetwork

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 2;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell.reuseIdentifier isEqualToString:@"join_network"]) {
        NSLog(@"join network");
        [self addLadder];
    }
    else {
        [self performSegueWithIdentifier:@"create_network" sender:self];
        }
}

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



@end
