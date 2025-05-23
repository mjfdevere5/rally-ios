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


// Max's commentary on how what modifications he made to this stuff
// 1. Imported 'AppConstant.h' but renamed it to 'ChatConstants.h'
// 2. Replaced all instances of PFUser with RA_ParseUser and corresponding properties
// 3. Modified how the image is dealt with in - (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
// 4. Commented out the code relating to push notifications in - (void)sendMessage:(NSString *)text Picture:(UIImage *)picture
// 5. Deleted a semicolon typo in - (void)sendMessage:(NSString *)text Picture:(UIImage *)picture
// 6. Override - (void)sendMessage:(NSString *)text Picture:(UIImage *)picture in RA_ChatView
// 7. Added - (void)sendMessage:(NSString *)text Picture:(UIImage *)picture to .h, so that it can be called in the override


#import <Parse/Parse.h>
#import "ProgressHUD.h"

#import "camera.h"
#import "ChatConstants.h"
#import "messages.h"

#import "ChatView.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface ChatView()
{
	NSTimer *timer;
	BOOL isLoading;

	NSString *roomId;

	NSMutableArray *users;
	NSMutableArray *messages;
	NSMutableDictionary *avatars;

	JSQMessagesBubbleImage *outgoingBubbleImageData;
	JSQMessagesBubbleImage *incomingBubbleImageData;
	
	JSQMessagesAvatarImage *placeholderImageData;
}
@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation ChatView

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWith:(NSString *)roomId_
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super init];
	roomId = roomId_;
	return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	self.title = @"Chat";

	users = [[NSMutableArray alloc] init];
	messages = [[NSMutableArray alloc] init];
	avatars = [[NSMutableDictionary alloc] init];

	RA_ParseUser *user = [RA_ParseUser currentUser];
	self.senderId = user.objectId;
	self.senderDisplayName = user.displayName;

	JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
	outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
	incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];

	placeholderImageData = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"blank_avatar"] diameter:30.0];

	isLoading = NO;
	[self loadMessages];

	ClearMessageCounter(roomId);
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidAppear:animated];
	timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(loadMessages) userInfo:nil repeats:YES];
	self.collectionView.collectionViewLayout.springinessEnabled = YES;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewWillDisappear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewWillDisappear:animated];
	[timer invalidate];
}

#pragma mark - Backend methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadMessages
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (isLoading == NO)
	{
		isLoading = YES;
		JSQMessage *message_last = [messages lastObject];

		PFQuery *query = [PFQuery queryWithClassName:PF_CHAT_CLASS_NAME];
		[query whereKey:PF_CHAT_ROOMID equalTo:roomId];
		if (message_last != nil) [query whereKey:PF_CHAT_CREATEDAT greaterThan:message_last.date];
		[query includeKey:PF_CHAT_USER];
		[query orderByDescending:PF_CHAT_CREATEDAT];
		[query setLimit:50];
		[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
		{
			if (error == nil)
			{
				for (PFObject *object in [objects reverseObjectEnumerator])
				{
					[self addMessage:object];
				}
				if ([objects count] != 0) [self finishReceivingMessage];
			}
			else [ProgressHUD showError:@"Network error."];
			isLoading = NO;
		}];
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)addMessage:(PFObject *)object
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	RA_ParseUser *user = object[PF_CHAT_USER];
	[users addObject:user];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (object[PF_CHAT_PICTURE] == nil)
	{
		JSQTextMessage *message = [[JSQTextMessage alloc] initWithSenderId:user.objectId senderDisplayName:user.displayName
																	  date:object.createdAt text:object[PF_CHAT_TEXT]];
		[messages addObject:message];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (object[PF_CHAT_PICTURE] != nil)
	{
		JSQPhotoMediaItem *mediaItem = [[JSQPhotoMediaItem alloc] initWithImage:nil];
		JSQMediaMessage *message = [[JSQMediaMessage alloc] initWithSenderId:user.objectId senderDisplayName:user.displayName
																		date:object.createdAt media:mediaItem];
		[messages addObject:message];
		//-----------------------------------------------------------------------------------------------------------------------------------------
		PFFile *filePicture = object[PF_CHAT_PICTURE];
		[filePicture getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error)
		{
			if (error == nil)
			{
				mediaItem.image = [UIImage imageWithData:imageData];
				[self.collectionView reloadData];
			}
		}];
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)sendMessage:(NSString *)text Picture:(UIImage *)picture // Overridden by Max
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	PFFile *filePicture = nil;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (picture != nil)
	{
		filePicture = [PFFile fileWithName:@"picture.jpg" data:UIImageJPEGRepresentation(picture, 0.6)];
		[filePicture saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
		{
			if (error != nil) NSLog(@"sendMessage picture save error.");
		}];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	PFObject *object = [PFObject objectWithClassName:PF_CHAT_CLASS_NAME];
	object[PF_CHAT_USER] = [RA_ParseUser currentUser];
	object[PF_CHAT_ROOMID] = roomId;
	object[PF_CHAT_TEXT] = text;
	if (filePicture != nil) object[PF_CHAT_PICTURE] = filePicture;
    
	[object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
	{
		if (error == nil)
		{
			[JSQSystemSoundPlayer jsq_playMessageSentSound];
			[self loadMessages];
		}
		else [ProgressHUD showError:@"Network error."]; // Max deleted a typo (duplicate semicolon)
	}];
	//---------------------------------------------------------------------------------------------------------------------------------------------
//	SendPushNotification(roomId, text); // Commented out by Max
	UpdateMessageCounter(roomId, text);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self finishSendingMessage];
}

