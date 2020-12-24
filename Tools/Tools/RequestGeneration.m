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
+ (void)generationSourcePath:(NSString *)sourcepath outputPath:(NSString *)outputPath config:(NSDictionary *)config {
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
    NSMutableString *racH = [[NSMutableString alloc] init];
    NSMutableString *racM = [[NSMutableString alloc] init];
    NSMutableString *proH = [[NSMutableString alloc] init];
    NSMutableString *proM = [[NSMutableString alloc] init];
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    NSString *hFilePath = [outputPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@Request.h", configDictionary[@"filename"]]];
    NSString *mFilePath = [outputPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@Request.m", configDictionary[@"filename"]]];
    NSString *rachFilePath = [outputPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@Request+RAC.h", configDictionary[@"filename"]]];
    NSString *racmFilePath = [outputPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@Request+RAC.m", configDictionary[@"filename"]]];
    NSString *prohFilePath = [outputPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@Request+PRO.h", configDictionary[@"filename"]]];
    NSString *promFilePath = [outputPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@Request+PRO.m", configDictionary[@"filename"]]];
    [fileManager createFileAtPath:hFilePath contents:nil attributes:nil];
    [fileManager createFileAtPath:mFilePath contents:nil attributes:nil];
    [fileManager createFileAtPath:rachFilePath contents:nil attributes:nil];
    [fileManager createFileAtPath:racmFilePath contents:nil attributes:nil];
    [fileManager createFileAtPath:prohFilePath contents:nil attributes:nil];
    [fileManager createFileAtPath:promFilePath contents:nil attributes:nil];
    
    //版权信息的导入
    [h appendString:[Utils createCopyrightByFilename:[NSString stringWithFormat:@"%@Request.h", configDictionary[@"filename"]] config:config]];
    [m appendString:[Utils createCopyrightByFilename:[NSString stringWithFormat:@"%@Request.m", configDictionary[@"filename"]] config:config]];
    //版权信息的导入
    [racH appendString:[Utils createCopyrightByFilename:[NSString stringWithFormat:@"%@Request+RAC.h", configDictionary[@"filename"]] config:config]];
    [racM appendString:[Utils createCopyrightByFilename:[NSString stringWithFormat:@"%@Request+RAC.m", configDictionary[@"filename"]] config:config]];
    //版权信息的导入
    [proH appendString:[Utils createCopyrightByFilename:[NSString stringWithFormat:@"%@Request+PRO.h", configDictionary[@"filename"]] config:config]];
    [proM appendString:[Utils createCopyrightByFilename:[NSString stringWithFormat:@"%@Request+PRO.m", configDictionary[@"filename"]] config:config]];
    
    //头文件的导入
    [h appendString:[self introductionPackages:H_FILE rtype:REQUEST_NORMAL]];
    [m appendString:[self introductionPackages:M_FILE rtype:REQUEST_NORMAL]];
    //头文件的导入
    [racH appendString:[self introductionPackages:H_FILE rtype:REQUEST_RAC]];
    [racM appendString:[self introductionPackages:M_FILE rtype:REQUEST_RAC]];
    //头文件的导入
    [proH appendString:[self introductionPackages:H_FILE rtype:REQUEST_PRO]];
    [proM appendString:[self introductionPackages:M_FILE rtype:REQUEST_PRO]];
    
    
    enumList = [Utils enumList:sourceString];
    
    //导入基本的 实现
    [h appendString:[self classOfRequest:H_FILE rtype:REQUEST_NORMAL]];
    [m appendString:[self classOfRequest:M_FILE rtype:REQUEST_NORMAL]];
    //导入基本的 实现
    [racH appendString:[self classOfRequest:H_FILE rtype:REQUEST_RAC]];
    [racM appendString:[self classOfRequest:M_FILE rtype:REQUEST_RAC]];
    //导入基本的 实现
    [proH appendString:[self classOfRequest:H_FILE rtype:REQUEST_PRO]];
    [proM appendString:[self classOfRequest:M_FILE rtype:REQUEST_PRO]];
    
    //匹配出所有的Request类型
    [h appendString:[self messageFromSourceString:sourceString fileType:H_FILE rtype:REQUEST_NORMAL]];
    [m appendString:[self messageFromSourceString:sourceString fileType:M_FILE rtype:REQUEST_NORMAL]];
    //匹配出所有的Request类型
    [racH appendString:[self messageFromSourceString:sourceString fileType:H_FILE rtype:REQUEST_RAC]];
    [racM appendString:[self messageFromSourceString:sourceString fileType:M_FILE rtype:REQUEST_RAC]];
    //匹配出所有的Request类型
    [proH appendString:[self messageFromSourceString:sourceString fileType:H_FILE rtype:REQUEST_PRO]];
    [proM appendString:[self messageFromSourceString:sourceString fileType:M_FILE rtype:REQUEST_PRO]];
    
    
    [h appendFormat:@"\n#pragma clang diagnostic pop\n\n@end\n\n\n"];
    [m appendFormat:@"#pragma clang diagnostic pop\n\n@end\n\n\n"];
    [racH appendFormat:@"\n#pragma clang diagnostic pop\n\n@end\n\n\n"];
    [racM appendFormat:@"#pragma clang diagnostic pop\n\n@end\n\n\n"];
    [proH appendFormat:@"\n#pragma clang diagnostic pop\n\n@end\n\n\n"];
    [proM appendFormat:@"#pragma clang diagnostic pop\n\n@end\n\n\n"];
    
    [h writeToFile:hFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [m writeToFile:mFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [racH writeToFile:rachFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [racM writeToFile:racmFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [proH writeToFile:prohFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [proM writeToFile:promFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

/**
 * @brief  导入头文件
 * @prama  fileType:[H_FILE:h文件  M_FILE: m文件]
 **/
+ (NSString *)introductionPackages:(FileType)fileType rtype:(RequestType)rtype {
    NSMutableString *result = [[NSMutableString alloc] init];
    switch (fileType) {
        case H_FILE:
        {
            [result appendFormat:@"#import <YLT_BaseLib/YLT_BaseLib.h>\n"];
            [result appendFormat:@"#import <ReactiveObjC/ReactiveObjC.h>\n"];
            [result appendFormat:@"#import <AFNetworking/AFNetworking.h>\n"];
            [result appendFormat:@"#import <FBLPromises/FBLPromises.h>\n"];
            [result appendFormat:@"#import \"PHRequest.h\"\n"];
            [result appendFormat:@"#import \"%@Model.h\"\n", configDictionary[@"filename"]];
        }
            break;
        case M_FILE:
        {
            [result appendFormat:@"#import \"%@Request.h\"\n", configDictionary[@"filename"]];
            if ([configDictionary[@"response"] isEqualToString:@"xml"]) {
                [result appendString:@"#import <XMLDictionary/XMLDictionary.h>\n"];
            }
        }
            break;
            
        default:
            break;
    }
    switch (rtype) {
        case REQUEST_NORMAL: {
        }
            break;
        case REQUEST_RAC: {
            if (fileType == H_FILE) {
                [result appendFormat:@"#import \"%@Request.h\"\n", configDictionary[@"filename"]];
            }
        }
            break;
        case REQUEST_PRO: {
            if (fileType == H_FILE) {
                [result appendFormat:@"#import \"%@Request.h\"\n", configDictionary[@"filename"]];
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
+ (NSString *)classOfRequest:(FileType)fileType rtype:(RequestType)rtype {
    NSMutableString *result = [[NSMutableString alloc] init];
    switch (rtype) {
        case REQUEST_NORMAL: {
            if (fileType == H_FILE) {
                [result appendFormat:@"\n\n@interface %@Request : NSObject {\n", configDictionary[@"filename"]];
                [result appendFormat:@"}\n"];
            } else {
                [result appendFormat:@"\n@implementation %@Request\n", configDictionary[@"filename"]];
            }
        }
            break;
        case REQUEST_RAC: {
            if (fileType == H_FILE) {
                [result appendFormat:@"\n\n@interface %@Request (RAC)\n", configDictionary[@"filename"]];
            } else {
                [result appendFormat:@"\n@implementation %@Request (RAC) \n", configDictionary[@"filename"]];
            }
        }
            break;
        case REQUEST_PRO: {
            if (fileType == H_FILE) {
                [result appendFormat:@"\n\n@interface %@Request (PRO)\n", configDictionary[@"filename"]];
            } else {
                [result appendFormat:@"\n@implementation %@Request (PRO) \n", configDictionary[@"filename"]];
            }
        }
            break;
        default:
            break;
    }
    switch (fileType) {
        case H_FILE:{
            [result appendFormat:@"#pragma clang diagnostic push\n"];
            [result appendFormat:@"#pragma clang diagnostic ignored \"-Wdocumentation\"\n"];
        }
            break;
        case M_FILE: {
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
+ (NSString *)messageFromSourceString:(NSString *)sourceString fileType:(FileType)fileType rtype:(RequestType)rtype {
    NSMutableString *result = [[NSMutableString alloc] init];
    NSString *regexRequest = @"request (get|post|upload|put|delete|iget|ipost|iupload|iput|idelete|patch|ipatch)(?:\\s+)(\\S+)(?:\\s+)(\\S+)(?:\\s*)\\{([\\s\\S]*?)\\}(\\d)?(?:\\s*?)";
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
            NSInteger cacheDay = [[items objectAtIndex:6] integerValue];//是否需要保存,保存多少天
            if (cacheDay == 0 && [[items objectAtIndex:6] isEqualToString:@"0"]) {
                cacheDay = -1;
            }

            [result appendString:[self generationFileType:fileType baseURL:@"" requestType:requestType methodName:interface returnType:returnType contents:contents methodType:TYPE_NOTES cacheDay:cacheDay rtype:rtype]];
            [result appendString:[self generationFileType:fileType baseURL:@"" requestType:requestType methodName:interface returnType:returnType contents:contents methodType:TYPE_METHOD cacheDay:cacheDay rtype:rtype]];
            [result appendString:[self generationFileType:fileType baseURL:@"" requestType:requestType methodName:interface returnType:returnType contents:contents methodType:TYPE_REQUEST cacheDay:cacheDay rtype:rtype]];
            [result appendString:[self generationFileType:fileType baseURL:@"" requestType:requestType methodName:interface returnType:returnType contents:contents methodType:TYPE_NORMALREQUEST cacheDay:cacheDay rtype:rtype]];
        }
    }
    
    /// 匹配带路径的网络请求
    regexRequest = @"request (get|post|upload|put|delete|iget|ipost|iupload|iput|idelete|patch|ipatch)(?:\\s+)(\\S+)(?:\\s+)(\\S+)(?:\\s+)(\\S+)(?:\\s*)\\{([\\s\\S]*?)\\}(\\d)?(?:\\s*?)";
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
            NSInteger cacheDay = [[items objectAtIndex:6] integerValue];//是否需要保存,保存多少天
            if (cacheDay == 0 && [[items objectAtIndex:6] isEqualToString:@"0"]) {
                cacheDay = -1;
            }

            [result appendString:[self generationFileType:fileType baseURL:baseUrl requestType:requestType methodName:interface returnType:returnType contents:contents methodType:TYPE_NOTES cacheDay:cacheDay rtype:rtype]];
            [result appendString:[self generationFileType:fileType baseURL:baseUrl requestType:requestType methodName:interface returnType:returnType contents:contents methodType:TYPE_METHOD cacheDay:cacheDay rtype:rtype]];
            [result appendString:[self generationFileType:fileType baseURL:baseUrl requestType:requestType methodName:interface returnType:returnType contents:contents methodType:TYPE_REQUEST cacheDay:cacheDay rtype:rtype]];
            [result appendString:[self generationFileType:fileType baseURL:baseUrl requestType:requestType methodName:interface returnType:returnType contents:contents methodType:TYPE_NORMALREQUEST cacheDay:cacheDay rtype:rtype]];
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
+ (NSString *)generationFileType:(FileType)fileType baseURL:(NSString *)baseURL requestType:(NSString *)requestType methodName:(NSString *)interface returnType:(NSString *)returnType contents:(NSArray *)contents methodType:(MethodType)methodType cacheDay:(NSInteger)cacheDay rtype:(RequestType)rtype {
    NSMutableString *result = [[NSMutableString alloc] init];
    
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
    BOOL returnIsValueType = [Utils.modelTypeConvertDictionary.allKeys containsObject:modelname];
    if (returnIsValueType) {
        modelname = Utils.modelTypeConvertDictionary[modelname];
        modelname = [modelname stringByReplacingOccurrencesOfString:@" *" withString:@""];
    }
    if (returnTypeList.count >= 3) {
        modelname = returnTypeList[1];
        returnIsValueType = [Utils.modelTypeConvertDictionary.allKeys containsObject:modelname];
        if (returnIsValueType) {
            modelname = Utils.modelTypeConvertDictionary[modelname];
            modelname = [modelname stringByReplacingOccurrencesOfString:@" *" withString:@""];
        }
        NSMutableString *returnTypeName = [[NSMutableString alloc] initWithString:[returnTypeList objectAtIndex:2]];
        [returnTypeName deleteCharactersInRange:[returnTypeName rangeOfString:@"("]];
        [returnTypeName deleteCharactersInRange:[returnTypeName rangeOfString:@")"]];
        if ([returnTypeName isEqualToString:@"list"] || [returnTypeName isEqualToString:@"array"]) {
            returnIsList = YES;
            returnType = [NSString stringWithFormat:@"NSMutableArray<%@ *>", modelname];
        }
    }
    BOOL isBaseType = NO;
    if ([[Utils modelTypeConvertDictionary].allKeys containsObject:[returnType lowercaseString]]) {
        returnType = [Utils modelTypeConvertDictionary][[returnType lowercaseString]];
        isBaseType = YES;
        if ([returnType hasSuffix:@" *"]) {
            returnType = [returnType stringByReplacingOccurrencesOfString:@" *" withString:@""];
        }
    }
    
    returnType = ([returnType isEqualToString:@"BaseCollection"]||isBaseType)?@"NSDictionary":returnType;
    NSString *uploadKey = @"";
    // h m 文件中均需导入的
    switch (methodType) {
        case TYPE_NOTES:
        {
            [result appendFormat:@"/**\n"];
            [result appendFormat:@" * @brief %@\n", [[contents firstObject] stringByReplacingOccurrencesOfString:@"/" withString:@""]];
            [result appendString:[self allPramaFromContents:contents withType:methodType fileType:fileType cacheDay:cacheDay rtype:rtype]];
            [result appendFormat:@" **/\n"];
        }
            break;
        
        case TYPE_NORMALREQUEST: {
            if (rtype == REQUEST_NORMAL) {
                if ([configDictionary[@"baseurl"] boolValue]) {
                    [result appendFormat:@"+(NSURLSessionDataTask *)%@URL:(NSString *)baseurl showHUD:(BOOL)showHUD", [interfacename stringByReplacingOccurrencesOfString:@"/" withString:@""]];
                } else {
                    [result appendFormat:@"+(NSURLSessionDataTask *)%@RequestShowHUD:(BOOL)showHUD", [interfacename stringByReplacingOccurrencesOfString:@"/" withString:@""]];
                }
            } else if (rtype == REQUEST_RAC) {
                if ([configDictionary[@"baseurl"] boolValue]) {
                    [result appendFormat:@"+(RACSignal<NSDictionary *> *)rac%@URL:(NSString *)baseurl showHUD:(BOOL)showHUD", [interfacename stringByReplacingOccurrencesOfString:@"/" withString:@""]];
                } else {
                    [result appendFormat:@"+(RACSignal<NSDictionary *> *)rac%@RequestShowHUD:(BOOL)showHUD", [interfacename stringByReplacingOccurrencesOfString:@"/" withString:@""]];
                }
            } else if (rtype == REQUEST_PRO) {
                if ([configDictionary[@"baseurl"] boolValue]) {
                    [result appendFormat:@"+(FBLPromise<NSDictionary *> *)promise%@URL:(NSString *)baseurl showHUD:(BOOL)showHUD", [interfacename stringByReplacingOccurrencesOfString:@"/" withString:@""]];
                } else {
                    [result appendFormat:@"+(FBLPromise<NSDictionary *> *)promise%@RequestShowHUD:(BOOL)showHUD", [interfacename stringByReplacingOccurrencesOfString:@"/" withString:@""]];
                }
            }
            //判断是否是上传接口  上传接口需要提取出来单独处理
            if ([requestType isEqualToString:@"upload"] || [requestType isEqualToString:@"iupload"]) {
                [result appendFormat:@" formDataBlock:(void(^)(id<AFMultipartFormData> formData))formDataBlock"];
            }
            [result appendFormat:@" iparams:(NSDictionary *)iparams"];
            if (rtype == REQUEST_NORMAL) {
                [result appendFormat:@" success:(void (^)(NSURLSessionDataTask *task, BaseCollection *result, %@ *data, NSDictionary *sourceData))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;", returnType];
            } else {
                [result appendFormat:@" returnValue:(%@ * __strong *)returnValue;", returnType];
            }
        }
            break;
        case TYPE_METHOD:
        {
            if (rtype == REQUEST_NORMAL) {
                if ([configDictionary[@"baseurl"] boolValue]) {
                    [result appendFormat:@"+(NSURLSessionDataTask *)%@URL:(NSString *)baseurl showHUD:(BOOL)showHUD", [interfacename stringByReplacingOccurrencesOfString:@"/" withString:@""]];
                } else {
                    [result appendFormat:@"+(NSURLSessionDataTask *)%@RequestShowHUD:(BOOL)showHUD", [interfacename stringByReplacingOccurrencesOfString:@"/" withString:@""]];
                }
            } else if (rtype == REQUEST_RAC) {
                if ([configDictionary[@"baseurl"] boolValue]) {
                    [result appendFormat:@"+(RACSignal<NSDictionary *> *)rac%@URL:(NSString *)baseurl showHUD:(BOOL)showHUD", [interfacename stringByReplacingOccurrencesOfString:@"/" withString:@""]];
                } else {
                    [result appendFormat:@"+(RACSignal<NSDictionary *> *)rac%@RequestShowHUD:(BOOL)showHUD", [interfacename stringByReplacingOccurrencesOfString:@"/" withString:@""]];
                }
            } else if (rtype == REQUEST_PRO) {
                if ([configDictionary[@"baseurl"] boolValue]) {
                    [result appendFormat:@"+(FBLPromise<NSDictionary *> *)promise%@URL:(NSString *)baseurl showHUD:(BOOL)showHUD", [interfacename stringByReplacingOccurrencesOfString:@"/" withString:@""]];
                } else {
                    [result appendFormat:@"+(FBLPromise<NSDictionary *> *)promise%@RequestShowHUD:(BOOL)showHUD", [interfacename stringByReplacingOccurrencesOfString:@"/" withString:@""]];
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
                }
                [result appendFormat:@" formDataBlock:(void(^)(id<AFMultipartFormData> formData))formDataBlock"];
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
            [result appendString:[self allPramaFromContents:contents withType:methodType fileType:fileType cacheDay:cacheDay rtype:rtype]];
            
            if (rtype == REQUEST_NORMAL) {
                [result appendFormat:@" success:(void (^)(NSURLSessionDataTask *task, BaseCollection *result, %@ *data, NSDictionary *sourceData))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure; ", returnType];
            } else {
                [result appendFormat:@" returnValue:(%@ * __strong *)returnValue;", returnType];
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
                case TYPE_NORMALREQUEST:
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
                case TYPE_NORMALREQUEST: {
                    if (rtype == REQUEST_NORMAL) {
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
                        [result appendFormat:@"\tNSMutableDictionary *requestParams = [[NSMutableDictionary alloc] initWithDictionary:([PHRequest baseParams:@{@\"requestAction\":@\"%@\"} extraData:extraData])];\n", interfacename];
                        [result appendFormat:@"\t[requestParams addEntriesFromDictionary:iparams];\n"];
                        [result appendFormat:@"\tNSString *baseUrl = [PHRequest baseURL:[NSString stringWithFormat:@\"%%@/%@/%%@\", BASE_URL, %@] baseParams:requestParams extraData:extraData];\n", baseURL, [configDictionary[@"baseurl"] boolValue]?@"baseurl":@"@\"\""];
                        
                        [result appendFormat:@"\tNSTimeInterval startTime = [[NSDate date] timeIntervalSince1970];\n"];
                        [result appendFormat:@"\tBOOL hasRequest = NO;\n"];
                        [result appendFormat:@"\tNSMutableDictionary *parameters = ([PHRequest baseUrl:baseUrl showHUD:showHUD uploadParams:requestParams currentTime:startTime extraData:extraData hasRequest:&hasRequest success:success failure:failure]);\n"];
                        [result appendFormat:@"\tif (hasRequest) {\n"];
                        [result appendFormat:@"\t\t return nil;\n"];
                        [result appendFormat:@"\t}\n"];
                        [result appendFormat:@"//\tYLT_Log(@\"%%@ %%@\", baseUrl, extraData);\n"];
                        
                        NSString *pathString = [self allPramaFromContents:contents withType:TYPE_PATH fileType:fileType cacheDay:cacheDay rtype:rtype];
                        if (pathString.length > 1) {
                            [result appendString:pathString];
                        }
                        [result appendFormat:@"\tNSString *uploadUrl = baseUrl;\n"];
                        NSString *queryString = [self allPramaFromContents:contents withType:TYPE_QUERY fileType:fileType cacheDay:cacheDay rtype:rtype];
                        if (queryString.length > 1) {
                            [result appendFormat:@"\tNSMutableDictionary *queryParams = [[NSMutableDictionary alloc] init];\n"];
                            [result appendString:queryString];
                            [result appendFormat:@"\tuploadUrl = [NSString stringWithFormat:@\"%%@?%%@\", baseUrl, AFQueryStringFromParameters(queryParams)];\n"];
                        }
                        
                        [result appendString:@"\tvoid(^callback)(NSURLSessionDataTask *task, id result) = ^(NSURLSessionDataTask *task, id result) {\n"];
                        [result appendFormat:@"\t\tNSInteger duration = ([[NSDate date] timeIntervalSince1970]-startTime)*1000;\n"];
                        [result appendFormat:@"\t\tif ([result isKindOfClass:NSData.class]) {\n"];
                        [result appendFormat:@"\t\t\tresult = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];\n"];
                        [result appendFormat:@"\t\t}\n"];
                        [result appendFormat:@"\t\tif ([result isKindOfClass:NSString.class]) {\n"];
                        [result appendFormat:@"\t\t\tresult = [result mj_keyValues];\n"];
                        [result appendFormat:@"\t\t}\n"];
                        if (cacheDay != 0) {
                            [result appendString:@"\t\tif (task) {//说明是从网络请求返回的数据\n"];
                            if (cacheDay != -1) {
                                [result appendFormat:@"\t\t\t[NSUserDefaults.standardUserDefaults setFloat:NSDate.date.timeIntervalSince1970 forKey:[NSString stringWithFormat:@\"Request%%@Time\", baseUrl]];\n"];
                            }
                            [result appendString:@"\t\t\t[NSUserDefaults.standardUserDefaults setObject:result forKey:[NSString stringWithFormat:@\"Request%@\", baseUrl]];\n"];
                            [result appendString:@"\t\t\t[NSUserDefaults.standardUserDefaults synchronize];\n"];
                            [result appendString:@"\t\t} else {\n"];
                            [result appendFormat:@"\t\t\tduration = 0;\n"];
                            [result appendFormat:@"\t\t}\n"];
                        }
                        
                        [result appendFormat:@"\t\tid decryptResult = ([PHRequest responseTitle:@\"%@\" task:task result:result baseUrl:uploadUrl parameters:requestParams duration:duration extraData:extraData]);\n", [[contents firstObject] stringByReplacingOccurrencesOfString:@"/" withString:@""]];
                        [result appendFormat:@"\t\tif (decryptResult == nil) {\n"];
                        [result appendFormat:@"\t\t\treturn ;\n"];
                        [result appendFormat:@"\t\t}\n"];
                        [result appendString:@"//\t\tYLT_Log(@\"%@ %@ %@\", baseUrl, extraData, decryptResult);\n"];
                        
                        [result appendFormat:@"\t\tBaseCollection *res = [BaseCollection mj_objectWithKeyValues:decryptResult];\n"];
                        [result appendString:@"\t\tid data = decryptResult[@\"data\"];\n"];
                        
                        [result appendFormat:@"\t\tif (success) {\n"];
                        if (![returnType isEqualToString:@"BaseCollection"] && ![returnType isEqualToString:@"NSDictionary"]) {
                            if (returnIsValueType) {
                                [result appendFormat:@"\t\t\tif ([data isKindOfClass:[NSObject class]]) {\n"];
                                [result appendFormat:@"\t\t\t\tNSMutableArray<%@ *> *info = @[data].mutableCopy;\n", modelname];
                                [result appendString:@"\t\t\t\tsuccess(task, res, info, result);\n"];
                                [result appendFormat:@"\t\t\t\t[PHRequest responseBaseUrl:baseUrl uploadParams:parameters sessionDataTask:task baseCollection:res data:info sourceData:decryptResult error:nil];\n"];
                            } else {
                                if (returnIsList) {//返回的数据类型是数组
                                    [result appendFormat:@"\t\t\tif ([data isKindOfClass:[NSDictionary class]]) {\n"];
                                    [result appendFormat:@"\t\t\t\tNSMutableArray<%@ *> *info = @[[%@ mj_objectWithKeyValues:data]].mutableCopy;\n", modelname, modelname];
                                    [result appendString:@"\t\t\t\tsuccess(task, res, info, result);\n"];
                                    [result appendFormat:@"\t\t\t\t[PHRequest responseBaseUrl:baseUrl uploadParams:parameters sessionDataTask:task baseCollection:res data:info sourceData:decryptResult error:nil];\n"];
                                    [result appendString:@"\t\t\t} else if ([data isKindOfClass:[NSArray class]]) {\n"];
                                    [result appendFormat:@"\t\t\t\tNSMutableArray *resultList = [%@ mj_objectArrayWithKeyValuesArray:data];\n", modelname];
                                    [result appendFormat:@"\t\t\t\tsuccess(task, res, resultList, decryptResult);\n"];
                                    [result appendFormat:@"\t\t\t\t[PHRequest responseBaseUrl:baseUrl uploadParams:parameters sessionDataTask:task baseCollection:res data:resultList sourceData:decryptResult error:nil];\n"];
                                } else {
                                    [result appendFormat:@"\t\t\tif ([data isKindOfClass:[NSDictionary class]]) {\n"];
                                    [result appendFormat:@"\t\t\t\t%@ *info = [%@ mj_objectWithKeyValues:data];\n", returnType, returnType];
                                    [result appendString:@"\t\t\t\tsuccess(task, res, info, decryptResult);\n"];
                                    [result appendFormat:@"\t\t\t\t[PHRequest responseBaseUrl:baseUrl uploadParams:parameters sessionDataTask:task baseCollection:res data:info sourceData:decryptResult error:nil];\n"];
                                }
                            }
                            
                            [result appendFormat:@"\t\t\t} else {\n"];
                            [result appendString:@"\t\t\t\tsuccess(task, res, data, decryptResult);\n"];
                            [result appendFormat:@"\t\t\t\t[PHRequest responseBaseUrl:baseUrl uploadParams:parameters sessionDataTask:task baseCollection:res data:data sourceData:decryptResult error:nil];\n"];
                            [result appendFormat:@"\t\t\t}\n"];
                        } else {
                            [result appendString:@"\t\t\tsuccess(task, res, data, decryptResult);\n"];
                            [result appendFormat:@"\t\t\t\t[PHRequest responseBaseUrl:baseUrl uploadParams:parameters sessionDataTask:task baseCollection:res data:data sourceData:decryptResult error:nil];\n"];
                        }
                        [result appendFormat:@"\t\t}\n"];
                        [result appendString:@"\t};\n"];
                        if (cacheDay != 0) {
                            [result appendString:@"\tif ([NSUserDefaults.standardUserDefaults.dictionaryRepresentation.allKeys containsObject:[NSString stringWithFormat:@\"Request%@\", baseUrl]]) {\n"];
                            [result appendString:@"\t\tid result = [NSUserDefaults.standardUserDefaults objectForKey:[NSString stringWithFormat:@\"Request%@\", baseUrl]];\n"];
                            [result appendString:@"\t\tcallback(nil, result);\n"];
                            if (cacheDay != -1) {
                                [result appendString:@"\t\t//判断是否缓存是否过期，如果没有过期，继续使用本地缓存\n"];
                                [result appendFormat:@"\t\tNSTimeInterval cacheTime = [NSUserDefaults.standardUserDefaults floatForKey:[NSString stringWithFormat:@\"Request%%@Time\", baseUrl]];\n"];
                                [result appendFormat:@"\t\tif ([[NSDate date] timeIntervalSince1970]-cacheTime<%zd*24.*3600.) {\n", cacheDay];
                                [result appendFormat:@"\t\t\treturn nil;\n"];
                                [result appendFormat:@"\t\t}\n"];
                            }
                            [result appendString:@"\t}\n"];
                        }
                        
                        if ([requestType isEqualToString:@"get"] || [requestType isEqualToString:@"iget"]) {
                            [result appendFormat:@"\tNSURLSessionDataTask *op = [[PHRequest sharedClient:@\"%@\"] GET:uploadUrl parameters:parameters headers:nil progress:^(NSProgress * uploadProgress) {\n", interfacename];
                            
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
                            [result appendFormat:@"\tNSURLSessionDataTask *op = [[PHRequest sharedClient:@\"%@\"] POST:uploadUrl parameters:parameters headers:nil progress:^(NSProgress * uploadProgress) {\n", interfacename];
                            
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
                            [result appendFormat:@"\tNSURLSessionDataTask *op = [[PHRequest sharedClient:@\"%@\"] PATCH:uploadUrl parameters:parameters headers:nil success:^(NSURLSessionDataTask *task, id result) {\n\n", interfacename];
                        }
                        else if ([requestType isEqualToString:@"upload"] || [requestType isEqualToString:@"iupload"]){
                            [result appendFormat:@"\tNSURLSessionDataTask *op = [[PHRequest sharedClient:@\"%@\"] POST:uploadUrl parameters:parameters headers:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {\n", interfacename];
                            [result appendFormat:@"\t\tif (formDataBlock) {\n"];
                            [result appendFormat:@"\t\t\tformDataBlock(formData);\n"];
                            [result appendFormat:@"\t\t} else {\n"];
                            [result appendFormat:@"\t\t\t[parameters enumerateKeysAndObjectsUsingBlock:^(NSString *key, id  _Nonnull obj, BOOL * _Nonnull stop) {\n"];
                            [result appendFormat:@"\t\t\t\t[formData appendPartWithFormData:[[NSString stringWithFormat:@\"%%@\", obj] dataUsingEncoding:NSUTF8StringEncoding] name:key];\n"];
                            [result appendFormat:@"\t\t\t}];\n"];
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
                            [result appendFormat:@"\tNSURLSessionDataTask *op = [[PHRequest sharedClient:@\"%@\"] PUT:uploadUrl parameters:parameters headers:nil success:^(NSURLSessionDataTask *task, id result) {\n", interfacename];
                        }
                        else if ([requestType isEqualToString:@"delete"] || [requestType isEqualToString:@"idelete"]) {
                            [result appendFormat:@"\tNSURLSessionDataTask *op = [[PHRequest sharedClient:@\"%@\"] DELETE:uploadUrl parameters:parameters headers:nil success:^(NSURLSessionDataTask *task, id result) {\n", interfacename];
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
                        [result appendFormat:@"\t\tNSInteger duration = ([[NSDate date] timeIntervalSince1970]-startTime)*1000;\n"];
                        [result appendFormat:@"\t\t([PHRequest responseTitle:@\"%@\" error:error baseUrl:uploadUrl parameters:requestParams duration:duration extraData:extraData]);\n", [[contents firstObject] stringByReplacingOccurrencesOfString:@"/" withString:@""]];
                        
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
                        [result appendFormat:@"\t\t[PHRequest responseBaseUrl:baseUrl uploadParams:parameters sessionDataTask:task baseCollection:nil data:nil sourceData:nil error:error];\n"];
                        [result appendString:@"\t}];\n"];
                        [result appendString:@"\treturn op;\n"];
                        [result appendString:@"}\n\n"];
                    } else if (rtype == REQUEST_RAC) {
                        [result appendFormat:@" {\n"];
                        [result appendFormat:@"\t@weakify(self);\n"];
                        [result appendFormat:@"\tRACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {\n"];
                        [result appendFormat:@"\t\t@strongify(self);\n"];
                        if ([configDictionary[@"baseurl"] boolValue]) {
                            [result appendFormat:@"\t\tNSURLSessionDataTask *task = [self %@URL:(NSString *)baseurl showHUD:(BOOL)showHUD", [interfacename stringByReplacingOccurrencesOfString:@"/" withString:@""]];
                        } else {
                            [result appendFormat:@"\t\tNSURLSessionDataTask *task = [self %@RequestShowHUD:(BOOL)showHUD", [interfacename stringByReplacingOccurrencesOfString:@"/" withString:@""]];
                        }
                        //判断是否是上传接口  上传接口需要提取出来单独处理
                        if ([requestType isEqualToString:@"upload"] || [requestType isEqualToString:@"iupload"]) {
                            [result appendFormat:@" formDataBlock:(void(^)(id<AFMultipartFormData> formData))formDataBlock"];
                        }
                        [result appendFormat:@" iparams:(NSDictionary *)iparams success:^(NSURLSessionDataTask *task, BaseCollection *result, %@ *data, NSDictionary *sourceData) {\n", returnType];
                        [result appendFormat:@"\t\t\tNSMutableDictionary *taskResult = [NSMutableDictionary dictionary];\n"];
                        [result appendFormat:@"\t\t\ttaskResult[@\"result\"] = result;\n"];
                        [result appendFormat:@"\t\t\ttaskResult[@\"data\"] = data;\n"];
                        [result appendFormat:@"\t\t\ttaskResult[@\"sourceData\"] = sourceData;\n"];
                        [result appendFormat:@"\t\t\t[subscriber sendNext:taskResult];\n"];
                        [result appendFormat:@"\t\t\t[subscriber sendCompleted];\n"];
                        [result appendFormat:@"\t\t} failure:^(NSURLSessionDataTask *task, NSError *error) {\n"];
                        [result appendFormat:@"\t\t\t[subscriber sendNext:error];\n"];
                        [result appendFormat:@"\t\t\t[subscriber sendCompleted];\n"];
                        [result appendFormat:@"\t\t}];\n"];
                        [result appendFormat:@"\t\treturn [RACDisposable disposableWithBlock:^{\n"];
                        [result appendFormat:@"\t\t\t[task cancel];\n"];
                        [result appendFormat:@"\t\t}];\n"];
                        [result appendFormat:@"\t}];\n"];
                        [result appendFormat:@"\treturn [signal replayLazily];\n"];
                        [result appendString:@"}\n\n"];
                    } else if (rtype == REQUEST_PRO) {
                        [result appendFormat:@" {\n"];
                        [result appendFormat:@"\t@weakify(self);\n"];
                        [result appendFormat:@"\tFBLPromise<NSDictionary *> *promoise = [FBLPromise async:^(FBLPromiseFulfillBlock  _Nonnull fulfill, FBLPromiseRejectBlock  _Nonnull reject) {\n"];
                        [result appendFormat:@"\t\t@strongify(self);\n"];
                        if ([configDictionary[@"baseurl"] boolValue]) {
                            [result appendFormat:@"\t\tNSURLSessionDataTask *task = [self %@URL:(NSString *)baseurl showHUD:(BOOL)showHUD", [interfacename stringByReplacingOccurrencesOfString:@"/" withString:@""]];
                        } else {
                            [result appendFormat:@"\t\tNSURLSessionDataTask *task = [self %@RequestShowHUD:(BOOL)showHUD", [interfacename stringByReplacingOccurrencesOfString:@"/" withString:@""]];
                        }
                        //判断是否是上传接口  上传接口需要提取出来单独处理
                        if ([requestType isEqualToString:@"upload"] || [requestType isEqualToString:@"iupload"]) {
                            [result appendFormat:@" formDataBlock:(void(^)(id<AFMultipartFormData> formData))formDataBlock"];
                        }
                        [result appendFormat:@" iparams:(NSDictionary *)iparams success:^(NSURLSessionDataTask *task, BaseCollection *result, %@ *data, NSDictionary *sourceData) {\n", returnType];
                        [result appendFormat:@"\t\t\tNSMutableDictionary *taskResult = [NSMutableDictionary dictionary];\n"];
                        [result appendFormat:@"\t\t\ttaskResult[@\"result\"] = result;\n"];
                        [result appendFormat:@"\t\t\ttaskResult[@\"data\"] = data;\n"];
                        [result appendFormat:@"\t\t\ttaskResult[@\"sourceData\"] = sourceData;\n"];
                        [result appendFormat:@"\t\t\tfulfill(taskResult);\n"];
                        [result appendFormat:@"\t\t} failure:^(NSURLSessionDataTask *task, NSError *error) {\n"];
                        [result appendFormat:@"\t\t\treject(error);\n"];
                        [result appendFormat:@"\t\t}];\n"];
                        [result appendFormat:@"\t}];\n"];
                        [result appendFormat:@"\treturn promoise;\n"];
                        [result appendString:@"}\n\n"];
                    }
                }
                    break;
                case TYPE_REQUEST: {
                    if (rtype == REQUEST_NORMAL) {
                        [result appendFormat:@"{\n"];
                        [result appendFormat:@"\tNSMutableDictionary *requestParams = [[NSMutableDictionary alloc] init];\n"];
                        [result appendString:[self allPramaFromContents:contents withType:methodType fileType:fileType cacheDay:cacheDay rtype:rtype]];
                        if ([configDictionary[@"baseurl"] boolValue]) {
                            [result appendFormat:@"\tNSURLSessionDataTask *task = [self %@URL:(NSString *)baseurl showHUD:(BOOL)showHUD", [interfacename stringByReplacingOccurrencesOfString:@"/" withString:@""]];
                        } else {
                            [result appendFormat:@"\tNSURLSessionDataTask *task = [self %@RequestShowHUD:showHUD", [interfacename stringByReplacingOccurrencesOfString:@"/" withString:@""]];
                        }
                        //判断是否是上传接口  上传接口需要提取出来单独处理
                        if ([requestType isEqualToString:@"upload"] || [requestType isEqualToString:@"iupload"]) {
                            [result appendFormat:@" formDataBlock:(void(^)(id<AFMultipartFormData> formData))formDataBlock"];
                        }
                        [result appendFormat:@" iparams:(NSDictionary *)requestParams success:success failure:failure];\n"];
                        [result appendFormat:@"\treturn task;\n"];
                        [result appendFormat:@"}\n\n"];
                    } else if (rtype == REQUEST_RAC) {
                        [result appendFormat:@" {\n"];
                        [result appendFormat:@"\t@weakify(self);\n"];
                        [result appendFormat:@"\tRACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {\n"];
                        [result appendFormat:@"\t\t@strongify(self);\n"];
                        if ([configDictionary[@"baseurl"] boolValue]) {
                            [result appendFormat:@"\t\tNSURLSessionDataTask *task = [self %@URL:(NSString *)baseurl showHUD:(BOOL)showHUD", [interfacename stringByReplacingOccurrencesOfString:@"/" withString:@""]];
                        } else {
                            [result appendFormat:@"\t\tNSURLSessionDataTask *task = [self %@RequestShowHUD:(BOOL)showHUD", [interfacename stringByReplacingOccurrencesOfString:@"/" withString:@""]];
                        }
                        //判断是否是上传接口  上传接口需要提取出来单独处理
                        if ([requestType isEqualToString:@"upload"] || [requestType isEqualToString:@"iupload"]) {
                            [result appendFormat:@" formDataBlock:(void(^)(id<AFMultipartFormData> formData))formDataBlock"];
                        }
                        [result appendString:[self allPramaFromContents:contents withType:methodType fileType:fileType cacheDay:cacheDay rtype:rtype]];
                        [result appendFormat:@" success:^(NSURLSessionDataTask *task, BaseCollection *result, %@ *data, NSDictionary *sourceData) {\n", returnType];
                        [result appendFormat:@"\t\t\t*returnValue = data;\n"];
                        [result appendFormat:@"\t\t\tNSMutableDictionary *taskResult = [NSMutableDictionary dictionary];\n"];
                        [result appendFormat:@"\t\t\ttaskResult[@\"result\"] = result;\n"];
                        [result appendFormat:@"\t\t\ttaskResult[@\"data\"] = data;\n"];
                        [result appendFormat:@"\t\t\ttaskResult[@\"sourceData\"] = sourceData;\n"];
                        [result appendFormat:@"\t\t\t[subscriber sendNext:taskResult];\n"];
                        [result appendFormat:@"\t\t\t[subscriber sendCompleted];\n"];
                        [result appendFormat:@"\t\t} failure:^(NSURLSessionDataTask *task, NSError *error) {\n"];
                        [result appendFormat:@"\t\t\t[subscriber sendNext:error];\n"];
                        [result appendFormat:@"\t\t\t[subscriber sendCompleted];\n"];
                        [result appendFormat:@"\t\t}];\n"];
                        [result appendFormat:@"\t\treturn [RACDisposable disposableWithBlock:^{\n"];
                        [result appendFormat:@"\t\t\t[task cancel];\n"];
                        [result appendFormat:@"\t\t}];\n"];
                        [result appendFormat:@"\t}];\n"];
                        [result appendFormat:@"\treturn [signal replayLazily];\n"];
                        [result appendString:@"}\n\n"];
                    } else if (rtype == REQUEST_PRO) {
                        [result appendFormat:@" {\n"];
                        [result appendFormat:@"\t@weakify(self);\n"];
                        [result appendFormat:@"\tFBLPromise<NSDictionary *> *promoise = [FBLPromise async:^(FBLPromiseFulfillBlock  _Nonnull fulfill, FBLPromiseRejectBlock  _Nonnull reject) {\n"];
                        [result appendFormat:@"\t\t@strongify(self);\n"];
                        if ([configDictionary[@"baseurl"] boolValue]) {
                            [result appendFormat:@"\t\tNSURLSessionDataTask *task = [self %@URL:(NSString *)baseurl showHUD:(BOOL)showHUD", [interfacename stringByReplacingOccurrencesOfString:@"/" withString:@""]];
                        } else {
                            [result appendFormat:@"\t\tNSURLSessionDataTask *task = [self %@RequestShowHUD:(BOOL)showHUD", [interfacename stringByReplacingOccurrencesOfString:@"/" withString:@""]];
                        }
                        //判断是否是上传接口  上传接口需要提取出来单独处理
                        if ([requestType isEqualToString:@"upload"] || [requestType isEqualToString:@"iupload"]) {
                            [result appendFormat:@" formDataBlock:(void(^)(id<AFMultipartFormData> formData))formDataBlock"];
                        }
                        [result appendString:[self allPramaFromContents:contents withType:methodType fileType:fileType cacheDay:cacheDay rtype:rtype]];
                        [result appendFormat:@" success:^(NSURLSessionDataTask *task, BaseCollection *result, %@ *data, NSDictionary *sourceData) {\n", returnType];
                        [result appendFormat:@"\t\t\t*returnValue = data;\n"];
                        [result appendFormat:@"\t\t\tNSMutableDictionary *taskResult = [NSMutableDictionary dictionary];\n"];
                        [result appendFormat:@"\t\t\ttaskResult[@\"result\"] = result;\n"];
                        [result appendFormat:@"\t\t\ttaskResult[@\"data\"] = data;\n"];
                        [result appendFormat:@"\t\t\ttaskResult[@\"sourceData\"] = sourceData;\n"];
                        [result appendFormat:@"\t\t\tfulfill(taskResult);\n"];
                        [result appendFormat:@"\t\t} failure:^(NSURLSessionDataTask *task, NSError *error) {\n"];
                        [result appendFormat:@"\t\t\treject(error);\n"];
                        [result appendFormat:@"\t\t}];\n"];
                        [result appendFormat:@"\t}];\n"];
                        [result appendFormat:@"\treturn promoise;\n"];
                        [result appendString:@"}\n\n"];
                    }
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
+ (NSString *)allPramaFromContents:(NSArray *)contents withType:(MethodType)methodType fileType:(FileType)fileType cacheDay:(NSInteger)cacheDay rtype:(RequestType)rtype {
    NSMutableString *result = [[NSMutableString alloc] init];
    for (int i = 0; i < contents.count; i++) {
        NSString *lineString = [contents objectAtIndex:i];
        NSString *regexLine = @"^(?:[\\s]*)(class|required|optional|repeated|upload|query|path)(?:[\\s]*)(\\S+)(?:[\\s]*)(\\S+)(?:[\\s]*)=(?:[\\s]*)(\\S+)(?:[\\s]*);([\\S\\s]*)$";
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
                
            case TYPE_METHOD: {
                if ([style isEqualToString:@"repeated"]) {
                    if ([[Utils modelTypeConvertDictionary].allKeys containsObject:[type lowercaseString]]) {
                        [result appendFormat:@" %@:(NSArray<%@> *)%@", fieldname, [Utils modelTypeConvertDictionary][[type lowercaseString]], fieldname];
                    } else {
                        [result appendFormat:@" %@:(NSArray<%@ *> *)%@", fieldname, type, fieldname];
                    }
                }
                else if ([style isEqualToString:@"class"]) {
                    [result appendFormat:@" %@:(%@ *)%@", fieldname, type, fieldname];
                } else if ([[Utils modelTypeConvertDictionary].allKeys containsObject:[type lowercaseString]]){
                    if ([[Utils modelTypeConvertDictionary][[type lowercaseString]] rangeOfString:@"*"].location == NSNotFound) {
                        [result appendFormat:@" %@:(%@)%@", fieldname, [Utils modelTypeConvertDictionary][[type lowercaseString]], fieldname];
                    } else {
                        [result appendFormat:@" %@:(%@)%@", fieldname, [Utils modelTypeConvertDictionary][[type lowercaseString]], fieldname];
                    }
                } else if ([enumList containsObject:type]) {
                    [result appendFormat:@" %@:(%@)%@", fieldname, type, fieldname];
                } else {
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
                    case TYPE_QUERY: {
                        if ([style isEqualToString:@"query"]) {
                            [result appendFormat:@"\tqueryParams[@\"%@\"] = requestParams[@\"%@\"];\n", keyname, keyname];
                            [result appendFormat:@"\t[parameters removeObjectForKey:@\"%@\"];\n", keyname];
                        }
                    }
                        break;
                    case TYPE_PATH: {
                        if ([style isEqualToString:@"path"]) {
                            [result appendFormat:@"\tbaseUrl = [NSString stringWithFormat:@\"%%@/%%@\", baseUrl, requestParams[@\"%@\"]];\n", keyname];
                        }
                    }
                        break;
                    case TYPE_REQUEST:
                    {
                        if (rtype == REQUEST_NORMAL) {
                            if ([style isEqualToString:@"repeated"]) {
                                if (IS_BASE_TYPE(type) || [enumList containsObject:type]) {
                                    [result appendFormat:@"\trequestParams[@\"%@\"] = %@;\n", keyname, fieldname];
                                } else if ([type isEqualToString:@"string"] || [NSClassFromString(type) isKindOfClass:[NSObject class]]){
                                    [result appendFormat:@"\trequestParams[@\"%@\"] = %@;\n", keyname, fieldname];
                                } else if ([Utils.modelTypeConvertDictionary.allKeys containsObject:type]) {
                                    [result appendFormat:@"\trequestParams[@\"%@\"] = %@;\n", keyname, fieldname];
                                } else {
                                    [result appendFormat:@"\trequestParams[@\"%@\"] = [%@ mj_keyValuesArrayWithObjectArray:%@];\n", keyname, type, fieldname];
                                }
                            } else if ([style isEqualToString:@"class"]) {
                                [result appendFormat:@"\trequestParams[@\"%@\"] = %@;\n", keyname, fieldname];
                            } else {
                                if (IS_BASE_TYPE(type) || [enumList containsObject:type]) {
                                    if ([[type lowercaseString] isEqualToString:@"int"] || [[type lowercaseString] isEqualToString:@"short"] || [enumList containsObject:type] || [type isEqualToString:@"integer"]) {
                                        [result appendFormat:@"\trequestParams[@\"%@\"] = [NSNumber numberWithInteger:%@];\n", keyname, fieldname];
                                    } else {
                                        [result appendFormat:@"\trequestParams[@\"%@\"] = [NSNumber numberWith%@:%@];\n", keyname, [NSString stringWithFormat:@"%@%@", [[type substringToIndex:1] uppercaseString], [type substringFromIndex:1]], fieldname];
                                    }
                                } else if ([type isEqualToString:@"string"] || [NSClassFromString(type) isKindOfClass:[NSObject class]]){
                                    [result appendFormat:@"\trequestParams[@\"%@\"] = %@;\n", keyname, fieldname];
                                } else if ([Utils.modelTypeConvertDictionary.allKeys containsObject:type]) {
                                    [result appendFormat:@"\trequestParams[@\"%@\"] = %@;\n", keyname, fieldname];
                                } else {
#warning 非简单数据类型的处理 包含枚举类型和model类型
                                    [result appendFormat:@"\trequestParams[@\"%@\"] = %@.mj_JSONObject;\n", keyname, fieldname];
                                }
                            }
                        } else {
                            if ([style isEqualToString:@"repeated"]) {
                                if ([[Utils modelTypeConvertDictionary].allKeys containsObject:[type lowercaseString]]) {
                                    [result appendFormat:@" %@:(NSArray<%@> *)%@", fieldname, [Utils modelTypeConvertDictionary][[type lowercaseString]], fieldname];
                                } else {
                                    [result appendFormat:@" %@:(NSArray<%@ *> *)%@", fieldname, type, fieldname];
                                }
                            }
                            else if ([style isEqualToString:@"class"]) {
                                [result appendFormat:@" %@:(%@ *)%@", fieldname, type, fieldname];
                            } else if ([[Utils modelTypeConvertDictionary].allKeys containsObject:[type lowercaseString]]){
                                if ([[Utils modelTypeConvertDictionary][[type lowercaseString]] rangeOfString:@"*"].location == NSNotFound) {
                                    [result appendFormat:@" %@:(%@)%@", fieldname, [Utils modelTypeConvertDictionary][[type lowercaseString]], fieldname];
                                } else {
                                    [result appendFormat:@" %@:(%@)%@", fieldname, [Utils modelTypeConvertDictionary][[type lowercaseString]], fieldname];
                                }
                            } else if ([enumList containsObject:type]) {
                                [result appendFormat:@" %@:(%@)%@", fieldname, type, fieldname];
                            } else {
                                //首先 区分开枚举类型与数据类型   所有的枚举类型  使用整型替代
                                [result appendFormat:@" %@:(%@ *)%@", fieldname, type, fieldname];
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




















