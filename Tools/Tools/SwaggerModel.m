//
//  SwaggerModel.m
//  Tools
//
//  Created by 項普華 on 2019/12/12.
//  Copyright © 2019 Alex xiang. All rights reserved.
//

#import "SwaggerModel.h"

@implementation SwaggerParam

- (BOOL)isValid {
    return (self.key && self.type);
}

- (NSString *)codeString {
    if (!self.key || !self.type) {
        return @"";
    }
    if ([self.key isEqualToString:@"body"] || [self.key isEqualToString:@"message"] || [self.key isEqualToString:@"code"]) {
        return @"";
    }
    if ([self.type isEqualToString:@"array"] && [self.sourceData.allKeys containsObject:@"items"]) {
        NSString *ref = [[self.sourceData objectForKey:@"items"] objectForKey:@"$ref"];
        if (ref) {
            self.type = [[ref componentsSeparatedByString:@"/"] lastObject];
        }
        return [NSString stringWithFormat:@"\trepeated %@ %@ = nil;//%@\n", self.type, self.key, self.summary];;
    }
    
    return [NSString stringWithFormat:@"\toptional %@ %@ = nil;//%@\n", self.type, self.key, self.summary];
}

@end

@implementation SwaggerModel

- (NSString *)responseObj {
    if (_responseObj == nil || _responseObj.length == 0) {
        _responseObj = @"BaseCollection";
    }
    return _responseObj;
}

- (NSString *)operationId {
    _operationId = self.basePath;
    NSArray<NSString *> *list = [[_operationId componentsSeparatedByString:@"/"] reverseObjectEnumerator].allObjects;
    _operationId = @"";
    __block BOOL sstop = NO;
    [list enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj && obj.length != 0) {
            _operationId = [NSString stringWithFormat:@"%@%@", obj, _operationId];
            *stop = sstop;
            sstop = YES;
        }
    }];
    _operationId = [NSString stringWithFormat:@"%@%@", self.pre, _operationId];
    return _operationId;
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
