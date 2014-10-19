//
//  RA_UserProfileDynamicTable.m
//  Rally
//
//  Created by Max de Vere on 13/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_UserProfileDynamicTable.h"
#import "NSDate+CoolStrings.h"
#import "RA_ParseChatroom.h"
#import "RA_ParseGame.h"
#import "ChatView.h"
#import "RA_UserProfileBaseCell.h"
#import "NSDate+Utilities.h"
#import "RA_UserProfileChatCell.h"
#import "RA_UserProfileAcceptGameCell.h"
#import "RA_NewsFeed.h"


@interface RA_UserProfileDynamicTable ()

// Cell array
@property (strong, nonatomic) NSArray *cellArray;
@property (nonatomic) NSInteger numberOfPreferences;

// Reference to cells
@property (strong, nonatomic) NSMutableDictionary *cells;

// Chatroom
@property (strong, nonatomic) RA_ParseChatroom *chatroom;
@property (nonatomic) BOOL hasChatroom;

@end


@implementation RA_UserProfileDynamicTable


#pragma mark - init and load up
// ******************** init and load up ********************


-(instancetype)initWithUser:(RA_ParseUser *)user andContext:(RA_UserProfileContext)context
{
    COMMON_LOG
    
    self = [super init];
    if (self) {
        self.user = user;
        self.context = context;
    }
    return self;
}



- (void)viewDidLoad
{
    COMMON_LOG
    
    if (!self.user) {
        COMMON_LOG_WITH_COMMENT(@"ERROR: No self.user")
        return;
    }
    
    // Super
    [super viewDidLoad];
    
    // Navbar
    self.navigationItem.title = [NSString stringWithFormat:@"User profile"];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    
    
    // Initialise dictionary
    self.cells = [NSMutableDictionary dictionary];
    
    // Register the nibs
//    [self.tableView registerClass:[RA_UserProfileBaseCell class] forCellReuseIdentifier:@"userprofile_acceptgame_cell"];
//    [self.tableView registerClass:[RA_UserProfileChatCell class] forCellReuseIdentifier:@"userprofile_chat_cell"];
//    [self.tableView registerClass:[RA_UserProfileBaseCell class] forCellReuseIdentifier:@"userprofile_proposegame_cell"];
//    [self.tableView registerClass:[RA_UserProfileBaseCell class] forCellReuseIdentifier:@"userprofile_report_cell"];
//    [self.tableView registerNib:[UINib nibWithNibName:@"userprofile_chat_cell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"userprofile_chat_cell"];
//    [self.tableView registerNib:[UINib nibWithNibName:@"userprofile_proposegame_cell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"userprofile_proposegame_cell"];
//    [self.tableView registerNib:[UINib nibWithNibName:@"userprofile_report_cell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"userprofile_report_cell"];
    UINib *nibFour = [UINib nibWithNibName:@"RA_UserProfileAcceptGameCell" bundle:nil];
    [self.tableView registerNib:nibFour forCellReuseIdentifier:@"userprofile_acceptgame_cell"];
    UINib *nib = [UINib nibWithNibName:@"RA_UserProfileChatCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"userprofile_chat_cell"];
    UINib *nibTwo = [UINib nibWithNibName:@"RA_UserProfileProposeGameCell" bundle:nil];
    [self.tableView registerNib:nibTwo forCellReuseIdentifier:@"userprofile_proposegame_cell"];
    UINib *nibThree = [UINib nibWithNibName:@"RA_UserProfileReportCell" bundle:nil];
    [self.tableView registerNib:nibThree forCellReuseIdentifier:@"userprofile_report_cell"];
    
    // Load cell arrays:
    // - userprofile_acceptgame_cell
    // - userprofile_chat_cell
    // - userprofile_proposegame_cell
    // - userprofile_report_cell
    if ([self.user.objectId isEqualToString:[RA_ParseUser currentUser].objectId]) {
        self.cellArray = @[@"userprofile_chat_cell",
                           @"userprofile_proposegame_cell",
                           @"userprofile_report_cell"]; // TO DO fix this
    }
    else if (self.context == RA_UserProfileContextGameManager) {
        self.cellArray = @[@"userprofile_chat_cell",
                           @"userprofile_proposegame_cell",
                           @"userprofile_report_cell"];
    }
    else if (self.context == RA_UserProfileContextLeaderboard) {
        self.cellArray = @[@"userprofile_chat_cell",
                           @"userprofile_proposegame_cell",
                           @"userprofile_report_cell"];
    }
    else if (self.context == RA_UserProfileContextNewsFeed) {
        self.cellArray = @[@"userprofile_chat_cell",
                           @"userprofile_proposegame_cell",
                           @"userprofile_report_cell"];
    }
    else if (self.context == RA_UserProfileContextShoutOut) {
        NSMutableArray *cellArrayMut = [NSMutableArray array];
        for (int i = 1 ; i <= [self.gamePref.dateTimePreferences count] ; i++) {
            [cellArrayMut addObject:@"userprofile_acceptgame_cell"];
        }
        [cellArrayMut addObjectsFromArray:@[@"userprofile_chat_cell",
                                            @"userprofile_proposegame_cell",
                                            @"userprofile_report_cell"]];
         self.cellArray = [NSArray arrayWithArray:cellArrayMut];
    }
    else {
        COMMON_LOG_WITH_COMMENT(@"ERROR: Unexpected self.context")
    }
    COMMON_LOG_WITH_COMMENT([self.cellArray description])
    
    // Prevents unused rows from appearing
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView.backgroundColor = [UIColor clearColor];
    
    // Load the table
    [self.tableView reloadData];
    
    // Parallax stuff, basic
    [self setHeaderImage:[UIImage imageNamed:@"placeholder"]]; // TO DO
    [self setTitleText:self.user.displayName];
    [self setSubtitleText:[NSString stringWithFormat:@"Member since %@ %@",
                           [self.user.createdAt getMonthLong:YES],
                           [self.user.createdAt getYearLong:NO]]];
    
    // Add an activity wheel over the top of the header
    UIView *viewForWheel = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [self headerHeight], 320)];
    [self addHeaderOverlayView:viewForWheel];
    UIActivityIndicatorView *activityWheel = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityWheel.tintColor = [UIColor darkGrayColor];
    activityWheel.hidesWhenStopped = YES;
    [viewForWheel addSubview:activityWheel];
    activityWheel.center = viewForWheel.center;
    
    // Now load the proper image
    [activityWheel startAnimating];
    PFFile *largeProfilePicFile = self.user.profilePicLarge;
    [largeProfilePicFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        [self setHeaderImage:[UIImage imageWithData:data]];
        [activityWheel stopAnimating];
    }];
    
    // Find chatroom in background
    if (![self.user.objectId isEqualToString:[RA_ParseUser currentUser].objectId]) {
        [self performSelectorInBackground:@selector(findChatroom) withObject:nil];
    }
}



