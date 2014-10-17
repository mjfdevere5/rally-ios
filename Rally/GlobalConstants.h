//
//  GlobalConstants.h
//  Rally
//
//  Created by Max de Vere on 08/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//



#pragma mark - devious strings
// ******************** devious strings ********************

#define     RA_SPORT_NAME_SQUASH                @"squash"
#define     RA_SPORT_NAME_TENNIS                @"tennis"

#define     RA_SIMRANKED_SIMRANKED_ONLY         @"sim_ranked_only"
#define     RA_SIMRANKED_EVERYONE               @"everyone"


#pragma mark - frequently used bits of code
// ******************** frequently used bits of code ********************

//#define     CUSER                               [RA_ParseUser currentUser]


#pragma mark - Logging
// ******************** Logging ********************

#define     COMMON_LOG                          if([NSThread isMainThread]){NSLog(@"[%@, %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));}else{NSLog(@"[%@, %@] (BACKGROUND)", NSStringFromClass([self class]), NSStringFromSelector(_cmd));}

#define     COMMON_LOG_WITH_COMMENT(comment)    if([NSThread isMainThread]){NSLog(@"[%@, %@] %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), comment);}else{NSLog(@"[%@, %@] (BACKGROUND) %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), comment);}



#pragma mark - Formatting and colour schemes
// ******************** Formatting and colour schemes ********************

// Colour picker macro
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

// Tabbar
#define     RA_TABBAR_COLOUR                    0xF0F0F0 // very light gray
#define     RA_TABBAR_UNSELECTED                0x5F5F5F // light gray
#define     RA_TABBAR_SELECTED                  0xE60000 // darker red

// Colour scheme
#define     GENERIC_BACKGROUND_COLOUR           0xFFF5F5 // light pinky grey
#define     FORMS_LIGHT_RED                     0xF06666
#define     FORMS_DARK_RED                      0xEB3333

// Ladder
#define     LADDER_FORM_NA_COLOR                0xF0F0F0 // very light gray
#define     LADDER_FORM_STD_COLOR               0xE60000 // darker red

// Navbar
#define     RA_NAVBAR_COLOUR                    0xE60000 // darker red
#define     RA_NAVBAR_TEXT_COLOUR               0xFFFFFF // pure white

// Game Manager
#define     CO_GREEN_CONFIRMED                  UIColorFromRGB(0x71C671)
#define     CO_AMBER_UNCONFIRMED                UIColorFromRGB(0xFF9900)
#define     CO_AMBER_UNCONFIRMED_LIGHTER        UIColorFromRGB(0xFFB84D)
#define     CO_GRAY_CANCELLED                   UIColorFromRGB(0xA0A0A0)


