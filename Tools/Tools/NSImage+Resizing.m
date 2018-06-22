//
//  NSImage+Resizing.m
//
//  Created by Tyler Williamson on 1/12/16.
//  Copyright © 2016 Tyler Williamson. All rights reserved.
//

#import "NSImage+Resizing.h"

@implementation NSImage (Resizing)

- (NSImage *) resizeImageToNewfactor:(CGFloat)factor {
    NSImage *sourceImage = self;
    
    // Report an error if the source isn't a valid image
    if (![sourceImage isValid]){
        NSLog(@"Invalid Image");
    } else {
        NSSize size = NSZeroSize;
        
        size.width = self.size.width*factor;
        size.height = self.size.height*factor;
        
        NSImage *ret = [[NSImage alloc] initWithSize:size];
        [ret lockFocus];
        NSAffineTransform *transform = [NSAffineTransform transform];
        [transform scaleBy:factor];
        [transform concat];
        [self drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];
        [ret unlockFocus];
        
        return ret;
    }
    return nil;

}

- (NSImage *) cropImageToSize:(NSSize)newSize fromPoint:(NSPoint)point{
    CGImageSourceRef source;
    
    source = CGImageSourceCreateWithData((CFDataRef)[self TIFFRepresentation], NULL);
    CGImageRef imageRef =  CGImageSourceCreateImageAtIndex(source, 0, NULL);
    
    CGRect sizeToBe = CGRectMake(point.x, point.y, newSize.width, newSize.height);
    CGImageRef croppedImage = CGImageCreateWithImageInRect(imageRef, sizeToBe);
    NSImage *finalImage = [[NSImage alloc] initWithCGImage:croppedImage size:NSZeroSize];
    CFRelease(imageRef);
    CFRelease(croppedImage);
    
    return finalImage;

}

@end
