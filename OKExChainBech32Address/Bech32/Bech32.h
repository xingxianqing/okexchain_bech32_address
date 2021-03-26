//
//  Bech32.h
//  
//
//  Created by Xing on 2021/3/23.
//  Copyright © 2021 Xing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Bech32Data.h"

NS_ASSUME_NONNULL_BEGIN


@interface Bech32 : NSObject


// covert okexchain address to 0x address
-(Bech32Data*)convertBech32ToHex:(NSString*)address;

//covert 0x address to okexchain address
-(NSString*)convertHexToBech32:(NSString*)hexAddress prefix:(NSString* _Nullable)prefix;

@end

NS_ASSUME_NONNULL_END
