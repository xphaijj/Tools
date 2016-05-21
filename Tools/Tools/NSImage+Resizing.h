//
//  NSImage+Resizing.h
//
//  Created by Tyler Williamson on 1/12/16.
//  Copyright © 2016 Tyler Williamson. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSImage (Resizing)

- (NSImage *) resizeImageToNewSize: (NSSize) newSize;
- (NSImage *) cropImageToSize: (NSSize) newSize fromPoint:(NSPoint) point;

@end
