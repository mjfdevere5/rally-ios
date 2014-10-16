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
    UIImage *pic = [self imageCroppedToFitSize:size];
    return pic;
}

-(UIImage *)getImageWithRoundedCorners:(NSInteger)radius
{
    UIImage *pic = [self roundedCornerImage:radius borderSize:0];
    return pic;
}

-(UIImage *)getImageCircularWithRadius:(CGFloat)radius
{
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




//-(UIImage *)getProfilePicAfterResizeAndCropReturnImage
//{
//    UIImage *pic = [self imageCroppedToFitSize:CGSizeMake(PF_USER_PIC_WIDTH, PF_USER_PIC_HEIGHT)];
//    return pic;
//}
//
//
//
//-(UIImage *)getThumbnailAfterResizeAndCropReturnImage;
//{
//    UIImage *thumb = [self imageCroppedToFitSize:CGSizeMake(PF_USER_PIC_THUMB_WIDTH, PF_USER_PIC_THUMB_HEIGHT)];
//    thumb = [thumb roundedCornerImage:5 borderSize:0];
//    return thumb;
//}
//
//
//
//-(UIImage *)getRoundedImageAfterResizeAndCropReturnImage
//{
//    UIImage *round = [self imageCroppedToFitSize:CGSizeMake(PF_USER_PIC_THUMB_WIDTH_ROUND, PF_USER_PIC_THUMB_HEIGHT)];
//    
//    UIImageView *roundView = [[UIImageView alloc]initWithImage:round];
//    
//    UIGraphicsBeginImageContextWithOptions(roundView.bounds.size, NO, 0.0);
//    [[UIBezierPath bezierPathWithRoundedRect:roundView.bounds
//                                cornerRadius:roundView.frame.size.width / 2] addClip];
//    [round drawInRect:roundView.bounds];
//    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    return finalImage;
//}
//
//
//
//-(NSData *)getProfilePicAfterResizeAndCropReturnData
//{
//    // Process the image
//    UIImage *pic = [self getProfilePicAfterResizeAndCropReturnImage];
//    
//    // Convert to JPEG data
//    NSData *picData = UIImageJPEGRepresentation(pic, 0.9f);
//    
//    // Return
//    return picData;
//}
//
//
//
//-(NSData *)getThumbnailAfterResizeAndCropReturnData
//{
//    // Process the image
//    UIImage *thumb = [self getThumbnailAfterResizeAndCropReturnImage];
//    
//    // Convert to JPEG data
//    NSData *thumbData = UIImageJPEGRepresentation(thumb, 0.9f);
//    
//    // Return
//    return thumbData;
//}
//
//
//
//-(NSData *)getRoundedImageAfterResizeAndCropReturnData;
//{
//    UIImage *pic = [self getRoundedImageAfterResizeAndCropReturnImage];
//    NSData *picData = UIImageJPEGRepresentation(pic, 0.9f);
//    return picData;
//}
//
//
//
//-(PFFile *)getProfilePicAfterResizeAndCropReturnFile
//{
//    NSData *picData = [self getProfilePicAfterResizeAndCropReturnData];
//    PFFile *picFile = [PFFile fileWithData:picData];
//    return picFile;
//}
//
//
//
//-(PFFile *)getThumbnailAfterResizeAndCropReturnFile
//{
//    NSData *thumbData = [self getThumbnailAfterResizeAndCropReturnData];
//    PFFile *thumbFile = [PFFile fileWithData:thumbData];
//    return thumbFile;
//}
//
//
//
//-(PFFile *)getRoundedImageAfterResizeAndCropReturnFile
//{
//    NSData *roundData = [self getRoundedImageAfterResizeAndCropReturnData];
//    PFFile *roundFile = [PFFile fileWithData:roundData];
//    return roundFile;
//}



@end
