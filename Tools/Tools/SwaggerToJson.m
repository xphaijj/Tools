//
//  SwaggerToJson.m
//  Tools
//
//  Created by 項普華 on 2019/12/12.
//  Copyright © 2019 Alex xiang. All rights reserved.
//

#import "SwaggerToJson.h"
#import "SwaggerModel.h"

@interface SwaggerToJson ()

@end

@implementation SwaggerToJson

/**
 * @brief  Model类自动生成
 * @prama  sourcepath:资源路径   outputPath:资源生成路径
 */
+ (void)generationSourcePath:(NSString *)sourcepath outputPath:(NSString *)outputPath config:(NSDictionary *)config {
    NSMutableString *h = [[NSMutableString alloc] init];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    NSString *hFilePath = [outputPath stringByAppendingPathComponent:[NSString stringWithFormat:@"source.h"]];
    [fileManager createFileAtPath:hFilePath contents:nil attributes:nil];
    
    NSMutableDictionary<NSString *, NSMutableArray<SwaggerParam *> *> *allModels = [[NSMutableDictionary alloc] init];
    NSMutableArray<SwaggerModel *> *allRequests = [[NSMutableArray alloc] init];
    NSError *error;
    NSDictionary *configData = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForAuxiliaryExecutable:sourcepath]] options:NSJSONReadingAllowFragments error:&error];
    [h appendFormat:@"Config config %@ \n\n", [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:configData[@"config"] options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding]];
    
    dispatch_group_t group = dispatch_group_create();
    [configData[@"list"] enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull sourceObj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *urlString = [sourceObj objectForKey:@"path"];
        //遍历请求网络
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
        dispatch_group_enter(group);
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse * response, NSError *error) {
            // 解析数据
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSDictionary<NSString *, NSDictionary *> *paths = dic[@"paths"];
            // 遍历path 找出所有的网络请求
            [paths enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSDictionary<NSString *, NSDictionary *> *obj, BOOL * _Nonnull stop) {
                [obj.allKeys enumerateObjectsUsingBlock:^(NSString * _Nonnull method, NSUInteger idx, BOOL * _Nonnull stop) {
                    SwaggerModel *model = [[SwaggerModel alloc] init];
                    if ([key hasPrefix:@"/front/"]) {
                        model.basePath = [NSString stringWithFormat:@"%@%@", sourceObj[@"basePath"], key];
                    } else {
                        model.basePath = [NSString stringWithFormat:@"%@", key];
                    }
                    model.pre = sourceObj[@"pre"];
                    model.method = method;//获取get、post
                    NSDictionary *more = [obj objectForKey:model.method];
                    model.summary = [more objectForKey:@"summary"];
                    model.operationId = [more objectForKey:@"operationId"];
                    
                    [[more objectForKey:@"parameters"] enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        NSDictionary *parameters = obj;
                        //解析请求参数
                        if (parameters.count != 0) {
                            //上传参数不为空
                            NSString *ref = [[parameters objectForKey:@"schema"] objectForKey:@"$ref"];
                            if (ref && [ref isKindOfClass:[NSString class]] && ref.length != 0) {
                                NSDictionary *pagrams = [self dcodeSourceDic:dic router:ref];
                                if ([pagrams.allKeys containsObject:@"properties"]) {
                                    [model.params addObjectsFromArray:[self dcodeProperties:[pagrams objectForKey:@"properties"]]];
                                }
                            } else {
                                SwaggerParam *params = [[SwaggerParam alloc] init];
                                params.key = [parameters objectForKey:@"name"];
                                if ([parameters.allKeys containsObject:@"type"]) {
                                    params.type = [parameters objectForKey:@"type"];
                                } else if ([parameters.allKeys containsObject:@"schema"]) {
                                    params.type = [[parameters objectForKey:@"schema"] objectForKey:@"type"];
                                }
                                params.summary = [parameters objectForKey:@"description"];
                                if ([parameters.allKeys containsObject:@"in"]) {
                                    params.inType = parameters[@"in"];
                                }
                                params.sourceData = parameters;
                                [model.params addObject:params];
                            }
                        }
                    }];
                    
                    //解析返回参数
                    BOOL isList = NO;
                    NSString *ref = [[[[more objectForKey:@"responses"] objectForKey:@"200"] objectForKey:@"schema"] objectForKey:@"$ref"];
                    ref = [[ref componentsSeparatedByString:@"/"] lastObject];
                    NSString *responseKey = ref;
                    if ([ref hasPrefix:@"Resp«List«"]) {
                        isList = YES;
                        responseKey = [NSString stringWithFormat:@"%@(list)", responseKey];
                    }
                    responseKey = [self convertKey:responseKey];
                    model.responseObj = responseKey;
                    [allRequests addObject:model];
                }];
            }];
            //遍历所有的model
            NSDictionary<NSString *, NSDictionary *> *definitions = dic[@"definitions"];
            NSArray *defs = definitions.allKeys;
            for (NSInteger i = 0; i < defs.count; i++) {
                NSString *key = defs[i];
                NSDictionary *obj = [definitions objectForKey:key];
                if ([key hasPrefix:@"Resp«"]) {
                    continue;
                }
                NSMutableArray<SwaggerParam *> *properties = [[NSMutableArray alloc] init];
                if ([obj.allKeys containsObject:@"properties"]) {
                    [properties addObjectsFromArray:[self dcodeProperties:[obj objectForKey:@"properties"]]];
                }
                if ([allModels.allKeys containsObject:[self convertKey:key]]) {
                    [allModels[[self convertKey:key]] enumerateObjectsUsingBlock:^(SwaggerParam * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        NSString *preStr = [NSString stringWithFormat:@"self.key == '%@'", obj.key];
                        NSPredicate *predicate = [NSPredicate predicateWithFormat:preStr];
                        if (![properties filteredArrayUsingPredicate:predicate].firstObject) {
                            [properties addObject:obj];
                        }
                    }];
                }
                [allModels setObject:properties forKey:[self convertKey:key]];
            }
            dispatch_group_leave(group);
        }];
        // 执行 task
        [dataTask resume];
        [[NSRunLoop mainRunLoop] runUntilDate:[[NSDate date] dateByAddingTimeInterval:0.5]];
    }];
    
    __block BOOL isFinish = NO;
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [allRequests enumerateObjectsUsingBlock:^(SwaggerModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [h appendFormat:@"request %@ %@ %@ %@ { //%@\n", obj.method, obj.operationPath, obj.responseObj, obj.basePath, obj.summary];
        
            [[obj.params sortedArrayUsingComparator:^NSComparisonResult(SwaggerParam *_Nonnull obj1, SwaggerParam *_Nonnull obj2) {
                NSStringCompareOptions comparisonOptions = NSCaseInsensitiveSearch|NSNumericSearch|NSWidthInsensitiveSearch|NSForcedOrderingSearch;
                return ([obj1.key compare:obj2.key options:comparisonOptions]);
            }] enumerateObjectsUsingBlock:^(SwaggerParam * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [h appendString:[obj codeString:YES]];
            }];
            [h appendFormat:@"}"];
            if ([configData.allKeys containsObject:@"cache"]) {
                NSArray *cacheList = configData[@"cache"];
                for (NSInteger cacheIndex = 0; cacheIndex < cacheList.count; cacheIndex++) {
                    NSDictionary *cacheSource = cacheList[cacheIndex];
                    if ([cacheSource.allKeys containsObject:@"path"] && [cacheSource.allKeys containsObject:@"day"] && [obj.operationPath hasPrefix:cacheSource[@"path"]]) {
                        [h appendFormat:@"%@", cacheSource[@"day"]];
                    }
                }
            }
            [h appendFormat:@"\n\n"];
        }];
        
        NSArray *allList = allModels.allKeys;
        for (NSInteger i = 0; i < allList.count; i++) {
            NSString *key = allList[i];
            NSMutableArray<SwaggerParam *> *obj = [allModels objectForKey:key];
            if (obj.count == 2) {
                if ([obj.firstObject.key isEqualToString:@"msg"] && [obj.lastObject.key isEqualToString:@"code"]) {
                    continue;
                } else if ([obj.firstObject.key isEqualToString:@"code"] && [obj.lastObject.key isEqualToString:@"msg"]) {
                    continue;
                }
            }
            
            [h appendFormat:@"message %@ : BaseCollection {\n", key];
            [obj enumerateObjectsUsingBlock:^(SwaggerParam * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [h appendString:[obj codeString:NO]];
            }];
            [h appendFormat:@"}\n\n"];
        }
        [h writeToFile:hFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        isFinish = YES;
    });
    
    if (!isFinish) {
        [[NSRunLoop mainRunLoop] runUntilDate:[[NSDate date] dateByAddingTimeInterval:1.]];
    }
    NSLog(@"done");
}

