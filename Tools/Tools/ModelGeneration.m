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

/**
 * @brief  Model类自动生成
 * @prama  sourcepath:资源路径   
 * @prama  outputPath:资源生成路径
 */
+(void)generationSourcePath:(NSString *)sourcepath outputPath:(NSString *)outputPath
{
    NSError *error;
    NSString *sourceString = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForAuxiliaryExecutable:sourcepath] encoding:NSUTF8StringEncoding error:&error];
    
    NSMutableString *h = [[NSMutableString alloc] init];
    NSMutableString *m = [[NSMutableString alloc] init];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    NSString *hFilePath = [outputPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.h", MODEL_NAME]];
    NSString *mFilePath = [outputPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.m", MODEL_NAME]];
    [fileManager createFileAtPath:hFilePath contents:nil attributes:nil];
    [fileManager createFileAtPath:mFilePath contents:nil attributes:nil];
    
//版权信息的导入
    [h appendString:[Utils createCopyrightByFilename:MODEL_NAME]];
    [m appendString:[Utils createCopyrightByFilename:MODEL_NAME]];
    
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
        }
            break;
        
        case M_FILE:
        {
            [result appendFormat:@"#import \"%@.h\"", MODEL_NAME];
        }
            break;
        default:
            break;
    }
    
    return result;
}

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
            NSMutableString *enumString = [[NSMutableString alloc] initWithString:[contents firstObject]];
            NSString *classname = [contents objectAtIndex:1];
            [enumString replaceOccurrencesOfString:@"\n    "
                                        withString:[NSString stringWithFormat:@"\n    %@_", classname]
                                           options:NSLiteralSearch
                                             range:NSMakeRange(0,[enumString length])];
            [result appendFormat:@"\ntypedef %@ %@;\n", enumString, classname];
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
    NSString *regex = @"message(?:\\s+)(\\S+)(?:\\s*)\\{([\\s\\S]*?)\\}(?:\\s*?)";
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
    
    //添加基类
    [result appendString:[self baseModel:fileType]];
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
        [result appendFormat:@"@class %@;\n", [contents objectAtIndex:1]];
    }
    
    return result;
}

/**
 * @brief  model 基类的实现
 * @prama  fileType:[H_FILE:h文件  M_FILE: m文件]
 */