// Should not be run on the main thread
-(void)findChatroom
{
    COMMON_LOG
    
    // Get each user
    RA_ParseUser *cUser = [RA_ParseUser currentUser];
    RA_ParseUser *opponent = self.user;
    
    // See if chatroom exists
    PFQuery *query = [RA_ParseChatroom query];
    [query whereKey:@"user1" equalTo:cUser];
    [query whereKey:@"user2" equalTo:opponent];
    NSArray *firstResults = [query findObjects];
    
    if ([firstResults count] > 0) {
        // Get existing chatroom
        self.chatroom = firstResults[0];
    }
    
    else {
        PFQuery *query = [RA_ParseChatroom query];
        [query whereKey:@"user1" equalTo:opponent];
        [query whereKey:@"user2" equalTo:cUser];
        NSArray *secondResults = [query findObjects];
        if ([secondResults count] > 0) {
            // Get existing chatroom
            self.chatroom = secondResults[0];
        }
        else {
            RA_ParseChatroom *newChatroom = [RA_ParseChatroom objectWithAutoACLAndUser1:cUser andUser2:opponent];
            self.chatroom = newChatroom;
            NSLog(@"Saving new chatroom");
            [self.chatroom save];
        }
    }
    
    [self.chatroom fetchIfNeeded]; // Don't think this is needed
    self.hasChatroom = YES;
    COMMON_LOG_WITH_COMMENT(@"Finished getting chatroom to pass forward")
    NSString *comment = [NSString stringWithFormat:@"Chatroom details: %@", [self.chatroom description]];
    COMMON_LOG_WITH_COMMENT(comment)
}



