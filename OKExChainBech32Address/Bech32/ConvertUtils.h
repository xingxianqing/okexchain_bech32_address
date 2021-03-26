//
//  ConvertUtils.h
//  
//
//  Created by Xing on 2021/3/23.
//  Copyright © 2019 Xing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConvertUtils : NSObject

//16进制转换为NSData
+ (NSData*)convertHexStrToData:(NSString*)str;

//NSData转换为16进制
+ (NSString*)convertDataToHexStr:(NSData*)data;

@end
