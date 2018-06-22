//
//  Utils.m
//  XXUtils
//
//  Created by Shanke on 15/2/4.
//  Copyright (c) 2015年 Alex Xiang 496007302@qq.com. All rights reserved.
//

#import "Utils.h"
#include <sys/sysctl.h>
#import <CommonCrypto/CommonDigest.h>
#import <UIKit/UIKit.h>


@implementation Utils


/**
 *	@brief	判断邮箱的基本验证 有效返回YES 无效返回NO
 *	@param 	email  待验证的邮箱字符串
 *  @result  返回邮箱验证的结果  有效返回YES 无效返回NO
 */
BOOL emailValidate(NSString *email)
{
    if([email rangeOfString:@"@"].location==NSNotFound || [email rangeOfString:@"."].location==NSNotFound){
        return NO;
    }
    
    NSString *accountName=[email substringToIndex: [email rangeOfString:@"@"].location];
    email=[email substringFromIndex:[email rangeOfString:@"@"].location+1];
    if([email rangeOfString:@"."].location==NSNotFound)
        return NO;
    NSString *domainName=[email substringToIndex:[email rangeOfString:@"."].location];
    
    NSString *subDomain=[email substringFromIndex:[email rangeOfString:@"."].location+1];
    
    NSString *unWantedInUName = @" ~!@#$^&*()={}[]|;':\"<>,?/`";
    NSString *unWantedInDomain = @" ~!@#$%^&*()={}[]|;':\"<>,+?/`";
    NSString *unWantedInSub = @" `~!@#$%^&*()={}[]:\";'<>,?/1234567890";
    
    if(!(subDomain.length>=2 && subDomain.length<=6))
        return NO;
    
    if([accountName isEqualToString:@""] || [accountName rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:unWantedInUName]].location!=NSNotFound || [domainName isEqualToString:@""] || [domainName rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:unWantedInDomain]].location!=NSNotFound || [subDomain isEqualToString:@""] || [subDomain rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:unWantedInSub]].location!=NSNotFound)
        return NO;
    
    return YES;
}

/**
 *	@brief	16进制颜色值转化为颜色
 *	@param 	color 16进制颜色值
 *  @result  返回该颜色值对应的颜色
 */
UIColor* colorWithHexString(NSString *color)
{
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor clearColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    
    //r
    NSString *rString = [cString substringWithRange:range];
    
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
}

/**
 *	@brief	截取屏幕图片
 *	@param 	要截取的屏幕View
 *  @result  返回截取的图片
 */
UIImage *imageFromView(UIView *orgView){
    UIGraphicsBeginImageContext(orgView.bounds.size);
    [orgView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

/**
 * @brief 验证手机号码
 * @params 要验证得手机号
 * @result 验证得结果
 */
BOOL validateUserPhone(NSString *str)
{
    NSString *regex = @"^((1[3,5,8][0-9])|(147)|(15[^4,\\D])|(18[0,5-9]))\\d{8}$";
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    BOOL isMatch = [pred evaluateWithObject:str];
    
    if (isMatch) {
        return YES;
    }
    else
    {
        return NO;
    }
}
/**
 * @brief 检测字符串的有效性
 * @param 要检测的字符串
 * @result 返回检测结果
 */
BOOL validateString(NSString *param)
{
    if ([param isKindOfClass:[NSNull class]] || [param isEqualToString:@"(null)"] || param.length == 0){
        return NO;
    }
    return YES;
}
/**
 * @brief MD5加密
 */
NSString *md5(NSString *psd)
{
    const char*cStr =[psd UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, strlen(cStr), result);
    return[NSString stringWithFormat:
           @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
           result[0], result[1], result[2], result[3],
           result[4], result[5], result[6], result[7],
           result[8], result[9], result[10], result[11],
           result[12], result[13], result[14], result[15]
           ];
}
/**
 * @brief 适配ImageView
 */
BOOL adaptImageView(UIImageView *imageView)
{
    CGPoint center = imageView.center;
    CGRect frame = imageView.frame;
    frame.size = sizeWithImage(imageView.frame.size, imageView.image.size);
    imageView.frame = frame;
    imageView.center = center;
    [imageView setNeedsDisplay];
    return YES;
}

/**
 * @brief 图片大小的适配
 */
CGSize sizeWithImage(CGSize originalSize, CGSize imageSize)
{
    CGSize result = originalSize;
    
    if (imageSize.width/imageSize.height == originalSize.width/originalSize.height) {
        return result;
    }
    
    if (imageSize.width/imageSize.height < originalSize.width/originalSize.height) {
        result.height = originalSize.height;
        result.width = result.height*imageSize.width/imageSize.height;
    }
    else {
        result.width = originalSize.width;
        result.height = result.width*imageSize.height/imageSize.width;
    }
    
    return result;
}

@end
