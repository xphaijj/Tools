//
//  Utils.h
//  Tools
//
//  Created by Alex xiang on 15/1/31.
//  Copyright (c) 2015年 Alex xiang. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RegexKitLite.h"

#define KEY @"KEY"
#define KEY_TYPE @"KEY_TYPE"
#define KEY_FIELDNAME @"KEY_FIELDNAME"

#define IS_BASE_TYPE(type) [[type lowercaseString] isEqualToString:@"int"] || [[type lowercaseString] isEqualToString:@"float"] || [[type lowercaseString] isEqualToString:@"double"] || [[type lowercaseString] isEqualToString:@"bool"] || [[type lowercaseString] isEqualToString:@"short"] || [[type lowercaseString] isEqualToString:@"byte"] || [[type lowercaseString] isEqualToString:@"long"] || [[type lowercaseString] isEqualToString:@"char"] || [[type lowercaseString] isEqualToString:@"longlong"] || [[type lowercaseString] isEqualToString:@"integer"] || [[type lowercaseString] isEqualToString:@"boolean"]


#define BUNDLE_PATH [NSString stringWithFormat:@"%@/Tools/", [[[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent] stringByDeletingLastPathComponent] stringByDeletingLastPathComponent]]


#pragma mark -- config

typedef enum FileType { //文件类型
    H_FILE,
    M_FILE
}FileType;

typedef enum RequestType {//网络请求类型
    REQUEST_NORMAL,
    REQUEST_RAC,
    REQUEST_PRO,
}RequestType;

typedef enum MethodType {//方法类型
    TYPE_PROPERTY,//属性解析
    TYPE_INIT,//初始化
    TYPE_KEYMAPPER,//静态方法
    TYPE_CLASS_IN_ARRAY,//数组中类的映射
    
    TYPE_ADD,//增加
    TYPE_DEL,//删除
    TYPE_UPDATE,//更新
    TYPE_SEL,//查询
    TYPE_MAX,//查询主键的最大值
    
#pragma mark ++ Request
    TYPE_NOTES,//获取注释
    TYPE_NORMALREQUEST,//普通网络请求
    TYPE_METHOD,//获取方法名
    TYPE_REQUEST,//网络请求的实现
    TYPE_QUERY,//query参数
}MethodType;

typedef enum TypeIndex {//增删改查 的选择索引
    INDEX_ONE,
    INDEX_TWO,
    INDEX_THREE,
    INDEX_FOUR
}TypeIndex;




@interface Utils : NSObject

/**
 model类型转化字典

 @return 类型转化字典
 */
+ (NSDictionary *)modelTypeConvertDictionary;

/**
 view类型转化字典

 @return view的类型
 */
+ (NSDictionary *)viewTypeConvertDictionary;

/**
 * @brief  为文件创建版权
 * @prama  filename:需要创建版权的文件名
 */
+(NSString *)createCopyrightByFilename:(NSString *)filename config:(NSDictionary *)config;

+(NSDictionary *)configDictionary:(NSString *)sourcePath;

+ (NSArray *)enumList:(NSString *)sourceString;

+(NSString *)note:(NSString *)note;



@end
