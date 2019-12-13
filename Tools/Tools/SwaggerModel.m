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

- (NSMutableArray<SwaggerParam *> *)params {
    if (!_params) {
        _params = [[NSMutableArray alloc] init];
    }
    return _params;
}

@end
