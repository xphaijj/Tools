//
//  Utils.m
//  Tools
//
//  Created by Alex xiang on 15/1/31.
//  Copyright (c) 2015年 Alex xiang. All rights reserved.
//

#import "Utils.h"

@implementation Utils

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
    [copyright appendFormat:@"// email:// 496007302@qq.com  tel:// +86 13316987488 \n"];
    [copyright appendFormat:@"//\n//\n\n"];
    
    return copyright;
}

+(NSDictionary *)configDictionary:(NSString *)sourcePath {
    NSString *sourceString = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForAuxiliaryExecutable:sourcePath] encoding:NSUTF8StringEncoding error:nil];
    
    NSDictionary *result = @{@"version":@"1.0",
                             @"request":@"json",//数据请求类型  json xml
                             @"response":@"json", //数据返回类型 json xml
                             @"pods":@YES,  //是否是pods
                             @"filename":@"PP" //文件名开头
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


@end
