//
//  RA_LoginLogout.m
//  Rally
//
//  Created by Max de Vere on 03/09/2014.
//  Copyright (c) 2014 NA. All rights reserved.
//

#import "RA_FacebookLoginComms.h"
#import "AppConstants.h"
#import "UIImage+ProfilePicHandling.h"
#import "RA_ParseUser.h"
#import "RA_ParseNetwork.h"


@interface RA_FacebookLoginComms ()

@property (strong, nonatomic) NSMutableData *fbImageData;

@end


@implementation RA_FacebookLoginComms


#pragma mark - singleton boilerplate
// ******************** singleton boilerplate ********************

+(instancetype)commsManager
{
    static RA_FacebookLoginComms *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}



-(instancetype)init
{
    COMMON_LOG
    self.fbImageData = [NSMutableData new];
    return self;
}



#pragma mark - login kick-off
// ******************** login kick-off ********************

-(void)loginWithFacebook:(id<RA_LoginLogoutDelegate>)delegate
{
    // Clear the Parse cache. Unrelated to the login process
    // Doing this just to prevent any confusion later on
    // Also helps for testing i.e. I can logout then back in again, and start running queries afresh
    [PFQuery clearAllCachedResults];
    NSLog(@"%@, %@, Cleared the Parse cache", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    // Set permissions required from the facebook user account
    NSArray *permissionsArray = @[ @"public_profile", @"email" ];
    
    // Login user using Facebook
    // This creates (and uploads to Parse) the PFUser, but with not much info from Facebook yet
    [PFFacebookUtils logInWithPermissions:permissionsArray
                                    block:^(PFUser *user, NSError *error) {
        if (!user) {
            
            // Delegate back to the view controller
            if ([delegate respondsToSelector:@selector(didLoginWithFacebook:withError:)])
                [delegate didLoginWithFacebook:NO withError:error];
            
        } else {
            
            RA_ParseUser *thisUser = (RA_ParseUser *)user;
            
            if (thisUser.isNew) {
                
                NSLog(@"Facebook user logged in - new user");
                
                // Now download from Facebook (and upload to Parse) the stuff we need.
                [self newUserProcedure:thisUser];
            
            } else {
                
                NSLog(@"Facebook user logged in - existing user");
                
                // Procedure for existing users
                [self existingUserProcedure:thisUser];

            }
            
            // Delegate back to the view controller
            if ([delegate respondsToSelector:@selector(didLoginWithFacebook:withError:)])
                [delegate didLoginWithFacebook:YES withError:nil];
            
        }
    }];
}



-(void)newUserProcedure:(RA_ParseUser *)user
{
    [FBRequestConnection startForMeWithCompletionHandler:
     ^(FBRequestConnection *connection, id result, NSError *error) {
         if (!error) {
             
             // Get and start saving the user to Parse (includes triggering the profile pic connection)
             RA_ParseNetwork *allRallyUsersNetwork = [RA_ParseNetwork objectWithoutDataWithObjectId:@"E2wWMqQTtY"];
             RA_ParseNetwork *allRallySquashNetwork = [RA_ParseNetwork objectWithoutDataWithObjectId:@"Utu5aSM2ke"];
             RA_ParseNetwork *allRallyTennisNetwork = [RA_ParseNetwork objectWithoutDataWithObjectId:@"Y2IHHx2uu4"];
             user.networkMemberships = [NSMutableArray arrayWithObjects:allRallyUsersNetwork,allRallySquashNetwork,allRallyTennisNetwork,nil];
             
             user.madeShoutBefore = NO;
             user.madeLeagueRequestBefore = NO;
             user.aboutMe = @"New to this 'Rally' malarkey...";
             
             // Get the FB data and save to the user
             NSDictionary *userData = (NSDictionary *)result;
             [self saveFBUserDataToParse:userData];
         }
         else {
             NSLog(@"newUserProcedure: FBRequest returns error: %@", error);
         }
     }];
}



// existingUserProcedure currently very similar the same as newUserProcedure
// Demonstrates slightly different method of executing the same procedure...
-(void)existingUserProcedure:(RA_ParseUser *)user
{
    FBRequest *request = [FBRequest requestForMe];
    
    [request startWithCompletionHandler:
     ^(FBRequestConnection *connection, id result, NSError *error) {
         
         if (!error) {
             
             // Ensure people have the "All Rally Users" network in their profiles TO DO
             if (!user.networkMemberships) {
                 RA_ParseNetwork *allRallyUsersNetwork = [RA_ParseNetwork objectWithoutDataWithObjectId:@"E2wWMqQTtY"];
                 RA_ParseNetwork *allRallySquashNetwork = [RA_ParseNetwork objectWithoutDataWithObjectId:@"Utu5aSM2ke"];
                 RA_ParseNetwork *allRallyTennisNetwork = [RA_ParseNetwork objectWithoutDataWithObjectId:@"Y2IHHx2uu4"];
                 user.networkMemberships = [NSMutableArray arrayWithObjects:allRallyUsersNetwork,allRallySquashNetwork,allRallyTennisNetwork,nil];
             }
             
             // Get the latest FB data and save to the user
             NSDictionary *userData = (NSDictionary *)result;
             [self saveFBUserDataToParse:userData];
         }
         else {
             NSString *logComment = [NSString stringWithFormat:@"ERROR: %@", error];
             COMMON_LOG_WITH_COMMENT(logComment)
         }
     }];
}



-(void)saveFBUserDataToParse:(NSDictionary *)userData
{
    // Example Facebook result to [FBRequestConnection startForMeWithCompletionHandler...]
    //
    //    2014-09-03 14:09:30.843 Rally[2208:60b] user info: {
    //        birthday = "11/26/1987";
    //        email = "mjf.devere@gmail.com";
    //        "first_name" = Max;
    //        gender = male;
    //        id = 10100914196974099;
    //        "last_name" = "de Vere";
    //        link = "https://www.facebook.com/app_scoped_user_id/10100914196974099/";
    //        locale = "en_GB";
    //        name = "Max de Vere";
    //        timezone = 1;
    //        "updated_time" = "2014-03-21T23:53:14+0000";
    //        verified = 1;
    //    }
    
    
    // We go item-by-item, else there is a risk that it just stops without returning an error
    RA_ParseUser *cUser = [RA_ParseUser currentUser];
    
    if(userData[@"id"]) {
        cUser.facebookID = userData[@"id"];
    }
    
    if(userData[@"email"]) {
        cUser.email = userData[@"email"];
    }
    
    if(userData[@"first_name"]) {
        cUser.firstName = userData[@"first_name"];
        cUser.displayName = userData[@"first_name"];
    }
    
    if(userData[@"last_name"]) {
        cUser.lastName = userData[@"last_name"];
    }
    
    if(userData[@"first_name"] && userData[@"last_name"]) {
        cUser.displayName = [NSString stringWithFormat:@"%@ %@.",
                                       userData[@"first_name"],
                                       [userData[@"last_name"] substringToIndex:1]];
    }
    
    if(userData[@"gender"]) {
        cUser.gender = userData[@"gender"];
    }
    
    if(userData[@"link"]) {
        cUser.facebookLink = userData[@"link"];
    }
    
    // Save these lightweight details to Parse
    [cUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            
            NSLog(@"%@, %@, saveInBackground SUCCESS", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
            
            // Now the more heavyweight task
            // Download the user's facebook profile picture
            [self startDownloadingProfilePicForFBUser:cUser];
            
        }
        else {
            NSLog(@"%@, %@, saveInBackground ERROR: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), error);
        }
    }];
}



#pragma mark - profile image
// ******************** profile image ********************


-(void)startDownloadingProfilePicForFBUser:(RA_ParseUser *)user
{
    NSLog(@"%@, %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    if (user.facebookID) {
        NSLog(@"%@, %@, user.facebookID found", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        
        // Define the image URL
        NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=640", user.facebookID]];
        
        // Define the request. What's with the Cache policy?
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:pictureURL
                                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                              timeoutInterval:2.0f];
        
        // Run network request asynchronously
        // Note this currently does not have to complete for the segue to trigger
        NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
        
        if (!urlConnection) {
            NSLog(@"%@, %@, ERROR: urlConnection failed", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        }
    }
    
    else {
        NSLog(@"%@, %@, ERROR: user.facebookID not found", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    }
    
}



-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"[%@, %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    // This method is called when the server has determined that it
    // has enough information to create the NSURLResponse object.
    
    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    
    // receivedData is an instance variable declared elsewhere.
    
    [self.fbImageData setLength:0];
}



-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"[%@, %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    // Append the new data to receivedData.
    // self.imageData is an instance variable declared elsewhere.
    [self.fbImageData appendData:data];
    NSLog(@"[%@, %@] self.fbImageData size: %lu", NSStringFromClass([self class]), NSStringFromSelector(_cmd), (unsigned long)[self.fbImageData length]);
}



-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"connectionDidFinishLoading");
    // Once the profile picture is dowloaded from facebook, we create a profile pics of various sizes.
    
    // Process the image and convert into PFFile
    UIImage *facebookPic = [UIImage imageWithData:self.fbImageData];
    PFFile *largePicFile = [facebookPic getFileResizedAndCropped:PF_USER_PIC_LARGE_SIZE];
    PFFile *mediumPicFile = [facebookPic getFileResizedAndCropped:PF_USER_PIC_MEDIUM_SIZE];
    PFFile *smallPicFile = [facebookPic getFileResizedAndCropped:PF_USER_PIC_SMALL_SIZE];
    
    // Save to the cUser
    RA_ParseUser *cUser = [RA_ParseUser currentUser];
    cUser.facebookImage = [PFFile fileWithData:self.fbImageData];
    cUser.profilePicLarge = largePicFile;
    cUser.profilePicMedium = mediumPicFile;
    cUser.profilePicSmall = smallPicFile;
    
    // Upload to Parse
    [cUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"[%@, %@] saveInBackground SUCCESS", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        }
        else{
            NSLog(@"[%@, %@] ERROR: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), error);
        }
    }];
}



@end

