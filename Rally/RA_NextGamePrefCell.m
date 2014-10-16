//
//  RA_LadderFormCell.m
//  Rally
//
//  Created by Max de Vere on 19/09/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_NextGamePrefCell.h"
#import "RA_GamePrefConfig.h"
#import "NSDate+CoolStrings.h"
#import "AppConstants.h"


@interface RA_NextGamePrefCell()
@end


@implementation RA_NextGamePrefCell

static void * const MyClassKVOContext = (void*)&MyClassKVOContext;


#pragma mark - load up
// ******************** load up ********************



- (void)awakeFromNib
{
    NSLog(@"%@ on thread %@", NSStringFromSelector(_cmd), [NSThread currentThread]);
    
    // Date stepper config
    self.dateStepper.minimumValue = 0.0;
    self.dateStepper.maximumValue = [[RA_GamePrefConfig gamePrefConfig].possibleDates count] - 1.0;
    self.dateStepper.stepValue = 1.0;
    self.dateStepper.value = 0.0;
    
    // Time stepper config
    self.timeStepper.minimumValue = 0.0;
    self.timeStepper.maximumValue = [[RA_GamePrefConfig gamePrefConfig].possibleTimes count] - 1.0;
    self.timeStepper.stepValue = 1.0;
    self.timeStepper.value = 0.0;
    
    // Register to be notified of changes to location
    [self registerAsListener];
    
    // Start up that loadingCircle, as we won't have a location quite yet
    [self.loadingCircle startAnimating];
    
    // Standard formatting
    self.preferenceSwitch.onTintColor = [UIColor whiteColor];
    self.courtBookingSwitch.onTintColor = [UIColor whiteColor];
    self.backgroundColor = UIColorFromRGB(FORMS_LIGHT_RED);
    
    self.whoToPlayBlurb.textColor = [UIColor whiteColor];
    self.whoToPlayBlurb.backgroundColor = UIColorFromRGB(FORMS_LIGHT_RED);
    self.whoControl.tintColor = [UIColor whiteColor];
    
    // Location preferences formatting
    
    self.comingFromStaticLabel.textColor = [UIColor whiteColor];
    self.locationOutlet.textColor = [UIColor whiteColor];
    self.loadingCircle.tintColor = [UIColor whiteColor];
    
    // Additional info config
    self.additionalInfoTextView.text = ADDITIONAL_INFO_DEFAULT;
    [self.additionalInfoTextView setFont:[UIFont italicSystemFontOfSize:14.0]];
    self.additionalInfoTextView.textColor = [UIColor whiteColor];
    
    
}



-(void)viewDidLayoutSubviews
{
    // Set the textView height
    self.courtBookingSpiel.translatesAutoresizingMaskIntoConstraints = YES;
    CGFloat textViewWidth = self.courtBookingSpiel.frame.size.width;
    CGSize textViewSize = [self.courtBookingSpiel sizeThatFits:CGSizeMake(textViewWidth, FLT_MAX)];
    [self.courtBookingSpiel setFrame:CGRectMake(self.courtBookingSpiel.frame.origin.x,
                                                self.courtBookingSpiel.frame.origin.y,
                                                textViewWidth,
                                                textViewSize.height)];
    [self.courtBookingSpiel reloadInputViews];
}



#pragma mark - update cell view
// ******************** update cell view ********************