#pragma mark - table view data source
// ******************** table view data source ********************


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.cellArray count];
}



-(RA_UserProfileBaseCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    COMMON_LOG
    
    // Dequeue
    RA_UserProfileBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellArray[indexPath.row] forIndexPath:indexPath];
    
    // Configure the cell
    cell.user = self.user;
    cell.gamePref = self.gamePref;
    cell.context = self.context;
    cell.indexPath = indexPath;
    [cell configureCell];
    
    // Add cell to dictionary
    [self.cells setValue:cell forKey:[NSString stringWithFormat:@"%@", [indexPath description]]];
    
    // Return the cell
    return cell;
}



#pragma mark - row selection
// ******************** row selection ********************


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    COMMON_LOG
    
    // Reporting a bad user. Fairly primitive, as it just opens the Mail app.
    if ([[tableView cellForRowAtIndexPath:indexPath].reuseIdentifier isEqualToString:@"userprofile_report_cell"]) {
        COMMON_LOG_WITH_COMMENT([tableView cellForRowAtIndexPath:indexPath].reuseIdentifier)
        NSString *addressee = @"mjf.devere@gmail.com";
        NSString *subject = @"Reporting user";
        NSString *body = [NSString stringWithFormat:@"Please include details of your complaint below:\n\n1. User ID: %@ (please do not delete)\n\n2. Please provide details of your complaint here: \n/n3. Can a member of the Rally team contact you for further information if necessary? Yes/No", self.user.objectId];
//        NSString *mailtoParam = [[NSString stringWithFormat:@"mailto:%@?subject=%@&body=%@", addressee, subject, body] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *mailtoParam = [[NSString stringWithFormat:@"mailto:%@?subject=%@&body=%@", addressee, subject, body] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mailtoParam]];
    }
    
    // Chat
    else if ([[tableView cellForRowAtIndexPath:indexPath].reuseIdentifier isEqualToString:@"userprofile_chat_cell"]) {
        COMMON_LOG_WITH_COMMENT([tableView cellForRowAtIndexPath:indexPath].reuseIdentifier)
        COMMON_LOG_WITH_COMMENT([self.chatroom description])
        if (!self.hasChatroom) {
            // Show HUD while finding chatroom
            MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
            [self.navigationController.view addSubview:HUD];
            HUD.delegate = self;
            [HUD showWhileExecuting:@selector(findChatroom) onTarget:self withObject:nil animated:YES];
            [HUD showAnimated:YES whileExecutingBlock:^{
                [self findChatroom];
            } completionBlock:^{
                COMMON_LOG_WITH_COMMENT(@"Just found a chatroom")
                [self segueToChatroom];
            }];
        }
        else {
            COMMON_LOG_WITH_COMMENT(@"Already have chatroom")
            [self segueToChatroom];
        }
    }
    
    // Propose game TO DO (currently just uploads a placeholder game)
