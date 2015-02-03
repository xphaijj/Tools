//
//  RequestGeneration.m
//  Tools
//
//  Created by Alex xiang on 15/1/31.
//  Copyright (c) 2015年 Alex xiang. All rights reserved.
//

#import "RequestGeneration.h"

@implementation RequestGeneration

/**
 * @brief  Model类自动生成
 * @prama  sourcepath:资源路径   outputPath:资源生成路径
 */
+ (void)generationSourcePath:(NSString *)sourcepath outputPath:(NSString *)outputPath
{
    NSError *error;
    NSString *sourceString = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForAuxiliaryExecutable:sourcepath] encoding:NSUTF8StringEncoding error:&error];
    
    NSMutableString *h = [[NSMutableString alloc] init];
    NSMutableString *m = [[NSMutableString alloc] init];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    NSString *hFilePath = [outputPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.h", REQUEST_NAME]];
    NSString *mFilePath = [outputPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.m", REQUEST_NAME]];
    [fileManager createFileAtPath:hFilePath contents:nil attributes:nil];
    [fileManager createFileAtPath:mFilePath contents:nil attributes:nil];
    
    //版权信息的导入
    [h appendString:[Utils createCopyrightByFilename:REQUEST_NAME]];
    [m appendString:[Utils createCopyrightByFilename:REQUEST_NAME]];
    
    //头文件的导入
    [h appendString:[self introductionPackages:H_FILE]];
    [m appendString:[self introductionPackages:M_FILE]];

    //导入基本的 实现
    [h appendString:[self classOfRequest:H_FILE]];
    [m appendString:[self classOfRequest:M_FILE]];
    
    //匹配出所有的Request类型
    [h appendString:[self messageFromSourceString:sourceString fileType:H_FILE]];
    [m appendString:[self messageFromSourceString:sourceString fileType:M_FILE]];
    
    [h appendFormat:@"\n@end\n\n\n"];
    [m appendFormat:@"\n@end\n\n\n"];
    
    [h writeToFile:hFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [m writeToFile:mFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

/**
 * @brief  导入头文件
 * @prama  fileType:[H_FILE:h文件  M_FILE: m文件]
 **/
+ (NSString *)introductionPackages:(FileType)fileType
{
    NSMutableString *result = [[NSMutableString alloc] init];
    switch (fileType) {
        case H_FILE:
        {
            [result appendString:@"#import <AFNetworking/AFNetworking.h>\n"];
            [result appendString:@"#import \"Config.h\"\n"];
            [result appendFormat:@"#import \"%@.h\"\n", MODEL_NAME];
        }
            break;
        case M_FILE:
        {
            [result appendFormat:@"#import \"%@.h\"\n", REQUEST_NAME];
            [result appendFormat:@"#import <SVProgressHUD/SVProgressHUD.h>\n"];
        }
            break;
            
        default:
            break;
    }
    
    return result;
}

/**
 * @brief  Request 基本类的功能
 * @prama  fileType:[H_FILE:h文件  M_FILE: m文件]
 **/
+ (NSString *)classOfRequest:(FileType)fileType
{
    NSMutableString *result = [[NSMutableString alloc] init];
    switch (fileType) {
        case H_FILE:
        {
            [result appendFormat:@"\n\n@interface Request : AFHTTPRequestOperationManager {\n"];
            [result appendFormat:@"}\n"];
            [result appendFormat:@"\n+ (instancetype)sharedClient;\n\n\n"];
        }
            break;
        case M_FILE:
        {
            [result appendFormat:@"\n@implementation Request\n"];
            [result appendFormat:@"\n+ (instancetype)sharedClient {\n"];
            [result appendFormat:@"\tstatic Request *_sharedClient;\n"];
            [result appendFormat:@"\tstatic dispatch_once_t onceToken;\n"];
            [result appendFormat:@"\tdispatch_once(&onceToken, ^{ \n"];
            [result appendFormat:@"\t\t_sharedClient = [[Request alloc] initWithBaseURL:[NSURL URLWithString:HOST_NAME]];\n"];
            [result appendFormat:@"\t\t_sharedClient.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];\n"];
            [result appendFormat:@"\t\t_sharedClient.responseSerializer = [AFJSONResponseSerializer serializer];//申明返回的结果是json类型\n"];
            [result appendFormat:@"\t\t_sharedClient.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@\"text/html\"];//如果报接受类型不一致请替换一致text/html或别的\n"];
            [result appendFormat:@"\t\t//_sharedClient.requestSerializer = [AFJSONRequestSerializer serializer];//申明请求的数据是json类型\n"];
            [result appendFormat:@"\t});\n"];
            [result appendFormat:@"\treturn _sharedClient;\n"];
            [result appendFormat:@"}\n\n\n"];
        }
            break;
            
        default:
            break;
    }
    
    return result;
}

/**
 * @brief  匹配出所有的Request类型
 * @prama  sourceString:需要匹配的字符串
 * @prama  fileType:[H_FILE:h文件  M_FILE: m文件]
 **/
+ (NSString *)messageFromSourceString:(NSString *)sourceString fileType:(FileType)fileType
{
    NSMutableString *result = [[NSMutableString alloc] init];
    NSString *regexRequest = @"request (get|post|upload)(?:\\s+)(\\S+)(?:\\s+)(\\S+)(?:\\s*)\\{([\\s\\S]*?)\\}(?:\\s*?)";
    NSArray *requestList = [sourceString arrayOfCaptureComponentsMatchedByRegex:regexRequest];

    @autoreleasepool {
        for (NSArray *items in requestList) {
            NSString *requestType = @"get";
            requestType = [items objectAtIndex:1];
            NSString *interface = [items objectAtIndex:2];
            NSString *returnType = [items objectAtIndex:3];
            NSArray *contents = [[items objectAtIndex:4] componentsSeparatedByString:@"\n"];
            
            [result appendString:[self generationRequestType:requestType methodName:interface returnType:returnType contents:contents methodType:TYPE_NOTES]];
            [result appendString:[self generationRequestType:requestType methodName:interface returnType:returnType contents:contents methodType:TYPE_METHOD]];
            
        }
    }
    
    return result;
}

/**
 * @brief  生成方法名
 * @prama  requestType:接口类型 get | post | upload
 * @prama  interface:接口名称
 * @prama  returnType:返回类型
 * @prama  methodType:方法类型
 * @prama  contents:接口参数
 */
+ (NSString *)generationRequestType:(NSString *)requestType methodName:(NSString *)interface returnType:(NSString *)returnType contents:(NSArray *)contents methodType:(MethodType)methodType
{
    NSMutableString *result = [[NSMutableString alloc] init];
    switch (methodType) {
        case TYPE_NOTES:
        {
            [result appendFormat:@"/**\n"];
            [self allPramaFromContents:contents withType:methodType];
            [result appendFormat:@"**/\n"];
        }
            break;
        
        case TYPE_METHOD:
        {
            [result appendFormat:@"+(AFHTTPRequestOperation *)%@RequestUrl:(NSString *)baseurl", interface];
            
            //判断是否是上传接口  上传接口需要提取出来单独处理
            if ([requestType isEqualToString:@"upload"]) {
                for (NSString *line in contents) {
                    NSString *regexLine = @"^(?:[\\s]*)(loadpath)(?:[\\s]*)(\\S+)(?:[\\s]*)(\\S+)(?:[\\s]*)=(?:[\\s]*)(\\S+)(?:[\\s]*);([\\S\\s]*)$";
                    NSArray *lineList = [line arrayOfCaptureComponentsMatchedByRegex:regexLine];
                    if (lineList.count == 0) {
                        continue;
                    }
                    NSArray *fields = [lineList firstObject];
                    if (fields.count < 6) {
                        continue;
                    }
                    
                    NSString *style = [fields objectAtIndex:1];
                    NSString *type = [fields objectAtIndex:2];
                    NSMutableString *fieldname = [fields objectAtIndex:3];
                    NSString *keyname = [fields objectAtIndex:3];
                    NSString *regex = @"^(?:[\\s]*)(?:[\\s]*)(\\S+)(?:[\\s]*)((?:\\()\\S+(?:\\)))";
                    NSArray *nameList = [[fieldname arrayOfCaptureComponentsMatchedByRegex:regex] firstObject];
                    if (nameList.count >= 3) {
                        keyname = [nameList objectAtIndex:1];
                        fieldname = [[NSMutableString alloc] initWithString:[nameList objectAtIndex:2]];
                        [fieldname deleteCharactersInRange:[fieldname rangeOfString:@"("]];
                        [fieldname deleteCharactersInRange:[fieldname rangeOfString:@")"]];
                    }
                    NSString *defaultValue = [fields objectAtIndex:4];
                    NSString *notes = [fields objectAtIndex:5];
                    
                    [result appendFormat:@"%@:(NSArray *)%@", fieldname, @"pic"];
                }
            }
            else if ([requestType isEqualToString:@"get"]) {
            }
            else if ([requestType isEqualToString:@"post"]) {
            }
            else {
                NSLog(@"ERROR -- 网络请求接口参数有误");
            }
            [self allPramaFromContents:contents withType:methodType];
            [result appendFormat:@";\n\n"];
        }
            break;
        default:
            break;
    }
    

    
    return result;
}

/**
 * @brief  request请求的所有参数
 * @prama  contents:参数列表
 * @prama  methodType:方法类型
 */
+ (NSString *)allPramaFromContents:(NSArray *)contents withType:(MethodType)methodType
{
    NSMutableString *result = [[NSMutableString alloc] init];
    for (int i = 0; i < contents.count; i++) {
        NSString *lineString = [contents objectAtIndex:i];
        NSString *regexLine = @"^(?:[\\s]*)(required|optional|repeated)(?:[\\s]*)(\\S+)(?:[\\s]*)(\\S+)(?:[\\s]*)=(?:[\\s]*)(\\S+)(?:[\\s]*);([\\S\\s]*)$";
        NSArray *lineList = [lineString arrayOfCaptureComponentsMatchedByRegex:regexLine];
        if (lineList.count == 0) {
            continue;
        }
        NSArray *fields = [lineList firstObject];
        if (fields.count < 6) {
            continue;
        }
        NSString *style = [fields objectAtIndex:1];
        NSString *type = [fields objectAtIndex:2];
        NSMutableString *fieldname = [fields objectAtIndex:3];
        NSString *keyname = [fields objectAtIndex:3];
        NSString *regex = @"^(?:[\\s]*)(?:[\\s]*)(\\S+)(?:[\\s]*)((?:\\()\\S+(?:\\)))";
        NSArray *nameList = [[fieldname arrayOfCaptureComponentsMatchedByRegex:regex] firstObject];
        if (nameList.count >= 3) {
            keyname = [nameList objectAtIndex:1];
            fieldname = [[NSMutableString alloc] initWithString:[nameList objectAtIndex:2]];
            [fieldname deleteCharactersInRange:[fieldname rangeOfString:@"("]];
            [fieldname deleteCharactersInRange:[fieldname rangeOfString:@")"]];
        }
        NSString *defaultValue = [fields objectAtIndex:4];
        NSString *notes = [fields objectAtIndex:5];
        switch (methodType) {
            case TYPE_NOTES:
            {
                if (i == 0) {
                    [result appendFormat:@" * @brief %@", [contents firstObject]];
                }
                [result appendFormat:@" * @prama %@:%@", fieldname, notes];
            }
                break;
            
            case TYPE_METHOD:
            {
                if ([style isEqualToString:@"repeated"]) {
#warning 上传数组的处理
                }
                else {
                    if (IS_BASE_TYPE(type)) {
                        [result appendFormat:@" %@:(%@)%@", fieldname, [type lowercaseString], fieldname];
                    }
                    else if ([type isEqualToString:@"string"]){
                        [result appendFormat:@" %@:(NSString *)%@", fieldname, fieldname];
                    }
                    else {
#warning 非简单数据类型的处理 包含枚举类型和model类型
                        //result appendString:@"%@:(%@)"
                    }
                }
            }
                break;
            default:
                break;
        }
    }
    
    
    return result;
}

@end



















