//
//  DBGeneration.h
//  Tools
//
//  Created by Alex xiang on 15/1/31.
//  Copyright (c) 2015年 Alex xiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utils.h"

@interface DBGeneration : NSObject

/**
 * @brief  DB类自动生成
 * @prama  sourcepath:资源路径   outputPath:资源生成路径
 */
+ (void)generationSourcePath:(NSString *)sourcepath outputPath:(NSString *)outputPath config:(NSDictionary *)config;

/**
 * @brief  导入头文件
 * @prama  fileType:[H_FILE:h文件  M_FILE:m文件]
 **/
+ (NSString *)introductionPackages:(FileType)fileType;

/**
 * @brief  匹配出所有的model类型
 * @prama  sourceString:需要匹配的字符串
 * @prama  fileType:[H_FILE:h文件  M_FILE: m文件]
 **/
+ (NSString *)messageFromSourceString:(NSString *)sourceString fileType:(FileType)fileType;


/**
 * @brief  model 基类的实现
 * @prama  fileType:[H_FILE:h文件  M_FILE: m文件]
 */
+ (NSString *)baseModel:(FileType)fileType;

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
 * @brief  方法的生成
 * @prama  classname:类名
 * @prama  contents:单个的model列表
 * @prama  fileType:[H_FILE:h文件  M_FILE: m文件]
 * @prama  methodType:方法类别 多个方法解析
 */
+ (NSString *)methodWithClass:(NSString *)classname contents:(NSString *)contents FileType:(FileType)fileType methodType:(MethodType)methodType;

/**
 * @brief  查找key 和 key的Type
 * @prama  contentlist: 数据列表
 */
+ (NSDictionary *)findKeyAndType:(NSArray *)contentList;
/**
 * @brief  单个model的解析
 * @prama  contentsList:所有属性列表
 * @prama  fileType:[H_FILE:h文件  M_FILE: m文件]
 * @prama  methodType:方法类别
 * @prama  index:增删改查方法的索引
 * @prama  key:数据库的key
 * @prama  keyType:数据库key的类型 string int
 * @prama  keyfieldname:数据库字段
 */
+ (NSString *)allPropertys:(NSArray *)contentsList fileType:(FileType)fileType methodType:(MethodType)methodType index:(TypeIndex)index key:(NSString *)key keyType:(NSString *)keyType keyfieldname:(NSString *)keyfieldname;

/**
 * @brief  解析单条属性
 * @prama  fields:单条属性的所有字段
 * @prama  fileType:[H_FILE:h文件  M_FILE: m文件]
 * @prama  methodType:方法类别 多个方法解析
 * @prama  index:增删改查方法的索引
 * @prama  key:数据库的key
 * @prama  keyType:数据库key的类型 string int
 * @prama  keyfieldname:数据库字段
 */
+ (NSString *)singleProperty:(NSArray *)fields fileType:(FileType)fileType methodType:(MethodType)methodType index:(TypeIndex)index key:(NSString *)key keyType:(NSString *)keyType keyfieldname:(NSString *)keyfieldname;

/**
 * @brief  数据库操作的基本生成
 * @prama  classname: 表名称
 **/
+ (NSString *)dbbaseControl:(NSString *)classname;

@end
