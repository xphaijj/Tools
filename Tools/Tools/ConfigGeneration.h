//
//  ConfigGeneration.h
//  Tools
//
//  Created by Alex xiang on 15/2/3.
//  Copyright (c) 2015年 Alex xiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConfigGeneration : NSObject

/**
 * @brief  配置文件的生成
 * @prama  outputPath:配置文件的生成路径
 **/
+ (void)generationOutputPath:(NSString *)outputPath config:(NSDictionary *)config;

@end
