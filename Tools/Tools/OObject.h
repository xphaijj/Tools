#import <Foundation/Foundation.h>

@interface OObject : NSObject<NSCopying> {
}
@property (readwrite, nonatomic, strong) NSString *dbPath;

- (id)init;
+ (OObject *)parseFromDictionary:(NSDictionary *)sender;
- (OObject *)parseFromDictionary:(NSDictionary *)sender;

- (NSDictionary *)dictionaryValue;
- (BOOL)saveForKey:(NSString *)sender;
+ (OObject *)findForKey:(NSString *)sender;

- (id)copyWithZone:(NSZone *)zone;
- (void)copyOperationWithObject:(id)object;

+ (OObject *)shareInstance;
+ (NSString *)initialDB;

@end
