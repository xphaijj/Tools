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

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSString *sourcePath = [NSString stringWithUTF8String:argv[1]];
        NSString *outputPath = [NSString stringWithUTF8String:argv[2]];
        [ModelGeneration generationSourcePath:sourcePath outputPath:outputPath];
        
        
        NSLog(@"\n%@ \n outputPath = %@\n", sourcePath, outputPath);
        
    }
    return 0;
}
