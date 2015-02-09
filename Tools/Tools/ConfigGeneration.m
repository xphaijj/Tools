//
//  ConfigGeneration.m
//  Tools
//
//  Created by Alex xiang on 15/2/3.
//  Copyright (c) 2015年 Alex xiang. All rights reserved.
//

#import "ConfigGeneration.h"
#import "Utils.h"

@implementation ConfigGeneration

/**
 * @brief  配置文件的生成
 * @prama  outputPath:配置文件的生成路径
 **/
+ (void)generationOutputPath:(NSString *)outputPath
{
    //NSString *sourceString = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForAuxiliaryExecutable:sourcepath] encoding:NSUTF8StringEncoding error:&error];
    
    NSMutableString *h = [[NSMutableString alloc] init];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    NSString *hFilePath = [outputPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.h", CONFIG_NAME]];
    [fileManager createFileAtPath:hFilePath contents:nil attributes:nil];
    
    //版权信息的导入
    [h appendString:[Utils createCopyrightByFilename:MODEL_NAME]];
    
    [h appendString:[[NSString alloc] initWithContentsOfURL:[NSURL URLWithString:@"http://git.oschina.net/phxiang/Public/raw/master/Config.h"] encoding:NSUTF8StringEncoding error:nil]];
    //[h appendString:[[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Config" ofType:@"h"] encoding:NSUTF8StringEncoding error:nil]];
    [h writeToFile:hFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}



















@end
