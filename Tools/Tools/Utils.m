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
+(NSString *)createCopyrightByFilename:(NSString *)filename {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy/MM/dd";
    
    NSMutableString *copyright = [[NSMutableString alloc] init];
    [copyright appendFormat:@"//\n"];
    [copyright appendFormat:@"// %@ \n//\n", filename];
    [copyright appendFormat:@"// Created By 项普华 Version: %.1f\n", CopyRightVersion];
    [copyright appendFormat:@"// Copyright (C) %@  By AlexXiang  All rights reserved.\n", [dateFormatter stringFromDate:[NSDate date]]];
    [copyright appendFormat:@"// email:// 496007302@qq.com  tel:// +86 13316987488 \n"];
    [copyright appendFormat:@"//\n//\n\n"];
    
    return copyright;
}




@end
