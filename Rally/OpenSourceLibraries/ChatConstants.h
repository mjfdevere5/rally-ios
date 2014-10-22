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

//-------------------------------------------------------------------------------------------------------------------------------------------------
#define HEXCOLOR(c) [UIColor colorWithRed:((c>>24)&0xFF)/255.0 green:((c>>16)&0xFF)/255.0 blue:((c>>8)&0xFF)/255.0 alpha:((c)&0xFF)/255.0]

//-------------------------------------------------------------------------------------------------------------------------------------------------
#define		PF_INSTALLATION_CLASS_NAME			@"_Installation"
#define		PF_INSTALLATION_OBJECTID			@"objectId"
#define		PF_INSTALLATION_USER				@"user"

#define		PF_CHAT_CLASS_NAME					@"Chat"
#define		PF_CHAT_USER						@"user"
#define		PF_CHAT_ROOMID						@"roomId"
#define		PF_CHAT_TEXT						@"text"
#define		PF_CHAT_PICTURE						@"picture"
#define		PF_CHAT_CREATEDAT					@"createdAt"

#define		PF_CHATROOMS_CLASS_NAME				@"ChatRooms"
#define		PF_CHATROOMS_NAME					@"name"

#define		PF_MESSAGES_CLASS_NAME				@"Messages"
#define		PF_MESSAGES_USER					@"user"
#define		PF_MESSAGES_ROOMID					@"roomId"
#define		PF_MESSAGES_DESCRIPTION				@"description"
#define		PF_MESSAGES_LASTUSER				@"lastUser"
#define		PF_MESSAGES_LASTMESSAGE				@"lastMessage"
#define		PF_MESSAGES_COUNTER					@"counter"
#define		PF_MESSAGES_UPDATEDACTION			@"updatedAction"

//-------------------------------------------------------------------------------------------------------------------------------------------------
#define		NOTIFICATION_APP_STARTED			@"NCAppStarted"
#define		NOTIFICATION_USER_LOGGED_IN			@"NCUserLoggedIn"
#define		NOTIFICATION_USER_LOGGED_OUT		@"NCUserLoggedOut"
