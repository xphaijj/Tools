//
//  NSImage+Resizing.m
//
//  Created by Tyler Williamson on 1/12/16.
//  Copyright © 2016 Tyler Williamson. All rights reserved.
//

#import "NSImage+Resizing.h"

@implementation NSImage (Resizing)

- (NSImage *) resizeImageToNewSize: (NSSize) newSize {
    NSImage *sourceImage = self;
    
    // Report an error if the source isn't a valid image
    if (![sourceImage isValid]){
        NSLog(@"Invalid Image");
    } else {
        NSImage *smallImage = [[NSImage alloc] initWithSize: newSize];
        [smallImage lockFocus];
        [sourceImage setSize: newSize];
        [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
        [sourceImage drawAtPoint:NSZeroPoint fromRect:CGRectMake(0, 0, newSize.width, newSize.height) operation:NSCompositeCopy fraction:1.0];
        [smallImage unlockFocus];
        return smallImage;
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
