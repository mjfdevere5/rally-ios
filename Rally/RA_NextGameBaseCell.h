//
//  RA_NextGameBaseCell.h
//  Rally
//
//  Created by Max de Vere on 16/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol RA_NextGameCellDelegate
@optional
-(void)didPickSport;

@end



@interface RA_NextGameBaseCell : UITableViewCell

@property (strong, nonatomic) NSObject<RA_NextGameCellDelegate>* viewControllerDelegate;
-(void)configureCell;

@end