+ (NSArray<SwaggerParam *> *)dcodeProperties:(NSDictionary<NSString *, NSDictionary*> *)properties {
    __block NSMutableArray<SwaggerParam *> *result = [[NSMutableArray alloc] init];
    [properties enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSDictionary * _Nonnull obj, BOOL * _Nonnull stop) {
        if (![obj.allKeys containsObject:@"type"] && [obj.allKeys containsObject:@"$ref"]) {
            NSString *ref = [obj objectForKey:@"$ref"];
            SwaggerParam *params = [[SwaggerParam alloc] init];
            params.key = key;
            params.type = [[ref componentsSeparatedByString:@"/"] lastObject];
            params.summary = obj[@"description"];
            params.sourceData = obj;
            if ([obj.allKeys containsObject:@"in"]) {
                params.inType = obj[@"in"];
            }
            if (params.isValid) {
                [result addObject:params];
            }
        } else {
            SwaggerParam *params = [[SwaggerParam alloc] init];
            params.key = key;
            params.type = obj[@"type"];
            params.summary = obj[@"description"];
            if ([obj.allKeys containsObject:@"in"]) {
                params.inType = obj[@"in"];
            }
            params.sourceData = obj;
            if (params.isValid) {
                [result addObject:params];
            }
        }
    }];
    return result;
}

+ (NSString *)convertKey:(NSString *)key {
    if ([key hasPrefix:@"Resp«List«"]) {
        key = [[key stringByReplacingOccurrencesOfString:@"Resp«List«" withString:@""] stringByReplacingOccurrencesOfString:@"»»" withString:@""];
    }
    while (key && [key hasPrefix:@"Resp«"]) {
        key = [key substringFromIndex:5];
    }
    while (key && [key rangeOfString:@"«"].location != NSNotFound) {
        key = [key stringByReplacingOccurrencesOfString:@"«" withString:@""];
    }
    while (key && [key rangeOfString:@"»"].location != NSNotFound) {
        key = [key stringByReplacingOccurrencesOfString:@"»" withString:@""];
    }
    return key;
}

+ (NSDictionary *)dcodeSourceDic:(NSDictionary *)sourceDic router:(NSString *)router {
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    __block NSDictionary *source = sourceDic;
    
    [[router componentsSeparatedByString:@"/"] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj isEqualToString:@"#"] && [source.allKeys containsObject:obj]) {
            source = [source objectForKey:obj];
        }
    }];
    [result addEntriesFromDictionary:source];
    return result;
}

@end
