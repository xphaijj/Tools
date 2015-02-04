//
// Model
//
// Created By 项普华 Version: 1.0
// Copyright (C) 2015/02/03  By AlexXiang  All rights reserved.
// email:// 496007302@qq.com  tel:// +86 13316987488
//
//

#ifndef XXUtils_XXConfig_h
#define XXUtils_XXConfig_h

#ifndef __has_feature
#define __has_feature(x) 0
#endif
#if __has_feature(objc_arc)
#define IF_ARC(with, without) with
#else
#define IF_ARC(with, without) without
#endif

#define $new(Klass) IF_ARC([[Klass alloc] init], [[[Klass alloc] init] autorelease])
#define $eql(a,b)   [(a) isEqual:(b)]

#define $arr(...)   [NSArray arrayWithObjects:__VA_ARGS__, nil]
#define $marr(...)  [NSMutableArray arrayWithObjects:__VA_ARGS__, nil]
#define $marrnew    [NSMutableArray array]
#define $set(...)   [NSSet setWithObjects:__VA_ARGS__, nil]
#define $mset(...)  [NSMutableSet setWithObjects:__VA_ARGS__, nil]
#define $msetnew    [NSMutableSet set]
#define $dict(...)  [NSDictionary dictionaryWithObjectsAndKeys:__VA_ARGS__, nil]
#define $mdict(...) [NSMutableDictionary dictionaryWithObjectsAndKeys:__VA_ARGS__, nil]
#define $mdictnew   [NSMutableDictionary dictionary]
#define $str(...)   [NSString stringWithFormat:__VA_ARGS__]
#define $mstr(...)  [NSMutableString stringWithFormat:__VA_ARGS__]
#define $mstrnew    [NSMutableString string]

#define $bool(val)      [NSNumber numberWithBool:(val)]
#define $char(val)      [NSNumber numberWithChar:(val)]
#define $double(val)    [NSNumber numberWithDouble:(val)]
#define $float(val)     [NSNumber numberWithFloat:(val)]
#define $int(val)       [NSNumber numberWithInt:(val)]
#define $integer(val)   [NSNumber numberWithInteger:(val)]
#define $long(val)      [NSNumber numberWithLong:(val)]
#define $longlong(val)  [NSNumber numberWithLongLong:(val)]
#define $short(val)     [NSNumber numberWithShort:(val)]
#define $uchar(val)     [NSNumber numberWithUnsignedChar:(val)]
#define $uint(val)      [NSNumber numberWithUnsignedInt:(val)]
#define $uinteger(val)  [NSNumber numberWithUnsignedInteger:(val)]
#define $ulong(val)     [NSNumber numberWithUnsignedLong:(val)]
#define $ulonglong(val) [NSNumber numberWithUnsignedLongLong:(val)]
#define $ushort(val)    [NSNumber numberWithUnsignedShort:(val)]

#define $nonretained(val) [NSValue valueWithNonretainedObject:(val)]
#define $pointer(val)     [NSValue valueWithPointer:(val)]
#define $point(val)       [NSValue valueWithPoint:(val)]
#define $range(val)       [NSValue valueWithRange:(val)]
#define $rect(val)        [NSValue valueWithRect:(val)]
#define $size(val)        [NSValue valueWithSize:(val)]

#define $safe(obj)        ((NSNull *)(obj) == [NSNull null] ? nil : (obj))


/**
 *	@brief	DEBUG模式的输出
 */
#if !defined(DEBUG) || DEBUG == 0
#define CCLOG(...) do {} while (0)
#define CCLOGINFO(...) do {} while (0)
#define CCLOGERROR(...) do {} while (0)
#define XXLOG do {} while (0)

#elif DEBUG == 1
#define CCLOG(...) NSLog(__VA_ARGS__)
#define CCLOGERROR(...) NSLog(__VA_ARGS__)
#define CCLOGINFO(...) do {} while (0)
#define XXLOG NSLog(@"-->> <<%@>> -->> <<%@>> ", self.class, NSStringFromSelector(_cmd));

#elif DEBUG > 1
#define CCLOG(...) NSLog(__VA_ARGS__)
#define CCLOGERROR(...) NSLog(__VA_ARGS__)
#define CCLOGINFO(...) NSLog(__VA_ARGS__)
#define XXLOG NSLog(@"-->> <<%@>> -->> <<%@>> ", self.class, NSStringFromSelector(_cmd));
#endif // DEBUG


#define LocalString(param) NSLocalizedString(param, nil)

/**
 *	@brief	判断设备是否是模拟器
 */
#if TARGET_IPHONE_SIMULATOR
#define SIMULATOR 1
#elif TARGET_OS_IPHONE
#define SIMULATOR 0
#endif

/**
 *	@brief	16进制颜色的使用 事例: UIColorFromRGB(0x0000FF)
 */
#define UIColorRGBString(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

/**
 *	@brief	10进制颜色的使用
 */
#define UIColorRGB(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]


/**
 * @brief  判断设备是否是iPad
 **/
#define [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad

/**
 * @brief 获取版本号
 */
#define OSVersion [[[UIDevice currentDevice] systemVersion] integerValue]

#endif
