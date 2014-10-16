//
//  RA_LadderForm.m
//  Rally
//
//  Created by Max de Vere on 19/09/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_NextGamePrefOne.h"
#import "RA_GamePrefConfig.h"
#import "RA_ParseGamePreferences.h"
#import "RA_NextGamePrefCell.h"
#import "AppConstants.h"
#import "RA_NextGamePrefCell.h"


@interface RA_NextGamePrefOne ()<UIAlertViewDelegate>
@property (nonatomic) NSArray *formCellArray;
@end


@implementation RA_NextGamePrefOne


#pragma mark - load up
// ******************** load up ********************


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Navbar
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    self.navigationItem.title = @"Your next game";
    
    // Form formatting
    self.tableView.backgroundColor = UIColorFromRGB(FORMS_DARK_RED);
    self.view.backgroundColor = UIColorFromRGB(FORMS_DARK_RED);
    self.separatorLine.backgroundColor = UIColorFromRGB(FORMS_LIGHT_RED);
    
    // Set the gamePrefConfig defaults
    [[RA_GamePrefConfig gamePrefConfig] resetToDefaults];
    
    // Set the formCellArray
    self.formCellArray = @[@[@"when_preference", @"when_preference", @"when_preference"], @[@"who_preference"]];
    
    // Reload the table
    [self.tableView reloadData];
}



#pragma mark - move to next view
// ******************** move to next view ********************


-(IBAction)setPrefButtonPushed:(UIButton *)button
{
    NSLog(@"%@ on thread %@", NSStringFromSelector(_cmd), [NSThread currentThread]);
    
    // Check valid before continuing
    if (![[RA_GamePrefConfig gamePrefConfig] validDatesAndTimes]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Something looks odd"
                                                        message:@"Two of your preferences are the same!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    // Perform segue
    [self performSegueWithIdentifier:@"goto_preferences2" sender:self];
}



#pragma mark - tableview delegate
// ******************** tableview delegate methods ********************


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.formCellArray count]; // Should be 2
}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *rowsInSection = self.formCellArray[section];
    NSInteger numberOfRows = [rowsInSection count];
    return numberOfRows;
}



-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title;
    switch (section) {
        case 0:
            title = @"Timeslot preferences (up to three)";
            break;
        case 1:
            title = @"Who would you like to challenge?";
            break;
        default:
            title = @"Hmm...";
            NSLog(@"ERROR in %@, %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
            break;
    }
    return title;
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            // 'When' preference
            return 84.0;
            break;
        case 1:
            return [self getWhoCellHeight:indexPath];
            break;
        default:
            NSLog(@"ERROR in %@, %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
            return 44.0;
            break;
    }
}


- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Text Color
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[UIColor whiteColor]];
}



-(RA_NextGamePrefCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    COMMON_LOG
    
    if (!self.formCellArray) {
        // Case included just in case
        COMMON_LOG_WITH_COMMENT(@"ERROR: No formCellArray")
        return nil;
    }
    else {
        NSString *reuseIdentifier = self.formCellArray[indexPath.section][indexPath.row];
        RA_NextGamePrefCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
        if ([reuseIdentifier isEqualToString:@"when_preference"]) {
            
            // Set whether cell is first, second or third preference
            NSArray *preferenceStrings = @[@"first", @"second", @"third"];
            cell.preferenceKey = preferenceStrings[indexPath.row];
            NSArray *preferenceOutput = @[@"First", @"Second", @"Third"];
            cell.prefLabel.text = preferenceOutput[indexPath.row];
            
            // First pref cell is configured a bit differently
            if ([cell.preferenceKey isEqualToString:@"first"]) {
                cell.preferenceSwitch.enabled = NO;
                cell.preferenceSwitch.hidden = YES;
            }
        }
        
        cell.topViewOne = self;
        [cell updateCell];
        return cell;
    }
}



#pragma mark - special inter-cell behaviour
// ******************** special inter-cell behaviour ********************


-(void)turnOnPrefTwo
{
    [RA_GamePrefConfig gamePrefConfig].secondPreference.isEnabled = YES;
    RA_NextGamePrefCell *cell = (RA_NextGamePrefCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    [cell updateCell];
}




-(void)turnOffPrefThree
{
    [RA_GamePrefConfig gamePrefConfig].thirdPreference.isEnabled = NO;
    RA_NextGamePrefCell *cell = (RA_NextGamePrefCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    [cell updateCell];
}



-(CGFloat)getWhoCellHeight:(NSIndexPath *)indexPath
{
    CGFloat textViewWidth = 285.0;
    UITextView *textView = [UITextView new];
    NSString *whoToPlay = [RA_GamePrefConfig gamePrefConfig].playWho;
    if ([whoToPlay isEqualToString:@"Everyone"]) {
        textView.text = EVERYONE_SELECTED_TO_PLAY;
    }
    else{
        textView.text = SIMILARLY_RANKED_TO_PLAY;
    }
    
    CGSize textViewSize = [textView sizeThatFits:CGSizeMake(textViewWidth,FLT_MAX)];
    NSLog(@"%f",textViewSize.height);
    return textViewSize.height + 80.0;

}



@end



