//
//  UIImage+ProfilePicHandling.m
//  Rally
//
//  Created by Max de Vere on 04/09/2014.
//  Copyright (c) 2014 NA. All rights reserved.
//

#import "UIImage+ProportionalFill.h"
#import "UIImage+RoundedCorner.h"
#import "UIImage+ProfilePicHandling.h"
#import "AppConstants.h"



@implementation UIImage (ProfilePicHandling)


-(UIImage *)getImageResizedAndCropped:(CGSize)size
{
    size = CGSizeMake(size.width*2, size.height*2);
    UIImage *pic = [self imageCroppedToFitSize:size];
    return pic;
}

-(UIImage *)getImageWithRoundedCorners:(NSInteger)radius
{
    radius = radius*2;
    UIImage *pic = [self roundedCornerImage:radius borderSize:0];
    return pic;
}

-(UIImage *)getImageCircularWithRadius:(CGFloat)radius
{
    radius = radius*2;
    UIImage *pic = [self imageCroppedToFitSize:CGSizeMake(radius,radius)];
    UIImageView *roundView = [[UIImageView alloc]initWithImage:pic];
    UIGraphicsBeginImageContextWithOptions(roundView.bounds.size, NO, 0.0);
    [[UIBezierPath bezierPathWithRoundedRect:roundView.bounds
                                cornerRadius:roundView.frame.size.width / 2] addClip];
    [pic drawInRect:roundView.bounds];
    UIImage *finalPic = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return finalPic;
}



-(NSData *)getDataResizedAndCropped:(CGSize)size
{
    UIImage *pic = [self getImageResizedAndCropped:size];
    NSData *picData = UIImageJPEGRepresentation(pic, 0.9f);
    return picData;
}

-(NSData *)getDataWithRoundedCorners:(NSInteger)radius
{
    UIImage *pic = [self getImageWithRoundedCorners:radius];
    NSData *picData = UIImageJPEGRepresentation(pic, 0.9f);
    return picData;
}

-(NSData *)getDataCircularWithRadius:(CGFloat)radius
{
    UIImage *pic = [self getImageCircularWithRadius:radius];
    NSData *picData = UIImageJPEGRepresentation(pic, 0.9f);
    return picData;
}



-(PFFile *)getFileResizedAndCropped:(CGSize)size
{
    NSData *picData = [self getDataResizedAndCropped:size];
    PFFile *picFile = [PFFile fileWithData:picData];
    return picFile;
}

-(PFFile *)getFileWithRoundedCorners:(NSInteger)radius
{
    NSData *picData = [self getDataWithRoundedCorners:radius];
    PFFile *picFile = [PFFile fileWithData:picData];
    return picFile;
}

-(PFFile *)getFileCircularWithRadius:(CGFloat)radius
{
    NSData *picData = [self getDataCircularWithRadius:radius];
    PFFile *picFile = [PFFile fileWithData:picData];
    return picFile;
}



@end
