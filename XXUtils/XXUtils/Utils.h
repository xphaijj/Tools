//
//  Utils.h
//  XXUtils
//
//  Created by Shanke on 15/2/4.
//  Copyright (c) 2015年 Alex Xiang 496007302@qq.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Utils : NSObject

/**
 *	@brief	判断邮箱的基本验证 有效返回YES 无效返回NO
 *
 *	@param 	email  待验证的邮箱字符串
 *  @result  返回邮箱验证的结果  有效返回YES 无效返回NO
 */
BOOL emailValidate(NSString *email);

/**
 *	@brief	16进制颜色值转化为颜色
 *	@param 	color 16进制颜色值
 *  @result  返回该颜色值对应的颜色
 */
UIColor *colorWithHexString(NSString *color);

/**
 *	@brief	截取屏幕图片
 *	@param 	要截取的屏幕View
 *  @result  返回截取的图片
 */
UIImage *imageFromView(UIView *orgView);

/**
 * @brief 验证手机号码
 * @params 要验证得手机号
 * @result 验证得结果
 */
BOOL validateUserPhone(NSString *str);

/**
 * @brief 检测字符串的有效性
 * @param 要检测的字符串
 * @result 返回检测结果
 */
BOOL validateString(NSString *param);

/**
 * @brief MD5加密
 */
NSString *md5(NSString *psd);

/**
 * @brief 适配ImageView
 */
BOOL adaptImageView(UIImageView *imageView);



@end
