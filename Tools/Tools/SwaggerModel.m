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
    return [NSString stringWithFormat:@"\toptional %@ %@ = nil;//%@\n", self.type, self.key, self.summary];
}

@end

@implementation SwaggerModel

- (NSString *)operationId {
    _operationId = self.basePath;
    while ([_operationId rangeOfString:@"/"].location != NSNotFound) {
        _operationId = [_operationId stringByReplacingOccurrencesOfString:@"/" withString:@""];
    }
    return _operationId;
}

- (NSString *)basePath {
    while ([_basePath hasSuffix:@"/"]) {
        _basePath = [_basePath substringToIndex:_basePath.length-1];
    }
    while ([_basePath hasPrefix:@"/"]) {
        _basePath = [_basePath substringFromIndex:1];
    }
    while ([_basePath hasSuffix:@"}"]) {
        NSString *lastParams = [_basePath componentsSeparatedByString:@"/"].lastObject;
        _basePath = [_basePath stringByReplacingOccurrencesOfString:lastParams withString:@""];
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
