//
//  SwaggerModel.m
//  Tools
//
//  Created by 項普華 on 2019/12/12.
//  Copyright © 2019 Alex xiang. All rights reserved.
//

#import "SwaggerModel.h"
#import "Utils.h"
#import "NSString+Hash.h"

@implementation SwaggerParam

- (BOOL)isValid {
    return (self.key && self.type);
}

- (NSString *)codeString:(BOOL)isRequest {
    if (!self.key || !self.type) {
        return @"";
    }
    if (isRequest == NO && ([self.key isEqualToString:@"msg"] || [self.key isEqualToString:@"code"] || [self.key isEqualToString:@"subCode"] || [self.key isEqualToString:@"subMsg"] || [self.key isEqualToString:@"pageSize"] || [self.key isEqualToString:@"hasNextPage"] || [self.key isEqualToString:@"hasPreviousPage"] || [self.key isEqualToString:@"total"] || [self.key isEqualToString:@"pageNum"])) {
        return @"";
    }
    
    NSString *flag = @"optional";
    if ([self.inType isEqualToString:@"path"]) {
        flag = @"path";
    } else if ([self.inType isEqualToString:@"query"]) {
        flag = @"query";
    } else if ([self.type isEqualToString:@"array"] && [self.sourceData.allKeys containsObject:@"items"]) {
        NSString *ref = [[self.sourceData objectForKey:@"items"] objectForKey:@"$ref"];
        if (ref) {
            self.type = [[ref componentsSeparatedByString:@"/"] lastObject];
        }
        if ([self.type isEqualToString:@"array"]) {
            self.type = @"id";
        }
        flag = @"repeated";
    }
    if ([self.type isEqualToString:@"boolean"]) {
        self.type = @"bool";
    }
    return [NSString stringWithFormat:@"\t%@ %@ %@ = nil;//%@\n", flag, self.type, [self.key isEqualToString:@"id"]?@"idId(id)":self.key, self.summary];
}

@end

@implementation SwaggerModel

- (NSString *)responseObj {
    if (_responseObj == nil || _responseObj.length == 0) {
        _responseObj = @"BaseCollection";
    }
    return _responseObj;
}

- (NSString *)operationPath {
    _operationPath = self.basePath;
    NSArray<NSString *> *list = [[_operationPath componentsSeparatedByString:@"/"] reverseObjectEnumerator].allObjects;
    _operationPath = @"";
    __block BOOL sstop = NO;
    _operationId = [NSString stringWithFormat:@"_%@", [[NSString stringWithFormat:@"%@%@", self.basePath, _operationId].md5String substringToIndex:8]];
    [list enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj && obj.length != 0) {
            _operationId = [NSString stringWithFormat:@"%@%@", obj, _operationId];
            *stop = sstop;
            sstop = YES;
        }
    }];
    _operationPath = [NSString stringWithFormat:@"%@%@%@", self.pre, _operationPath, self.operationId];
    
    while ([_operationPath rangeOfString:@"{"].location != NSNotFound || [_operationPath rangeOfString:@"}"].location != NSNotFound) {
        _operationPath = [[_operationPath stringByReplacingOccurrencesOfString:@"{" withString:@""] stringByReplacingOccurrencesOfString:@"}" withString:@""];
    }
    _operationPath = [_operationPath stringByReplacingOccurrencesOfString:@"UsingPOST" withString:@""];
    _operationPath = [_operationPath stringByReplacingOccurrencesOfString:@"UsingGET" withString:@""];
    
    return _operationPath;
}

- (NSString *)basePath {
    while ([_basePath hasSuffix:@"/"] || [_basePath hasPrefix:@"/"] || [_basePath hasSuffix:@"}"]) {
        if ([_basePath hasSuffix:@"/"]) {
            _basePath = [_basePath substringToIndex:_basePath.length-1];
        }
        if ([_basePath hasPrefix:@"/"]) {
            _basePath = [_basePath substringFromIndex:1];
        }
        if ([_basePath hasSuffix:@"}"]) {
            NSString *lastParams = [_basePath componentsSeparatedByString:@"/"].lastObject;
            _basePath = [_basePath stringByReplacingOccurrencesOfString:lastParams withString:@""];
        }
    }
    
    return _basePath;
}

- (NSMutableArray<SwaggerParam *> *)params {
    if (!_params) {
        _params = [[NSMutableArray alloc] init];
    }
    return _params;
}

@end
