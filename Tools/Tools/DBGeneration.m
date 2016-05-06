//
//  DBGeneration.m
//  Tools
//
//  Created by Alex xiang on 15/1/31.
//  Copyright (c) 2015年 Alex xiang. All rights reserved.
//

#import "DBGeneration.h"

@implementation DBGeneration

static NSDictionary *configDictionary;
/**
 * @brief  DB类自动生成
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
    
    NSString *hFilePath = [outputPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@Model+DB.h", config[@"filename"]]];
    NSString *mFilePath = [outputPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@Model+DB.m", config[@"filename"]]];
    [fileManager createFileAtPath:hFilePath contents:nil attributes:nil];
    [fileManager createFileAtPath:mFilePath contents:nil attributes:nil];
    
    //版权信息的导入
    [h appendString:[Utils createCopyrightByFilename:[NSString stringWithFormat:@"%@Model+DB.h", config[@"filename"]] config:config]];
    [m appendString:[Utils createCopyrightByFilename:[NSString stringWithFormat:@"%@Model+DB.m", config[@"filename"]] config:config]];
    
    //头文件的导入
    [h appendString:[self introductionPackages:H_FILE]];
    [m appendString:[self introductionPackages:M_FILE]];
    
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
            if ([configDictionary[@"pods"] boolValue]) {
                [result appendFormat:@"#import <FMDB/FMDatabase.h>\n"];
            }
            else {
                [result appendFormat:@"#import \"FMDatabase.h\"\n"];
            }
            [result appendFormat:@"#import \"%@Model.h\"\n", configDictionary[@"filename"]];
        }
            break;
            
        case M_FILE:
        {
            [result appendFormat:@"#import \"%@Config.h\"\n",  configDictionary[@"filename"]];
            [result appendFormat:@"#import \"%@Model+DB.h\"",  configDictionary[@"filename"]];
        }
            break;
        default:
            break;
    }
    
    return result;
}

/**
 * @brief  匹配出所有的model类型
 * @prama  sourceString:需要匹配的字符串
 * @prama  fileType:[H_FILE:h文件  M_FILE: m文件]
 **/
+ (NSString *)messageFromSourceString:(NSString *)sourceString fileType:(FileType)fileType {
    NSMutableString *result = [[NSMutableString alloc] init];
    NSString *regex = @"message(?:\\s+)(\\S+)(?:\\s*)\\{([\\s\\S]*?)\\}(?:\\s*?)";
    NSArray *classes = [sourceString arrayOfCaptureComponentsMatchedByRegex:regex];
    [result appendFormat:@"\n\n"];
    
    //添加基类
    [result appendString:[self baseModel:fileType]];
    //添加Model
    [result appendString:[self generationModelsFromClasses:classes fileType:fileType]];
    
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
            [result appendString:@"@interface OObject(DB) {\n"];
            [result appendString:@"}\n"];
            [result appendString:@"- (BOOL)save;\n"];
            [result appendString:@"- (BOOL)del;\n"];
            [result appendString:@"+ (BOOL)delByConditions:(NSString *)sender;\n"];
            [result appendString:@"- (BOOL)update;\n"];
            [result appendString:@"+ (BOOL)updateByConditions:(NSString *)sender;\n"];
            [result appendString:@"+ (NSArray *)findByConditions:(NSString *)sender;\n"];
            [result appendString:@"+ (NSInteger)maxKeyValue;\n"];
            [result appendString:@"\n@end\n"];
        }
            break;
        case M_FILE:
        {
            [result appendString:@"@implementation OObject(DB) \n"];
            [result appendString:@"- (BOOL)save {\n"];
            [result appendString:@"\treturn NO;\n"];
            [result appendString:@"}\n"];
            [result appendString:@"- (BOOL)del {\n"];
            [result appendString:@"\treturn NO;\n"];
            [result appendString:@"}\n"];
            [result appendString:@"+ (BOOL)delByConditions:(NSString *)sender {\n"];
            [result appendString:@"\treturn NO;\n"];
            [result appendString:@"}\n"];
            [result appendString:@"- (BOOL)update {\n"];
            [result appendString:@"\treturn NO;\n"];
            [result appendString:@"}\n"];
            [result appendString:@"+ (BOOL)updateByConditions:(NSString *)sender {\n"];
            [result appendString:@"\treturn NO;\n"];
            [result appendString:@"}\n"];
            [result appendString:@"+ (NSArray *)findByConditions:(NSString *)sender {\n"];
            [result appendString:@"\treturn [[NSMutableArray alloc] init];\n"];
            [result appendString:@"}\n"];
            [result appendString:@"+ (NSInteger)maxKeyValue {\n"];
            [result appendString:@"\treturn 0;\n"];
            [result appendString:@"}\n"];
            [result appendString:@"\n@end\n"];
        }
            break;
            
        default:
            break;
    }
    
    return result;
}

