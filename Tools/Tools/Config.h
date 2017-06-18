//
// PPConfig.h 
//
// Created By 项普华 Version: 2.0
// Copyright (C) 2016/09/13  By AlexXiang  All rights reserved.
// email:// 496007302@qq.com  tel:// +86 13316987488 
//
//

#ifndef XPHProject_Config_h
#define XPHProject_Config_h


#ifndef __has_feature
#define __has_feature(x) 0
#endif


#define HOST_NAME @""
#define BASE_URL @""

#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;
#define LocalString(param) NSLocalizedString(param, nil)

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

/**
 *    @brief	DEBUG模式的输出
 */
#if !defined(DEBUG) || DEBUG == 0

#define PHLogInfo(...) do {} whle (0)
#define PHLogInfoINFO(...) do {} while (0)
#define PHLogInfoERROR(...) do {} while (0)
#define XXLOG do {} while (0)
#define ERRORS(msg)  do{} while(0)

#define IS_DEBUG NO


#elif DEBUG >= 1

#define PHLogInfo(...) NSLog(__VA_ARGS__)
#define PHLogInfoERROR(...) NSLog(__VA_ARGS__)
#define PHLogInfoINFO(...) do {} while (0)
#define XXLOG NSLog(@"-->> <<%@>> -->> <<%@>> ", self.class, NSStringFromSelector(_cmd));
#define ERRORS(msg)  [WToast showWithText:msg];

#define IS_DEBUG YES


#endif // DEBUG

/**
 *	@brief	判断设备是否是模拟器
 */
#if TARGET_IPHONE_SIMULATOR
#define SIMULATOR 1
#elif TARGET_OS_IPHONE
#define SIMULATOR 0
#endif

/**
 *	@brief	16进制颜色的使用 事例: UIColorFromRGB(0x0000FF00)
 */
#define UIColorRGBAString(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF000000) >> 32))/255.0 green:((float)((rgbValue & 0xFF0000) >> 16))/255.0 blue:((float)((rgbValue & 0xFF00) >> 8))/255.0 alpha:((float)(rgbValue & 0xFF))/255.0]

/**
 *	@brief	10进制颜色的使用
 */
#define UIColorRGBA(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

#define mas_all(targetView, superview) [targetView mas_makeConstraints:^(MASConstraintMaker *make) { make.top.equalTo(superview.mas_top).with.offset(0); make.bottom.equalTo(superview.mas_bottom).with.offset(0); make.left.equalTo(superview.mas_left).with.offset(0); make.right.equalTo(superview.mas_right).with.offset(0); }];

#define STORYBOARD(storyboardName) [UIStoryboard storyboardWithName:storyboardName bundle:nil]


#endif
