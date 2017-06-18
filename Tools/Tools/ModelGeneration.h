//
//  ModelGeneration.h
//  Tools
//
//  Created by Alex xiang on 15/1/31.
//  Copyright (c) 2015年 Alex xiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utils.h"

@interface ModelGeneration : NSObject

/**
 * @brief  Model类自动生成
 * @prama  sourcepath:资源路径   outputPath:资源生成路径
 */
+ (void)generationSourcePath:(NSString *)sourcepath outputPath:(NSString *)outputPath config:(NSDictionary *)config;

/**
 * @brief  导入头文件
 * @prama  fileType:[H_FILE:h文件  M_FILE: m文件]
 **/
+ (NSString *)introductionPackages:(FileType)fileType;

/**
 * @brief  匹配出所有的枚举类型
 * @prama  sourceString:需要匹配的字符串
 **/
+ (NSString *)enumFromSourceString:(NSString *)sourceString;

/**
 * @brief  匹配出所有的model类型
 * @prama  sourceString:需要匹配的字符串
 * @prama  fileType:[H_FILE:h文件  M_FILE: m文件]
 **/
+ (NSString *)messageFromSourceString:(NSString *)sourceString fileType:(FileType)fileType;

/**
 * @brief  h 文件中 @class 所有的model
 * @prama  classes:所有的model 列表
 */
+ (NSString *)allClass:(NSArray *)classes;

/**
 * @brief  models 数据的生成
 * @prama  classes:所有的model列表
 * @prama  fileType:[H_FILE:h文件  M_FILE: m文件]
 */
+ (NSString *)generationModelsFromClasses:(NSArray *)classes fileType:(FileType)fileType;

/**
 * @brief  单个model的解析
 * @prama  contents:单个的model列表
 * @prama  fileType:[H_FILE:h文件  M_FILE: m文件]
 */
+ (NSString *)modelFromClass:(NSArray *)contents fileType:(FileType)fileType;

/**
 * @brief  单个model的解析
 * @prama  contentsList:所有属性列表
 * @prama  fileType:[H_FILE:h文件  M_FILE: m文件]
 * @prama  methodType:方法类别
 */
+ (NSString *)allPropertys:(NSArray *)contentsList fileType:(FileType)fileType methodType:(MethodType)methodType;

/**
 * @brief  单个model的所有property解析
 * @prama  contents:单个model的所有属性
 * @prama  fileType:[H_FILE:h文件  M_FILE: m文件]
 */
+ (NSString *)propertyFromContents:(NSString *)contents fileType:(FileType)fileType;

/**
 * @brief  解析单条属性
 * @prama  fields:单条属性的所有字段
 * @prama  fileType:[H_FILE:h文件  M_FILE: m文件]
 * @prama  methodType:方法类别 多个方法解析
 */
+ (NSString *)singleProperty:(NSArray *)fields fileType:(FileType)fileType methodType:(MethodType)methodType;

/**
 * @brief  方法的生成
 * @prama  classname:类名
 * @prama  contents:单个的model列表
 * @prama  fileType:[H_FILE:h文件  M_FILE: m文件]
 * @prama  methodType:方法类别 多个方法解析
 */
+ (NSString *)methodWithClass:(NSString *)classname contents:(NSString *)contents FileType:(FileType)fileType methodType:(MethodType)methodType;



@end
