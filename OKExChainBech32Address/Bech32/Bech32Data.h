//
//  Bech32Data.h
//  
//
//  Created by Xing on 2021/3/23.
//  Copyright © 2021 Xing. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Bech32Data : NSObject

-(instancetype)initWithPrefix:(NSString*)prefix address:(NSString*)address;

@property(nonatomic,readonly)NSString* address;

@property(nonatomic,readonly)NSString* prefix;

@end

NS_ASSUME_NONNULL_END
