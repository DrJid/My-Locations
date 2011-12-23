//
//  UIImage+Resize.m
//  MyLocations
//
//  Created by Maijid  Moujaled on 12/21/11.
//  Copyright (c) 2011 Grinnell College. All rights reserved.
//

#import "UIImage+Resize.h"

@implementation UIImage (Resize)


- (UIImage *)resizedImageWithBounds:(CGSize)bounds
{
    CGFloat horizontalRatio = bounds.width / self.size.width;
    CGFloat verticalRatio = bounds.height / self.size.height;
    CGFloat ratio = MIN(horizontalRatio, verticalRatio);
    CGSize newSize = CGSizeMake(self.size.width * ratio, self.size.height * ratio);
    
    UIGraphicsBeginImageContextWithOptions(newSize, YES, 0);
    [self drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}
@end
