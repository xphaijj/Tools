//
//  DBGeneration.m
//  Tools
//
//  Created by Alex xiang on 15/1/31.
//  Copyright (c) 2015年 Alex xiang. All rights reserved.
//

#import "DBGeneration.h"

#define DB_NAME(classname) [NSString stringWithFormat:@"DB_%@", classname]

@implementation DBGeneration

static NSArray *enumList;
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
    enumList = [Utils enumList:sourceString];
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
                [result appendFormat:@"#import <FMDB/FMDB.h>\n"];
            }
            else {
                [result appendFormat:@"#import \"FMDB.h\"\n"];
            }
            [result appendFormat:@"#import <YLT_BaseLib/YLT_BaseLib.h>\n"];
            [result appendFormat:@"#import \"%@Model.h\"\n", configDictionary[@"filename"]];
            [result appendFormat:@"\n//数据库操作完成回调\ntypedef void(^YLT_DBComplete)(id response);"];
        }
            break;
            
        case M_FILE:
        {
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
//    NSString *regex = @"message(?:\\s+)(\\S+)(?:\\s*)\\{([\\s\\S]*?)\\}(?:\\s*?)";
    
    NSString *regex = @"message((?:\\s+)(\\S+)(?:\\s*)(:(?:\\s+)(\\S+)(?:\\s*))?)\\{([\\s\\S]*?)\\}(?:\\s+)([TCRUD]{0,5})";
    NSArray *classes = [sourceString arrayOfCaptureComponentsMatchedByRegex:regex];
    [result appendFormat:@"\n\n"];

    //添加Model
    [result appendString:[self generationModelsFromClasses:classes fileType:fileType]];
    
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
    NSString *classname = [contents objectAtIndex:2];//获取类名称
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
    
    NSString *modelClass = [contents objectAtIndex:5];//获取属性
    //是否是用户关联数据库,TCRUD是否全都需要,默认全都需要‘T用户关联,C增加, R查询, U更新, D删除’
    NSString *tcrud = [contents objectAtIndex:6] ;
    BOOL userDb = [tcrud containsString:@"T"];
    if ([tcrud containsString:@"C"]) {
        [result appendString:[self methodWithClass:classname contents:modelClass FileType:fileType methodType:TYPE_ADD userDb:userDb]];//增
    }
    if ([tcrud containsString:@"R"]) {
        [result appendString:[self methodWithClass:classname contents:modelClass FileType:fileType methodType:TYPE_SEL userDb:userDb]];//查
    }
    if ([tcrud containsString:@"U"]) {
        [result appendString:[self methodWithClass:classname contents:modelClass FileType:fileType methodType:TYPE_UPDATE userDb:userDb]];//改
    }
    if ([tcrud containsString:@"D"]) {
        [result appendString:[self methodWithClass:classname contents:modelClass FileType:fileType methodType:TYPE_DEL userDb:userDb]];//删
    }
//    [result appendString:[self methodWithClass:classname contents:modelClass FileType:fileType methodType:TYPE_MAX userDb:userDb]];
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
 * @prama  userDb:是否使用用户关联数据库
 */
+ (NSString *)methodWithClass:(NSString *)classname contents:(NSString *)contents FileType:(FileType)fileType methodType:(MethodType)methodType userDb:(BOOL)userDb;
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
                    [result appendString:@"- (void)saveDB:(YLT_DBComplete)complete;\n"];
                }
                    break;
                case TYPE_DEL:
                {
                    [result appendString:@"- (void)delDB:(YLT_DBComplete)complete;\n"];
                    [result appendString:@"+ (void)delDB_ForConditions:(NSString *)sender complete:(YLT_DBComplete)complete;\n"];
                }
                    break;
                case TYPE_UPDATE:
                {
                    [result appendString:@"- (void)updateDB:(YLT_DBComplete)complete;\n"];
                    [result appendString:@"+ (void)updateDB_ForConditions:(NSString *)sender complete:(YLT_DBComplete)complete;\n"];
                }
                    break;
                case TYPE_SEL:
                {
                    [result appendString:@"+ (void)findDB_ForConditions:(NSString *)sender complete:(YLT_DBComplete)complete;\n"];
                }
                    break;
                case TYPE_MAX:
                {
                    [result appendFormat:@"+ (NSInteger)maxKeyValueDB:(FMDatabaseQueue *)db;\n"];
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
                    /** * 同步 */
                    [result appendString:@"\n- (void)saveDB:(YLT_DBComplete)complete {\n"];
                    [result appendString:[self db_funcHeader:userDb]];
                    [result appendFormat:@"\t\t\t[db executeUpdate:@\"CREATE TABLE IF NOT EXISTS %@(", DB_NAME(classname)];
                    if ([keyType isEqualToString:@"int"]) {
                        [result appendFormat:@"%@ INTEGER PRIMARY KEY", key];
                    } else if ([keyType isEqualToString:@"string"]){
                        [result appendFormat:@"%@ TEXT PRIMARY KEY", key];
                    }
                    [result appendString:[self allPropertys:contentsList fileType:fileType methodType:TYPE_ADD index:INDEX_ONE key:key keyType:keyType keyfieldname:keyfieldname]];
                    [result appendFormat:@")\"];\n"];
                    [result appendFormat:@"\t\t\tif ([db executeUpdate:@\"INSERT INTO %@(", DB_NAME(classname)];
                    [result appendString:[self allPropertys:contentsList fileType:fileType methodType:TYPE_ADD index:INDEX_TWO key:key keyType:keyType keyfieldname:keyfieldname insert:YES]];
                    [result appendFormat:@") VALUES ("];
                    [result appendString:[self allPropertys:contentsList fileType:fileType methodType:TYPE_ADD index:INDEX_THREE key:key keyType:keyType keyfieldname:keyfieldname insert:YES]];
                    [result appendFormat:@")\""];
                    
                    [result appendString:[self allPropertys:contentsList fileType:fileType methodType:TYPE_ADD index:INDEX_FOUR key:key keyType:keyType keyfieldname:keyfieldname insert:YES]];
                    [result appendFormat:@"]) {\n"];
                    [result appendFormat:@"\t\t\t\tresult = YES;\n"];
                    [result appendFormat:@"\t\t\t}\n"];
                    [result appendString:[self db_funcFooter]];
                }
                    break;
                case TYPE_DEL:
                {
                    /** *同步 */
                    [result appendFormat:@"\n- (void)delDB:(YLT_DBComplete)complete {\n"];
                    [result appendString:[self db_funcHeader:userDb]];
                    if ([keyType isEqualToString:@"int"]) {
                        [result appendFormat:@"\t\t\tif ([db executeUpdate:@\"DELETE FROM %@ WHERE %@ = ?\", [NSNumber numberWithInteger:self.%@]]) {\n", DB_NAME(classname), key, keyfieldname];
                    }
                    else if ([keyType isEqualToString:@"string"]) {
                        [result appendFormat:@"\t\t\tif ([db executeUpdate:@\"DELETE FROM %@ WHERE %@ = ?\", self.%@]) {\n", classname, key, keyfieldname];
                    }
                    [result appendFormat:@"\t\t\t\tresult = YES;\n"];
                    [result appendFormat:@"\t\t\t}\n"];
                    [result appendString:[self db_funcFooter]];
                    
                    [result appendFormat:@"\n+ (void)delDB_ForConditions:(NSString *)sender complete:(YLT_DBComplete)complete {\n"];
                    [result appendString:[self db_funcHeader:userDb]];
                    [result appendFormat:@"\t\t\tif ([db executeUpdate:[NSString stringWithFormat:@\"DELETE FROM %@%%@\", sender]]) {\n", DB_NAME(classname)];
                    [result appendFormat:@"\t\t\t\tresult = YES;\n"];
                    [result appendFormat:@"\t\t\t}\n"];
                    [result appendString:[self db_funcFooter]];
                }
                    break;
                case TYPE_UPDATE:
                {
                    /** *同步 */
                    [result appendString:@"\n- (void)updateDB:(YLT_DBComplete)complete {\n"];
                    [result appendString:[self db_funcHeader:userDb]];
                    [result appendFormat:@"\t\t\tif ([db executeUpdate:@\"UPDATE %@ SET ", DB_NAME(classname)];
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
                    [result appendFormat:@"]) {\n"];
                    [result appendFormat:@"\t\t\t\tresult = YES;\n"];
                    [result appendFormat:@"\t\t\t}\n"];
                    [result appendString:[self db_funcFooter]];
                    
                    [result appendString:@"\n+ (void)updateDB_ForConditions:(NSString *)sender complete:(YLT_DBComplete)complete {\n"];
                    [result appendString:[self db_funcHeader:userDb]];
                    [result appendFormat:@"\t\t\tif ([db executeUpdate:[NSString stringWithFormat:@\"UPDATE %@ SET %%@\", sender]]) {\n", DB_NAME(classname)];
                    [result appendFormat:@"\t\t\t\tresult = YES;\n"];
                    [result appendFormat:@"\t\t\t}\n"];
                    [result appendString:[self db_funcFooter]];
                }
                    break;
                case TYPE_SEL:
                {
                    /** *同步 */
                    [result appendString:@"\n+ (void)findDB_ForConditions:(NSString *)sender complete:(YLT_DBComplete)complete {\n"];
                    NSString *dbqueue = userDb ? @"ylt_userDbQueue" : @"ylt_databaseQueue";
                    [result appendFormat:@"\t[[YLT_DBHelper shareInstance].%@ inDatabase:^(FMDatabase * _Nonnull db) {\n",dbqueue];
                    [result appendFormat:@"\t\tNSMutableArray *result = nil;\n"];
                    [result appendFormat:@"\t\tif (!db.isOpen) {\n"];
                    [result appendFormat:@"\t\t\tYLT_LogWarn(@\"数据库错误\");\n"];
                    [result appendFormat:@"\t\t} else {\n"];
                    [result appendFormat:@"\t\t\tresult = [[NSMutableArray alloc] init];\n"];
                    [result appendFormat:@"\t\t\tFMResultSet* set;\n"];
                    [result appendFormat:@"\t\t\tif (!sender.ylt_isValid) {\n"];
                
                    [result appendFormat:@"\t\t\t\tset = [db executeQuery:@\"SELECT * FROM %@\"];\n", DB_NAME(classname)];
                    [result appendFormat:@"\t\t\t} else {\n"];
                    [result appendFormat:@"\t\t\t\tset = [db executeQuery:[NSString stringWithFormat:@\"SELECT * FROM %@ WHERE %%@\", sender]];\n", DB_NAME(classname)];
                    [result appendFormat:@"\t\t\t}\n"];
                    [result appendFormat:@"\t\t\twhile ([set next]) {\n"];
                    [result appendFormat:@"\t\t\t\t%@ *item = [[%@ alloc] init];\n", classname, classname];
                    if ([keyType isEqualToString:@"int"]) {
                        [result appendFormat:@"\t\t\t\titem.%@ = [set intForColumn:@\"%@\"];\n", keyfieldname, key];
                    }
                    else if ([keyType isEqualToString:@"string"]) {
                        [result appendFormat:@"\t\t\t\t\titem.%@ = [set stringForColumn:@\"%@\"];\n", keyfieldname, key];
                    }
                    [result appendString:[self allPropertys:contentsList fileType:fileType methodType:methodType index:INDEX_ONE key:key keyType:keyType keyfieldname:keyfieldname]];
                    [result appendString:@"\t\t\t\t[result addObject:item];\n"];
                    [result appendFormat:@"\t\t\t}\n"];
                    [result appendFormat:@"\t\t}\n"];
                    [result appendFormat:@"\t\tif (complete) {\n"];
                    [result appendFormat:@"\t\t\tcomplete(result);\n"];
                    [result appendFormat:@"\t\t}\n"];
                    [result appendFormat:@"\t}];\n"];
                    [result appendFormat:@"}\n"];
                }
                    break;
                case TYPE_MAX:
                {
                    /** *同步 */
                    [result appendFormat:@"\n+ (NSInteger)maxKeyValueDB:(FMDatabaseQueue *)db {\n"];
                    [result appendString:[self dbbaseControl2:classname]];
                    [result appendFormat:@"\tFMResultSet* set = [db executeQuery:@\"SELECT MAX(CAST(%@ as INT)) FROM %@\"];\n", key, DB_NAME(classname)];
                    [result appendFormat:@"\tNSInteger result = 0;\n"];
                    [result appendFormat:@"\tif ([set next]) {\n"];
                    [result appendFormat:@"\t\tresult = [set intForColumnIndex:0];\n"];
                    [result appendFormat:@"\t}\n"];
                    [result appendString:[self footControl]];
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
+ (NSString *)allPropertys:(NSArray *)contentsList fileType:(FileType)fileType methodType:(MethodType)methodType index:(TypeIndex)index key:(NSString *)key keyType:(NSString *)keyType keyfieldname:(NSString *)keyfieldname {
    return [self allPropertys:contentsList fileType:fileType methodType:methodType index:index key:key keyType:keyType keyfieldname:keyfieldname insert:NO];
}
/**
 * @brief  单个model的解析
 * @prama  contentsList:所有属性列表
 * @prama  fileType:[H_FILE:h文件  M_FILE: m文件]
 * @prama  methodType:方法类别
 * @prama  index:增删改查方法的索引
 */
+ (NSString *)allPropertys:(NSArray *)contentsList fileType:(FileType)fileType methodType:(MethodType)methodType index:(TypeIndex)index key:(NSString *)key keyType:(NSString *)keyType keyfieldname:(NSString *)keyfieldname insert:(BOOL)insert {
    NSMutableString *result = [[NSMutableString alloc] init];
    for (int j = 0; j < contentsList.count; j++) {
        NSString *propertyString = contentsList[j];
        NSString *regex = @"^(?:[\\s]*)(required|optional|repeated)(?:[\\s]*)(\\S+)(?:[\\s]*)(\\S+)(?:[\\s]*)=(?:[\\s]*)(\\S+)(?:[\\s]*);([\\S\\s]*)$";
        if (insert) {
            regex = @"^(?:[\\s]*)(required|optional|repeated|primary)(?:[\\s]*)(\\S+)(?:[\\s]*)(\\S+)(?:[\\s]*)=(?:[\\s]*)(\\S+)(?:[\\s]*);([\\S\\s]*)$";
        }
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
        if ((methodType == TYPE_ADD) && (result.length != 0) && (index == INDEX_TWO || index == INDEX_THREE)) {
            [result appendFormat:@","];
        }
        NSLog(@"fields:%@ propertys:%@ \n",fields,propertys);
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
        fieldname = [nameList objectAtIndex:1];
        NSMutableString *str = [[NSMutableString alloc] initWithString:[nameList objectAtIndex:2]];
        [str deleteCharactersInRange:[str rangeOfString:@"("]];
        [str deleteCharactersInRange:[str rangeOfString:@")"]];
        keyname = (NSString *)str;
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
                            if ([type isEqualToString:@"int"] || [enumList containsObject:type] || [type isEqualToString:@"longlong"] || [type isEqualToString:@"number"]) {
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
                            [result appendFormat:@", %@ %@", fieldname, typeValue];
                        }
                            break;
                        case INDEX_TWO:
                        {
                            [result appendFormat:@"%@", fieldname];
                        }
                            break;
                        case INDEX_THREE:
                        {
                            [result appendString:@"?"];
                        }
                            break;
                        case INDEX_FOUR:
                        {
                            if ([type isEqualToString:@"int"] || [type isEqualToString:@"short"] || [enumList containsObject:type]) {
                                [result appendFormat:@", [NSNumber numberWithInteger:self.%@]", fieldname];
                            } else if ([type isEqualToString:@"bool"]) {
                                [result appendFormat:@", [NSNumber numberWithBool:self.%@]", fieldname];
                            } else if ([type isEqualToString:@"long"]) {
                                [result appendFormat:@", [NSNumber numberWithLong:self.%@]", fieldname];
                            } else if ([type isEqualToString:@"float"]) {
                                [result appendFormat:@", [NSNumber numberWithFloat:self.%@]", fieldname];
                            } else if ([type isEqualToString:@"double"]) {
                                [result appendFormat:@", [NSNumber numberWithDouble:self.%@]", fieldname];
                            } else if ([type isEqualToString:@"char"]) {
                                [result appendFormat:@", [NSNumber numberWithChar:self.%@]", fieldname];
                            } else if ([type isEqualToString:@"string"] || [type isEqualToString:@"number"]) {
                                [result appendFormat:@", self.%@", fieldname];
                            } else if ([type isEqualToString:@"longlong"]) {
                                [result appendFormat:@", [NSNumber numberWithLongLong:self.%@]", fieldname];
                            } else {
                                [result appendFormat:@", [self.%@ mj_JSONString]", fieldname];
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
                            [result appendFormat:@" %@ = ?,", fieldname];
                        }
                            break;
                        case INDEX_TWO:
                        {
                            if ([type isEqualToString:@"int"] || [enumList containsObject:type]) {
                                [result appendFormat:@", [NSNumber numberWithInteger:self.%@]", fieldname];
                            } else if ([type isEqualToString:@"short"]) {
                                [result appendFormat:@", [NSNumber numberWithShort:self.%@]", fieldname];
                            } else if ([type isEqualToString:@"bool"]) {
                                [result appendFormat:@", [NSNumber numberWithBool:self.%@]", fieldname];
                            } else if ([type isEqualToString:@"long"]) {
                                [result appendFormat:@", [NSNumber numberWithLong:self.%@]", fieldname];
                            } else if ([type isEqualToString:@"float"]) {
                                [result appendFormat:@", [NSNumber numberWithFloat:self.%@]", fieldname];
                            } else if ([type isEqualToString:@"double"]) {
                                [result appendFormat:@", [NSNumber numberWithDouble:self.%@]", fieldname];
                            } else if ([type isEqualToString:@"char"]) {
                                [result appendFormat:@", [NSNumber numberWithChar:self.%@]", fieldname];
                            } else if ([type isEqualToString:@"string"] || [type isEqualToString:@"number"]) {
                                [result appendFormat:@", self.%@", fieldname];
                            } else if ([type isEqualToString:@"longlong"]) {
                                [result appendFormat:@", [NSNumber numberWithLongLong:self.%@]", fieldname];
                            } else {
                                [result appendFormat:@", [self.%@ mj_JSONString]", fieldname];
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
                    if ([type isEqualToString:@"int"] || [enumList containsObject:type]) {
                        [result appendFormat:@"\t\t\t\titem.%@ = [set intForColumn:@\"%@\"];\n", fieldname, fieldname];
                    } else if ([type isEqualToString:@"short"]) {
                        [result appendFormat:@"\t\t\t\titem.%@ = [set intForColumn:@\"%@\"];\n", fieldname, fieldname];
                    } else if ([type isEqualToString:@"bool"]) {
                        [result appendFormat:@"\t\t\t\titem.%@ = [set boolForColumn:@\"%@\"];\n", fieldname, fieldname];
                    } else if ([type isEqualToString:@"long"]) {
                        [result appendFormat:@"\t\t\t\titem.%@ = [set longForColumn:@\"%@\"];\n", fieldname, fieldname];
                    } else if ([type isEqualToString:@"float"]) {
                        [result appendFormat:@"\t\t\t\titem.%@ = [set doubleForColumn:@\"%@\"];\n", fieldname, fieldname];
                    } else if ([type isEqualToString:@"double"]) {
                        [result appendFormat:@"\t\t\t\titem.%@ = [set doubleForColumn:@\"%@\"];\n", fieldname, fieldname];
                    } else if ([type isEqualToString:@"char"]) {
                        [result appendFormat:@"\t\t\t\titem.%@ = [set stringForColumn:@\"%@\"];\n", fieldname, fieldname];
                    } else if ([type isEqualToString:@"dic"] || [type isEqualToString:@"dictionary"] || [type isEqualToString:@"map"]) {
                        [result appendFormat:@"\t\t\t\titem.%@ = [NSMutableDictionary dictionaryWithDictionary:[[set stringForColumn:@\"%@\"] mj_JSONObject]];\n", fieldname, fieldname];
                    } else if ([type isEqualToString:@"array"] || [type isEqualToString:@"list"]) {
                        [result appendFormat:@"\t\t\t\titem.%@ = [NSMutableArray arrayWithArray:[[set stringForColumn:@\"%@\"] mj_JSONObject]];\n", fieldname, fieldname];
                    } else if ([type isEqualToString:@"string"]) {
                        [result appendFormat:@"\t\t\t\titem.%@ = [set stringForColumn:@\"%@\"];\n", fieldname, fieldname];
                    } else if ([type isEqualToString:@"longlong"]) {
                        [result appendFormat:@"\t\t\t\titem.%@ = [set longLongIntForColumn:@\"%@\"];\n", fieldname, fieldname];
                    } else if ([type isEqualToString:@"number"]) {
                        [result appendFormat:@"\t\t\t\titem.%@ = [NSNumber numberWithInt:[set intForColumn:@\"%@\"]];\n",fieldname, fieldname];
                    } else {
                        //自定义对象
                        [result appendFormat:@"\t\t\t\titem.%@ = [%@ mj_objectWithKeyValues:[[set stringForColumn:@\"%@\"] mj_JSONObject]];\n",fieldname, type, fieldname];
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

+ (NSString *)footControl {
    NSMutableString *result = [[NSMutableString alloc] init];
    [result appendString:@"\tif (sync) {\n"];
    [result appendString:@"\t\t[db close];\n"];
    [result appendString:@"\t}\n"];
    return result;
}

/**
 * @brief  数据库操作的基本生成
 * @prama  classname: 表名称
 **/
+ (NSString *)dbbaseControl:(NSString *)classname
{
    NSMutableString *result = [[NSMutableString alloc] init];
    [result appendString:@"\tBOOL sync = NO;\n"];
    [result appendString:@"\tif (db == nil) {\n"];
    [result appendString:@"\t\tsync = YES;\n"];
    [result appendString:@"\t\tdb = [FMDatabaseQueue databaseWithPath:[YLT_DBHelper shareInstance].ylt_dbPath];\n"];
    [result appendString:@"\t}\n"];
    [result appendString:@"\tif (![db open]) {\n"];
    [result appendString:@"\t\tYLT_LogWarn(@\"数据库错误\");\n"];
    [result appendString:@"\t\treturn nil;\n"];
    [result appendString:@"\t}\n"];
    return result;
}

/**
 * @brief  数据库操作的基本生成
 * @prama  classname: 表名称
 **/
+ (NSString *)dbbaseControl2:(NSString *)classname {
    NSMutableString *result = [[NSMutableString alloc] init];
    [result appendString:@"\tBOOL sync = NO;\n"];
    [result appendString:@"\tif (db == nil) {\n"];
    [result appendString:@"\t\tsync = YES;\n"];
    [result appendString:@"\t\tdb = [FMDatabaseQueue databaseWithPath:[YLT_DBHelper shareInstance].ylt_dbPath];\n"];
    [result appendString:@"\t}\n"];
    [result appendString:@"\tif (![db open]) {\n"];
    [result appendString:@"\t\tYLT_LogWarn(@\"数据库错误\");\n"];
    [result appendString:@"\t\treturn 0;\n"];
    [result appendString:@"\t}\n"];
    return result;
}

+ (NSString *)db_funcHeader:(BOOL)userDb {
    NSMutableString *result = [[NSMutableString alloc] init];
    NSString *dbqueue = userDb ? @"ylt_userDbQueue" : @"ylt_databaseQueue";
    [result appendFormat:@"\t[[YLT_DBHelper shareInstance].%@ inDatabase:^(FMDatabase * _Nonnull db) {\n",dbqueue];
    [result appendFormat:@"\t\tBOOL result = NO;\n"];
    [result appendFormat:@"\t\tif (!db.isOpen) {\n"];
    [result appendFormat:@"\t\t\tYLT_LogWarn(@\"数据库错误\");\n"];
    [result appendFormat:@"\t\t} else {\n"];
    return result;
}

+ (NSString *)db_funcFooter {
    NSMutableString *result = [[NSMutableString alloc] init];
    [result appendFormat:@"\t\t}\n"];
    [result appendFormat:@"\t\tif (complete) {\n"];
    [result appendFormat:@"\t\t\tcomplete(@(result));\n"];
    [result appendFormat:@"\t\t}\n"];
    [result appendFormat:@"\t}];\n"];
    [result appendFormat:@"}\n"];
    return result;
}

@end
