//
//  SwaggerModel.h
//  Tools
//
//  Created by 項普華 on 2019/12/12.
//  Copyright © 2019 Alex xiang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SwaggerParam : NSObject

/** <#注释#> */
@property (nonatomic, strong) NSString *type;
/** <#注释#> */
@property (nonatomic, strong) NSString *key;
/** <#注释#> */
@property (nonatomic, strong) NSString *summary;

- (BOOL)isValid;

- (NSString *)codeString;

@end


@interface SwaggerModel : NSObject

/** <#注释#> */
@property (nonatomic, strong) NSString *host;
/** <#注释#> */
@property (nonatomic, strong) NSString *basePath;
/** <#注释#> */
@property (nonatomic, strong) NSString *method;
/** 注解 */
@property (nonatomic, strong) NSString *summary;
/** <#注释#> */
@property (nonatomic, strong) NSString *operationId;
/** <#注释#> */
@property (nonatomic, strong) NSMutableArray<SwaggerParam *> *params;
/** <#注释#> */
@property (nonatomic, strong) NSString *responseObj;

@end

NS_ASSUME_NONNULL_END
