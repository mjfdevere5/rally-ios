//
//  RA_Settings.m
//  Rally
//
//  Created by Max de Vere on 12/09/2014.
//  Copyright (c) 2014 NA. All rights reserved.
//

#import "RA_Settings.h"
#import "AppConstants.h"
#import "GKImagePicker.h"
#import "UIImage+ProfilePicHandling.h"
#import "UIImage+Resize.h"


@interface RA_Settings ()<GKImagePickerDelegate, UIImagePickerControllerDelegate,
                            UINavigationControllerDelegate, UIAlertViewDelegate>

@property BOOL inEditMode;
@property (nonatomic, strong) GKImagePicker *imagePicker;

@end


@implementation RA_Settings


-(instancetype)init
{
    self = [super init];
    if (self) {
        self.inEditMode = NO;
    }
    return self;
}


- (void)viewDidLoad
{
    NSLog(@"%@ on thread %@", NSStringFromSelector(_cmd), [NSThread currentThread]);
    
    [super viewDidLoad];
    
    // Navbar
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    
    // Set the version number outlet
    self.versionOutlet.text = [NSString stringWithFormat:@"Version %@",
                               [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
    
    // Set the other outlets
    RA_ParseUser *cUser = [RA_ParseUser currentUser];
    if ([cUser isDataAvailable]) {
        [self setOutletsWithUser:cUser];
        // This may not be up-to-date, so also get the latest from the network
        // TO DO: Implement some local cache
        
    }
    else {
        // Start a HUD while we fetch the current user information
        // Probably will never be needed, as I *think* we always have the current user to hand
        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:HUD];
        HUD.delegate = self;
        [HUD showAnimated:YES whileExecutingBlock:^{
            [cUser fetch];
        } completionBlock:^{
            [self setOutletsWithUser:cUser];
        }];
    }
}



-(void)setOutletsWithUser:(RA_ParseUser *)user
{
    NSLog(@"%@ on thread %@", NSStringFromSelector(_cmd), [NSThread currentThread]);
    
    // We have the text to hand
    self.username.text = user.displayName;
    
    // But the image might take a while to download
    [self.activityWheel startAnimating];
    self.profileImage.file = user.profilePicMedium;
    [self.profileImage loadInBackground:^(UIImage *image, NSError *error) {
        if (!error) {
            [self.activityWheel stopAnimating];
        }
        else {
            NSLog(@"loadInBackground error: %@", [error localizedDescription]);
        }
    }];
}



// Very good walkthrough of dynamically-sized textviews and cells here:
// http://stackoverflow.com/a/18818036/3364933
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Annoying this will crash if you try to access reuseIdentifiers for this method
    // The reason is here: http://stackoverflow.com/a/12653203/3364933
    // Therefore we do this 'manually' using the indexPath
    
    if ([indexPath isEqual:[NSIndexPath indexPathForRow:1 inSection:1]]) {
        
        // Size of the image plus some margin above and below
        // Note that the constraints I've put in the storyboard are simply the imageView height and that it is centered vertically. Therefore the 'gap to top' and 'gap to bottom' are effectively controlled here
        float gapToTop = 8.0;
        float gapToBottom = 8.0;
        return (gapToTop + self.profileImage.frame.size.height + gapToBottom);
    }
    
    else {
        NSLog(@"Case: default cell height");
        
        // Default row height
        return 44.0;
    }
}



#pragma mark - cell actions


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%@ on thread %@", NSStringFromSelector(_cmd), [NSThread currentThread]);
    
    // Recent chats
    // Segue programmed in Storyboard
    
    // Logout
    if ([[tableView cellForRowAtIndexPath:indexPath].reuseIdentifier isEqualToString:@"logout"]) {
        NSLog(@"logout tapped");
        [self logoutTapped];
    }
    
    // Image picker
    if ([[tableView cellForRowAtIndexPath:indexPath].reuseIdentifier isEqualToString:@"profile_pic"]) {
        NSLog(@"profile_pic tapped");
        self.imagePicker = [[GKImagePicker alloc] init];
        self.imagePicker.cropSize = CGSizeMake(PF_USER_PIC_LARGE_WIDTH * 0.4, PF_USER_PIC_LARGE_HEIGHT * 0.4);
        self.imagePicker.delegate = self;
        [self presentViewController:self.imagePicker.imagePickerController animated:YES completion:nil];
    }
    
    // Support
    if ([[tableView cellForRowAtIndexPath:indexPath].reuseIdentifier isEqualToString:@"email_us"]) {
        NSLog(@"email_us tapped");
        NSString *mailtoParam = [@"mailto:mjf.devere@gmail.com?subject=[Rally support]: " stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mailtoParam]];
    }
    
    // Privacy policy
    if ([[tableView cellForRowAtIndexPath:indexPath].reuseIdentifier isEqualToString:@"privacy_policy"]) {
        NSLog(@"privacy_policy tapped");
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.iubenda.com/privacy-policy/258590"]];
    }
}



#pragma mark - logout


-(void)logoutTapped
{
    if (!self.inEditMode) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Logout", nil];
        [alert show];
        // When user taps one of these options, the delegate method below is called
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // Logout
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Logout"]) {
        [RA_ParseUser logOut];
        [self.tabBarController dismissViewControllerAnimated:YES completion:^{
            // Do nothing
        }];
    }
}


#pragma mark - image picker

- (void)imagePicker:(GKImagePicker *)imagePicker pickedImage:(UIImage *)image
{
    NSLog(@"%@ on thread %@", NSStringFromSelector(_cmd), [NSThread currentThread]);
    
    // Cancel the Parse image download (if ongoing)
    [self.profileImage.file cancel];
    
    // Some logs to understand the shape/size of the image
    NSLog(@"Image returned by GKImage Picker has dimensions: width %f by height %f",
          image.size.width, image.size.height);
    
    //  Display the selected thumbnail image
    self.profileImage.image = image;
    
    // Do some resizing
    // Note that the image picker thing actually, bizzarely, returns an image...
    // ...that may not be 320x200 (as specified when we launched the image picker)...
    // ...but sometimes a weird stretched version.
    UIImage *picLarge = [image resizedImage:PF_USER_PIC_LARGE_SIZE interpolationQuality:kCGInterpolationDefault];
    
    // Get the various sizes we require and save these to the current user
    UIImage *picMedium = [picLarge getImageResizedAndCropped:PF_USER_PIC_MEDIUM_SIZE];
    self.profileImage.image = picMedium;
    
    // Hide image picker
    [self hideImagePicker];
    
    // Save images to user
    RA_ParseUser *cUser = [RA_ParseUser currentUser];
    cUser.profilePicLarge = [PFFile fileWithData:UIImageJPEGRepresentation(picLarge, 0.9f)];
    cUser.profilePicMedium = [PFFile fileWithData:UIImageJPEGRepresentation(picMedium, 0.9f)];
    cUser.profilePicSmall = [picMedium getFileResizedAndCropped:PF_USER_PIC_SMALL_SIZE];
    [cUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) { NSLog(@"cUser saved with new pics"); }
        else { NSLog(@"cUser with new pics failed to save with error: %@", [error localizedDescription]); }
    }];
}

- (void)hideImagePicker
{
    NSLog(@"%@ on thread %@", NSStringFromSelector(_cmd), [NSThread currentThread]);
    
    [self.imagePicker.imagePickerController dismissViewControllerAnimated:YES completion:nil];
}


@end