/**
 * @brief  models 数据的生成
 * @prama  classes:所有的model列表
 * @prama  fileType:[H_FILE:h文件  M_FILE: m文件]
 */
+ (NSString *)generationModelsFromClasses:(NSArray *)classes fileType:(FileType)fileType
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
            [result appendFormat:@"\n\n@interface %@(DB) {\n", classname];
            [result appendFormat:@"}\n"];
        }
            break;
        case M_FILE:
        {
            [result appendFormat:@"\n\n@implementation %@(DB)\n\n", classname];
        }
            break;
            
        default:
            break;
    }
    
    NSString *modelClass = [contents objectAtIndex:2];//获取属性
    
    [result appendString:[self methodWithClass:classname contents:modelClass FileType:fileType methodType:TYPE_ADD]];//增
    [result appendString:[self methodWithClass:classname contents:modelClass FileType:fileType methodType:TYPE_DEL]];//删
    [result appendString:[self methodWithClass:classname contents:modelClass FileType:fileType methodType:TYPE_UPDATE]];//改
    [result appendString:[self methodWithClass:classname contents:modelClass FileType:fileType methodType:TYPE_SEL]];//查
    [result appendString:[self methodWithClass:classname contents:modelClass FileType:fileType methodType:TYPE_MAX]];
    //单个类的结束标志
    [result appendFormat:@"\n@end\n"];
    
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
    
    NSDictionary *keyInfo = [self findKeyAndType:contentsList];
    NSString *key = [keyInfo objectForKey:KEY];
    NSString *keyType = [keyInfo objectForKey:KEY_TYPE];
    NSString *keyfieldname = [keyInfo objectForKey:KEY_FIELDNAME];
    if (!(key.length != 0 && ([[keyType lowercaseString] isEqualToString:@"int"] || [[keyType lowercaseString] isEqualToString:@"string"]))) {
        return @"";
    }
    
    switch (fileType) {
        case H_FILE:
        {
            switch (methodType) {
                case TYPE_ADD:
                {
                    [result appendString:@"- (BOOL)save;\n"];
                }
                    break;
                case TYPE_DEL:
                {
                    [result appendString:@"- (BOOL)del;\n"];
                    [result appendString:@"+ (BOOL)delByConditions:(NSString *)sender;\n"];
                }
                    break;
                case TYPE_UPDATE:
                {
                    [result appendString:@"- (BOOL)update;\n"];
                    [result appendString:@"+ (BOOL)updateByConditions:(NSString *)sender;\n"];
                }
                    break;
                case TYPE_SEL:
                {
                    [result appendString:@"+ (NSArray *)findByConditions:(NSString *)sender;\n"];
                }
                    break;
                case TYPE_MAX:
                {
                    [result appendFormat:@"+ (NSInteger)maxKeyValue;\n"];
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
                case TYPE_ADD:
                {
                    [result appendString:@"\n- (BOOL)save {\n"];
                    [result appendString:[self dbbaseControl:classname]];
                    [result appendFormat:@"\tBOOL result = NO;\n"];
                    [result appendFormat:@"\t[db executeUpdate:@\"CREATE TABLE IF NOT EXISTS %@(", classname];
                    if ([keyType isEqualToString:@"int"]) {
                        [result appendFormat:@"%@ INTEGER PRIMARY KEY AUTOINCREMENT", key];
                    }
                    else if ([keyType isEqualToString:@"string"]){
                        [result appendFormat:@"%@ TEXT PRIMARY KEY AUTOINCREMENT", key];
                    }
                    [result appendString:[self allPropertys:contentsList fileType:fileType methodType:TYPE_ADD index:INDEX_ONE key:key keyType:keyType keyfieldname:keyfieldname]];
                    [result appendFormat:@")\"];\n"];
                    [result appendFormat:@"\tresult = [db executeUpdate:@\"INSERT INTO %@( %@", classname, key];
                    [result appendString:[self allPropertys:contentsList fileType:fileType methodType:TYPE_ADD index:INDEX_TWO key:key keyType:keyType keyfieldname:keyfieldname]];
                    [result appendFormat:@") VALUES (?"];
                    [result appendString:[self allPropertys:contentsList fileType:fileType methodType:TYPE_ADD index:INDEX_THREE key:key keyType:keyType keyfieldname:keyfieldname]];
                    if ([keyType isEqualToString:@"int"]) {
                        [result appendFormat:@")\", [NSNumber numberWithInteger:self.%@]", keyfieldname];
                    }
                    else {
                        [result appendFormat:@")\", self.%@", keyfieldname];
                    }
                    
                    [result appendString:[self allPropertys:contentsList fileType:fileType methodType:TYPE_ADD index:INDEX_FOUR key:key keyType:keyType keyfieldname:keyfieldname]];
                    [result appendFormat:@"];\n"];
                    [result appendFormat:@"\t[db close];\n"];
                    [result appendFormat:@"\treturn result;\n"];
                    [result appendFormat:@"}\n"];
                }
                    break;
                case TYPE_DEL:
                {
                    [result appendFormat:@"\n- (BOOL)del {\n"];
                    [result appendString:[self dbbaseControl:classname]];
                    [result appendFormat:@"\tBOOL result = NO;\n"];
                    if ([keyType isEqualToString:@"int"]) {
                        [result appendFormat:@"\tresult = [db executeUpdate:@\"DELETE FROM %@ WHERE %@ = ?\", [NSNumber numberWithInteger:self.%@]];\n", classname, key, keyfieldname];
                    }
                    else if ([keyType isEqualToString:@"string"]) {
                        [result appendFormat:@"\tresult = [db executeUpdate:@\"DELETE FROM %@ WHERE %@ = ?\", self.%@];\n", classname, key, keyfieldname];
                    }
                    [result appendFormat:@"\t[db close];\n"];
                    [result appendFormat:@"\treturn result;\n"];
                    [result appendFormat:@"}\n"];
                    
                    [result appendFormat:@"\n+ (BOOL)delByConditions:(NSString *)sender {\n"];
                    [result appendString:[self dbbaseControl:classname]];
                    [result appendFormat:@"\tBOOL result = NO;\n"];
                    [result appendFormat:@"\tresult = [db executeUpdate:@\"DELETE FROM %@ WHERE %%@\", sender];\n", classname];
                    [result appendFormat:@"\t[db close];\n"];
                    [result appendFormat:@"\treturn result;\n"];
                    [result appendFormat:@"}\n"];
                    
                }
                    break;
                case TYPE_UPDATE:
                {
                    [result appendString:@"\n- (BOOL)update {\n"];
                    [result appendString:[self dbbaseControl:classname]];
                    [result appendFormat:@"\tBOOL result = NO;\n"];
                    [result appendFormat:@"\tresult = [db executeUpdate:@\"UPDATE %@ SET ", classname];
                    [result appendString:[self allPropertys:contentsList fileType:fileType methodType:methodType index:INDEX_ONE key:key keyType:keyType keyfieldname:keyfieldname]];
                    [result deleteCharactersInRange:NSMakeRange(result.length-1, 1)];
                    [result appendFormat:@" WHERE %@ = ?\"", key];
                    [result appendString:[self allPropertys:contentsList fileType:fileType methodType:methodType index:INDEX_TWO key:key keyType:keyType keyfieldname:keyfieldname]];
                    if ([keyType isEqualToString:@"int"]) {
                        [result appendFormat:@", [NSNumber numberWithInteger:self.%@]", keyfieldname];
                    }
                    else {
                        [result appendFormat:@", self.%@", keyfieldname];
                    }
                    [result appendFormat:@"];\n"];
                    [result appendFormat:@"\t[db close];\n"];
                    [result appendFormat:@"\treturn result;\n"];
                    [result appendFormat:@"}\n"];
                    
                    
                    [result appendString:@"\n+ (BOOL)updateByConditions:(NSString *)sender {\n"];
                    [result appendString:[self dbbaseControl:classname]];
                    [result appendFormat:@"\tBOOL result = NO;\n"];
                    [result appendString:@"\tresult = [db executeUpdate:@\"UPDATE Product SET \", sender];\n"];
                    [result appendString:@"\t[db close];\n"];
                    [result appendString:@"\treturn result;\n"];
                    [result appendString:@"}\n"];
                }
                    break;
                case TYPE_SEL:
                {
                    [result appendString:@"\n+ (NSArray *)findByConditions:(NSString *)sender {\n"];
                    [result appendString:[self dbbaseControl:classname]];
                    [result appendString:@"\tNSMutableArray *result = [[NSMutableArray alloc] init];\n"];
                    [result appendString:@"\tFMResultSet* set;\n"];
                    [result appendString:@"\tif (sender.length == 0) {\n"];
                    [result appendFormat:@"\t\tset = [db executeQuery:@\"SELECT * FROM %@\"];\n", classname];
                    [result appendFormat:@"\t}\n"];
                    [result appendFormat:@"\telse {\n"];
                    [result appendFormat:@"\t\tset = [db executeQuery:[NSString stringWithFormat:@\"SELECT * FROM %@ WHERE %%@\", sender]];\n", classname];
                    [result appendFormat:@"\t}\n"];
                    [result appendFormat:@"\twhile ([set next]) {\n"];
                    [result appendFormat:@"\t\t%@ *item = [[%@ alloc] init];\n", classname, classname];
                    if ([keyType isEqualToString:@"int"]) {
                        [result appendFormat:@"\t\titem.%@ = [set intForColumn:@\"%@\"];\n", keyfieldname, key];
                    }
                    else if ([keyType isEqualToString:@"string"]) {
                        [result appendFormat:@"\t\titem.%@ = [set stringForColumn:@\"%@\"];\n", keyfieldname, key];
                    }
                    [result appendString:[self allPropertys:contentsList fileType:fileType methodType:methodType index:INDEX_ONE key:key keyType:keyType keyfieldname:keyfieldname]];
                    [result appendString:@"\t\t[result addObject:item];\n"];
                    [result appendFormat:@"\t}\n"];
                    [result appendString:@"\treturn result;\n"];
                    [result appendString:@"}\n"];
                }
                    break;
                case TYPE_MAX:
                {
                    [result appendFormat:@"\n+ (NSInteger)maxKeyValue {\n"];
                    [result appendString:[self dbbaseControl:classname]];
                    [result appendFormat:@"\tFMResultSet* set = [db executeQuery:@\"SELECT MAX(CAST(%@ as INT)) FROM %@\"];\n", key, classname];
                    [result appendFormat:@"\tNSInteger result = 0;\n"];
                    [result appendFormat:@"\tif ([set next]) {\n"];
                    [result appendFormat:@"\t\tresult = [set intForColumnIndex:0];\n"];
                    [result appendFormat:@"\t}\n"];
                    [result appendFormat:@"\treturn result;\n"];
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

/**
 * @brief  数据库操作的基本生成
 * @prama  classname: 表名称
 **/
+ (NSString *)dbbaseControl:(NSString *)classname
{
    NSMutableString *result = [[NSMutableString alloc] init];
    [result appendFormat:@"\t[%@ initialDB];\n", classname];
    [result appendFormat:@"\tFMDatabase *db = [FMDatabase databaseWithPath:[OObject shareInstance].dbPath];\n"];
    [result appendFormat:@"\tif (![db open]) {\n"];
    [result appendFormat:@"\t\tSHOW_DB_ERROR(@\"数据库打开失败\");\n"];
    [result appendFormat:@"\t\treturn NO;\n"];
    [result appendFormat:@"\t}\n"];
    return result;
}

/**
 * @brief  单个model的解析
 * @prama  contentsList:所有属性列表
 * @prama  fileType:[H_FILE:h文件  M_FILE: m文件]
 * @prama  methodType:方法类别
 * @prama  index:增删改查方法的索引
 */
+ (NSString *)allPropertys:(NSArray *)contentsList fileType:(FileType)fileType methodType:(MethodType)methodType index:(TypeIndex)index key:(NSString *)key keyType:(NSString *)keyType keyfieldname:(NSString *)keyfieldname
{
    NSMutableString *result = [[NSMutableString alloc] init];
    
    for (NSString *propertyString in contentsList) {
        NSString *regex = @"^(?:[\\s]*)(required|optional|repeated)(?:[\\s]*)(\\S+)(?:[\\s]*)(\\S+)(?:[\\s]*)=(?:[\\s]*)(\\S+)(?:[\\s]*);([\\S\\s]*)$";
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
        [result appendString:[self singleProperty:fields fileType:fileType methodType:methodType index:index key:key keyType:keyType keyfieldname:keyfieldname]];
        
    }
    return result;
}

/**
 * @brief  查找key 和 key的Type
 * @prama  contentlist: 数据列表
 */
+ (NSDictionary *)findKeyAndType:(NSArray *)contentList
{
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    NSString *keyType = @"";
    NSString *key = @"";
    NSString *fieldname = @"";
    for (NSString *propertyString in contentList) {
        NSString *regex = @"^(?:[\\s]*)(primary)(?:[\\s]*)(\\S+)(?:[\\s]*)(\\S+)(?:[\\s]*)=(?:[\\s]*)(\\S+)(?:[\\s]*);([\\S\\s]*)$";
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
        
        keyType = [fields objectAtIndex:2];
        key = [fields objectAtIndex:3];
        fieldname = key;
        NSString *nameRegex = @"^(?:[\\s]*)(?:[\\s]*)(\\S+)(?:[\\s]*)((?:\\()\\S+(?:\\)))";
        NSArray *nameList = [[key arrayOfCaptureComponentsMatchedByRegex:nameRegex] firstObject];
        if (nameList.count >= 3) {
            key = [nameList objectAtIndex:1];
            NSMutableString *str = [[NSMutableString alloc] initWithString:[nameList objectAtIndex:2]];
            [str deleteCharactersInRange:[str rangeOfString:@"("]];
            [str deleteCharactersInRange:[str rangeOfString:@")"]];
            fieldname = (NSString *)str;
        }
        break;
    }
    [result setObject:key forKey:KEY];
    [result setObject:keyType forKey:KEY_TYPE];
    [result setObject:fieldname forKey:KEY_FIELDNAME];
    return result;
}

/**
 * @brief  解析单条属性
 * @prama  fields:单条属性的所有字段
 * @prama  fileType:[H_FILE:h文件  M_FILE: m文件]
 * @prama  methodType:方法类别 多个方法解析
 * @prama  index:增删改查方法的索引
 */
+ (NSString *)singleProperty:(NSArray *)fields fileType:(FileType)fileType methodType:(MethodType)methodType index:(TypeIndex)index key:(NSString *)key keyType:(NSString *)keyType keyfieldname:(NSString *)keyfieldname
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
                case TYPE_ADD:
                {
                }
                    break;
                case TYPE_DEL:
                {
                }
                    break;
                case TYPE_UPDATE:
                {
                }
                    break;
                case TYPE_SEL:
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
                case TYPE_ADD:
                {
                    switch (index) {
                        case INDEX_ONE://创建
                        {
                            NSString *typeValue = @"INTEGER";//默认整形
                            if ([type isEqualToString:@"int"]) {
                                typeValue = @"INTEGER";
                            }
                            else if ([type isEqualToString:@"short"]) {
                                typeValue = @"SMALLINT";
                            }
                            else if ([type isEqualToString:@"bool"]) {
                                typeValue = @"TINYINT";
                            }
                            else if ([type isEqualToString:@"long"]) {
                                typeValue = @"BIGINT";
                            }
                            else if ([type isEqualToString:@"float"]) {
                                typeValue = @"FLOAT";
                            }
                            else if ([type isEqualToString:@"double"]) {
                                typeValue = @"DOUBLE";
                            }
                            else if ([type isEqualToString:@"char"]) {
                                typeValue = @"CHAR";
                            }
                            else {
                                typeValue = @"TEXT";
                            }
                            [result appendFormat:@", %@ %@", keyname, typeValue];
                        }
                            break;
                        case INDEX_TWO:
                        {
                            [result appendFormat:@", %@", keyname];
                        }
                            break;
                        case INDEX_THREE:
                        {
                            [result appendString:@", ?"];
                        }
                            break;
                        case INDEX_FOUR:
                        {
                            if ([type isEqualToString:@"int"] || [type isEqualToString:@"short"]) {
                                [result appendFormat:@", [NSNumber numberWithInteger:self.%@]", fieldname];
                            }
                            else if ([type isEqualToString:@"bool"]) {
                                [result appendFormat:@", [NSNumber numberWithBool:self.%@]", fieldname];
                            }
                            else if ([type isEqualToString:@"long"]) {
                                [result appendFormat:@", [NSNumber numberWithLong:self.%@]", fieldname];
                            }
                            else if ([type isEqualToString:@"float"]) {
                                [result appendFormat:@", [NSNumber numberWithFloat:self.%@]", fieldname];
                            }
                            else if ([type isEqualToString:@"double"]) {
                                [result appendFormat:@", [NSNumber numberWithDouble:self.%@]", fieldname];
                            }
                            else if ([type isEqualToString:@"char"]) {
                                [result appendFormat:@", [NSNumber numberWithChar:self.%@]", fieldname];
                            }
                            else {
                                [result appendFormat:@", self.%@", fieldname];
                            }
                        }
                            break;
                            
                        default:
                            break;
                    }
                }
                    break;
                case TYPE_DEL:
                {
                }
                    break;
                case TYPE_UPDATE:
                {
                    switch (index) {
                        case INDEX_ONE:
                        {
                            [result appendFormat:@" %@ = ?,", keyname];
                        }
                            break;
                        case INDEX_TWO:
                        {
                            if ([type isEqualToString:@"int"]) {
                                [result appendFormat:@", [NSNumber numberWithInteger:self.%@]", fieldname];
                            }
                            else if ([type isEqualToString:@"short"]) {
                                [result appendFormat:@", [NSNumber numberWithShort:self.%@]", fieldname];
                            }
                            else if ([type isEqualToString:@"bool"]) {
                                [result appendFormat:@", [NSNumber numberWithBool:self.%@]", fieldname];
                            }
                            else if ([type isEqualToString:@"long"]) {
                                [result appendFormat:@", [NSNumber numberWithLong:self.%@]", fieldname];
                            }
                            else if ([type isEqualToString:@"float"]) {
                                [result appendFormat:@", [NSNumber numberWithFloat:self.%@]", fieldname];
                            }
                            else if ([type isEqualToString:@"double"]) {
                                [result appendFormat:@", [NSNumber numberWithDouble:self.%@]", fieldname];
                            }
                            else if ([type isEqualToString:@"char"]) {
                                [result appendFormat:@", [NSNumber numberWithChar:self.%@]", fieldname];
                            }
                            else {
                                [result appendFormat:@", self.%@", fieldname];
                            }
                        }
                            break;
                            
                        default:
                            break;
                    }
                }
                    break;
                case TYPE_SEL:
                {
                    if ([type isEqualToString:@"int"]) {
                        [result appendFormat:@"\t\titem.%@ = [set intForColumn:@\"%@\"];\n", fieldname, keyname];
                    }
                    else if ([type isEqualToString:@"short"]) {
                        [result appendFormat:@"\t\titem.%@ = [set intForColumn:@\"%@\"];\n", fieldname, keyname];
                    }
                    else if ([type isEqualToString:@"bool"]) {
                        [result appendFormat:@"\t\titem.%@ = [set boolForColumn:@\"%@\"];\n", fieldname, keyname];
                    }
                    else if ([type isEqualToString:@"long"]) {
                        [result appendFormat:@"\t\titem.%@ = [set longForColumn:@\"%@\"];\n", fieldname, keyname];
                    }
                    else if ([type isEqualToString:@"float"]) {
                        [result appendFormat:@"\t\titem.%@ = [set doubleForColumn:@\"%@\"];\n", fieldname, keyname];
                    }
                    else if ([type isEqualToString:@"double"]) {
                        [result appendFormat:@"\t\titem.%@ = [set doubleForColumn:@\"%@\"];\n", fieldname, keyname];
                    }
                    else if ([type isEqualToString:@"char"]) {
                        [result appendFormat:@"\t\titem.%@ = [set stringForColumn:@\"%@\"];\n", fieldname, keyname];
                    }
                    else {
                        [result appendFormat:@"\t\titem.%@ = [set stringForColumn:@\"%@\"];\n", fieldname, keyname];
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

@end
