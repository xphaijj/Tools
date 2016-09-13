
@interface OObject : NSObject<NSCopying> {
}
@property (readwrite, nonatomic, strong) NSString *dbPath;

- (id)init;
+ (id)parseFromDictionary:(NSDictionary *)sender;
- (id)parseFromDictionary:(NSDictionary *)sender;

- (NSMutableDictionary *)dictionaryValue;
- (BOOL)saveForKey:(NSString *)sender;
+ (id)findForKey:(NSString *)sender;

- (id)copyWithZone:(NSZone *)zone;
- (void)copyOperationWithObject:(id)object;

+ (id)shareInstance;
+ (NSString *)initialDB;

@end
