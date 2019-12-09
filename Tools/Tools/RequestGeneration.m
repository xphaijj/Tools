//
//  RequestGeneration.m
//  Tools
//
//  Created by Alex xiang on 15/1/31.
//  Copyright (c) 2015年 Alex xiang. All rights reserved.
//

#import "RequestGeneration.h"

@implementation RequestGeneration
static NSArray *enumList;
static NSDictionary *configDictionary;
/**
 * @brief  Model类自动生成
 * @prama  sourcepath:资源路径   outputPath:资源生成路径
 */
+ (void)generationSourcePath:(NSString *)sourcepath outputPath:(NSString *)outputPath config:(NSDictionary *)config
{
    configDictionary = config;
    if (![configDictionary.allKeys containsObject:@"baseurl"]) {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:configDictionary];
        [dic setObject:@NO forKey:@"baseurl"];
        configDictionary = [dic copy];
    }
    NSError *error;
    NSString *sourceString = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForAuxiliaryExecutable:sourcepath] encoding:NSUTF8StringEncoding error:&error];
    
    NSMutableString *h = [[NSMutableString alloc] init];
    NSMutableString *m = [[NSMutableString alloc] init];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    NSString *hFilePath = [outputPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@Request.h", configDictionary[@"filename"]]];
    NSString *mFilePath = [outputPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@Request.m", configDictionary[@"filename"]]];
    [fileManager createFileAtPath:hFilePath contents:nil attributes:nil];
    [fileManager createFileAtPath:mFilePath contents:nil attributes:nil];
    
    //版权信息的导入
    [h appendString:[Utils createCopyrightByFilename:[NSString stringWithFormat:@"%@Request.h", configDictionary[@"filename"]] config:config]];
    [m appendString:[Utils createCopyrightByFilename:[NSString stringWithFormat:@"%@Request.m", configDictionary[@"filename"]] config:config]];
    
    //头文件的导入
    [h appendString:[self introductionPackages:H_FILE]];
    [m appendString:[self introductionPackages:M_FILE]];
    
    enumList = [Utils enumList:sourceString];
    
    //导入基本的 实现
    [h appendString:[self classOfRequest:H_FILE]];
    [m appendString:[self classOfRequest:M_FILE]];
    
    //匹配出所有的Request类型
    [h appendString:[self messageFromSourceString:sourceString fileType:H_FILE]];
    [m appendString:[self messageFromSourceString:sourceString fileType:M_FILE]];
    
    
    [h appendFormat:@"\n#pragma clang diagnostic pop\n"];
    [m appendFormat:@"#pragma clang diagnostic pop\n"];
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
            [result appendFormat:@"#import <YLT_BaseLib/YLT_BaseLib.h>\n"];
            [result appendFormat:@"#import <ReactiveObjC/ReactiveObjC.h>\n"];
            [result appendFormat:@"#import <AFNetworking/AFNetworking.h>\n"];
            [result appendFormat:@"#import \"PHRequest.h\"\n"];
            [result appendFormat:@"#import \"%@Model.h\"\n", configDictionary[@"filename"]];
        }
            break;
        case M_FILE:
        {
            [result appendFormat:@"#import \"%@Request.h\"\n", configDictionary[@"filename"]];
            if ([configDictionary[@"pods"] boolValue]) {
                [result appendString:@"#import <AFNetworking/AFNetworking.h>\n"];
                if ([configDictionary[@"response"] isEqualToString:@"xml"]) {
                    [result appendString:@"#import <XMLDictionary/XMLDictionary.h>\n"];
                }
            }
            else {
                [result appendString:@"#import \"AFNetworking.h\"\n"];
                if ([configDictionary[@"response"] isEqualToString:@"xml"]) {
                    [result appendString:@"#import \"XMLDictionary.h\"\n"];
                }
            }
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
            [result appendFormat:@"\n\n@interface %@Request : NSObject {\n", configDictionary[@"filename"]];
            [result appendFormat:@"}\n"];
            [result appendFormat:@"#pragma clang diagnostic push\n"];
            [result appendFormat:@"#pragma clang diagnostic ignored \"-Wdocumentation\"\n"];
        }
            break;
        case M_FILE:
        {
            [result appendFormat:@"\n@implementation %@Request\n", configDictionary[@"filename"]];
            [result appendFormat:@"#pragma clang diagnostic push\n"];
            [result appendFormat:@"#pragma clang diagnostic ignored \"-Wundeclared-selector\"\n"];
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
    NSString *regexRequest = @"request (get|post|upload|put|delete|iget|ipost|iupload|iput|idelete|patch|ipatch)(?:\\s+)(\\S+)(?:\\s+)(\\S+)(?:\\s*)\\{([\\s\\S]*?)\\}(save)?(?:\\s*?)";
    NSArray *requestList = [sourceString arrayOfCaptureComponentsMatchedByRegex:regexRequest];
    @autoreleasepool {
        for (NSArray *items in requestList) {
            NSString *requestType = @"get";
            requestType = [items objectAtIndex:1];
            NSString *interface = [items objectAtIndex:2];
            
            NSString *returnType = [items objectAtIndex:3];
            if ([returnType isEqualToString:@"nil"]) {
                returnType = @"BaseCollection";
            }
            NSArray *contents = [[items objectAtIndex:4] componentsSeparatedByString:@"\n"];
            BOOL hasSave = ![[items objectAtIndex:6] isEqualToString:@""];//是否需要保存
            
            [result appendString:[self generationFileType:fileType baseURL:@"" requestType:requestType methodName:interface returnType:returnType contents:contents methodType:TYPE_NOTES hasSave:hasSave]];
            [result appendString:[self generationFileType:fileType baseURL:@"" requestType:requestType methodName:interface returnType:returnType contents:contents methodType:TYPE_METHOD hasSave:hasSave]];
            [result appendString:[self generationFileType:fileType baseURL:@"" requestType:requestType methodName:interface returnType:returnType contents:contents methodType:TYPE_REQUEST hasSave:hasSave]];
            [result appendString:[self generationFileType:fileType baseURL:@"" requestType:requestType methodName:interface returnType:returnType contents:contents methodType:TYPE_NORMALREQUEST hasSave:hasSave]];
            [result appendString:[self generationFileType:fileType baseURL:@"" requestType:requestType methodName:interface returnType:returnType contents:contents methodType:TYPE_RACSIGNAL hasSave:hasSave]];
            [result appendString:[self generationFileType:fileType baseURL:@"" requestType:requestType methodName:interface returnType:returnType contents:contents methodType:TYPE_NORMALRAC hasSave:hasSave]];
        }
    }
    
    /// 匹配带路径的网络请求
    regexRequest = @"request (get|post|upload|put|delete|iget|ipost|iupload|iput|idelete|patch|ipatch)(?:\\s+)(\\S+)(?:\\s+)(\\S+)(?:\\s+)(\\S+)(?:\\s*)\\{([\\s\\S]*?)\\}(save)?(?:\\s*?)";
    requestList = [sourceString arrayOfCaptureComponentsMatchedByRegex:regexRequest];
    @autoreleasepool {
        for (NSArray *items in requestList) {
            NSString *requestType = @"get";
            requestType = [items objectAtIndex:1];
            NSString *interface = [items objectAtIndex:2];
            
            NSString *returnType = [items objectAtIndex:3];
            if ([returnType isEqualToString:@"nil"]) {
                returnType = @"BaseCollection";
            }
            NSString *baseUrl = [items objectAtIndex:4];
            NSArray *contents = [[items objectAtIndex:5] componentsSeparatedByString:@"\n"];
            BOOL hasSave = ![[items objectAtIndex:6] isEqualToString:@""];//是否需要保存
            
            [result appendString:[self generationFileType:fileType baseURL:baseUrl requestType:requestType methodName:interface returnType:returnType contents:contents methodType:TYPE_NOTES hasSave:hasSave]];
            [result appendString:[self generationFileType:fileType baseURL:baseUrl requestType:requestType methodName:interface returnType:returnType contents:contents methodType:TYPE_METHOD hasSave:hasSave]];
            [result appendString:[self generationFileType:fileType baseURL:baseUrl requestType:requestType methodName:interface returnType:returnType contents:contents methodType:TYPE_REQUEST hasSave:hasSave]];
            [result appendString:[self generationFileType:fileType baseURL:baseUrl requestType:requestType methodName:interface returnType:returnType contents:contents methodType:TYPE_NORMALREQUEST hasSave:hasSave]];
            [result appendString:[self generationFileType:fileType baseURL:baseUrl requestType:requestType methodName:interface returnType:returnType contents:contents methodType:TYPE_RACSIGNAL hasSave:hasSave]];
            [result appendString:[self generationFileType:fileType baseURL:baseUrl requestType:requestType methodName:interface returnType:returnType contents:contents methodType:TYPE_NORMALRAC hasSave:hasSave]];
            
        }
    }
    
    return result;
}

/**
 * @brief  生成方法名
 * @prama  fileType:[H_FILE:h文件  M_FILE: m文件]
 * @prama  baseURL 基础路径
 * @prama  requestType:接口类型 get | post | upload
 * @prama  interface:接口名称
 * @prama  returnType:返回类型
 * @prama  methodType:方法类型
 * @prama  contents:接口参数
 */
+ (NSString *)generationFileType:(FileType)fileType baseURL:(NSString *)baseURL requestType:(NSString *)requestType methodName:(NSString *)interface returnType:(NSString *)returnType contents:(NSArray *)contents methodType:(MethodType)methodType hasSave:(BOOL)hasSave
{
    NSMutableString *result = [[NSMutableString alloc] init];
    NSMutableString *res1 = [[NSMutableString alloc] init];
    NSMutableString *res2 = [[NSMutableString alloc] init];
    NSMutableString *res3 = [[NSMutableString alloc] init];
    
    NSMutableString *interfacename = (NSMutableString *)interface;
    NSString *regex = @"^(?:[\\s]*)(?:[\\s]*)(\\S+)(?:[\\s]*)((?:\\()\\S+(?:\\)))";
    NSArray *nameList = [[interface arrayOfCaptureComponentsMatchedByRegex:regex] firstObject];
    if (nameList.count >= 3) {
        interface = [nameList objectAtIndex:1];
        interfacename = [[NSMutableString alloc] initWithString:[nameList objectAtIndex:2]];
        [interfacename deleteCharactersInRange:[interfacename rangeOfString:@"("]];
        [interfacename deleteCharactersInRange:[interfacename rangeOfString:@")"]];
    }
    NSArray *returnTypeList = [[returnType arrayOfCaptureComponentsMatchedByRegex:regex] firstObject];
    BOOL returnIsList = NO;//返回数据是否是数组类型
    NSString *modelname = returnType;
    if (returnTypeList.count >= 3) {
        modelname = returnTypeList[1];
        NSMutableString *returnTypeName = [[NSMutableString alloc] initWithString:[returnTypeList objectAtIndex:2]];
        [returnTypeName deleteCharactersInRange:[returnTypeName rangeOfString:@"("]];
        [returnTypeName deleteCharactersInRange:[returnTypeName rangeOfString:@")"]];
        if ([returnTypeName isEqualToString:@"list"] || [returnTypeName isEqualToString:@"array"]) {
            returnIsList = YES;
            returnType = [NSString stringWithFormat:@"NSMutableArray<%@ *>", modelname];
        }
    }
    
    NSString *uploadKey = @"";
    // h m 文件中均需导入的
    switch (methodType) {
        case TYPE_NOTES:
        {
            [result appendFormat:@"/**\n"];
            [result appendFormat:@" * @brief %@\n", [[contents firstObject] stringByReplacingOccurrencesOfString:@"/" withString:@""]];
            [result appendString:[self allPramaFromContents:contents withType:methodType fileType:fileType hasSave:hasSave]];
            [result appendFormat:@" **/\n"];
        }
            break;
        
        case TYPE_NORMALREQUEST:
        case TYPE_NORMALRAC: {
            if (methodType == TYPE_NORMALREQUEST) {
                if ([configDictionary[@"baseurl"] boolValue]) {
                    [result appendFormat:@"+(NSURLSessionDataTask *)%@RequestUrl:(NSString *)baseurl showHUD:(BOOL)showHUD", [interfacename stringByReplacingOccurrencesOfString:@"/" withString:@""]];
                } else {
                    [result appendFormat:@"+(NSURLSessionDataTask *)%@RequestShowHUD:(BOOL)showHUD", [interfacename stringByReplacingOccurrencesOfString:@"/" withString:@""]];
                }
            } else {
                if ([configDictionary[@"baseurl"] boolValue]) {
                    [result appendFormat:@"+(RACSignal *)%@RequestUrl:(NSString *)baseurl showHUD:(BOOL)showHUD", [interfacename stringByReplacingOccurrencesOfString:@"/" withString:@""]];
                } else {
                    [result appendFormat:@"+(RACSignal *)%@RequestShowHUD:(BOOL)showHUD", [interfacename stringByReplacingOccurrencesOfString:@"/" withString:@""]];
                }
            }
            //判断是否是上传接口  上传接口需要提取出来单独处理
            if ([requestType isEqualToString:@"upload"] || [requestType isEqualToString:@"iupload"]) {
                [result appendFormat:@" formDataBlock:(void(^)(id<AFMultipartFormData> formData))formDataBlock"];
            }
            [result appendFormat:@" iparams:(NSDictionary *)iparams"];
            if (methodType == TYPE_NORMALREQUEST) {
                [result appendFormat:@" success:(void (^)(NSURLSessionDataTask *task, BaseCollection *result, %@ *data, id sourceData))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;", [returnType isEqualToString:@"BaseCollection"]?@"NSDictionary":returnType];
            } else {
                [result appendFormat:@";"];
            }
        }
            break;
        case TYPE_METHOD:
        case TYPE_RACSIGNAL:
        {
            if (methodType == TYPE_METHOD) {
                if ([configDictionary[@"baseurl"] boolValue]) {
                    [result appendFormat:@"+(NSURLSessionDataTask *)%@RequestUrl:(NSString *)baseurl showHUD:(BOOL)showHUD", [interfacename stringByReplacingOccurrencesOfString:@"/" withString:@""]];
                } else {
                    [result appendFormat:@"+(NSURLSessionDataTask *)%@RequestShowHUD:(BOOL)showHUD", [interfacename stringByReplacingOccurrencesOfString:@"/" withString:@""]];
                }
            } else {
                if ([configDictionary[@"baseurl"] boolValue]) {
                    [result appendFormat:@"+(RACSignal *)%@RequestUrl:(NSString *)baseurl showHUD:(BOOL)showHUD", [interfacename stringByReplacingOccurrencesOfString:@"/" withString:@""]];
                } else {
                    [result appendFormat:@"+(RACSignal *)%@RequestShowHUD:(BOOL)showHUD", [interfacename stringByReplacingOccurrencesOfString:@"/" withString:@""]];
                }
            }
            
            //判断是否是上传接口  上传接口需要提取出来单独处理
            if ([requestType isEqualToString:@"upload"] || [requestType isEqualToString:@"iupload"]) {
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
                    NSString *fieldname = [fields objectAtIndex:3];
                    NSMutableString *keyname = [fields objectAtIndex:3];
                    NSString *regex = @"^(?:[\\s]*)(?:[\\s]*)(\\S+)(?:[\\s]*)((?:\\()\\S+(?:\\)))";
                    NSArray *nameList = [[fieldname arrayOfCaptureComponentsMatchedByRegex:regex] firstObject];
                    if (nameList.count >= 3) {
                        fieldname = [nameList objectAtIndex:1];
                        keyname = [[NSMutableString alloc] initWithString:[nameList objectAtIndex:2]];
                        [keyname deleteCharactersInRange:[keyname rangeOfString:@"("]];
                        [keyname deleteCharactersInRange:[keyname rangeOfString:@")"]];
                    }
                    uploadKey = fieldname;
                    NSString *defaultValue = [fields objectAtIndex:4];
                    NSString *notes = [fields objectAtIndex:5];
                    
                    [result appendFormat:@" formDataBlock:(void(^)(id<AFMultipartFormData> formData))formDataBlock"];
                }
            }
            else if ([requestType isEqualToString:@"get"] || [requestType isEqualToString:@"iget"]) {
            }
            else if ([requestType isEqualToString:@"post"] || [requestType isEqualToString:@"ipost"]) {
            }
            else if ([requestType isEqualToString:@"patch"] || [requestType isEqualToString:@"ipatch"]) {
            }
            else if ([requestType isEqualToString:@"put"] || [requestType isEqualToString:@"iput"]) {
            }
            else if ([requestType isEqualToString:@"delete"] || [requestType isEqualToString:@"idelete"]) {
            }
            else {
                NSLog(@"ERROR -- 网络请求接口参数有误");
            }
            [result appendString:[self allPramaFromContents:contents withType:methodType fileType:fileType hasSave:hasSave]];
            
            if (methodType == TYPE_METHOD) {
                [result appendFormat:@" success:(void (^)(NSURLSessionDataTask *task, BaseCollection *result, %@ *data, id sourceData))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure; ", [returnType isEqualToString:@"BaseCollection"]?@"NSDictionary":returnType];
            } else {
                [result appendFormat:@";"];
            }
        }
            break;
        default:
            break;
    }
    
    
    //区分 h m 文件导入的
    switch (fileType) {
        case H_FILE:
        {
            switch (methodType) {
                case TYPE_REQUEST:
                case TYPE_RACSIGNAL:
                case TYPE_NORMALREQUEST:
                case TYPE_NORMALRAC:
                {
                    [result appendFormat:@"\n"];
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
                case TYPE_METHOD: {
                }
                    break;
                case TYPE_RACSIGNAL: {
                    [res1 appendFormat:@" {\n"];
                    [res1 appendFormat:@"\t@weakify(self);\n"];
                    [res1 appendFormat:@"\tRACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {\n"];
                    [res1 appendFormat:@"\t\t@strongify(self);\n"];
                    if ([configDictionary[@"baseurl"] boolValue]) {
                        [res1 appendFormat:@"\t\tNSURLSessionDataTask *task = [self %@RequestUrl:(NSString *)baseurl showHUD:(BOOL)showHUD", [interfacename stringByReplacingOccurrencesOfString:@"/" withString:@""]];
                    } else {
                        [res1 appendFormat:@"\t\tNSURLSessionDataTask *task = [self %@RequestShowHUD:(BOOL)showHUD", [interfacename stringByReplacingOccurrencesOfString:@"/" withString:@""]];
                    }
                    //判断是否是上传接口  上传接口需要提取出来单独处理
                    if ([requestType isEqualToString:@"upload"] || [requestType isEqualToString:@"iupload"]) {
                        [res1 appendFormat:@" formDataBlock:(void(^)(id<AFMultipartFormData> formData))formDataBlock"];
                    }
                    [res1 appendString:[self allPramaFromContents:contents withType:methodType fileType:fileType hasSave:hasSave]];
                    [res1 appendFormat:@" success:^(NSURLSessionDataTask *task, BaseCollection *result, %@ *data, id sourceData) {\n", [returnType isEqualToString:@"BaseCollection"]?@"NSDictionary":returnType];
                    [res1 appendFormat:@"\t\t\t[subscriber sendNext:@{@\"result\":result, @\"data\":data, @\"sourceData\":sourceData}];\n"];
                    [res1 appendFormat:@"\t\t\t[subscriber sendCompleted];\n"];
                    [res1 appendFormat:@"\t\t} failure:^(NSURLSessionDataTask *task, NSError *error) {\n"];
                    [res1 appendFormat:@"\t\t\t[subscriber sendNext:error];\n"];
                    [res1 appendFormat:@"\t\t\t[subscriber sendCompleted];\n"];
                    [res1 appendFormat:@"\t\t}];\n"];
                    [res1 appendFormat:@"\t\treturn [RACDisposable disposableWithBlock:^{\n"];
                    [res1 appendFormat:@"\t\t\t[task cancel];\n"];
                    [res1 appendFormat:@"\t\t}];\n"];
                    [res1 appendFormat:@"\t}];\n"];
                    [res1 appendFormat:@"\treturn [signal replayLazily];\n"];
                    [res1 appendString:@"}\n\n"];
                    [result appendString:res1];
                }
                    break;
                case TYPE_NORMALRAC: {
                    [res2 appendFormat:@" {\n"];
                    [res2 appendFormat:@"\t@weakify(self);\n"];
                    [res2 appendFormat:@"\tRACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {\n"];
                    [res2 appendFormat:@"\t\t@strongify(self);\n"];
                    if ([configDictionary[@"baseurl"] boolValue]) {
                        [res2 appendFormat:@"\t\tNSURLSessionDataTask *task = [self %@RequestUrl:(NSString *)baseurl showHUD:(BOOL)showHUD", [interfacename stringByReplacingOccurrencesOfString:@"/" withString:@""]];
                    } else {
                        [res2 appendFormat:@"\t\tNSURLSessionDataTask *task = [self %@RequestShowHUD:(BOOL)showHUD", [interfacename stringByReplacingOccurrencesOfString:@"/" withString:@""]];
                    }
                    //判断是否是上传接口  上传接口需要提取出来单独处理
                    if ([requestType isEqualToString:@"upload"] || [requestType isEqualToString:@"iupload"]) {
                        [res2 appendFormat:@" formDataBlock:(void(^)(id<AFMultipartFormData> formData))formDataBlock"];
                    }
                    [res2 appendFormat:@" iparams:(NSDictionary *)iparams success:^(NSURLSessionDataTask *task, BaseCollection *result, %@ *data, id sourceData) {\n", [returnType isEqualToString:@"BaseCollection"]?@"NSDictionary":returnType];
                    [res2 appendFormat:@"\t\t\t[subscriber sendNext:@{@\"result\":result, @\"data\":data, @\"sourceData\":sourceData}];\n"];
                    [res2 appendFormat:@"\t\t\t[subscriber sendCompleted];\n"];
                    [res2 appendFormat:@"\t\t} failure:^(NSURLSessionDataTask *task, NSError *error) {\n"];
                    [res2 appendFormat:@"\t\t\t[subscriber sendNext:error];\n"];
                    [res2 appendFormat:@"\t\t\t[subscriber sendCompleted];\n"];
                    [res2 appendFormat:@"\t\t}];\n"];
                    [res2 appendFormat:@"\t\treturn [RACDisposable disposableWithBlock:^{\n"];
                    [res2 appendFormat:@"\t\t\t[task cancel];\n"];
                    [res2 appendFormat:@"\t\t}];\n"];
                    [res2 appendFormat:@"\t}];\n"];
                    [res2 appendFormat:@"\treturn [signal replayLazily];\n"];
                    [res2 appendString:@"}\n\n"];
                    [result appendString:res2];
                }
                    break;
                case TYPE_NORMALREQUEST: {
                    BOOL hideHud = [requestType hasPrefix:@"i"];
                    [result appendFormat:@"{\n"];
                    
                    if (!hideHud) {
                        [result appendFormat:@"\tif (showHUD) {\n"];
                        [result appendFormat:@"\t\tdispatch_async(dispatch_get_main_queue(), ^{\n"];
                        [result appendFormat:@"\t\t\t[PHRequest showRequestHUD];\n"];
                        [result appendFormat:@"\t\t});\n"];
                        [result appendFormat:@"\t}\n"];
                    }
                    [result appendFormat:@"\tNSMutableDictionary *extraData = [[NSMutableDictionary alloc] init];\n"];
                    [result appendFormat:@"\tNSMutableDictionary *requestParams = [[NSMutableDictionary alloc] initWithDictionary:([PHRequest baseParams:@{@\"action\":@\"%@\"} extraData:extraData])];\n", interfacename];
                    [result appendFormat:@"\t[requestParams addEntriesFromDictionary:iparams];\n"];
                    [result appendFormat:@"\tNSString *baseUrl = [PHRequest baseURL:[NSString stringWithFormat:@\"%%@/%@/%%@\", BASE_URL, %@] extraData:extraData];\n", baseURL, [configDictionary[@"baseurl"] boolValue]?@"baseurl":@"@\"\""];
                    
                    [result appendFormat:@"\tNSDictionary *parameters = ([PHRequest uploadParams:requestParams extraData:extraData]);\n"];
                    [result appendFormat:@"\tYLT_Log(@\"%%@ %%@\", baseUrl, extraData);\n"];
                    
                    [result appendString:@"\tvoid(^callback)(NSURLSessionDataTask *task, id result) = ^(NSURLSessionDataTask *task, id result) {\n"];
                    if (hasSave) {
                        [result appendString:@"\t\tif (task) {//说明是从网络请求返回的数据\n"];
                        [result appendString:@"\t\t\t[[NSUserDefaults standardUserDefaults] setObject:result forKey:baseUrl];\n"];
                        [result appendString:@"\t\t\t[[NSUserDefaults standardUserDefaults] synchronize];\n"];
                        [result appendString:@"\t\t}\n"];
                    }
                    [result appendFormat:@"\t\tid decryptResult = ([PHRequest responseTitle:@\"%@\" result:result baseUrl:baseUrl parameters:requestParams extraData:extraData]);\n", [[contents firstObject] stringByReplacingOccurrencesOfString:@"/" withString:@""]];
                    [result appendString:@"\t\tYLT_Log(@\"%@ %@ %@\", baseUrl, extraData, decryptResult);\n"];
                    
                    [result appendFormat:@"\t\tBaseCollection *res = [BaseCollection mj_objectWithKeyValues:decryptResult];\n"];
                    [result appendString:@"\t\tid data = decryptResult[@\"body\"];\n"];
                    
                    [result appendFormat:@"\t\tif (success) {\n"];
                    if (![returnType isEqualToString:@"BaseCollection"]) {
                        if (returnIsList) {//返回的数据类型是数组
                            [result appendFormat:@"\t\t\tif ([data isKindOfClass:[NSDictionary class]]) {\n"];
                            [result appendFormat:@"\t\t\t\t%@ *info = [%@ mj_objectWithKeyValues:data];\n", modelname, modelname];
                            [result appendString:@"\t\t\t\tsuccess(task, res, @[info].mutableCopy, result);\n"];
                            [result appendString:@"\t\t\t} else if ([data isKindOfClass:[NSArray class]]) {\n"];
                            [result appendFormat:@"\t\t\t\tNSMutableArray *resultList = [%@ mj_objectArrayWithKeyValuesArray:data];\n", modelname];
                            
//                            [result appendFormat:@"\t\t\t\tNSMutableArray *resultList = [[NSMutableArray alloc] init];\n"];
//                            [result appendFormat:@"\t\t\t\t[((NSArray *) data) enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {\n"];
//                            [result appendFormat:@"\t\t\t\t\tif ([obj isKindOfClass:[NSDictionary class]] || [obj isKindOfClass:[NSString class]]) {\n"];
//                            [result appendFormat:@"\t\t\t\t\t\t[resultList addObject:[%@ mj_objectWithKeyValues:obj]];\n", modelname];
//                            [result appendFormat:@"\t\t\t\t\t} else {\n"];
//                            [result appendFormat:@"\t\t\t\t\t\t[resultList addObject:obj];\n"];
//                            [result appendFormat:@"\t\t\t\t\t}\n"];
//                            [result appendFormat:@"\t\t\t\t}];\n"];
                            [result appendFormat:@"\t\t\t\tsuccess(task, res, resultList, decryptResult);\n"];
                        } else {
                            [result appendFormat:@"\t\t\tif ([data isKindOfClass:[NSDictionary class]]) {\n"];
                            [result appendFormat:@"\t\t\t\t%@ *info = [%@ mj_objectWithKeyValues:data];\n", returnType, returnType];
                            [result appendString:@"\t\t\t\tsuccess(task, res, info, decryptResult);\n"];
                        }
                        
                        [result appendFormat:@"\t\t\t} else {\n"];
                        [result appendString:@"\t\t\t\tsuccess(task, res, data, decryptResult);\n"];
                        [result appendFormat:@"\t\t\t}\n"];
                    } else {
                        [result appendString:@"\t\t\tsuccess(task, res, data, decryptResult);\n"];
                    }
                    [result appendFormat:@"\t\t}\n"];
                    [result appendString:@"\t};\n"];
                    if (hasSave) {
                        [result appendString:@"\tif ([[NSUserDefaults standardUserDefaults].dictionaryRepresentation.allKeys containsObject:baseUrl]) {\n"];
                        [result appendString:@"\t\tid result = [[NSUserDefaults standardUserDefaults] objectForKey:baseUrl];\n"];
                        [result appendString:@"\t\tcallback(nil, result);\n"];
                        [result appendString:@"\t}\n"];
                    }
                    
                    if ([requestType isEqualToString:@"get"] || [requestType isEqualToString:@"iget"]) {
                        [result appendFormat:@"\tNSURLSessionDataTask *op = [[PHRequest sharedClient:@\"%@\"] GET:baseUrl parameters:parameters progress:^(NSProgress * uploadProgress) {\n", interfacename];
                        
                        if (!hideHud) {
                            [result appendFormat:@"\t\tif (showHUD) {\n"];
                            [result appendFormat:@"\t\t\tdispatch_async(dispatch_get_main_queue(), ^{\n"];
                            [result appendFormat:@"\t\t\t\t[PHRequest showPercentHUD:(((CGFloat)uploadProgress.completedUnitCount)/((CGFloat)uploadProgress.totalUnitCount))];\n"];
                            
                            [result appendFormat:@"\t\t\t});\n"];
                            [result appendFormat:@"\t\t}\n"];
                        }
                        
                        [result appendFormat:@"\t} success:^(NSURLSessionDataTask *task, id result) {\n"];
                    }
                    else if ([requestType isEqualToString:@"post"] || [requestType isEqualToString:@"ipost"]) {
                        [result appendFormat:@"\tNSURLSessionDataTask *op = [[PHRequest sharedClient:@\"%@\"] POST:baseUrl parameters:parameters progress:^(NSProgress * uploadProgress) {\n", interfacename];
                        
                        if (!hideHud) {
                            [result appendFormat:@"\t\tif (showHUD) {\n"];
                            [result appendFormat:@"\t\t\tdispatch_async(dispatch_get_main_queue(), ^{\n"];
                            [result appendFormat:@"\t\t\t\t[PHRequest showPercentHUD:(((CGFloat)uploadProgress.completedUnitCount)/((CGFloat)uploadProgress.totalUnitCount))];\n"];
                            [result appendFormat:@"\t\t\t});\n"];
                            [result appendFormat:@"\t\t}\n"];
                        }
                        
                        [result appendFormat:@"\t} success:^(NSURLSessionDataTask *task, id result) {\n"];
                    }
                    else if ([requestType isEqualToString:@"patch"] || [requestType isEqualToString:@"ipatch"]) {
                        [result appendFormat:@"\tNSURLSessionDataTask *op = [[PHRequest sharedClient:@\"%@\"] PATCH:baseUrl parameters:parameters success:^(NSURLSessionDataTask *task, id result) {\n\n", interfacename];
                    }
                    else if ([requestType isEqualToString:@"upload"] || [requestType isEqualToString:@"iupload"]){
                        [result appendFormat:@"\tNSURLSessionDataTask *op = [[PHRequest sharedClient:@\"%@\"] POST:baseUrl parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {\n", interfacename];
                        [result appendFormat:@"\t\tif (formDataBlock) {\n"];
                        [result appendFormat:@"\t\t\tformDataBlock(formData);\n"];
                        [result appendFormat:@"\t\t}\n"];
                        [result appendFormat:@"\t}\n"];
                        [result appendFormat:@"\tprogress:^(NSProgress * uploadProgress) {\n"];
                        
                        if (!hideHud) {
                            [result appendFormat:@"\t\tif (showHUD) {\n"];
                            [result appendFormat:@"\t\t\tdispatch_async(dispatch_get_main_queue(), ^{\n"];
                            [result appendFormat:@"\t\t\t\t[PHRequest showPercentHUD:(((CGFloat)uploadProgress.completedUnitCount)/((CGFloat)uploadProgress.totalUnitCount))];\n"];
                            [result appendFormat:@"\t\t\t});\n"];
                            [result appendFormat:@"\t\t}\n"];
                        }
                        
                        [result appendFormat:@"\t} success:^(NSURLSessionDataTask *task, id result) {\n"];
                    }
                    else if ([requestType isEqualToString:@"put"] || [requestType isEqualToString:@"iput"]) {
                        [result appendFormat:@"\tNSURLSessionDataTask *op = [[PHRequest sharedClient:@\"%@\"] PUT:baseUrl parameters:parameters success:^(NSURLSessionDataTask *task, id result) {\n", interfacename];
                    }
                    else if ([requestType isEqualToString:@"delete"] || [requestType isEqualToString:@"idelete"]) {
                        [result appendFormat:@"\tNSURLSessionDataTask *op = [[PHRequest sharedClient:@\"%@\"] DELETE:baseUrl parameters:parameters success:^(NSURLSessionDataTask *task, id result) {\n", interfacename];
                    }
                    
                    if (!hideHud) {
                        [result appendFormat:@"\t\tif (showHUD) {\n"];
                        [result appendFormat:@"\t\t\tdispatch_async(dispatch_get_main_queue(), ^{\n"];
                        [result appendFormat:@"\t\t\t\t[PHRequest hideRequestHUD];\n"];
                        [result appendFormat:@"\t\t\t});\n"];
                        [result appendFormat:@"\t\t}\n"];
                    }
                    
                    if ([configDictionary[@"response"] isEqualToString:@"xml"]) {
                        [result appendString:@"\t\tresult = [[XMLDictionaryParser sharedInstance] dictionaryWithParser:result];\n"];
                    }
                    else if ([configDictionary[@"response"] isEqualToString:@"json"]){
                    }
                    
                    [result appendString:@"\t\tcallback(task, result);\n"];
                    
                    [result appendString:@"\t} failure:^(NSURLSessionDataTask *task, NSError *error) {\n"];
                    [result appendFormat:@"\t\tYLT_LogError(@\"%%@ %%@ %%@\", baseUrl, extraData, task);\n"];
                    
                    [result appendFormat:@"\t\t([PHRequest responseTitle:@\"%@\" error:error baseUrl:baseUrl parameters:requestParams extraData:extraData]);\n", [[contents firstObject] stringByReplacingOccurrencesOfString:@"/" withString:@""]];
                    
                    if (!hideHud) {
                        [result appendFormat:@"\t\tif (showHUD) {\n"];
                        [result appendFormat:@"\t\t\tdispatch_async(dispatch_get_main_queue(), ^{\n"];
                        [result appendFormat:@"\t\t\t\t[PHRequest errorRequestHUD:task error:error];\n"];
                        [result appendFormat:@"\t\t\t});\n"];
                        [result appendFormat:@"\t\t}\n"];
                    }
                    
                    [result appendFormat:@"\t\tif (failure) {\n"];
                    [result appendFormat:@"\t\t\tfailure(task, error);\n"];
                    [result appendFormat:@"\t\t}\n"];
                    [result appendString:@"\t}];\n"];
                    [result appendString:@"\treturn op;\n"];
                    [result appendString:@"}\n\n"];
                }
                    break;
                case TYPE_REQUEST: {
                    [res3 appendFormat:@"{\n"];
                    [res3 appendFormat:@"\tNSMutableDictionary *requestParams = [[NSMutableDictionary alloc] init];\n"];
                    [res3 appendString:[self allPramaFromContents:contents withType:methodType fileType:fileType hasSave:hasSave]];
                    if ([configDictionary[@"baseurl"] boolValue]) {
                        [res3 appendFormat:@"\tNSURLSessionDataTask *task = [self %@RequestUrl:(NSString *)baseurl showHUD:(BOOL)showHUD", [interfacename stringByReplacingOccurrencesOfString:@"/" withString:@""]];
                    } else {
                        [res3 appendFormat:@"\tNSURLSessionDataTask *task = [self %@RequestShowHUD:showHUD", [interfacename stringByReplacingOccurrencesOfString:@"/" withString:@""]];
                    }
                    //判断是否是上传接口  上传接口需要提取出来单独处理
                    if ([requestType isEqualToString:@"upload"] || [requestType isEqualToString:@"iupload"]) {
                        [res3 appendFormat:@" formDataBlock:(void(^)(id<AFMultipartFormData> formData))formDataBlock"];
                    }
                    [res3 appendFormat:@" iparams:(NSDictionary *)requestParams success:success failure:failure];\n"];
                    [res3 appendFormat:@"\treturn task;\n"];
                    [res3 appendFormat:@"}\n\n"];
                    [result appendString:res3];
                }
                    break;
                    
                default:
                    break;
            }
        }
        default:
            break;
    }
    
    
    
    return result;
}

/**
 * @brief  request请求的所有参数
 * @prama  contents:参数列表
 * @prama  methodType:方法类型
 * @prama  fileType:[H_FILE:h文件  M_FILE: m文件]
 */
+ (NSString *)allPramaFromContents:(NSArray *)contents withType:(MethodType)methodType fileType:(FileType)fileType hasSave:hasSave
{
    NSMutableString *result = [[NSMutableString alloc] init];
    for (int i = 0; i < contents.count; i++) {
        NSString *lineString = [contents objectAtIndex:i];
        NSString *regexLine = @"^(?:[\\s]*)(class|required|optional|repeated|upload)(?:[\\s]*)(\\S+)(?:[\\s]*)(\\S+)(?:[\\s]*)=(?:[\\s]*)(\\S+)(?:[\\s]*);([\\S\\s]*)$";
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
        NSString *fieldname = [fields objectAtIndex:3];
        NSMutableString *keyname = [fields objectAtIndex:3];
        NSString *regex = @"^(?:[\\s]*)(?:[\\s]*)(\\S+)(?:[\\s]*)((?:\\()\\S+(?:\\)))";
        NSArray *nameList = [[fieldname arrayOfCaptureComponentsMatchedByRegex:regex] firstObject];
        if (nameList.count >= 3) {
            fieldname = [nameList objectAtIndex:1];
            keyname = [[NSMutableString alloc] initWithString:[nameList objectAtIndex:2]];
            [keyname deleteCharactersInRange:[keyname rangeOfString:@"("]];
            [keyname deleteCharactersInRange:[keyname rangeOfString:@")"]];
        }
        NSString *defaultValue = [fields objectAtIndex:4];
        NSString *notes = [fields objectAtIndex:5];
        notes = [notes stringByReplacingOccurrencesOfString:@"/" withString:@""];
        
        //h m 文件都需要导入的文件
        switch (methodType) {
            case TYPE_NOTES:
            {
                [result appendFormat:@" * @prama %@:%@\n", fieldname, notes];
            }
                break;
                
            case TYPE_METHOD:
            case TYPE_RACSIGNAL:
            {
                if ([style isEqualToString:@"repeated"]) {
                    if ([[Utils modelTypeConvertDictionary].allKeys containsObject:[type lowercaseString]]) {
                        [result appendFormat:@" %@:(NSArray<%@> *)%@", fieldname, [Utils modelTypeConvertDictionary][[type lowercaseString]], fieldname];
                    } else {
                        [result appendFormat:@" %@:(NSArray<%@ *> *)%@", fieldname, type, fieldname];
                    }
                }
                else if ([style isEqualToString:@"class"]) {
                    [result appendFormat:@" %@:(%@ *)%@", fieldname, type, fieldname];
                }
                else if ([[Utils modelTypeConvertDictionary].allKeys containsObject:[type lowercaseString]]){
                    if ([[Utils modelTypeConvertDictionary][[type lowercaseString]] rangeOfString:@"*"].location == NSNotFound) {
                        [result appendFormat:@" %@:(%@)%@", fieldname, [Utils modelTypeConvertDictionary][[type lowercaseString]], fieldname];
                    } else {
                        [result appendFormat:@" %@:(%@)%@", fieldname, [Utils modelTypeConvertDictionary][[type lowercaseString]], fieldname];
                    }
                }
                else {
                    //首先 区分开枚举类型与数据类型   所有的枚举类型  使用整型替代
                    [result appendFormat:@" %@:(%@ *)%@", fieldname, type, fieldname];
                }
            }
                break;
                
            case TYPE_REQUEST:
            {
            }
                break;
                
            default:
                break;
        }
        
        switch (fileType) {
            case H_FILE:
            {
                
            }
                break;
            case M_FILE:
            {
                switch (methodType) {
                    case TYPE_REQUEST:
                    {
                        if ([style isEqualToString:@"repeated"]) {
                            [result appendFormat:@"\trequestParams[@\"%@\"] = %@;\n", keyname, fieldname];
                        }
                        else if ([style isEqualToString:@"class"]) {
                            [result appendFormat:@"\trequestParams[@\"%@\"] = %@;\n", keyname, fieldname];
                        }
                        else {
                            if (IS_BASE_TYPE(type) || [enumList containsObject:type]) {
                                if ([[type lowercaseString] isEqualToString:@"int"] || [[type lowercaseString] isEqualToString:@"short"] || [enumList containsObject:type]) {
                                    [result appendFormat:@"\trequestParams[@\"%@\"] = [NSNumber numberWithInteger:%@];\n", keyname, fieldname];
                                }
                                else {
                                    [result appendFormat:@"\trequestParams[@\"%@\"] = [NSNumber numberWith%@:%@];\n", keyname, [NSString stringWithFormat:@"%@%@", [[type substringToIndex:1] uppercaseString], [type substringFromIndex:1]], fieldname];
                                }
                            }
                            else if ([type isEqualToString:@"string"] || [NSClassFromString(type) isKindOfClass:[NSObject class]]){
                                [result appendFormat:@"\trequestParams[@\"%@\"] = %@;\n", keyname, fieldname];
                            }
                            else {
#warning 非简单数据类型的处理 包含枚举类型和model类型
                                [result appendFormat:@"\trequestParams[@\"%@\"] = %@;\n", keyname, fieldname];
                            }
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
        
    }
    
    
    return result;
}

@end




















