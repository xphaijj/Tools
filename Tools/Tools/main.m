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
#import "PictureGeneration.h"
#import "Utils.h"

void generation(NSString *sourcePath, NSString *outputPath, NSDictionary *config);


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
                BOOL isDirectory = NO;
                BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:sourcePath isDirectory:&isDirectory];
                if (exist) {
                    if (isDirectory) {
                        outputPath = sourcePath;
                        [PictureGeneration generationSourcePath:sourcePath outPath:outputPath];
                    }
                    else {
                        outputPath = [[NSMutableString alloc] initWithUTF8String:argv[1]];
                        outputPath = [outputPath substringToIndex:([outputPath rangeOfString:@"/" options:NSBackwardsSearch].location+1)];
                        
                        NSDictionary *config = [Utils configDictionary:sourcePath];
                        generation(sourcePath, outputPath, config);
                    }
                }
            }
                break;
            case 3:
            {
                sourcePath = [NSString stringWithUTF8String:argv[1]];
                BOOL isDirectory = NO;
                BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:sourcePath isDirectory:&isDirectory];
                if (exist) {
                    if (isDirectory) {
                        outputPath = sourcePath;
                        [PictureGeneration generationSourcePath:sourcePath outPath:outputPath];
                    }
                    else {
                        outputPath = (NSMutableString *)[NSString stringWithUTF8String:argv[2]];
                        
                        NSDictionary *config = [Utils configDictionary:sourcePath];
                        generation(sourcePath, outputPath, config);
                    }
                }
                
                
            }
                break;
                
            default:
                break;
        }
    }
    return 0;
}

void generation(NSString *sourcePath, NSString *outputPath, NSDictionary *config) {
    NSLog(@"\n\tsourcePath = %@ \n\toutputPath = %@\n", sourcePath, outputPath);
    [ModelGeneration generationSourcePath:sourcePath outputPath:outputPath config:config];
    [DBGeneration generationSourcePath:sourcePath outputPath:outputPath config:config];
    [RequestGeneration generationSourcePath:sourcePath outputPath:outputPath config:config];    
}
