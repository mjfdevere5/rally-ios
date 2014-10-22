//
//  RA_ChatView.h
//  Rally
//
//  Created by Max de Vere on 22/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatView.h"
#import "RA_ParseChatroom.h"

@interface RA_ChatView : ChatView

-(id)initWithChatroom:(RA_ParseChatroom *)chatroom;

@end
