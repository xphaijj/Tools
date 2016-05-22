//
//  NSImage+Resizing.h
//
//  Created by Tyler Williamson on 1/12/16.
//  Copyright © 2016 Tyler Williamson. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSImage (Resizing)

- (NSImage *) resizeImageToNewfactor:(CGFloat)factor;
- (NSImage *) cropImageToSize: (NSSize) newSize fromPoint:(NSPoint) point;

@end
