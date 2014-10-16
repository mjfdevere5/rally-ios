//
// Copyright (c) 2014 Related Code - http://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Parse/Parse.h>
#import "ProgressHUD.h"
#import "AppConstants.h"
#import "ChatView.h"
#import "RA_TabBar.h"
#import "RA_ParseRecentChat.h"
#import "NSString+StringsUtils.h"


@interface ChatView()
{
	NSTimer *timer;
	BOOL isLoading;

	NSString *chatroomId;

	NSMutableArray *users;
	NSMutableArray *messages;
	NSMutableDictionary *avatars;

	UIImageView *outgoingBubbleImageView;
	UIImageView *incomingBubbleImageView;
}


@end



@implementation ChatView



- (id)initWith:(NSString *)chatroomId_
{
	self = [super init];
	chatroomId = chatroomId_;
	return self;
}


// Cool tab bar toggle that I don't need
// Max added this
- (void)setTabBarVisible:(BOOL)visible animated:(BOOL)animated
{
    COMMON_LOG
    
    // Bail if the current state matches the desired state
    if ([self tabBarIsVisible] == visible) {
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
// Know the current state
- (BOOL)tabBarIsVisible {
    return self.tabBarController.tabBar.frame.origin.y < CGRectGetMaxY(self.view.frame);
}



- (void)viewDidLoad
{
    COMMON_LOG
    
	[super viewDidLoad];
	self.title = @"Chat";
    
    COMMON_LOG_WITH_COMMENT(@"Set title")
    
    // Hide the tab bar so we can see the text input
    [self setTabBarVisible:NO animated:YES];
    
    COMMON_LOG_WITH_COMMENT(@"Set tabbar invisible")

	users = [[NSMutableArray alloc] init];
	messages = [[NSMutableArray alloc] init];
	avatars = [[NSMutableDictionary alloc] init];

	self.sender = [RA_ParseUser currentUser].objectId;

	outgoingBubbleImageView = [JSQMessagesBubbleImageFactory outgoingMessageBubbleImageViewWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
	incomingBubbleImageView = [JSQMessagesBubbleImageFactory incomingMessageBubbleImageViewWithColor:[UIColor jsq_messageBubbleGreenColor]];

	isLoading = NO;
    
	[self loadMessages];
	timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(loadMessages) userInfo:nil repeats:YES];
    
    COMMON_LOG_WITH_COMMENT(@"End")
}



- (void)viewDidAppear:(BOOL)animated
{
    COMMON_LOG
    
	[super viewDidAppear:animated];
	self.collectionView.collectionViewLayout.springinessEnabled = YES;
}



- (void)viewWillDisappear:(BOOL)animated
{
    COMMON_LOG
    
	[super viewWillDisappear:animated];
    [self setTabBarVisible:YES animated:YES];
	[timer invalidate];
}



- (void)loadMessages
{
    COMMON_LOG
    
	if (isLoading == NO)
	{
		isLoading = YES;
		JSQMessage *message_last = [messages lastObject];
        
		PFQuery *query = [PFQuery queryWithClassName:PF_CHAT_CLASS_NAME];
		[query whereKey:PF_CHAT_CHATROOM equalTo:chatroomId];
		if (message_last != nil) [query whereKey:PF_CHAT_CREATEDAT greaterThan:message_last.date];
		[query includeKey:PF_CHAT_USER];
		[query orderByAscending:PF_CHAT_CREATEDAT];
        query.limit = 15;
		[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
         {
             if (error == nil)
             {
                 NSLog(@"loadMessages: number of objects found: %lu", (unsigned long)[objects count]);
                 for (PFObject *object in objects)
                 {
                     RA_ParseUser *user = object[PF_CHAT_USER];
                     [users addObject:user];
                     
                     JSQMessage *message = [[JSQMessage alloc] initWithText:object[PF_CHAT_TEXT] sender:user.objectId date:object.createdAt];
                     [messages addObject:message];
                 }
                 if ([objects count] != 0) [self finishReceivingMessage];
             }
             else [ProgressHUD showError:@"Network error."];
             isLoading = NO;
         }];
    }
}



#pragma mark -
#pragma mark - JSQMessagesViewController method overrides


- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text sender:(NSString *)sender date:(NSDate *)date
{
    COMMON_LOG
    
    // Upload chat object
	PFObject *object = [PFObject objectWithClassName:PF_CHAT_CLASS_NAME];
	object[PF_CHAT_CHATROOM] = chatroomId;
	object[PF_CHAT_USER] = [RA_ParseUser currentUser];
	object[PF_CHAT_TEXT] = text;
	[object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
	{
		if (error == nil)
		{
			[JSQSystemSoundPlayer jsq_playMessageSentSound];
			[self loadMessages];
		}
		else [ProgressHUD showError:@"Network error"];
	}];
    
    [self saveMessageObjectWithText:text andDate:date];
    [self performSelectorInBackground:@selector(sendPushToOpponentWithText:) withObject:text];
	[self finishSendingMessage];
}



// Max added this
-(void)opponentIfNeeded
{
    COMMON_LOG
    
    [self.chatRoomObject fetchIfNeeded];
    RA_ParseUser *user1 = self.chatRoomObject.user1;
    RA_ParseUser *user2 = self.chatRoomObject.user2;
    self.opponent = ([[RA_ParseUser currentUser].objectId isEqualToString:user1.objectId]) ? user2 : user1;
    NSLog(@"cUser.objectId: %@", [RA_ParseUser currentUser].objectId);
    NSLog(@"user1.objectId: %@", user1.objectId);
    NSLog(@"user2.objectId: %@", user2.objectId);
    NSLog(@"Selected objectId: %@", self.opponent.objectId);
    
    [self.opponent fetchIfNeeded];
}



// Max added this
-(void)sendPushToOpponentWithText:(NSString *)text
{
    COMMON_LOG
    
    NSLog(@"%@ %@ %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd),[NSThread currentThread]);

    // Initialise our push
    PFPush *push = [[PFPush alloc] init];
    
    // Push query
    PFQuery *pushQuery = [PFInstallation query];
    [self opponentIfNeeded];
    [pushQuery whereKey:@"user" equalTo:self.opponent];
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



// Max added this method and called it in the above method
-(void)saveMessageObjectWithText:(NSString *)text andDate:(NSDate *)date
{
    COMMON_LOG
    
    // Upload RA_ParseMessageObject
    // When opponent runs a query for messages, they will only see one per chatroom
    // (and delete the older ones in the process)
    
    // Note, because of how this chatroom was coded, the only real way to get the opponent user is via the chatroomId
    [self.chatRoomObject fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (error) {
            NSLog(@"ERROR in %@, %@: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [error localizedDescription]);
        }
        else {
            NSLog(@"SUCCESS, fetched chatRoomObject in %@, %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
            RA_ParseRecentChat *message = [RA_ParseRecentChat object];
            [self opponentIfNeeded];
            message.user = self.opponent;
            message.dateUpdated = date;
            message.markAsSeen = NO;
            message.fromName = [RA_ParseUser currentUser].displayName;
            message.messagePreview = [text getMessagePreview];
            message.fromUser = [RA_ParseUser currentUser];
            message.chatroomId = chatroomId;
            message.chatroom = self.chatRoomObject;
            
            [message saveEventually:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    NSLog(@"SUCCESS messageObject upload complete in %@, %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
                }
                else if (error) {
                    NSLog(@"ERROR in %@, %@, saveEventually: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [error localizedDescription]);
                }
            }];
        }
    }];
}



- (void)didPressAccessoryButton:(UIButton *)sender
{
    COMMON_LOG
    
	NSLog(@"didPressAccessoryButton");
}



#pragma mark -
#pragma mark - JSQMessages CollectionView DataSource


- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
	return [messages objectAtIndex:indexPath.item];
}



- (UIImageView *)collectionView:(JSQMessagesCollectionView *)collectionView bubbleImageViewForItemAtIndexPath:(NSIndexPath *)indexPath
{
	JSQMessage *message = [messages objectAtIndex:indexPath.item];
	if ([[message sender] isEqualToString:self.sender])
	{
		return [[UIImageView alloc] initWithImage:outgoingBubbleImageView.image highlightedImage:outgoingBubbleImageView.highlightedImage];
	}
	else return [[UIImageView alloc] initWithImage:incomingBubbleImageView.image highlightedImage:incomingBubbleImageView.highlightedImage];
}



/* Max has commented out most of this */

- (UIImageView *)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageViewForItemAtIndexPath:(NSIndexPath *)indexPath
{
//	RA_ParseUser *user = [users objectAtIndex:indexPath.item];
//
//	UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blank_avatar"]];
//	if (avatars[user.objectId] == nil)
//	{
//		PFFile *filePicture = user[PF_USER_THUMBNAIL];
//		[filePicture getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error)
//		{
//			if (error == nil)
//			{
//				avatars[user.objectId] = [UIImage imageWithData:imageData];
//				[imageView setImage:avatars[user.objectId]];
//			}
//		}];
//	}
//	else [imageView setImage:avatars[user.objectId]];
//
//	imageView.layer.cornerRadius = imageView.frame.size.width/2;
//	imageView.layer.masksToBounds = YES;
//
//	return imageView;
    
    return nil;
}



- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item % 3 == 0)
	{
		JSQMessage *message = [messages objectAtIndex:indexPath.item];
		return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
	}
	return nil;
}



- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [messages objectAtIndex:indexPath.item];
	if ([message.sender isEqualToString:self.sender])
	{
		return nil;
	}
	
	if (indexPath.item - 1 > 0)
	{
		JSQMessage *previousMessage = [messages objectAtIndex:indexPath.item - 1];
		if ([[previousMessage sender] isEqualToString:message.sender])
		{
			return nil;
		}
	}

	RA_ParseUser *user = [users objectAtIndex:indexPath.item];
	return [[NSAttributedString alloc] initWithString:user.displayName];
}



- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}



