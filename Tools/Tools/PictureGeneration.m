//
//  PictureGeneration.m
//  Tools
//
//  Created by 項普華 on 16/5/21.
//  Copyright © 2016年 Alex xiang. All rights reserved.
//

#import "PictureGeneration.h"
#import "NSImage+Resizing.h"
#import <Cocoa/Cocoa.h>

@implementation PictureGeneration

+ (void)generationSourcePath:(NSString *)sourcePath outPath:(NSString *)outPath{
    NSArray *conents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:sourcePath error:nil];
    for (NSString *filename in conents) {
        if ([filename hasSuffix:@".png"] && !([filename hasSuffix:@"@2x.png"] || [filename hasSuffix:@"@3x.png"])) {
            NSMutableString *string = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%@/%@", sourcePath, filename]];
            [string replaceOccurrencesOfString:@".png" withString:@"@3x.png" options:NSBackwardsSearch range:NSMakeRange(string.length-9, 9)];
            BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:string];
            if (!exist) {
                NSImage *image;
                if (exist) {
                    NSLog(@"-- %@", string);
                    image = [[NSImage alloc] initWithContentsOfFile:string];
                }
                else {
                    image = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", sourcePath, filename]];
                }
                NSLog(@"++  %f ++ %f", image.size.width, image.size.height);
                
                [PictureGeneration saveImage:image path:string];
                image = [image resizeImageToNewfactor:2.0/3.88125];
                [string replaceOccurrencesOfString:@"@3x.png" withString:@"@2x.png" options:NSBackwardsSearch range:NSMakeRange(string.length-9, 9)];
                [PictureGeneration saveImage:image path:string];
//                image = [image resizeImageToNewfactor:1.0/2.0];
//                [string replaceOccurrencesOfString:@"@2x.png" withString:@".png" options:NSBackwardsSearch range:NSMakeRange(string.length-9, 9)];
//                [PictureGeneration saveImage:image path:string];
            }
        }
    }
}

+ (void)saveImage:(NSImage *)image path:(NSString *)path
{
    NSLog(@"-- %f -- %f", image.size.width, image.size.height);
    NSBitmapImageRep *rep = [[NSBitmapImageRep alloc]
                             initWithBitmapDataPlanes:NULL
                             pixelsWide:image.size.width
                             pixelsHigh:image.size.height
                             bitsPerSample:8
                             samplesPerPixel:4
                             hasAlpha:YES
                             isPlanar:NO
                             colorSpaceName:NSCalibratedRGBColorSpace
                             bytesPerRow:0
                             bitsPerPixel:0];
    [rep setSize:NSMakeSize(image.size.width, image.size.height)];
    
    
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithBitmapImageRep:rep]];
    [image drawInRect:NSMakeRect(0, 0, image.size.width, image.size.height) fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];
    [NSGraphicsContext restoreGraphicsState];
    
    NSData *data = [rep representationUsingType:NSPNGFileType properties:@{NSImageCompressionFactor:@(1)}];
    [data writeToFile:path atomically:YES];
}



@end
