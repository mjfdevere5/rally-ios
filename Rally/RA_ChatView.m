//
//  RA_ChatView.m
//  Rally
//
//  Created by Max de Vere on 22/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_ChatView.h"
#import "ChatConstants.h"
#import "RA_ParseRecentChat.h"
#import "NSString+StringsUtils.h"


@interface RA_ChatView ()
@property (strong, nonatomic) RA_ParseChatroom *chatroom;
@property (strong, nonatomic) RA_ParseUser *opponent;
@end


@implementation RA_ChatView

-(id)initWithChatroom:(RA_ParseChatroom *)chatroom
{
    self = [super initWith:chatroom.objectId];
    if (self) {
        self.chatroom = chatroom;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTabBarVisible:NO animated:YES];
}

#pragma mark - Tab bar
// ******************** Tab bar ********************

// Max added this
- (void)setTabBarVisible:(BOOL)visible animated:(BOOL)animated
{ COMMON_LOG
    
    // Bail if the current state matches the desired state
    if ([self tabBarIsVisible] == visible) {
        COMMON_LOG_WITH_COMMENT(@"Nothing to do")
        return;
    }
    
    // Get a frame calculation ready
    CGRect frame = self.tabBarController.tabBar.frame;
    CGFloat height = frame.size.height;
    CGFloat offsetY = (visible)? -height : height;
    
    // Zero duration means no animation
    CGFloat duration = (animated)? 0.3 : 0.0;
    
    [UIView animateWithDuration:duration animations:^{
        self.tabBarController.tabBar.frame = CGRectOffset(frame, 0, offsetY);
    }];
}

- (BOOL)tabBarIsVisible
{
    NSLog(@"self.tabBarController.tabBar.frame.origin.y = %f", self.tabBarController.tabBar.frame.origin.y);
    NSLog(@"CGRectGetMaxY(self.view.frame) = %f", CGRectGetMaxY(self.view.frame));
    BOOL isVisible = self.tabBarController.tabBar.frame.origin.y < CGRectGetMaxY(self.view.frame);
    BOOL exceptionSix = self.tabBarController.tabBar.frame.origin.y == 618.0;
    BOOL exceptionSixPlus = self.tabBarController.tabBar.frame.origin.y == 687.0;
    return (isVisible || exceptionSix || exceptionSixPlus);
}


#pragma mark - Overrides
// ******************** Overrides ********************

- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date
{
    [super didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date];
    
    [self performSelectorInBackground:@selector(additionalActionsWithText:) withObject:text];
}


#pragma mark - Push notifications
// ******************** Push notifications ********************

-(void)additionalActionsWithText:text // (BACKGROUND ONLY)
{
    // Get the opponent
    [self.chatroom fetchIfNeeded];
    RA_ParseUser *user1 = self.chatroom.user1;
    RA_ParseUser *user2 = self.chatroom.user2;
    self.opponent = ([[RA_ParseUser currentUser].objectId isEqualToString:user1.objectId]) ? user2 : user1;
    [self.opponent fetchIfNeeded];
    [self sendPushToOpponentWithText:text];
    [self updateRecentChatsWithText:text];
}

-(void)sendPushToOpponentWithText:(NSString *)text
{
    COMMON_LOG
    
    NSLog(@"%@ %@ %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd),[NSThread currentThread]);
    
    // Initialise our push
    PFPush *push = [[PFPush alloc] init];
    
    // Push query
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"user" equalTo:[self opponent]];
    [push setQuery:pushQuery];
    
    // Push config
    NSString *pushString = [NSString stringWithFormat:@"%@: %@", [RA_ParseUser currentUser].displayName, text];
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          pushString, @"alert",
                          @"cheering.caf", @"sound",
                          @"Increment", @"badge",
                          nil];
    [push setData:data];
    
    // Send
    [push sendPushInBackground];
}

-(void)updateRecentChatsWithText:text;
{
    [self.chatroom fetchIfNeeded];
    
    // One for my opponent
    RA_ParseRecentChat *recentChat = [RA_ParseRecentChat object];
    recentChat.user = self.opponent;
    recentChat.fromUser = [RA_ParseUser currentUser];
    recentChat.dateUpdated = [NSDate date];
    recentChat.messagePreview = [text getMessagePreview];
    recentChat.chatroom = self.chatroom;
    recentChat.markAsSeen = NO;
    
    // ... and one for me
    RA_ParseRecentChat *recentChatTwo = [RA_ParseRecentChat object];
    recentChatTwo.user = [RA_ParseUser currentUser];
    recentChatTwo.fromUser = self.opponent;
    recentChatTwo.dateUpdated = [NSDate date];
    recentChatTwo.messagePreview = [text getMessagePreview];
    recentChatTwo.chatroom = self.chatroom;
    recentChatTwo.markAsSeen = YES;
    
    // Save these
    [PFObject saveAllInBackground:@[recentChat, recentChatTwo] block:^(BOOL succeeded, NSError *error) {
        if (error) {
            COMMON_LOG_WITH_COMMENT(@"ERROR")
        }
    }];
}



#pragma mark - Dealloc/ disappear
// ******************** Dealloc/ disappear ********************

- (void)viewWillDisappear:(BOOL)animated
{ COMMON_LOG
    [super viewWillDisappear:animated];
    [self setTabBarVisible:YES animated:YES];
}




@end