#pragma mark -
#pragma mark - UICollectionView DataSource



- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [messages count];
}



- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
	
	JSQMessage *message = [messages objectAtIndex:indexPath.item];
	if ([message.sender isEqualToString:self.sender])
	{
		cell.textView.textColor = [UIColor blackColor];
	}
	else
	{
		cell.textView.textColor = [UIColor whiteColor];
	}
	
	cell.textView.linkTextAttributes = @{NSForegroundColorAttributeName:cell.textView.textColor,
										 NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle | NSUnderlinePatternSolid)};
	
	return cell;
}



#pragma mark -
#pragma mark - JSQMessages collection view flow layout delegate


- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
				   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.item % 3 == 0)
	{
		return kJSQMessagesCollectionViewCellLabelHeightDefault;
	}
	return 0.0f;
}



- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
				   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
	JSQMessage *message = [messages objectAtIndex:indexPath.item];
	if ([[message sender] isEqualToString:self.sender])
	{
		return 0.0f;
	}
	
	if (indexPath.item - 1 > 0)
	{
		JSQMessage *previousMessage = [messages objectAtIndex:indexPath.item - 1];
		if ([[previousMessage sender] isEqualToString:[message sender]])
		{
			return 0.0f;
		}
	}
	return kJSQMessagesCollectionViewCellLabelHeightDefault;
}



- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
				   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
	return 0.0f;
}



- (void)collectionView:(JSQMessagesCollectionView *)collectionView
				header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
	NSLog(@"didTapLoadEarlierMessagesButton");
}

@end