-(void)updateCell
{
    // When
    if ([self.reuseIdentifier isEqualToString:@"when_preference"]) {
        RA_DateAndTimePreference *pref = [[RA_GamePrefConfig gamePrefConfig].preferencesDict objectForKey:self.preferenceKey];
        self.dateLabel.text = [pref getDateString];
        self.timeLabel.text = [pref getTimeString];
        BOOL enabled = pref.isEnabled;
        [self updateWhenCellFormatting:enabled];
    }
    
    if ([self.reuseIdentifier isEqualToString:@"who_preference"]) {
        
        NSInteger selectedSegment = self.whoControl.selectedSegmentIndex;
        
        if (selectedSegment == 0) {
            //toggle the correct view to be visible
            //[self.whoToPlayBlurb setScrollEnabled:YES];
            self.whoToPlayBlurb.text = EVERYONE_SELECTED_TO_PLAY;
//            [self.whoToPlayBlurb sizeToFit];
//            [self.whoToPlayBlurb setScrollEnabled:NO];
        }
        
        else{
            //toggle the correct view to be visible
            //[self.whoToPlayBlurb setScrollEnabled:YES];
            self.whoToPlayBlurb.text = SIMILARLY_RANKED_TO_PLAY;
//            [self.whoToPlayBlurb sizeToFit];
//            [self.whoToPlayBlurb setScrollEnabled:NO];
        }
    }
        

    
    if ([self.reuseIdentifier isEqualToString: @"location_pref"])
    {
        [self updateLocationOutletAndWheel];
    }

    
    // Booking help
    if ([self.reuseIdentifier isEqualToString:@"court_booking_preference"]) {
        BOOL bookingHelpWanted = [RA_GamePrefConfig gamePrefConfig].bookingHelpWanted;
        if (bookingHelpWanted) {
            self.courtBookingHelpBlurb.text = @"Court booking ON";
            [self.courtBookingHelpBlurb setFont:[UIFont boldSystemFontOfSize:16.0]];
            self.courtBookingHelpBlurb.textColor = [UIColor whiteColor];
            
            self.courtBookingSpiel.text = BOOKING_HELP_ON_SPIEL;
            [self.courtBookingSpiel setFont:[UIFont systemFontOfSize:14.0]];
            self.courtBookingSpiel.textColor = [UIColor whiteColor];
        }
        else {
            self.courtBookingHelpBlurb.text = @"Court booking OFF";
            [self.courtBookingHelpBlurb setFont:[UIFont systemFontOfSize:16.0]];
            self.courtBookingHelpBlurb.textColor = [UIColor whiteColor];
            
            self.courtBookingSpiel.text = BOOKING_HELP_OFF_SPIEL;
            [self.courtBookingSpiel setFont:[UIFont italicSystemFontOfSize:14.0]];
            self.courtBookingSpiel.textColor = [UIColor whiteColor];
        }
    }
    if ([self.reuseIdentifier isEqualToString:@"who_preference"]) {
        self.whoToPlayBlurb.textColor = [UIColor whiteColor];
        [self.whoToPlayBlurb setFont:[UIFont italicSystemFontOfSize:14.0]];
    }
    
    // Additional info
    if ([self.reuseIdentifier isEqualToString:@"additional_info"]) {
        self.additionalInfoTextView.text = [RA_GamePrefConfig gamePrefConfig].additionalInfo;
    }
}



-(void)updateWhenCellFormatting:(BOOL)enabled
{
    if (enabled) {
        self.dateLabel.textColor = [UIColor whiteColor];
        self.timeLabel.textColor = [UIColor whiteColor];
        
        self.dateStepper.tintColor = [UIColor whiteColor];
        self.timeStepper.tintColor = [UIColor whiteColor];
        
        self.dateStepper.enabled = YES;
        self.timeStepper.enabled = YES;
        
        [self.preferenceSwitch setOn:YES animated:YES];
    }
    else {
        self.dateLabel.textColor = UIColorFromRGB(FORMS_LIGHT_RED);
        self.timeLabel.textColor = UIColorFromRGB(FORMS_LIGHT_RED);
        
        self.dateStepper.tintColor = UIColorFromRGB(FORMS_LIGHT_RED);
        self.timeStepper.tintColor = UIColorFromRGB(FORMS_LIGHT_RED);
        
        self.dateStepper.enabled = NO;
        self.timeStepper.enabled = NO;
        
        [self.preferenceSwitch setOn:NO animated:YES];
    }
}



#pragma mark - user control
// ******************** user control ********************


