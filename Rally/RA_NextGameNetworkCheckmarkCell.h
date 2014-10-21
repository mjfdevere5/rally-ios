//
//  RA_NextGameNetworkCheckmarkCell.h
//  Rally
//
//  Created by Max de Vere on 16/10/2014.
//  Copyright (c) 2014 Rally. All rights reserved.
//

#import "RA_NextGameBaseCell.h"
#import "RA_ParseNetwork.h"

@interface RA_NextGameNetworkCheckmarkCell : RA_NextGameBaseCell

@property (strong, nonatomic) RA_ParseNetwork *network;
@property (weak, nonatomic) IBOutlet UILabel *networkNameLabel;

@end
