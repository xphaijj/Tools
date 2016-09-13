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
        }
            break;
            
        case M_FILE:
        {
            [result appendFormat:@"#import \"%@Config.h\"\n", configDictionary[@"filename"]];
            [result appendFormat:@"#import \"%@Model.h\"", configDictionary[@"filename"]];
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
    NSString *regex = @"message((?:\\s+)(\\S+)(?:\\s*)(:(?:\\s+)(\\S+)(?:\\s*))?)\\{([\\s\\S]*?)\\}(?:\\s*?)";
    NSArray *classes = [sourceString arrayOfCaptureComponentsMatchedByRegex:regex];
    [result appendFormat:@"\n\n"];
    
    switch (fileType) {
        case H_FILE:
        {
            //@class 所有的model
            [result appendFormat:@"@class OObject;\n"];
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
        [result appendFormat:@"@class %@;\n", [contents objectAtIndex:2]];
    }
    [result appendFormat:@"\n"];
    for (NSArray *contents in classes) {
        [result appendFormat:@"static %@ *%@ShareObject = nil;\n", [contents objectAtIndex:2], [[contents objectAtIndex:2] lowercaseString]];
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
            [result appendFormat:@"%@", [[NSString alloc] initWithContentsOfURL:[NSURL URLWithString:@"http://git.oschina.net/phxiang/Public/raw/master/OObject.h"] encoding:NSUTF8StringEncoding error:nil]];
        }
            break;
        case M_FILE:
        {
            [result appendFormat:@"%@", [[NSString alloc] initWithContentsOfURL:[NSURL URLWithString:@"http://git.oschina.net/phxiang/Public/raw/master/OObject.m"] encoding:NSUTF8StringEncoding error:nil]];
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
    NSString *classname = [contents objectAtIndex:2];//获取类名称
    NSString *superClassname = [contents objectAtIndex:4];//获取父类名称
    if (superClassname.length == 0) {
        superClassname = @"OObject";
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
    [result appendString:[self methodWithClass:classname contents:modelClass FileType:fileType methodType:TYPE_STATIC]];
    [result appendString:[self methodWithClass:classname contents:modelClass FileType:fileType methodType:TYPE_PARSE]];//解析方法
    [result appendString:[self methodWithClass:classname contents:modelClass FileType:fileType methodType:TYPE_DICTIONARY]];//字典化
    [result appendString:[self methodWithClass:classname contents:modelClass FileType:fileType methodType:TYPE_COPY]];//拷贝
    
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
                    if ([style isEqualToString:@"repeated"]) {//数组类型单独处理
                        [result appendFormat:@"@property (readwrite, nonatomic, strong) NSMutableArray *%@List;//%@\n", fieldname, notes];
                    }
                    else if (IS_BASE_TYPE(type)) {//数据的基本类型 int | float | double | bool
                        if ([[type lowercaseString] isEqualToString:@"int"] || [[type lowercaseString] isEqualToString:@"short"]) {
                            [result appendFormat:@"@property (readwrite, nonatomic, assign) NSInteger %@;//%@\n", fieldname, notes];
                        }
                        else if ([[type lowercaseString] isEqualToString:@"float"] || [[type lowercaseString] isEqualToString:@"double"]) {
                            [result appendFormat:@"@property (readwrite, nonatomic, assign) CGFloat %@;//%@\n", fieldname, notes];
                        }
                        else if([[type lowercaseString] isEqualToString:@"long"]) {
                            [result appendFormat:@"@property (readwrite, nonatomic, assign) long long %@;//%@\n", fieldname, notes];
                        }
                        else if ([[type lowercaseString] isEqualToString:@"bool"]){
                            [result appendFormat:@"@property (readwrite, nonatomic, assign) BOOL %@;//%@\n", fieldname, notes];
                        }
                        else {}
                        
                        
                    }
                    else if ([[type lowercaseString] isEqualToString:@"string"]){
                        [result appendFormat:@"@property (readwrite, nonatomic, strong) NSString *%@;//%@\n", fieldname, notes];
                    }
                    else if ([enumList containsObject:type]) {//枚举类型
                        [result appendFormat:@"@property (readwrite, nonatomic, assign) %@ %@;//%@\n", type, fieldname, notes];
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
                case TYPE_STATIC:
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
                    else if ([enumList containsObject:type]) {//枚举类型
                        [result appendFormat:@"\t\tself.%@ = %@;\n", fieldname, defaultValue];
                    }
                    else {
                        [result appendFormat:@"\t\tself.%@ = [[%@ alloc] init];\n", fieldname, type];
                    }
                }
                    break;
                case TYPE_PARSE:
                {
                    if ([[style lowercaseString] isEqualToString:@"repeated"]) {
                        [result appendFormat:@"\tif ([sender hasKey:@\"%@\"]) {\n", keyname];
                        if (IS_BASE_TYPE(type) || [[type lowercaseString] isEqualToString:@"string"] || [enumList containsObject:type]) {
                            [result appendFormat:@"\t\t[self.%@List addObjectsFromArray:[sender arrayForKey:@\"%@\"]];\n", fieldname, keyname];
                        }
                        else {
                            [result appendFormat:@"\t\tfor (id object in [sender arrayForKey:@\"%@\"]) {\n", keyname];
                            
                            [result appendFormat:@"\t\t\tif (object && [object isKindOfClass:[NSDictionary class]]) {\n"];
                            [result appendFormat:@"\t\t\t\t%@ *item = (%@ *)[%@ parseFromDictionary:object];\n", type, type, type];
                            [result appendFormat:@"\t\t\t\t[self.%@List addObject:item];\n", fieldname];
                            [result appendFormat:@"\t\t\t}\n"];
                            
                            [result appendFormat:@"\t\t\telse if (object && [object isKindOfClass:[NSArray class]]) {\n"];
                            [result appendFormat:@"\t\t\t\tif (((NSArray *)object).count > 0 && [((NSArray *)object)[0] isKindOfClass:[NSDictionary class]]) {\n"];
                            [result appendFormat:@"\t\t\t\t\t%@ *item = (%@ *)[%@ parseFromDictionary:((NSArray *)object)[0]];\n", type, type, type];
                            [result appendFormat:@"\t\t\t\t\t[self.%@List addObject:item];\n", fieldname];
                            [result appendFormat:@"\t\t\t\t}\n"];
                            [result appendFormat:@"\t\t\t\telse {\n"];
                            [result appendFormat:@"\t\t\t\t\t%@ *item = (%@ *)[%@ parseFromDictionary:@{}];\n", type, type, type];
                            [result appendFormat:@"\t\t\t\t\t[self.%@List addObject:item];\n", fieldname];
                            [result appendFormat:@"\t\t\t\t}\n"];
                            [result appendFormat:@"\t\t\t}\n"];
                            
                            [result appendFormat:@"\t\t}\n"];
                        }
                        [result appendString:@"\t}\n"];
                        
                        [result appendFormat:@"\telse if ([sender hasKey:@\"%@\"] && [[sender dictionaryForKey:@\"%@\"] isKindOfClass:[NSDictionary class]]) {\n", keyname, keyname];
                        if (IS_BASE_TYPE(type) || [[type lowercaseString] isEqualToString:@"string"] || [enumList containsObject:type]) {
                            [result appendFormat:@"\t\t[self.%@List addObject:[sender arrayForKey:@\"%@\"]];\n", fieldname, keyname];
                        }
                        else {
                            [result appendFormat:@"\t\t%@ *item = (%@ *)[%@ parseFromDictionary:[sender objectForKey:@\"%@\"]];\n", type, type, type, keyname];
                            [result appendFormat:@"\t\t[self.%@List addObject:item];\n", fieldname];
                        }
                        [result appendString:@"\t}\n"];
                    }
                    else if (IS_BASE_TYPE(type) || [enumList containsObject:type]) {
                        if ([[style lowercaseString] isEqualToString:@"required"]) {//必需字段
                            [result appendFormat:@"\tif (![sender hasKey:@\"%@\"]) {\n", keyname];
                            [result appendFormat:@"\t\tCCLOG(@\"%@ +++++++++++++++MODEL+++++++++++++ 必须字段为空\");\n", fieldname];
                            [result appendFormat:@"\t}\n"];
                        }
                        if (IS_BASE_TYPE(type)) {
                            if ([[type lowercaseString] isEqualToString:@"int"] || [[type lowercaseString] isEqualToString:@"short"]) {
                                [result appendFormat:@"\tself.%@ = [sender int32ForKey:@\"%@\"];\n", fieldname, keyname];
                            }
                            else if ([[type lowercaseString] isEqualToString:@"float"] || [[type lowercaseString] isEqualToString:@"double"]) {
                                [result appendFormat:@"\tself.%@ = [sender CGFloatForKey:@\"%@\"];\n", fieldname, keyname];
                            }
                            else if ([[type lowercaseString] isEqualToString:@"long"]) {
                                [result appendFormat:@"\tself.%@ = [sender longLongForKey:@\"%@\"];\n", fieldname, keyname];
                            }
                            else if ([[type lowercaseString] isEqualToString:@"bool"]) {
                                [result appendFormat:@"\tself.%@ = [sender boolForKey:@\"%@\"];\n", fieldname, keyname];
                            }
                            else  {
                            }
                        }
                        else {
                            [result appendFormat:@"\tself.%@ = [sender int32ForKey:@\"%@\"];\n", fieldname, keyname];
                        }
                    }
                    else if ([[type lowercaseString] isEqualToString:@"string"]) {
                        if ([[style lowercaseString] isEqualToString:@"required"]) {//必需字段
                            [result appendFormat:@"\tif (![sender hasKey:@\"%@\"]) {\n", keyname];
                            [result appendFormat:@"\t\tCCLOG(@\"%@ +++++++++++++++MODEL+++++++++++++ 必须字段为空\");\n", fieldname];
                            [result appendFormat:@"\t}\n"];
                        }
                        [result appendFormat:@"\tself.%@ = [sender stringForKey:@\"%@\"];\n", fieldname, keyname];
                    }
                    else {
                        if ([[style lowercaseString] isEqualToString:@"required"]) {//必需字段
                            [result appendFormat:@"\tif (![sender hasKey:@\"%@\"]) {\n", keyname];
                            [result appendFormat:@"\t\tCCLOG(@\"%@ +++++++++++++++MODEL+++++++++++++ 必须字段为空\");\n", fieldname];
                            [result appendFormat:@"\t}\n"];
                        }
                        [result appendFormat:@"\tif ([sender hasKey:@\"%@\"] && [[sender dictionaryForKey:@\"%@\"] isKindOfClass:[NSDictionary class]]) {\n", keyname, keyname];
                        [result appendFormat:@"\t\tself.%@ = (%@ *)[%@ parseFromDictionary:[sender dictionaryForKey:@\"%@\"]];\n", fieldname, type, type, keyname];
                        [result appendFormat:@"\t}\n"];
                    }
                }
                    break;
                case TYPE_DICTIONARY:
                {
                    if ([[style lowercaseString] isEqualToString:@"repeated"]) {
                        if (IS_BASE_TYPE(type) || [[type lowercaseString] isEqualToString:@"string"] || [enumList containsObject:type]) {
                            [result appendFormat:@"\t[dictionaryValue setObj:self.%@List forKey:@\"%@\"];\n", fieldname, keyname];
                        }
                        else {
                            [result appendFormat:@"\tNSMutableArray *%@Items = [[NSMutableArray alloc] init];\n", fieldname];
                            [result appendFormat:@"\tfor (%@ *item in self.%@List) {\n", type, fieldname];
                            [result appendFormat:@"\t\t[%@Items addObject:[item dictionaryValue]];\n", fieldname];
                            [result appendFormat:@"\t}\n"];
                            [result appendFormat:@"\t[dictionaryValue setObj:%@Items forKey:@\"%@\"];\n", fieldname, keyname];
                        }
                    }
                    else if (IS_BASE_TYPE(type)) {
                        if ([[type lowercaseString] isEqualToString:@"int"] || [[type lowercaseString] isEqualToString:@"short"]) {
                            [result appendFormat:@"\t[dictionaryValue setObj:[NSNumber numberWithInteger:self.%@] forKey:@\"%@\"];\n", fieldname, keyname];
                        }
                        else  {
                            [result appendFormat:@"\t[dictionaryValue setObj:[NSNumber numberWith%@:self.%@] forKey:@\"%@\"];\n", [NSString stringWithFormat:@"%@%@", [[type substringToIndex:1] uppercaseString], [type substringFromIndex:1]], fieldname, keyname];
                        }
                    }
                    else if ([enumList containsObject:type]) {
                        [result appendFormat:@"\t[dictionaryValue setObj:[NSNumber numberWithInteger:self.%@] forKey:@\"%@\"];\n", fieldname, keyname];
                    }
                    else if ([[type lowercaseString] isEqualToString:@"string"]) {
                        [result appendFormat:@"\t[dictionaryValue setObj:self.%@ forKey:@\"%@\"];\n", fieldname, keyname];
                    }
                    else {
                        [result appendFormat:@"\t[dictionaryValue setObj:[self.%@ dictionaryValue] forKey:@\"%@\"];\n", fieldname, keyname];
                    }
                }
                    break;
                case TYPE_COPY:
                {
                    if ([[style lowercaseString] isEqualToString:@"repeated"]) {
                        [result appendFormat:@"\t\tobject.%@List = [[NSMutableArray alloc] initWithArray:self.%@List copyItems:YES];\n", fieldname, fieldname];
                    }
                    else if (IS_BASE_TYPE(type)) {
                        [result appendFormat:@"\t\tobject.%@ = self.%@;\n", fieldname, fieldname];
                    }
                    else if ([[type lowercaseString] isEqualToString:@"string"]) {
                        [result appendFormat:@"\t\tobject.%@ = self.%@;\n", fieldname, fieldname];
                    }
                    else if ([enumList containsObject:type]) {//枚举类型
                        [result appendFormat:@"\t\tobject.%@ = self.%@;\n", fieldname, fieldname];
                    }
                    else {
                        [result appendFormat:@"\t\tobject.%@ = self.%@.copy;\n", fieldname, fieldname];
                    }
                }
                    break;
                case TYPE_STATIC:
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
                    [result appendFormat:@"- (%@ *)parseFromDictionary:(NSDictionary *)sender;\n", classname];
                }
                    break;
                case TYPE_DICTIONARY:
                {
                    [result appendFormat:@"- (NSMutableDictionary *)dictionaryValue;\n"];
                }
                    break;
                case TYPE_COPY:
                {
                    [result appendFormat:@"- (void)copyOperationWithObject:(%@ *)object;\n", classname];
                }
                    break;
                case TYPE_STATIC:
                {
                    [result appendFormat:@"+ (%@ *)shareInstance;\n", classname];
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
                    [result appendFormat:@"\n- (%@ *)parseFromDictionary:(NSDictionary *)sender {\n", classname];
                    [result appendFormat:@"\t[super parseFromDictionary:sender];\n"];
                    [result appendString:[self allPropertys:contentsList fileType:fileType methodType:methodType]];
                    [result appendString:@"\treturn self;\n"];
                    [result appendFormat:@"}\n\n"];
                }
                    break;
                case TYPE_DICTIONARY:
                {
                    [result appendFormat:@"\n- (NSMutableDictionary *)dictionaryValue {\n"];
                    [result appendFormat:@"\tNSMutableDictionary *dictionaryValue = [super dictionaryValue];\n"];
                    [result appendString:[self allPropertys:contentsList fileType:fileType methodType:methodType]];
                    [result appendFormat:@"\treturn dictionaryValue;\n"];
                    [result appendFormat:@"}\n"];
                }
                    break;
                case TYPE_COPY:
                {
                    [result appendFormat:@"\n- (void)copyOperationWithObject:(%@ *)object {\n", classname];
                    [result appendString:[self allPropertys:contentsList fileType:fileType methodType:methodType]];
                    [result appendFormat:@"}\n\n"];
                }
                    break;
                case TYPE_STATIC:
                {
                    [result appendFormat:@"+ (%@ *)shareInstance {\n", classname];
                    [result appendFormat:@"\tstatic dispatch_once_t onceToken;\n"];
                    [result appendFormat:@"\tdispatch_once(&onceToken, ^{\n"];
                    [result appendFormat:@"\t\t%@ShareObject = [[[self class] alloc] init];\n", [classname lowercaseString]];
                    [result appendFormat:@"\t});\n"];
                    [result appendFormat:@"\treturn %@ShareObject;\n", [classname lowercaseString]];
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
