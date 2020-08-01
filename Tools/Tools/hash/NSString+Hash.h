//
//  NSString+Hash.h
//  YLT_Crypto
//
//  Created by YLT on 2017/10/13.
//

#import <Foundation/Foundation.h>

@interface NSString (Hash)

#pragma mark - 散列函数
/**
 MD5 加密
 * 终端命令测试
 * md5 -s "string"
 @return 加密后字串
 */
- (NSString *)md5String;

/**
 SHA1 加密
 * 终端命令测试
 * echo -n "string" | openssl dgst -sha1
 @return 加密后字串
 */
- (NSString *)sha1String;

/**
 计算SHA256散列结果
 *
 * 终端测试命令：
 * echo -n "string" | openssl dgst -sha256
 @return 加密后字串
 */
- (NSString *)sha256String;

/**
 计算SHA 512散列结果
 *
 * 终端测试命令：
 * echo -n "string" | openssl dgst -sha512
 @return 128个字符的SHA 512散列字符串
 */
- (NSString *)sha512String;

#pragma mark - HMAC 散列函数
/**
 计算HMAC MD5散列结果
 *
 * 终端测试命令：
 * echo -n "string" | openssl dgst -md5 -hmac "key"
 @return 32个字符的HMAC MD5散列字符串
 */
- (NSString *)hmacMD5StringWithKey:(NSString *)key;

/**
 计算HMAC SHA1散列结果
 *
 * 终端测试命令：
 * echo -n "string" | openssl dgst -sha1 -hmac "key"
 @return 40个字符的HMAC SHA1散列字符串
 */
- (NSString *)hmacSHA1StringWithKey:(NSString *)key;

/**
 计算HMAC SHA256散列结果
 *
 * 终端测试命令：
 * echo -n "string" | openssl dgst -sha256 -hmac "key"
 @return 64个字符的HMAC SHA256散列字符串
 */
- (NSString *)hmacSHA256StringWithKey:(NSString *)key;

/**
 计算HMAC SHA512散列结果
 *
 * 终端测试命令：
 * echo -n "string" | openssl dgst -sha512 -hmac "key"
 @return 128个字符的HMAC SHA512散列字符串
 */
- (NSString *)hmacSHA512StringWithKey:(NSString *)key;

#pragma mark - 文件散列函数

/**
 计算文件的MD5散列结果
 *
 * 终端测试命令：
 * md5 file.dat
 @return 32个字符的MD5散列字符串
 */
- (NSString *)fileMD5Hash;

/**
 计算文件的SHA1散列结果
 *
 * 终端测试命令：
 * openssl dgst -sha1 file.dat
 *
 @return 40个字符的SHA1散列字符串
 */
- (NSString *)fileSHA1Hash;

/**
 计算文件的SHA256散列结果
 *
 * 终端测试命令：
 * openssl dgst -sha256 file.dat
 @return 64个字符的SHA256散列字符串
 */
- (NSString *)fileSHA256Hash;

/**
 计算文件的SHA512散列结果
 *
 * 终端测试命令：
 * openssl dgst -sha512 file.dat
 @return 128个字符的SHA512散列字符串
 */
- (NSString *)fileSHA512Hash;

@end