//    else if ([[tableView cellForRowAtIndexPath:indexPath].reuseIdentifier isEqualToString:@"userprofile_proposegame_cell"]) {
//        COMMON_LOG_WITH_COMMENT([tableView cellForRowAtIndexPath:indexPath].reuseIdentifier)
//        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view]; // Not sure if alloc init works, because the tutorials say to use 'object'
//        [self.navigationController.view addSubview:HUD];
//        HUD.delegate = self;
//        [HUD showAnimated:YES whileExecutingBlock:^{
//            // Create the game
//            RA_ParseGame *game = [[RA_ParseGame alloc] initAsProposalFromMeToOpponent:self.user andNetwork:[RA_ParseNetwork rallyUsersNetwork] andDatetime:[[NSDate date] dateByAddingDays:2]];
//            [game save];
//            
//            // Send push
//            [game.network fetchIfNeeded]; // Fetch the rallyUsersNetwork
//            NSString *pushText = [NSString stringWithFormat:@"%@ is suggesting %@ %@",
//                                  [RA_ParseUser currentUser].displayName,
//                                  game.network.sport,
//                                  [game.datetime getCommonSpeechWithOnDayLong:NO dateOrdinal:NO monthLong:NO]];
//            PFPush *push = [self configurePushWithText:pushText];
//            [push sendPushInBackground];
//            
//        } completionBlock:^{
//            // Show congrats
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Congrats, that works"
//                                                            message:nil
//                                                           delegate:nil
//                                                  cancelButtonTitle:@"OK"
//                                                  otherButtonTitles:nil];
//            [alert show];
//        }];
//    }
    
    // Accept game
    else if ([[tableView cellForRowAtIndexPath:indexPath].reuseIdentifier isEqualToString:@"userprofile_acceptgame_cell"]) {
        COMMON_LOG_WITH_COMMENT([tableView cellForRowAtIndexPath:indexPath].reuseIdentifier)
        
        // Handle the cell visuals
        RA_UserProfileAcceptGameCell *cell = [self.cells valueForKey:[NSString stringWithFormat:@"%@", [indexPath description]]];
        cell.leftImage.hidden = YES; // Makes invisible
        [cell.activityWheel startAnimating];
        
        // Now we want to do all of the following: 0. Ask for a proper time, 1. Delete the gamePref object. 2. If that is successful (i.e. we got there first) then create a game object 3. Delete the news feed item
        NSDate *selectedDate = self.gamePref.dateTimePreferences[indexPath.row];
        [self.gamePref deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                COMMON_LOG_WITH_COMMENT(@"Delete successful")
                
                RA_ParseGame *newGame = [[RA_ParseGame alloc] initAsAcceptanceFromMeToOpponent:self.user
                                                                                      andSport:self.gamePref.sport
                                                                                   andDatetime:selectedDate];
                
                [newGame saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        COMMON_LOG_WITH_COMMENT(@"New game save successful")
                        
                        // Stop the wheel
                        [cell.activityWheel stopAnimating];
                        
                        COMMON_LOG_WITH_COMMENT(@"Stopped animating")
                        
                        // Send push in background
                        NSString *pushText = [NSString stringWithFormat:@"%@ has CONFIRMED your %@ game %@ at %@",
                                              [RA_ParseUser currentUser].displayName,
                                              newGame.sport,
                                              [[newGame.datetime getCommonSpeechWithOnDayLong:NO dateOrdinal:NO monthLong:NO] lowercaseString],
                                              [newGame.datetime getCommonSpeechClock]];
                        
                        COMMON_LOG_WITH_COMMENT(@"Created string")
                        
                        PFPush *push = [self configurePushWithText:pushText];
                        [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            if (succeeded) {
                                COMMON_LOG_WITH_COMMENT(@"Push send successful")
                            }
                            else {
                                COMMON_LOG_WITH_COMMENT(@"ERROR: Push send failed")
                            }
                        }];

                        // Say well done
                        COMMON_LOG_WITH_COMMENT(@"About to show alert")
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Congrats"
                                                                        message:@"You have CONFIRMED this game and can now view it in your Games Manager, found in the tab bar at the bottom of this screen."
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
                        [alert show];
                        
                        // Segue backwards
                        [self.navigationController popToRootViewControllerAnimated:YES];
                    }
                    else {
                        // TO DO throw some sort of error message and stop the activity wheel
                        [cell.activityWheel stopAnimating];
                        COMMON_LOG_WITH_COMMENT(@"ERROR: New game save failed")
                    }
                }];
            }
            else {
                // TO DO throw some sort of error message and stop the activity wheel
                [cell.activityWheel stopAnimating];
                COMMON_LOG_WITH_COMMENT(@"ERROR: Delete failed")
            }
        }];
    }
    
    else {
        COMMON_LOG_WITH_COMMENT(@"ERROR: Unexpected cell identifier")
    }
}



-(void)segueToChatroom
{
    COMMON_LOG
    
    RA_ParseChatroom *room = self.chatroom;
    ChatView *chatView = [[ChatView alloc] initWith:room.objectId];
    chatView.chatRoomObject = room;
    [self.navigationController pushViewController:chatView animated:YES];
}



-(PFPush *)configurePushWithText:(NSString *)text
{
    COMMON_LOG
    
    // Initialise our push
    PFPush *push = [[PFPush alloc] init];
    
    // Push query
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"user" equalTo:self.user];
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



// Need to cancel the background thread before dealloc, I think
-(void)dealloc
{
    COMMON_LOG
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(findChatroom) object:nil];
    // [super dealloc]; // Called automatically by ARC
}


@end



