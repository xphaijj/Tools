//
//  Utils.m
//  Tools
//
//  Created by Alex xiang on 15/1/31.
//  Copyright (c) 2015年 Alex xiang. All rights reserved.
//

#import "Utils.h"

@interface Utils () {
}
@property (nonatomic, strong) NSArray *enumList;

@end



@implementation Utils

static Utils *shareData;
+ (Utils *)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareData = [[self alloc] init];
    });
    return shareData;
}

/**
 model类型转化字典
 
 @return 类型转化字典
 */
+ (NSDictionary *)modelTypeConvertDictionary {
    return @{
             @"bool":@"BOOL ",
             @"byte":@"Byte ",
             @"char":@"Char ",
             @"short":@"NSInteger ",
             @"int":@"NSInteger ",
             @"long":@"NSInteger ",
             @"long long":@"long long ",
             @"longlong":@"long long ",
             @"time":@"long long ",
             @"float":@"CGFloat ",
             @"double":@"CGFloat ",
             @"string":@"NSString *",
             @"number":@"NSNumber *",
             @"list":@"NSMutableArray *",
             @"array":@"NSMutableArray *",
             @"map":@"NSMutableDictionary *",
             @"dic":@"NSMutableDictionary *",
             @"dictionary":@"NSMutableDictionary *",
             @"id":@"id ",
             };
}

/**
 view类型转化字典
 
 @return view的类型
 */
+ (NSDictionary *)viewTypeConvertDictionary {
    return @{
             @"label":@"UILabel *",
             @"button":@"UIButton *",
             @"btn":@"UIButton *",
             @"view":@"UIView *",
             @"imageview":@"UIImageView *",
             @"image":@"UIImageView *",
             };
}
/**
 * @brief  为文件创建版权
 * @prama  filename:需要创建版权的文件名
 */
+(NSString *)createCopyrightByFilename:(NSString *)filename config:(NSDictionary *)config{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy/MM/dd";
    
    NSMutableString *copyright = [[NSMutableString alloc] init];
    [copyright appendFormat:@"//\n"];
    [copyright appendFormat:@"// %@ \n//\n", filename];
    [copyright appendFormat:@"// Created By 项普华 Version: %@\n", config[@"version"]];
    [copyright appendFormat:@"// Copyright (C) %@  By AlexXiang  All rights reserved.\n", [dateFormatter stringFromDate:[NSDate date]]];
    [copyright appendFormat:@"// email:// xiangpuhua@126.com  tel:// +86 13316987488 \n"];
    [copyright appendFormat:@"//\n//\n\n"];
    
    return copyright;
}

+(NSDictionary *)configDictionary:(NSString *)sourcePath {
    NSString *sourceString = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForAuxiliaryExecutable:sourcePath] encoding:NSUTF8StringEncoding error:nil];
    
    NSDictionary *result = @{@"version":@"3.0",
                             @"request":@"json",//数据请求类型  json xml
                             @"response":@"json", //数据返回类型 json xml
                             @"pods":@YES,  //是否是pods
                             @"filename":@"PP", //文件名开头
                             @"content_type":@"text/html",//content_type
                             };
    NSString *regex = @"Config(?:\\s+)(\\S+)(?:\\s*)\\{([\\s\\S]*?)\\}(?:\\s*?)";
    NSArray *list = [sourceString arrayOfCaptureComponentsMatchedByRegex:regex];
    if (list.count > 0) {
        NSArray *contents = list[0];
        NSString *jsonString = [NSString stringWithFormat:@"{%@}", contents[2]];
        result = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
        NSLog(@"%@", result);
    }
    
    return result;
}
/**
 * @brief  匹配出所有的枚举类型
 * @prama  sourceString:需要匹配的字符串
 **/
+ (NSArray *)enumList:(NSString *)sourceString {
    if ([Utils shareInstance].enumList) {
        return [Utils shareInstance].enumList;
    }
    NSString *regex = @"enum(?:\\s+)(\\S+)(?:\\s*)\\{([\\s\\S]*?)\\}(?:\\s*?)";
    NSArray *list = [sourceString arrayOfCaptureComponentsMatchedByRegex:regex];
    NSMutableArray *enumList = [[NSMutableArray alloc] init];
    for (NSArray *contents in list) {
        @autoreleasepool {
            NSString *classname = [contents objectAtIndex:1];
            NSMutableString *enumString = [[NSMutableString alloc] initWithString:[contents objectAtIndex:2]];
            [enumString replaceOccurrencesOfString:@"\n    "
                                        withString:[NSString stringWithFormat:@"\n    %@_", classname]
                                           options:NSLiteralSearch
                                             range:NSMakeRange(0,[enumString length])];
            [enumList addObject:classname];
        }
    }
    [Utils shareInstance].enumList = enumList;
    return [Utils shareInstance].enumList;
}

+(NSString *)note:(NSString *)note {
    return [NSString stringWithFormat:@"/** %@ */\n", note];
}


@end
