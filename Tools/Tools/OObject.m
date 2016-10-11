
@implementation OObject

- (id)init {
    self = [super init];
    if (!self) {
        CCLOG(@"%@   初始化失败", NSStringFromClass([self class]));
    }
    return self;
}

+ (id)parseFromDictionary:(NSDictionary *)sender {
    if (![sender isKindOfClass:[NSDictionary class]]) {
        CCLOG(@"Product +++++++++++++++MODEL+++++++++++++ 解析非字典类");
        return [self init];
    }
    return [[[[self class] alloc] init] parseFromDictionary:sender];
}

- (id)parseFromDictionary:(NSDictionary *)sender {
    if (![self init]) {
        CCLOG(@"Product +++++++++++++++MODEL+++++++++++++ 初始化失败");
    }
    if (![sender isKindOfClass:[NSDictionary class]]) {
        CCLOG(@"Product +++++++++++++++MODEL+++++++++++++ 解析非字典类");
        return self;
    }
    return self;
}


- (NSMutableDictionary *)dictionaryValue {
    NSMutableDictionary *dictionaryValue = [[NSMutableDictionary alloc] init];
    return dictionaryValue;
}

- (BOOL)saveForKey:(NSString *)sender {
    NSDictionary *dictionaryValue = [self dictionaryValue];
    [[NSUserDefaults standardUserDefaults] setObject:dictionaryValue forKey:sender];
    BOOL saveResult = [[NSUserDefaults standardUserDefaults] synchronize];
    return saveResult;
}

+ (id)findForKey:(NSString *)sender {
    if (![[NSUserDefaults standardUserDefaults] objectForKey:sender]) {
        return nil;
    }
    NSDictionary *findDictionary = [[NSUserDefaults standardUserDefaults] dictionaryForKey:sender];
    if (![findDictionary isKindOfClass:[NSDictionary class]]) {
        CCLOG(@"Product +++++++++++++++MODEL+++++++++++++ 查找数据出错");
        return nil;
    }
    OObject *findResult = [[self class] parseFromDictionary:findDictionary];
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
+ (id)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareObject = [[[self class] alloc] init];
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
        ((OObject *)[OObject shareInstance]).dbPath = [NSString stringWithFormat:@"%@/database.db", dirPath];
    });
    return ((OObject *)[OObject shareInstance]).dbPath;
}

@end

