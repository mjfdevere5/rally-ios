//
//  RA_rallySportSelector.m
//  Rally
//
//  Created by Alex Brunicki on 09/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_rallySportSelector.h"
#import "RA_ParseNetwork.h"
#import "RA_GamePrefConfig.h"

@interface RA_rallySportSelector ()

@end

@implementation RA_rallySportSelector

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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 2;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [[RA_ParseUser currentUser] fetchIfNeeded];
    if ([cell.reuseIdentifier isEqualToString:@"rally_sport_squash"]) {
        NSLog(@"Log for rally sport");
        for (RA_ParseNetwork *network in [RA_ParseUser currentUser].networkMemberships) {
            if ([network.objectId isEqualToString:@"Utu5aSM2ke"]) {
//                [RA_GamePrefConfig gamePrefConfig].network = network;
                
            }
        }
    }
    else{
        for (RA_ParseNetwork *network in [RA_ParseUser currentUser].networkMemberships) {
            if ([network.objectId isEqualToString:@"Y2IHHx2uu4"]) {
//                [RA_GamePrefConfig gamePrefConfig].network = network;
            }
        }

    }
    [self performSegueWithIdentifier:@"to_leaderboard" sender:self];
    
        
}

@end
