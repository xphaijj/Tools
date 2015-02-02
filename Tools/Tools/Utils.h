//
//  Utils.h
//  Tools
//
//  Created by Alex xiang on 15/1/31.
//  Copyright (c) 2015年 Alex xiang. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RegexKitLite.h"

#define MODEL_NAME @"Model"   //生成Model的名称
#define REQUEST_NAME @"Request" //网络文件名称
#define CopyRightVersion 1.0

#define KEY @"KEY"
#define KEY_TYPE @"KEY_TYPE"
#define KEY_FIELDNAME @"KEY_FIELDNAME"

typedef enum FileType { //文件类型
    H_FILE,
    M_FILE
}FileType;

typedef enum MethodType {//方法类型
    TYPE_PROPERTY,//属性解析
    TYPE_INIT,//初始化
    TYPE_PARSE,//解析
    TYPE_DICTIONARY,//字典化
    TYPE_SAVE,//保存
    
    TYPE_ADD,//增加
    TYPE_DEL,//删除
    TYPE_UPDATE,//更新
    TYPE_SEL//查询
}MethodType;

typedef enum TypeIndex {//增删改查 的选择索引
    INDEX_ONE,
    INDEX_TWO,
    INDEX_THREE,
    INDEX_FOUR
}TypeIndex;



@interface Utils : NSObject

/**
 * @brief  为文件创建版权
 * @prama  filename:需要创建版权的文件名
 */
+(NSString *)createCopyrightByFilename:(NSString *)filename;




@end
