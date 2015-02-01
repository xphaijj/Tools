//
//  Utils.h
//  Tools
//
//  Created by Alex xiang on 15/1/31.
//  Copyright (c) 2015年 Alex xiang. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RegexKitLite.h"

#define CopyRightVersion 1.0

typedef enum FileType { //文件类型
    H_FILE,
    M_FILE
}FileType;

typedef enum MethodType {//方法类型
    TYPE_PROPERTY,
    TYPE_INIT,
    TYPE_PARSE,
    TYPE_DICTIONARY
}MethodType;



@interface Utils : NSObject

/**
 * @brief  为文件创建版权
 * @prama  filename:需要创建版权的文件名
 */
+(NSString *)createCopyrightByFilename:(NSString *)filename;




@end