- (IBAction)prefToggled:(UISwitch *)sender
{
    RA_DateAndTimePreference *pref = [[RA_GamePrefConfig gamePrefConfig].preferencesDict objectForKey:self.preferenceKey];
    pref.isEnabled = [sender isOn];
    
    if (pref.isEnabled) {
        [self.topViewOne turnOnPrefTwo];
    }
    else {
        [self.topViewOne turnOffPrefThree];
    }
    
    [self updateCell];
}



-(void)dateChanged:(UIStepper *)sender
{
    RA_DateAndTimePreference *pref = [[RA_GamePrefConfig gamePrefConfig].preferencesDict objectForKey:self.preferenceKey];
    pref.date = [RA_GamePrefConfig gamePrefConfig].possibleDates[(int)[sender value]];
    
    [self updateCell];
}



-(void)timeChanged:(UIStepper *)sender
{
    RA_DateAndTimePreference *pref = [[RA_GamePrefConfig gamePrefConfig].preferencesDict objectForKey:self.preferenceKey];
    pref.time = [RA_GamePrefConfig gamePrefConfig].possibleTimes[(int)[sender value]];
    
    [self updateCell];
}



- (IBAction)courtBookingHelpSwitchChanged:(UISwitch *)sender
{
    [RA_GamePrefConfig gamePrefConfig].bookingHelpWanted = [sender isOn];
    [self.topViewTwo.tableView reloadData];
}



-(IBAction)whoToPlay:(UISegmentedControl *)sender
{
    NSInteger selectedSegment = self.whoControl.selectedSegmentIndex;
    
    if (selectedSegment == 0) {
        //toggle the correct view to be visible
        [RA_GamePrefConfig gamePrefConfig].playWho = @"Everyone";
    }
    else{
        //toggle the correct view to be visible
        [RA_GamePrefConfig gamePrefConfig].playWho = @"Similarly ranked";
    }

    [self.topViewOne.tableView reloadData];
}



-(void)registerAsListener
{
    if ([self.reuseIdentifier isEqualToString:@"location_pref"])
    {
        // Used to update location cell outlet
        [[RA_GamePrefConfig gamePrefConfig] addObserver:self
                                               forKeyPath:@"ladderLocationPlacemark"
                                                  options:NSKeyValueObservingOptionNew
                                                  context:MyClassKVOContext];
        NSLog(@"Registered for ladderLocationPlacemark");
    }
}



-(void)dealloc
{
    if ([self.reuseIdentifier isEqualToString:@"location_pref"])
    {
        [[RA_GamePrefConfig gamePrefConfig] removeObserver:self
                                                  forKeyPath:@"ladderLocationPlacemark"
                                                     context:MyClassKVOContext];
    }
    
}



-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@"observeValueForKeyPath called for: %@", keyPath);
    
    if ([keyPath isEqualToString:@"ladderLocationPlacemark"])
    {
        [self updateLocationOutletAndWheel];
    }
    
    else
        NSLog(@"observeValueForKeyPath error");
}



-(void)updateLocationOutletAndWheel
{
    if (![RA_GamePrefConfig gamePrefConfig].ladderLocationPlacemark.subLocality)
    {
        NSLog(@"updateLocationOutletAndWheel: did not find a value for ladderLocationPlacemark.subLocality");
        
        // Make user think we're still looking for a location, even if we have one
        // Maybe this is a bad strategy
        self.locationOutlet.text = @"";
        [self.loadingCircle startAnimating];
    }
    
    else
    {
        
        [self.loadingCircle stopAnimating];
        [self.loadingCircle hidesWhenStopped];

        
        
        // Convenience variable. Note this is a pointer, will it change as shoutLocationPlacemark changes? (We want it to anyway)
        CLPlacemark *placemark = [RA_GamePrefConfig gamePrefConfig].ladderLocationPlacemark;
        NSString *locationPrettyString = placemark.subLocality;
        
        // Set the outlet
        self.locationOutlet.text = locationPrettyString;
        
        // Update singleton
        [RA_GamePrefConfig gamePrefConfig].ladderLocationString = locationPrettyString;
    }
}






@end


