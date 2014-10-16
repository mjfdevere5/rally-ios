//
//  UIImage+ProfilePicHandling.h
//  Rally
//
//  Created by Max de Vere on 04/09/2014.
//  Copyright (c) 2014 NA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ProfilePicHandling)

//-(UIImage *)getProfilePicAfterResizeAndCropReturnImage;
//-(UIImage *)getThumbnailAfterResizeAndCropReturnImage;
//-(UIImage *)getRoundedImageAfterResizeAndCropReturnImage;
//
//-(NSData *)getProfilePicAfterResizeAndCropReturnData;
//-(NSData *)getThumbnailAfterResizeAndCropReturnData;
//-(NSData *)getRoundedImageAfterResizeAndCropReturnData;
//
//-(PFFile *)getProfilePicAfterResizeAndCropReturnFile;
//-(PFFile *)getThumbnailAfterResizeAndCropReturnFile;
//-(PFFile *)getRoundedImageAfterResizeAndCropReturnFile;


-(UIImage *)getImageResizedAndCropped:(CGSize)size;
-(UIImage *)getImageWithRoundedCorners:(NSInteger)radius;
-(UIImage *)getImageCircularWithRadius:(CGFloat)radius;

-(NSData *)getDataResizedAndCropped:(CGSize)size;
-(NSData *)getDataWithRoundedCorners:(NSInteger)radius;
-(NSData *)getDataCircularWithRadius:(CGFloat)radius;

-(PFFile *)getFileResizedAndCropped:(CGSize)size;
-(PFFile *)getFileWithRoundedCorners:(NSInteger)radius;
-(PFFile *)getFileCircularWithRadius:(CGFloat)radius;

@end
