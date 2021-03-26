//
//  Bech32Data.m
//  
//
//  Created by Xing on 2021/3/23.
//  Copyright © 2021 Xing. All rights reserved.
//

#import "Bech32Data.h"

@implementation Bech32Data

-(instancetype)initWithPrefix:(NSString*)prefix address:(NSString*)address{
    self = [super init];
    if (self) {
        _prefix = prefix;
        _address = address;
    }
    return self;
}

@end
