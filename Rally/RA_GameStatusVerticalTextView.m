//
//  RA_GameStatusVerticalTextView.m
//  Rally
//
//  Created by Max de Vere on 15/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_GameStatusVerticalTextView.h"
#import "RA_ParseGame.h"

@interface RA_GameStatusVerticalTextView()
@property (strong, nonatomic) UILabel *textLabel;
@end


@implementation RA_GameStatusVerticalTextView


#pragma mark - init
// ******************** init ********************


- (void)initialize
{
    COMMON_LOG
    
    // Prepare the label
    self.textLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.height, self.bounds.size.width)]; // Height and width swapped ahead of rotation
    self.textLabel.font = [UIFont systemFontOfSize:13.0];
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.textLabel];
}

- (id)init
{
    if (self = [super init]) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

-(void)layoutSubviews
{
    COMMON_LOG
    
    self.textLabel.transform = CGAffineTransformMakeRotation(3*M_PI_2);
    self.textLabel.center = self.center;
}



#pragma mark - configure
// ******************** configure ********************


-(void)configureForStatus:(NSString *)status
{
    if ([status isEqualToString:RA_GAME_STATUS_CONFIRMED]) {
        self.textLabel.text = @"Confirmed";
        self.textLabel.textColor = [UIColor whiteColor];
        self.backgroundColor = CO_GREEN_CONFIRMED;
    }
    else if ([status isEqualToString:RA_GAME_STATUS_PROPOSED] || [status isEqualToString:RA_GAME_STATUS_UNCONFIRMED]) {
        self.textLabel.text = @"TBC";
        self.textLabel.textColor = [UIColor whiteColor];
        self.backgroundColor = CO_AMBER_UNCONFIRMED_LIGHTER;
    }
    else if ([status isEqualToString:RA_GAME_STATUS_CANCELLED]) {
        self.textLabel.text = @"Cancelled";
        self.textLabel.textColor = [UIColor whiteColor];
        self.backgroundColor = CO_GRAY_CANCELLED;
    }
    else if ([status isEqualToString:RA_GAME_STATUS_COMPLETED]) {
        self.textLabel.text = @"Completed";
        self.textLabel.textColor = [UIColor whiteColor];
        self.backgroundColor = CO_GREEN_CONFIRMED;
    }
    else if ([status isEqualToString:RA_GAME_STATUS_UNCONFIRMED]) {
        self.textLabel.text = @"TBC";
        self.textLabel.textColor = [UIColor whiteColor];
        self.backgroundColor = CO_AMBER_UNCONFIRMED;
    }
    else {
        COMMON_LOG_WITH_COMMENT(@"ERROR: Unexpected style")
    }
}



@end


