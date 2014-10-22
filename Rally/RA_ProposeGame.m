//
//  RA_ProposeGame.m
//  Rally
//
//  Created by Max de Vere on 20/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_ProposeGame.h"
#import "RA_ProposeGameBaseCell.h"
#import "RA_ParseGame.h"
#import "MBProgressHUD.h"
#import "NSDate+UtilitiesMax.h"

@interface RA_ProposeGame()<MBProgressHUDDelegate>
@property (strong, nonatomic) NSArray *cellArray;
@property (strong, nonatomic) RA_ParseGame *game;
@end

@implementation RA_ProposeGame


#pragma mark - load up
// ******************** load up ********************

- (void)viewDidLoad
{ COMMON_LOG
    [super viewDidLoad];
    
    // Navbar
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    self.navigationItem.title = @"Game setup";
    
    // Form formatting
    self.tableView.backgroundColor = RA_TEST_WHITE;
    self.view.backgroundColor = RA_TEST_WHITE;
  
    
    // Set a default dateTime
    self.dateTime = [[NSDate date] upcomingHour];
    
    // Simple cell array
    self.cellArray = @[ @[@"proposegame_picksport_cell"] , @[@"proposegame_datetime_cell"] ];
    
    CALayer *btnLayer = [self.setPrefButton layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:0.0f];
    
    // Reload the table
    [self.tableView reloadData];
}


#pragma mark - tableview data source
// ******************** tableview data source ********************

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.cellArray count]; // Should be 2
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *rowsInSection = self.cellArray[section];
    NSInteger numberOfRows = [rowsInSection count];
    return numberOfRows;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title;
    switch (section) {
        case 0:
            title = @"Sport";
            break;
        case 1:
            title = @"Logistics";
            break;
        default:
            title = @"...";
            COMMON_LOG_WITH_COMMENT(@"ERROR: Unexpected section")
            break;
    }
    return title;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId = self.cellArray[indexPath.section][indexPath.row];
    if ([cellId isEqualToString:@"proposegame_picksport_cell"]) {
        return 56.0;
    }
    else if ([cellId isEqualToString:@"proposegame_datetime_cell"]) {
        return 90.0;
    }
    else {
        return 44.0;
        COMMON_LOG_WITH_COMMENT(@"ERROR: Unexpected cellId")
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{ COMMON_LOG_WITH_COMMENT([indexPath description])
    // Dequeue
    NSString *reuseIdentifier = self.cellArray[indexPath.section][indexPath.row];
    COMMON_LOG_WITH_COMMENT(@"reuse id")
    RA_ProposeGameBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    COMMON_LOG_WITH_COMMENT([cell description])
    
    // Configuration
    cell.myViewController = self;
    COMMON_LOG_WITH_COMMENT(@"1")
    [cell configureCell];
    COMMON_LOG_WITH_COMMENT(@"2")
    
    // Return
    return cell;
}


#pragma mark - button tap
// ******************** button tap ********************

- (IBAction)setPrefButtonTapped:(id)sender
{ COMMON_LOG
    if (!self.sport) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not so fast!"
                                                        message:@"You haven't selected a sport"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    // Prepare the game object for upload
    self.game = [[RA_ParseGame alloc] initAsProposalFromMeToOpponent:self.opponent
                                                                     andSport:self.sport
                                                                  andDatetime:self.dateTime];
    
    // Prepare the progress HUD
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.delegate = self;
    [HUD show:YES];
    
    // Upload
    [self.game saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [HUD hide:YES];
        if (succeeded) { [self configUploadedSuccessfully]; }
        else { [self configFailedToUploadWithError:error]; }
    }];
}

-(void)configUploadedSuccessfully
{
    
    // Throw a 'success' alert
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!"
                                                    message:[NSString stringWithFormat:@"You've proposed a game to %@. You'll get a ping when your match is confirmed.", self.opponent.displayName]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles: nil];
    [alert show];
    
    // Push
    NSString *pushText = [NSString stringWithFormat:@"%@ has sent you a game proposal", [RA_ParseUser currentUser].displayName];
    PFPush *push = [self configurePushWithText:pushText];
    [push sendPushInBackground];
    
    // Unwind completely
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(PFPush *)configurePushWithText:(NSString *)text
{
    COMMON_LOG
    
    // Initialise our push
    PFPush *push = [[PFPush alloc] init];
    
    // Push query
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"user" equalTo:[self.game opponent]];
    [push setQuery:pushQuery];
    
    // Push config
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          text, @"alert",
                          @"cheering.caf", @"sound",
                          @"Increment", @"badge",
                          nil];
    [push setData:data];
    
    // Return
    return push;
}

-(void)configFailedToUploadWithError:(NSError *)error
{
    NSLog(@"%@ on thread %@", NSStringFromSelector(_cmd), [NSThread currentThread]);
    NSLog(@"ERROR uploading shout in background: %@", [error localizedDescription]);
    
    // Throw a 'uh oh' alert
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh oh!"
                                                    message:[NSString stringWithFormat:@"Seems like something went wrong with the connection - your game proposal was not sent."]
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Try again", nil];
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Try again"]) {
        [self setPrefButtonTapped:nil];
    }
}


@end
