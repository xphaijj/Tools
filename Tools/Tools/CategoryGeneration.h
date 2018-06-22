//
//  CategoryGeneration.h
//  Tools
//
//  Created by Alex xiang on 15/2/6.
//  Copyright (c) 2015年 Alex xiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CategoryGeneration : NSObject


/**
 * @brief  NSDictionary+Model 生成
 * @prama  outputPath:输出路径
 */
+ (void)generationDictionaryCategory:(NSString *)outputPath;


/**
 * @brief  NSArray+Model 生成
 * @prama  outputPath:输出路径
 */
+ (void)generationArrayCategory:(NSString *)outputPath;



/**
 * @brief  NSString+Model 生成
 * @prama  outputPath:输出路径
 */
+ (void)generationStringCategory:(NSString *)outputPath;


@end