#pragma mark - JSQMessagesViewController method overrides

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self sendMessage:text Picture:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didPressAccessoryButton:(UIButton *)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil
											   otherButtonTitles:@"Take photo", @"Choose existing photo", nil];
	[action showInView:self.view];
}

#pragma mark - JSQMessages CollectionView DataSource

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return messages[indexPath.item];
}
//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
			 messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	JSQMessage *message = messages[indexPath.item];
	if ([message.senderId isEqualToString:self.senderId])
	{
		return outgoingBubbleImageData;
	}
	return incomingBubbleImageData;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
					avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	RA_ParseUser *user = users[indexPath.item];
	if (avatars[user.objectId] == nil)
	{
		PFFile *fileThumbnail = user.profilePicSmall;
		[fileThumbnail getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error)
		{
			if (error == nil)
			{
				avatars[user.objectId] = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageWithData:imageData] diameter:30.0];
				[self.collectionView reloadData];
			}
		}];
		return placeholderImageData;
	}
	else return avatars[user.objectId];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (indexPath.item % 3 == 0)
	{
		JSQMessage *message = messages[indexPath.item];
		return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
	}
	return nil;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	JSQMessage *message = messages[indexPath.item];
	if ([message.senderId isEqualToString:self.senderId])
	{
		return nil;
	}

	if (indexPath.item - 1 > 0)
	{
		JSQMessage *previousMessage = messages[indexPath.item-1];
		if ([previousMessage.senderId isEqualToString:message.senderId])
		{
			return nil;
		}
	}
	return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return nil;
}

#pragma mark - UICollectionView DataSource

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return [messages count];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
	
	JSQMessage *message = messages[indexPath.item];
	if ([message.senderId isEqualToString:self.senderId])
	{
		cell.textView.textColor = [UIColor blackColor];
	}
	else
	{
		cell.textView.textColor = [UIColor whiteColor];
	}
	return cell;
}

#pragma mark - JSQMessages collection view flow layout delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
				   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (indexPath.item % 3 == 0)
	{
		return kJSQMessagesCollectionViewCellLabelHeightDefault;
	}
	return 0.0f;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
				   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	JSQMessage *message = messages[indexPath.item];
	if ([message.senderId isEqualToString:self.senderId])
	{
		return 0.0f;
	}
	
	if (indexPath.item - 1 > 0)
	{
		JSQMessage *previousMessage = messages[indexPath.item-1];
		if ([previousMessage.senderId isEqualToString:message.senderId])
		{
			return 0.0f;
		}
	}
	return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
				   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return 0.0f;
}

#pragma mark - Responding to collection view tap events

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)collectionView:(JSQMessagesCollectionView *)collectionView
				header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSLog(@"didTapLoadEarlierMessagesButton");
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView
		   atIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSLog(@"didTapAvatarImageView");
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSLog(@"didTapMessageBubbleAtIndexPath");
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSLog(@"didTapCellAtIndexPath %@", NSStringFromCGPoint(touchLocation));
}

#pragma mark - UIActionSheetDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (buttonIndex != actionSheet.cancelButtonIndex)
	{
		if (buttonIndex == 0)	ShouldStartCamera(self, YES);
		if (buttonIndex == 1)	ShouldStartPhotoLibrary(self, YES);
	}
}

#pragma mark - UIImagePickerControllerDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UIImage *picture = info[UIImagePickerControllerEditedImage];
	[self sendMessage:@"[Picture message]" Picture:picture];
	[picker dismissViewControllerAnimated:YES completion:nil];
}

@end
