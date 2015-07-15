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
            if (K_HAS_PODS) {
                [result appendString:@"#import <AFNetworking/AFNetworking.h>\n"];
                [result appendString:@"#import <XMLDictionary/XMLDictionary.h>\n"];
                [result appendString:@"#import <WToast/WToast.h>\n"];
            }
            else {
                [result appendString:@"#import \"AFNetworking.h\"\n"];
                [result appendString:@"#import \"XMLDictionary.h\"\n"];
                [result appendString:@"#import \"WToast.h\"\n"];
            }
            [result appendFormat:@"#import \"%@.h\"\n", CONFIG_NAME];
            [result appendFormat:@"#import \"%@.h\"\n", MODEL_NAME];
            [result appendFormat:@"#import \"NSDictionary+SafeAccess.h\"\n"];
        }
            break;
        case M_FILE:
        {
            [result appendFormat:@"#import \"%@.h\"\n", REQUEST_NAME];
            if (K_HAS_PODS) {
                [result appendFormat:@"#import <SVProgressHUD/SVProgressHUD.h>\n"];
            }
            else {
                [result appendFormat:@"#import \"SVProgressHUD.h\"\n"];
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
            [result appendFormat:@"\n\n@interface PPRequest : AFHTTPRequestOperationManager {\n"];
            [result appendFormat:@"}\n"];
            [result appendFormat:@"\n+ (instancetype)sharedClient;\n\n\n"];
        }
            break;
        case M_FILE:
        {
            [result appendFormat:@"\n@implementation PPRequest\n"];
            [result appendFormat:@"\n+ (instancetype)sharedClient {\n"];
            [result appendFormat:@"\tstatic PPRequest *_sharedClient;\n"];
            [result appendFormat:@"\tstatic dispatch_once_t onceToken;\n"];
            [result appendFormat:@"\tdispatch_once(&onceToken, ^{ \n"];
            [result appendFormat:@"\t\t_sharedClient = [[PPRequest alloc] initWithBaseURL:[NSURL URLWithString:HOST_NAME]];\n"];
            [result appendFormat:@"\t\t_sharedClient.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];\n"];
            if (K_RESPONSE_TYPE == XML_TYPE) {
                [result appendFormat:@"\t\t_sharedClient.responseSerializer = [AFXMLParserResponseSerializer serializer];//申明返回的结果是json类型\n"];
            }
            else {
                [result appendFormat:@"\t\t_sharedClient.responseSerializer = [AFJSONResponseSerializer serializer];//申明返回的结果是json类型\n"];
            }
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
            
            [result appendString:[self generationFileType:fileType requestType:requestType methodName:interface returnType:returnType contents:contents methodType:TYPE_NOTES]];
            [result appendString:[self generationFileType:fileType requestType:requestType methodName:interface returnType:returnType contents:contents methodType:TYPE_METHOD]];
            [result appendString:[self generationFileType:fileType requestType:requestType methodName:interface returnType:returnType contents:contents methodType:TYPE_REQUEST]];
            
        }
    }
    
    return result;
}

/**
 * @brief  生成方法名
 * @prama  fileType:[H_FILE:h文件  M_FILE: m文件]
 * @prama  requestType:接口类型 get | post | upload
 * @prama  interface:接口名称
 * @prama  returnType:返回类型
 * @prama  methodType:方法类型
 * @prama  contents:接口参数
 */
