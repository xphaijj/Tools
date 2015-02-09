//
//  main.m
//  Tools
//
//  Created by Alex xiang on 15/1/31.
//  Copyright (c) 2015年 Alex xiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ModelGeneration.h"
#import "DBGeneration.h"
#import "RequestGeneration.h"
#import "ConfigGeneration.h"

void generation(NSString *sourcePath, NSString *outputPath);

//     /Users/Alex/Desktop/

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSString *sourcePath;
        NSString *outputPath;
        switch (argc) {
            case 0:
            case 1:
            {
            }
                break;
            case 2:
            {
                sourcePath = [NSString stringWithUTF8String:argv[1]];
                outputPath = [[NSMutableString alloc] initWithUTF8String:argv[1]];
                outputPath = [outputPath substringToIndex:([outputPath rangeOfString:@"/" options:NSBackwardsSearch].location+1)];
                generation(sourcePath, outputPath);
            }
                break;
            case 3:
            {
                sourcePath = [NSString stringWithUTF8String:argv[1]];
                outputPath = (NSMutableString *)[NSString stringWithUTF8String:argv[2]];
                generation(sourcePath, outputPath);
            }
                break;
                
            default:
                break;
        }
    }
    return 0;
}

void generation(NSString *sourcePath, NSString *outputPath) {
    NSLog(@"\n\tsourcePath = %@ \n\toutputPath = %@\n", sourcePath, outputPath);
    [ModelGeneration generationSourcePath:sourcePath outputPath:outputPath];
    [DBGeneration generationSourcePath:sourcePath outputPath:outputPath];
    [RequestGeneration generationSourcePath:sourcePath outputPath:outputPath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/%@.h", outputPath, CONFIG_NAME]]) {
        [ConfigGeneration generationOutputPath:outputPath];
    }
    
}