+ (NSString *)baseModel:(FileType)fileType
{
    NSMutableString *result = [[NSMutableString alloc] init];
    switch (fileType) {
        case H_FILE:
        {
            [result appendString:@"static NSString *dbPath;\n\n"];
            [result appendString:@"\n\n@interface OObject : NSObject {\n"];
            [result appendString:@"}\n"];
            [result appendString:@"+(NSString *)initialDB;\n"];
            [result appendString:@"\n@end\n"];
        }
            break;
        case M_FILE:
        {
            [result appendString:@"\n\n@implementation OObject \n"];
            [result appendString:@"\n+(NSString *)initialDB {\n"];
            [result appendString:@"\tstatic dispatch_once_t onceToken;\n"];
            [result appendString:@"\tdispatch_once(&onceToken, ^{\n"];
            [result appendString:@"\t\tNSString *dirPath = [NSString stringWithFormat:@\"%@/%@\", [NSSearchPathForDirectoriesInDomains(NSCachesDirectory , NSUserDomainMask , YES) lastObject], @\"DB\"];\n"];
            [result appendString:@"\t\tBOOL isDir = NO;\n"];
            [result appendString:@"\t\tbool existed = [[NSFileManager defaultManager] fileExistsAtPath:dirPath isDirectory:&isDir];\n"];
            [result appendString:@"\t\tif (!(isDir == YES && existed == YES)) {\n"];
            [result appendString:@"\t\t\t[[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];\n"];
            [result appendString:@"\t\t}\n"];
            [result appendString:@"\t\tdbPath = [NSString stringWithFormat:@\"%@/database.sqlite\", dirPath];\n"];
            [result appendString:@"\t});\n"];
            [result appendString:@"\treturn dbPath;\n"];
            [result appendString:@"}\n"];
            [result appendString:@"\n\n@end\n\n"];
        }
            break;
            
        default:
            break;
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
    NSString *classname = [contents objectAtIndex:1];//获取类名称
    switch (fileType) {
        case H_FILE:
        {
            [result appendFormat:@"\n\n@interface %@ : OObject {\n", classname];
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
    
    NSString *modelClass = [contents objectAtIndex:2];//获取属性
    [result appendString:[self propertyFromContents:modelClass fileType:fileType]]; //属性的生成
    [result appendString:[self methodWithClass:classname contents:modelClass FileType:fileType methodType:TYPE_INIT]];//初始化方法
    [result appendString:[self methodWithClass:classname contents:modelClass FileType:fileType methodType:TYPE_PARSE]];//解析方法
    [result appendString:[self methodWithClass:classname contents:modelClass FileType:fileType methodType:TYPE_DICTIONARY]];//字典化
    [result appendString:[self methodWithClass:classname contents:modelClass FileType:fileType methodType:TYPE_SAVE]];//存取
    
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
        keyname = [nameList objectAtIndex:1];
        NSMutableString *str = [[NSMutableString alloc] initWithString:[nameList objectAtIndex:2]];
        [str deleteCharactersInRange:[str rangeOfString:@"("]];
        [str deleteCharactersInRange:[str rangeOfString:@")"]];
        fieldname = (NSString *)str;
    }
    NSString *defaultValue = [fields objectAtIndex:4];//默认值
    NSString *notes = [fields objectAtIndex:5];//注释
    
    switch (fileType) {
        case H_FILE:
        {
            switch (methodType) {
                case TYPE_PROPERTY:
                {
                    if ([style isEqualToString:@"repeated"]) {//数组类型单独处理
                        [result appendFormat:@"@property (readwrite, nonatomic, strong) NSMutableArray *%@List;//%@\n", fieldname, notes];
                    }
                    else if (IS_BASE_TYPE(type)) {//数据的基本类型 int | float | double | bool
                        [result appendFormat:@"@property (readwrite, nonatomic, assign) %@ %@;//%@\n", [type lowercaseString], fieldname, notes];
                    }
                    else if ([[type lowercaseString] isEqualToString:@"string"]){
                        [result appendFormat:@"@property (readwrite, nonatomic, strong) NSString *%@;//%@\n", fieldname, notes];
                    }
                    else {
                        [result appendFormat:@"@property (readwrite, nonatomic, strong) %@ *%@;//%@\n", type, fieldname, notes];
                    }
                }
                    break;
                case TYPE_INIT:
                {
                }
                    break;
                case TYPE_PARSE:
                {}
                    break;
                case TYPE_DICTIONARY:
                {
                }
                    break;
                case TYPE_SAVE:
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
                        [result appendFormat:@"@synthesize %@List;\n//%@", fieldname, notes];
                    }
                    else {
                        [result appendFormat:@"@synthesize %@;//%@\n", fieldname, notes];
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
                    else {
                        [result appendFormat:@"\t\tself.%@ = [[%@ alloc] init];\n", fieldname, type];
                    }
                }
                    break;
                case TYPE_PARSE:
                {
                    if ([[style lowercaseString] isEqualToString:@"repeated"]) {
                        [result appendFormat:@"\tif ([sender.allKeys containsObject:@\"%@\"] && [[sender objectForKey:@\"%@\"] isKindOfClass:[NSArray class]]) {\n", keyname, keyname];
                        if (IS_BASE_TYPE(type) || [[type lowercaseString] isEqualToString:@"string"] || [enumList containsObject:type]) {
                            [result appendFormat:@"\t\tself.%@List addObjectsFromArray:[sender objectForKey:@\"%@\"];\n", fieldname, keyname];
                        }
                        else {
                            [result appendFormat:@"\t\tfor (id object in [sender objectForKey:@\"%@\"]) {\n", keyname];
                            [result appendFormat:@"\t\t\tif (object && [object isKindOfClass:[NSDictionary class]]) {\n"];
                            [result appendFormat:@"\t\t\t\t%@ *item = [%@ parseFromDictionary:object];\n", type, type];
                            [result appendFormat:@"\t\t\t\t[self.%@List addObject:item];\n", fieldname];
                            [result appendFormat:@"\t\t\t}\n"];
                            [result appendFormat:@"\t\t}\n"];
                        }
                        [result appendString:@"\t}\n"];
                    }
                    else if (IS_BASE_TYPE(type) || [enumList containsObject:type]) {
                        if ([[style lowercaseString] isEqualToString:@"required"]) {//必需字段
                            [result appendFormat:@"\tNSAssert(([[sender allKeys] containsObject:@\"%@\"] && !([[sender objectForKey:@\"%@\"] isKindOfClass:[NSNull class]])), @\"字段不能为空\");\n", keyname, keyname];
                        }
                        if (IS_BASE_TYPE(type)) {
                            [result appendFormat:@"\tself.%@ = [[sender objectForKey:@\"%@\"] %@Value];\n", fieldname, keyname, [type lowercaseString]];
                        }
                        else {
                            [result appendFormat:@"\tself.%@ = [[sender objectForKey:@\"%@\"] intValue];\n", fieldname, keyname];
                        }
                    }
                    else if ([[type lowercaseString] isEqualToString:@"string"]) {
                        if ([[style lowercaseString] isEqualToString:@"required"]) {//必需字段
                            [result appendFormat:@"\tNSAssert(([[sender allKeys] containsObject:@\"%@\"] && !([[sender objectForKey:@\"%@\"] isKindOfClass:[NSNull class]])), @\"字段不能为空\");\n", keyname, keyname];
                        }
                        [result appendFormat:@"\tself.%@ = [sender objectForKey:@\"%@\"];\n", fieldname, keyname];
                    }
                    else {
                        if ([[style lowercaseString] isEqualToString:@"required"]) {//必需字段
                            [result appendFormat:@"\tNSAssert(([[sender allKeys] containsObject:@\"%@\"] && !([[sender objectForKey:@\"%@\"] isKindOfClass:[NSNull class]])), @\"字段不能为空\");\n", keyname, keyname];
                        }
                        [result appendFormat:@"\tif ([sender.allKeys containsObject:@\"%@\"] && [[sender objectForKey:@\"%@\"] isKindOfClass:[NSDictionary class]]) {\n", keyname, keyname];
                        [result appendFormat:@"\t\tself.%@ = [%@ parseFromDictionary:[sender objectForKey:@\"%@\"]];\n", fieldname, type, keyname];
                        [result appendFormat:@"\t}\n"];
                    }
                }
                    break;
                case TYPE_DICTIONARY:
                {
                    if ([[style lowercaseString] isEqualToString:@"repeated"]) {
                        if (IS_BASE_TYPE(type) || [[type lowercaseString] isEqualToString:@"string"] || [enumList containsObject:type]) {
                            [result appendFormat:@"\t[dictionaryValue setObject:self.%@List forKey:@\"%@\"];\n", fieldname, keyname];
                        }
                        else {
                            
                            [result appendFormat:@"\tNSMutableArray *%@Items = [[NSMutableArray alloc] init];\n", fieldname];
                            [result appendFormat:@"\tfor (%@ *item in self.%@List) {\n", type, fieldname];
                            [result appendFormat:@"\t\t[%@Items addObject:[item dictionaryValue]];\n", fieldname];
                            [result appendFormat:@"\t}\n"];
                            [result appendFormat:@"\t[dictionaryValue setObject:%@Items forKey:@\"%@\"];\n", fieldname, keyname];
                        }
                    }
                    else if (IS_BASE_TYPE(type) || [enumList containsObject:type]) {
                        [result appendFormat:@"\t[dictionaryValue setObject:[NSNumber numberWith%@:self.%@] forKey:@\"%@\"];\n", [NSString stringWithFormat:@"%@%@", [[type substringToIndex:1] uppercaseString], [type substringFromIndex:1]], fieldname, keyname];
                    }
                    else if ([[type lowercaseString] isEqualToString:@"string"]) {
                        [result appendFormat:@"\t[dictionaryValue setObject:self.%@ forKey:@\"%@\"];\n", fieldname, keyname];
                    }
                    else {
                        [result appendFormat:@"\t[dictionaryValue setObject:[self.%@ dictionaryValue] forKey:@\"%@\"];\n", fieldname, keyname];
                    }
                }
                    break;
                case TYPE_SAVE:
                {
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
                    [result appendString:@"\n- (id)init;\n"];
                }
                    break;
                case TYPE_PARSE:
                {
                    [result appendFormat:@"+ (%@ *)parseFromDictionary:(NSDictionary *)sender;\n", classname];
                    [result appendFormat:@"- (%@ *)parseFromDictionary:(NSDictionary *)sender;\n", classname];
                }
                    break;
                case TYPE_DICTIONARY:
                {
                    [result appendFormat:@"- (NSDictionary *)dictionaryValue;\n"];
                }
                    break;
                case TYPE_SAVE:
                {
                    [result appendFormat:@"- (BOOL)saveForKey:(NSString *)sender;\n"];
                    [result appendFormat:@"+ (%@ *)findForKey:(NSString *)sender;\n", classname];
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
                case TYPE_PARSE:
                {
                    [result appendFormat:@"\n+ (%@ *)parseFromDictionary:(NSDictionary *)sender {\n", classname];
                    [result appendFormat:@"\treturn [[[%@ alloc] init] parseFromDictionary:sender];\n", classname];
                    [result appendFormat:@"}\n\n"];
                    [result appendFormat:@"\n- (%@ *)parseFromDictionary:(NSDictionary *)sender {\n", classname];
                    [result appendFormat:@"\tif ([self init]) {\n"];
                    [result appendFormat:@"\t\tNSString *errors = [NSString stringWithFormat:@\"%@ 初始化失败\"];\n", classname];
                    [result appendFormat:@"\t\tSHOW_REQUEST_ERRORS(errors);\n"];
                    [result appendString:@"\t}\n"];
                    [result appendString:@"\tif (![sender isKindOfClass:[NSDictionary class]]) {\n"];
                    [result appendFormat:@"\t\tNSString *errors = [NSString stringWithFormat:@\"%@ 解析非字典类\"];\n", classname];
                    [result appendFormat:@"\t\tSHOW_REQUEST_ERRORS(errors);\n"];
                    [result appendString:@"\t\treturn self;\n"];
                    [result appendString:@"\t}\n"];
                    [result appendString:[self allPropertys:contentsList fileType:fileType methodType:methodType]];
                    [result appendString:@"\treturn self;\n"];
                    [result appendFormat:@"}\n\n"];
                }
                    break;
                case TYPE_DICTIONARY:
                {
                    [result appendFormat:@"\n- (NSDictionary *)dictionaryValue {\n"];
                    [result appendFormat:@"\tNSMutableDictionary *dictionaryValue = [[NSMutableDictionary alloc] init];\n"];
                    [result appendString:[self allPropertys:contentsList fileType:fileType methodType:methodType]];
                    [result appendFormat:@"\treturn dictionaryValue;\n"];
                    [result appendFormat:@"}\n"];
                }
                    break;
                case TYPE_SAVE:
                {
                    [result appendFormat:@"\n- (BOOL)saveForKey:(NSString *)sender {\n"];
                    [result appendFormat:@"\tNSDictionary *dictionaryValue = [self dictionaryValue];\n"];
                    [result appendFormat:@"\t[[NSUserDefaults standardUserDefaults] setObject:dictionaryValue forKey:sender];\n"];
                    [result appendFormat:@"\tBOOL saveResult = [[NSUserDefaults standardUserDefaults] synchronize];\n"];
                    [result appendFormat:@"return saveResult;\n"];
                    [result appendFormat:@"}\n"];
                    
                    [result appendFormat:@"\n+ (%@ *)findForKey:(NSString *)sender {\n", classname];
                    [result appendFormat:@"\tNSDictionary *findDictionary = [[NSUserDefaults standardUserDefaults] objectForKey:sender];\n"];
                    [result appendFormat:@"\tif (![findDictionary isKindOfClass:[NSDictionary class]]) {\n"];
                    [result appendFormat:@"\t\t[[[UIAlertView alloc] initWithTitle:@\"FindForKey 出现错误\" message:nil delegate:nil cancelButtonTitle:@\"好的\" otherButtonTitles:nil, nil] show];\n"];
                    [result appendFormat:@"\t\treturn nil;\n"];
                    [result appendFormat:@"\t}\n"];
                    [result appendFormat:@"\t%@ *findResult = [%@ parseFromDictionary:findDictionary];\n", classname, classname];
                    [result appendFormat:@"\treturn findResult;\n"];
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