+ (NSString *)generationFileType:(FileType)fileType requestType:(NSString *)requestType methodName:(NSString *)interface returnType:(NSString *)returnType contents:(NSArray *)contents methodType:(MethodType)methodType
{
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

    // h m 文件中均需导入的
    switch (methodType) {
        case TYPE_NOTES:
        {
            [result appendFormat:@"/**\n"];
            [result appendFormat:@" * @brief %@\n", [contents firstObject]];
            [result appendString:[self allPramaFromContents:contents withType:methodType fileType:fileType]];
            [result appendFormat:@" **/\n"];
        }
            break;
            
        case TYPE_METHOD:
        {
            [result appendFormat:@"+(AFHTTPRequestOperation *)%@RequestUrl:(NSString *)baseurl", interfacename];
            
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
                    
                    [result appendFormat:@" %@:(NSArray *)%@", fieldname, @"pic"];
                }
            }
            else if ([requestType isEqualToString:@"get"]) {
            }
            else if ([requestType isEqualToString:@"post"]) {
            }
            else {
                NSLog(@"ERROR -- 网络请求接口参数有误");
            }
            [result appendString:[self allPramaFromContents:contents withType:methodType fileType:fileType]];
            [result appendFormat:@" success:(void (^)(AFHTTPRequestOperation *operation, %@ *result))success  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;", returnType];
            
            
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
                {
                    [result appendFormat:@"\n\n"];
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
                case TYPE_REQUEST:
                {
                    [result appendString:@"{\n"];
                    [result appendString:@"\t[SVProgressHUD showWithStatus:@\"正在加载...\"];\n"];
                    [result appendString:@"\t[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;\n"];
                    [result appendString:@"\tNSMutableDictionary *params = [[NSMutableDictionary alloc] init];\n"];
                    [result appendString:[self allPramaFromContents:contents withType:methodType fileType:fileType]];
                    
                    if ([requestType isEqualToString:@"get"]) {
                        [result appendString:@"\tAFHTTPRequestOperation *op = [[PPRequest sharedClient] GET:[NSString stringWithFormat:@\"%@%@\", BASE_URL, baseurl] parameters:params success:^(AFHTTPRequestOperation *operation, id result) {\n"];
                    }
                    else if ([requestType isEqualToString:@"post"]) {
                        [result appendString:@"\tAFHTTPRequestOperation *op = [[PPRequest sharedClient] POST:[NSString stringWithFormat:@\"%@%@\", BASE_URL, baseurl] parameters:params success:^(AFHTTPRequestOperation *operation, id result) {\n"];
                    }
                    else if ([requestType isEqualToString:@"upload"]){
                        [result appendString:@"\tAFHTTPRequestOperation *op = [[PPRequest sharedClient] POST:[NSString stringWithFormat:@\"%@%@\", BASE_URL, baseurl] parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {\n"];
                        [result appendFormat:@"\t\tfor (int i = 0; i < pic.count; i++) {\n"];
                        [result appendFormat:@"\t\t\tUIImage *image = [pic objectAtIndex:i];\n"];
                        [result appendFormat:@"\t\t\t[formData appendPartWithFileData:UIImageJPEGRepresentation(image, 1.0) name:[NSString stringWithFormat:@\"%%i.png\", i] fileName:[NSString stringWithFormat:@\"%%i.png\", i] mimeType:@\"image/png\"];\n"];
                        [result appendFormat:@"\t\t}\n"];
                        [result appendFormat:@"\t} success:^(AFHTTPRequestOperation *operation, id result) {\n"];
                    }
                    
                    [result appendString:@"\t\t[SVProgressHUD dismiss];\n"];
                    [result appendString:@"\t\t[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;\n"];
                    [result appendFormat:@"\t\t%@ *info;\n", returnType];
                    if (K_RESPONSE_TYPE == XML_TYPE) {
                        [result appendString:@"\t\tNSDictionary *res = [[XMLDictionaryParser sharedInstance] dictionaryWithParser:result];\n"];
                        [result appendFormat:@"\t\tinfo = [%@ parseFromDictionary:res];\n", returnType];
                    }
                    else {
                        [result appendFormat:@"\t\tinfo = [%@ parseFromDictionary:result];\n", returnType];
                    }
                    [result appendString:@"\t\tsuccess(operation, info);\n"];
                    [result appendString:@"\t} failure:^(AFHTTPRequestOperation *operation, NSError *error) {\n"];
                    [result appendString:@"\t\t[WToast showWithText:@\"网络异常\"];\n"];
                    [result appendString:@"\t\t[SVProgressHUD dismiss];\n"];
                    [result appendString:@"\t\t[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;\n"];
                    [result appendFormat:@"\t\tfailure(operation, error);\n"];
                    [result appendString:@"\t}];\n"];
                    [result appendString:@"\treturn op;\n"];
                    [result appendString:@"}\n\n\n"];
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
+ (NSString *)allPramaFromContents:(NSArray *)contents withType:(MethodType)methodType fileType:(FileType)fileType
{
    NSMutableString *result = [[NSMutableString alloc] init];
    for (int i = 0; i < contents.count; i++) {
        NSString *lineString = [contents objectAtIndex:i];
        NSString *regexLine = @"^(?:[\\s]*)(class|required|optional|repeated)(?:[\\s]*)(\\S+)(?:[\\s]*)(\\S+)(?:[\\s]*)=(?:[\\s]*)(\\S+)(?:[\\s]*);([\\S\\s]*)$";
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
        
        //h m 文件都需要导入的文件
        switch (methodType) {
            case TYPE_NOTES:
            {
                [result appendFormat:@" * @prama %@:%@\n", fieldname, notes];
            }
                break;
                
            case TYPE_METHOD:
            {
                if ([style isEqualToString:@"repeated"]) {
//#warning 上传数组的处理
                    [result appendFormat:@" %@:(NSArray *)%@List", fieldname, fieldname];
                }
                else if ([style isEqualToString:@"class"]) {
                    [result appendFormat:@" %@:(%@ *)%@", fieldname, type, fieldname];
                }
                else {
                    if (IS_BASE_TYPE(type)) {
                        if ([[type lowercaseString] isEqualToString:@"int"] || [[type lowercaseString] isEqualToString:@"short"]) {
                            [result appendFormat:@" %@:(NSInteger)%@", fieldname, fieldname];
                        }
                        else if ([[type lowercaseString] isEqualToString:@"float"] || [[type lowercaseString] isEqualToString:@"double"]) {
                            [result appendFormat:@" %@:(CGFloat)%@", fieldname, fieldname];
                        }
                        else if ([[type lowercaseString] isEqualToString:@"long"]) {
                            [result appendFormat:@" %@:(long long)%@", fieldname, fieldname];
                        }
                        else if ([[type lowercaseString] isEqualToString:@"bool"]) {
                            [result appendFormat:@" %@:(BOOL)%@", fieldname, fieldname];
                        }
                        else  {
                        }
                    }
                    else if ([type isEqualToString:@"string"]){
                        [result appendFormat:@" %@:(NSString *)%@", fieldname, fieldname];
                    }
                    else {
#warning 非简单数据类型的处理 包含枚举类型和model类型
                        [result appendFormat:@" %@:(%@)%@", fieldname, type, fieldname];
                    }
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
//#warning 上传数组的处理
                            [result appendFormat:@"\t[params setObj:[%@List componentsJoinedByString:@\",\"] forKey:@\"%@\"];\n", fieldname, keyname];
                        }
                        else if ([style isEqualToString:@"class"]) {
                            [result appendFormat:@"\t[params addEntriesFromDictionary:[%@ dictionaryValue]];\n", fieldname];
                        }
                        else {
                            if (IS_BASE_TYPE(type)) {
                                if ([[type lowercaseString] isEqualToString:@"int"] || [[type lowercaseString] isEqualToString:@"short"]) {
                                    [result appendFormat:@"\t[params setObj:[NSNumber numberWithInteger:%@] forKey:@\"%@\"];\n", fieldname, keyname];
                                }
                                else {
                                    [result appendFormat:@"\t[params setObj:[NSNumber numberWith%@:%@] forKey:@\"%@\"];\n", [NSString stringWithFormat:@"%@%@", [[type substringToIndex:1] uppercaseString], [type substringFromIndex:1]], fieldname, keyname];
                                }
                            }
                            else if ([type isEqualToString:@"string"]){
                                [result appendFormat:@"\t[params setObj:%@ forKey:@\"%@\"];\n", fieldname, keyname];
                            }
                            else {
#warning 非简单数据类型的处理 包含枚举类型和model类型
                                [result appendFormat:@"\t[params setObj:[NSNumber numberWithInteger:%@] forKey:@\"%@\"];\n", fieldname, keyname];
                                //result appendString:@"%@:(%@)"
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



















