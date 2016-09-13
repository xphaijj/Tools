#import "OObject.h"

@implementation OObject

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

+ (OObject *)parseFromDictionary:(NSDictionary *)sender {
    return [[[OObject alloc] init] parseFromDictionary:sender];
}

- (OObject *)parseFromDictionary:(NSDictionary *)sender {
    if (![self init]) {
        NSLog(@"Product +++++++++++++++MODEL+++++++++++++ 初始化失败");
    }
    if (![sender isKindOfClass:[NSDictionary class]]) {
        NSLog(@"Product +++++++++++++++MODEL+++++++++++++ 解析非字典类");
        return self;
    }
    return self;
}


- (NSDictionary *)dictionaryValue {
    NSMutableDictionary *dictionaryValue = [[NSMutableDictionary alloc] init];
    return dictionaryValue;
}

- (BOOL)saveForKey:(NSString *)sender {
    NSDictionary *dictionaryValue = [self dictionaryValue];
    [[NSUserDefaults standardUserDefaults] setObject:dictionaryValue forKey:sender];
    BOOL saveResult = [[NSUserDefaults standardUserDefaults] synchronize];
    return saveResult;
}

+ (OObject *)findForKey:(NSString *)sender {
    NSDictionary *findDictionary = [[NSUserDefaults standardUserDefaults] dictionaryForKey:sender];
    if (![findDictionary isKindOfClass:[NSDictionary class]]) {
        NSLog(@"Product +++++++++++++++MODEL+++++++++++++ 查找数据出错");
        return nil;
    }
    
    OObject *findResult = [OObject parseFromDictionary:findDictionary];
    return findResult;
}


- (id)copyWithZone:(NSZone *)zone {
    OObject *copyObject = [[self class] allocWithZone:zone];
    [self copyOperationWithObject:copyObject];
    return copyObject;
}

- (void)copyOperationWithObject:(id)object {
}


static OObject *shareObject = nil;
+ (OObject *)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareObject = [[OObject alloc] init];
    });
    return shareObject;
}

+(NSString *)initialDB {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *dirPath = [NSString stringWithFormat:@"%@/%@", [NSSearchPathForDirectoriesInDomains(NSCachesDirectory , NSUserDomainMask , YES) lastObject], @"DB"];
        BOOL isDir = NO;
        bool existed = [[NSFileManager defaultManager] fileExistsAtPath:dirPath isDirectory:&isDir];
        if (!(isDir == YES && existed == YES)) {
            [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        [OObject shareInstance].dbPath = [NSString stringWithFormat:@"%@/database.db", dirPath];
    });
    return [OObject shareInstance].dbPath;
}

@end

