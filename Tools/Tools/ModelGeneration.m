//
//  ModelGeneration.m
//  Tools
//
//  Created by Alex xiang on 15/1/31.
//  Copyright (c) 2015年 Alex xiang. All rights reserved.
//

#import "ModelGeneration.h"

@implementation ModelGeneration

static NSMutableArray *enumList;
static NSDictionary *configDictionary;
/**
 * @brief  Model类自动生成
 * @prama  sourcepath:资源路径
 * @prama  outputPath:资源生成路径
 */
+(void)generationSourcePath:(NSString *)sourcepath outputPath:(NSString *)outputPath config:(NSDictionary *)config
{
    configDictionary = config;
    NSError *error;
    NSString *sourceString = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForAuxiliaryExecutable:sourcepath] encoding:NSUTF8StringEncoding error:&error];
    
    NSMutableString *h = [[NSMutableString alloc] init];
    NSMutableString *m = [[NSMutableString alloc] init];
    NSFileManager *fileManager = [[NSFileManager alloc] init];

    NSString *hFilePath = [outputPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@Model.h", config[@"filename"]]];
    NSString *mFilePath = [outputPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@Model.m", config[@"filename"]]];
    [fileManager createFileAtPath:hFilePath contents:nil attributes:nil];
    [fileManager createFileAtPath:mFilePath contents:nil attributes:nil];
    
    //版权信息的导入
    [h appendString:[Utils createCopyrightByFilename:[NSString stringWithFormat:@"%@Model.h", config[@"filename"]] config:config]];
    [m appendString:[Utils createCopyrightByFilename:[NSString stringWithFormat:@"%@Model.m", config[@"filename"]] config:config]];
    
    //头文件的导入 h 文件@class 形式导入  m 文件import
    [h appendString:[self introductionPackages:H_FILE]];
    [m appendString:[self introductionPackages:M_FILE]];
    
    //匹配出所有的枚举类型
    [h appendString:[self enumFromSourceString:sourceString]];
    
    //匹配出所有的Model类型
    [h appendString:[self messageFromSourceString:sourceString fileType:H_FILE]];
    [m appendString:[self messageFromSourceString:sourceString fileType:M_FILE]];
    
    [h writeToFile:hFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [m writeToFile:mFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

/**
 * @brief  导入头文件
 * @prama  fileType:[H_FILE:h文件  M_FILE:m文件]
 **/
+ (NSString *)introductionPackages:(FileType)fileType {
    NSMutableString *result = [[NSMutableString alloc] init];
    switch (fileType) {
        case H_FILE:
        {
            [result appendFormat:@"#import <UIKit/UIKit.h>\n"];
            [result appendFormat:@"#import <Foundation/Foundation.h>\n"];
            [result appendFormat:@"#import \"NSDictionary+Safe.h\"\n"];
            [result appendFormat:@"#import \"PHModel.h\"\n\n\n"];
        }
            break;
            
        case M_FILE:
        {
            [result appendFormat:@"#import \"PHMacro.h\"\n"];
            [result appendFormat:@"#import \"%@Model.h\"", configDictionary[@"filename"]];
        }
            break;
        default:
            break;
    }
    
    return result;
}

typedef NS_ENUM(NSUInteger, Code) {
    OK = 200,//成功
    Fail = 404,
};
/**
 * @brief  匹配出所有的枚举类型
 * @prama  sourceString:需要匹配的字符串
 **/
+ (NSString *)enumFromSourceString:(NSString *)sourceString
{
    NSMutableString *result = [[NSMutableString alloc] init];
    NSString *regex = @"enum(?:\\s+)(\\S+)(?:\\s*)\\{([\\s\\S]*?)\\}(?:\\s*?)";
    NSArray *list = [sourceString arrayOfCaptureComponentsMatchedByRegex:regex];
    enumList = [[NSMutableArray alloc] init];
    for (NSArray *contents in list) {
        @autoreleasepool {
            NSString *classname = [contents objectAtIndex:1];
            [result appendFormat:@"typedef NS_ENUM(NSUInteger, %@) {", classname];
            NSMutableString *enumString = [[NSMutableString alloc] initWithString:[contents objectAtIndex:2]];
            [enumString replaceOccurrencesOfString:@"\n    "
                                        withString:[NSString stringWithFormat:@"\n    %@_", classname]
                                           options:NSLiteralSearch
                                             range:NSMakeRange(0,[enumString length])];
            [result appendString:enumString];
            [result appendFormat:@"};\n"];
            [enumList addObject:classname];
        }
    }
    
    return result;
}

/**
 * @brief  匹配出所有的model类型
 * @prama  sourceString:需要匹配的字符串
 * @prama  fileType:[H_FILE:h文件  M_FILE: m文件]
 **/
+ (NSString *)messageFromSourceString:(NSString *)sourceString fileType:(FileType)fileType
{
    NSMutableString *result = [[NSMutableString alloc] init];
    NSString *regex = @"message((?:\\s+)(\\S+)(?:\\s*)(:(?:\\s+)(\\S+)(?:\\s*))?)\\{([\\s\\S]*?)\\}(?:\\s*?)";
    NSArray *classes = [sourceString arrayOfCaptureComponentsMatchedByRegex:regex];
    [result appendFormat:@"\n\n"];
    
    switch (fileType) {
        case H_FILE:
        {
            //@class 所有的model
            [result appendString:[self allClass:classes]];
        }
            break;
        case M_FILE:
        {
        }
            
        default:
            break;
    }

    //添加Model
    [result appendString:[self generationModelsFromClasses:classes fileType:fileType]];
    
    return result;
}

/**
 * @brief  h 文件中 @class 所有的model
 * @prama  classes:所有的model 列表
 */
+ (NSString *)allClass:(NSArray *)classes
{
    NSMutableString *result = [[NSMutableString alloc] init];
    for (NSArray *contents in classes) {
        [result appendFormat:@"@class %@;\n", [contents objectAtIndex:2]];
    }
    
    return result;
}

/**
 * @brief  生成所有的model
 * @prama  classes:所有的model列表
 * @prama  fileType:[H_FILE:h文件  M_FILE: m文件]
 */
+ (NSString *)generationModelsFromClasses:(NSArray *)classes fileType:(FileType)fileType;
{
    NSMutableString *result = [[NSMutableString alloc] init];
    @autoreleasepool {
        for (NSArray *contents in classes) {
            [result appendString:[self modelFromClass:contents fileType:fileType]];
        }
    }
    
    return result;
}

/**
 * @brief  单个model的解析
 * @prama  contents:单个的model列表
 * @prama  fileType:[H_FILE:h文件  M_FILE: m文件]
 */
+ (NSString *)modelFromClass:(NSArray *)contents fileType:(FileType)fileType
{
    NSMutableString *result = [[NSMutableString alloc] init];
    NSString *classname = [contents objectAtIndex:2];//获取类名称
    NSString *superClassname = [contents objectAtIndex:4];//获取父类名称
    if (superClassname.length == 0) {
        superClassname = @"PHModel";
    }
    switch (fileType) {
        case H_FILE:
        {
            [result appendFormat:@"\n\n@interface %@ : %@ {\n", classname, superClassname];
            [result appendFormat:@"}\n"];
        }
            break;
        case M_FILE:
        {
            [result appendFormat:@"\n\n@implementation %@\n\n", classname];
        }
            break;
            
        default:
            break;
    }
    
    NSString *modelClass = [contents objectAtIndex:5];//获取属性
    [result appendString:[self propertyFromContents:modelClass fileType:fileType]]; //属性的生成
    [result appendString:[self methodWithClass:classname contents:modelClass FileType:fileType methodType:TYPE_INIT]];//初始化方法
    [result appendString:[self methodWithClass:classname contents:modelClass FileType:fileType methodType:TYPE_KEYMAPPER]];
    
    //单个类的结束标志
    [result appendFormat:@"\n@end\n"];
    
    return result;
}

/**
 * @brief  单个model的所有property解析
 * @prama  contents:单个model的所有属性
 * @prama  fileType:[H_FILE:h文件  M_FILE: m文件]
 */
+ (NSString *)propertyFromContents:(NSString *)contents fileType:(FileType)fileType
{
    NSMutableString *result = [[NSMutableString alloc] init];
    NSMutableArray *contentsList = (NSMutableArray *)[contents componentsSeparatedByString:@"\n"];
    //移除首尾的无效数据
    [contentsList removeObjectAtIndex:0];
    [contentsList removeLastObject];
    
    [result appendString:[self allPropertys:contentsList fileType:fileType methodType:TYPE_PROPERTY]];
    
    return result;
}

/**
 * @brief  单个model的解析
 * @prama  contentsList:所有属性列表
 * @prama  fileType:[H_FILE:h文件  M_FILE: m文件]
 * @prama  methodType:方法类别
 */
+ (NSString *)allPropertys:(NSArray *)contentsList fileType:(FileType)fileType methodType:(MethodType)methodType
{
    NSMutableString *result = [[NSMutableString alloc] init];
    for (NSString *propertyString in contentsList) {
        NSString *regex = @"^(?:[\\s]*)(primary|required|optional|repeated)(?:[\\s]*)(\\S+)(?:[\\s]*)(\\S+)(?:[\\s]*)=(?:[\\s]*)(\\S+)(?:[\\s]*);([\\S\\s]*)$";
        NSArray *propertys = [propertyString arrayOfCaptureComponentsMatchedByRegex:regex];
        //判断是否有属性
        if (propertys.count == 0) {
            continue;
        }
        // 判断属性的有效性
        NSArray *fields = [propertys firstObject];
        if (fields.count < 6) {
            continue;
        }
        [result appendString:[self singleProperty:fields fileType:fileType methodType:methodType]];
        
    }
    return result;
}

/**
 * @brief  解析单条属性
 * @prama  fields:单条属性的所有字段
 * @prama  fileType:[H_FILE:h文件  M_FILE: m文件]
 * @prama  methodType:方法类别 多个方法解析
 */
+ (NSString *)singleProperty:(NSArray *)fields fileType:(FileType)fileType methodType:(MethodType)methodType
{
    NSMutableString *result = [[NSMutableString alloc] init];
    NSString *style = [fields objectAtIndex:1];//required | optional | repeated | primary...
    NSString *type = [fields objectAtIndex:2];//数据类型 string | int | float | double ....
    NSString *fieldname = [fields objectAtIndex:3];//名称
    NSString *keyname = [fields objectAtIndex:3];//key
    NSString *nameRegex = @"^(?:[\\s]*)(?:[\\s]*)(\\S+)(?:[\\s]*)((?:\\()\\S+(?:\\)))";
    NSArray *nameList = [[fieldname arrayOfCaptureComponentsMatchedByRegex:nameRegex] firstObject];
    if (nameList.count >= 3) {
        fieldname = [nameList objectAtIndex:1];
        NSMutableString *str = [[NSMutableString alloc] initWithString:[nameList objectAtIndex:2]];
        [str deleteCharactersInRange:[str rangeOfString:@"("]];
        [str deleteCharactersInRange:[str rangeOfString:@")"]];
        keyname = (NSString *)str;
    }
    NSString *defaultValue = [fields objectAtIndex:4];//默认值
    NSString *notes = [fields objectAtIndex:5];//注释
    notes = [notes stringByReplacingOccurrencesOfString:@"/" withString:@""];
    switch (fileType) {
        case H_FILE:
        {
            switch (methodType) {
                case TYPE_PROPERTY:
                {
                    [result appendString:[Utils note:notes]];//添加注释
                    if ([style isEqualToString:@"repeated"]) {//数组类型单独处理
                        [result appendFormat:@"@property (readwrite, nonatomic, strong) NSMutableArray *%@List;\n", fieldname];
                    }
                    else if (IS_BASE_TYPE(type)) {//数据的基本类型 int | float | double | bool
                        if ([[type lowercaseString] isEqualToString:@"int"] || [[type lowercaseString] isEqualToString:@"short"]) {
                            [result appendFormat:@"@property (readwrite, nonatomic, assign) NSInteger %@;\n", fieldname];
                        }
                        else if ([[type lowercaseString] isEqualToString:@"float"] || [[type lowercaseString] isEqualToString:@"double"]) {
                            [result appendFormat:@"@property (readwrite, nonatomic, assign) CGFloat %@;\n", fieldname];
                        }
                        else if([[type lowercaseString] isEqualToString:@"long"]) {
                            [result appendFormat:@"@property (readwrite, nonatomic, assign) long long %@;\n", fieldname];
                        }
                        else if ([[type lowercaseString] isEqualToString:@"bool"]){
                            [result appendFormat:@"@property (readwrite, nonatomic, assign) BOOL %@;\n", fieldname];
                        }
                        else {}
                        
                        
                    }
                    else if ([[type lowercaseString] isEqualToString:@"string"]){
                        [result appendFormat:@"@property (readwrite, nonatomic, strong) NSString *%@;\n", fieldname];
                    }
                    else if ([enumList containsObject:type]) {//枚举类型
                        [result appendFormat:@"@property (readwrite, nonatomic, assign) %@ %@;\n", type, fieldname];
                    }
                    else {
                        [result appendFormat:@"@property (readwrite, nonatomic, strong) %@ *%@;\n", type, fieldname];
                    }
                }
                    break;
                case TYPE_INIT:
                {
                }
                    break;
                case TYPE_KEYMAPPER:
                {
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        case M_FILE:
        {
            switch (methodType) {
                case TYPE_PROPERTY:
                {
                    if ([style isEqualToString:@"repeated"]) {
                        [result appendFormat:@"@synthesize %@List;\n", fieldname];
                    }
                    else {
                        [result appendFormat:@"@synthesize %@;\n", fieldname];
                    }
                }
                    break;
                case TYPE_INIT:
                {
                    if ([[style lowercaseString] isEqualToString:@"repeated"]) {
                        if ([defaultValue isEqualToString:@"nil"] || [defaultValue isEqualToString:@"0"]) {
                            [result appendFormat:@"\t\tself.%@List = [[NSMutableArray alloc] init];\n", fieldname];
                        }
                        else {
                            [result appendFormat:@"\t\tself.%@List = [[NSMutableArray alloc] initWithArray:[%@ componentsSeparatedByString:@\",\"]];\n", fieldname, defaultValue];
                        }
                    }
                    else if (IS_BASE_TYPE(type)) {
                        if ([defaultValue isEqualToString:@"nil"]) {
                            [result appendFormat:@"\t\tself.%@ = 0;\n", fieldname];
                        }
                        else {
                            [result appendFormat:@"\t\tself.%@ = %@;\n", fieldname, defaultValue];
                        }
                    }
                    else if ([[type lowercaseString] isEqualToString:@"string"]) {
                        if ([defaultValue isEqualToString:@"nil"]) {
                            [result appendFormat:@"\t\tself.%@ = @\"\";\n", fieldname];
                        }
                        else {
                            [result appendFormat:@"\t\tself.%@ = @\"%@\";\n", fieldname, defaultValue];
                        }
                    }
                    else if ([enumList containsObject:type]) {//枚举类型
                        [result appendFormat:@"\t\tself.%@ = %@;\n", fieldname, defaultValue];
                    }
                    else {
                        [result appendFormat:@"\t\tself.%@ = [[%@ alloc] init];\n", fieldname, type];
                    }
                }
                    break;
                case TYPE_KEYMAPPER:
                {
                    if (![fieldname isEqualToString:keyname]) {
                        [result appendFormat:@"\t\t\t@\"%@\":@[", fieldname];
                        NSArray *keyNames = [keyname componentsSeparatedByString:@","];
                        for (int i = 0; i < keyNames.count; i++) {
                            NSString *singleKeyname = keyNames[i];
                            if (i != 0) {
                                [result appendFormat:@","];
                            }
                            [result appendFormat:@"@\"%@\"", singleKeyname];
                        }
                        [result appendFormat:@"],\n"];
                    }
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        default:
            break;
    }
    
    
    return result;
}

/**
 * @brief  方法的生成
 * @prama  classname:类名
 * @prama  contents:单个的model列表
 * @prama  fileType:[H_FILE:h文件  M_FILE: m文件]
 * @prama  methodType:方法类别 多个方法解析
 */
+ (NSString *)methodWithClass:(NSString *)classname contents:(NSString *)contents FileType:(FileType)fileType methodType:(MethodType)methodType;
{
    NSMutableString *result = [[NSMutableString alloc] init];
    NSMutableArray *contentsList = (NSMutableArray *)[contents componentsSeparatedByString:@"\n"];
    //移除首尾的无效数据
    [contentsList removeObjectAtIndex:0];
    [contentsList removeLastObject];
    
    switch (fileType) {
        case H_FILE:
        {
            switch (methodType) {
                case TYPE_PROPERTY:
                {
                }
                    break;
                case TYPE_INIT:
                {
                }
                    break;
                case TYPE_KEYMAPPER:
                {
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case M_FILE:
        {
            switch (methodType) {
                case TYPE_PROPERTY:
                {
                }
                    break;
                case TYPE_INIT:
                {
                    [result appendString:@"\n- (id)init {\n"];
                    [result appendString:@"\tself = [super init];\n"];
                    [result appendString:@"\tif (self) {\n"];
                    [result appendString:[self allPropertys:contentsList fileType:fileType methodType:methodType]];
                    [result appendString:@"\t}\n"];
                    [result appendString:@"\treturn self;\n"];
                    [result appendString:@"}\n\n"];
                }
                    break;
                case TYPE_KEYMAPPER:
                {
                    [result appendFormat:@"+ (NSDictionary *)ph_keyMapper {\n"];
                    [result appendString:@"\treturn @{\n"];
                    [result appendString:[self allPropertys:contentsList fileType:fileType methodType:methodType]];
                    [result appendString:@"\t\t\t\t};\n"];
                    [result appendFormat:@"}\n"];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
    
    return result;
}


@end
