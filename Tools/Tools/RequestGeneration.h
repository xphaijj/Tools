//
//  RequestGeneration.h
//  Tools
//
//  Created by Alex xiang on 15/1/31.
//  Copyright (c) 2015年 Alex xiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utils.h"

@interface RequestGeneration : NSObject

/**
 * @brief  Request类自动生成
 * @prama  sourcepath:资源路径   outputPath:资源生成路径
 */
+ (void)generationSourcePath:(NSString *)sourcepath outputPath:(NSString *)outputPath config:(NSDictionary *)config;

/**
 * @brief  导入头文件
 * @prama  fileType:[H_FILE:h文件  M_FILE: m文件]
 **/
+ (NSString *)introductionPackages:(FileType)fileType;

/**
 * @brief  Request 基本类的功能
 * @prama  fileType:[H_FILE:h文件  M_FILE: m文件]
 **/
+ (NSString *)classOfRequest:(FileType)fileType;

/**
 * @brief  匹配出所有的Request类型
 * @prama  sourceString:需要匹配的字符串
 * @prama  fileType:[H_FILE:h文件  M_FILE: m文件]
 **/
+ (NSString *)messageFromSourceString:(NSString *)sourceString fileType:(FileType)fileType;

/**
 * @brief  生成方法名
 * @prama  fileType:[H_FILE:h文件  M_FILE: m文件]
 * @prama  baseURL 基础路径
 * @prama  requestType:接口类型 get | post | upload
 * @prama  interface:接口名称
 * @prama  returnType:返回类型
 * @prama  methodType:方法类型
 * @prama  contents:接口参数
 */
+ (NSString *)generationFileType:(FileType)fileType baseURL:(NSString *)baseURL requestType:(NSString *)requestType methodName:(NSString *)interface returnType:(NSString *)returnType contents:(NSArray *)contents methodType:(MethodType)methodType;

/**
 * @brief  request请求的所有参数
 * @prama  contents:参数列表
 * @prama  methodType:方法类型
 * @prama  fileType:[H_FILE:h文件  M_FILE: m文件]
 */
+ (NSString *)allPramaFromContents:(NSArray *)contents withType:(MethodType)methodType fileType:(FileType)fileType;














@end
