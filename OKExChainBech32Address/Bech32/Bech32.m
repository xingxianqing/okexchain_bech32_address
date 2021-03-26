//
//  Bech32.m
//  
//
//  Created by Xing on 2021/3/23.
//  Copyright © 2021 Xing. All rights reserved.
//

#import "Bech32.h"
#import "ConvertUtils.h"


static NSString* ALPHABET = @"qpzry9x8gf2tvdw0s3jn54khce6mua7l";

static NSDictionary* ALPHABET_MAP;

@implementation Bech32

-(instancetype)init{
    self = [super init];
    if (self) {
        NSMutableDictionary* dic = [NSMutableDictionary dictionary];
        for (int i = 0; i < ALPHABET.length; i++) {
            [dic setValue:[NSNumber numberWithInt:i] forKey:[ALPHABET substringWithRange:NSMakeRange(i, 1)]];
        }
        ALPHABET_MAP = dic;
    }
    return self;
}

-(int)polymodStep:(int)pre{
    int b = pre >> 25;
    return ((pre & 0x1FFFFFF) << 5) ^
    (-((b >> 0) & 1) & 0x3b6a57b2) ^
    (-((b >> 1) & 1) & 0x26508e6d) ^
    (-((b >> 2) & 1) & 0x1ea119fa) ^
    (-((b >> 3) & 1) & 0x3d4233dd) ^
    (-((b >> 4) & 1) & 0x2a1462b3);
}

-(int)prefixChk:(NSString*)prefix {
    int chk = 1;
    for (int i = 0; i < prefix.length; ++i) {
        char c = [prefix characterAtIndex:i];
        if ((c < 33 || c > 126)) {
            @throw [NSException exceptionWithName:@"prefixChk_1" reason:@"Invalid prefix" userInfo:nil];
        }
        chk = [self polymodStep:chk] ^ (c >> 5);
    }
    chk = [self polymodStep:chk];
    for (int i = 0; i < prefix.length; ++i) {
        char v = [prefix characterAtIndex:i];
        chk = [self polymodStep:chk] ^ (v & 0x1f);
    }
    return chk;
}

-(NSString*)convertHexToBech32:(NSString*)hexAddress prefix:(NSString* _Nullable)prefix{
    if (prefix == nil) { prefix = @"okexchain";}
    prefix = prefix.lowercaseString;
    NSString* p = [hexAddress substringWithRange:NSMakeRange(0, 2)];
    if ([p isEqualToString:@"0x"]) {
        hexAddress = [hexAddress substringWithRange:NSMakeRange(2, hexAddress.length-2)];
    }
    hexAddress = hexAddress.lowercaseString;

    NSData* data = [ConvertUtils convertHexStrToData:hexAddress];
    NSData* words = [self convert:data inBits:8 outBits:5 pad:YES];
    
    if ((prefix.length + 7 + words.length) > 90) {
        @throw [NSException exceptionWithName:@"bech32_encode_1" reason:@"Exceeds length limit" userInfo:nil];
    }

    uint8_t * bytePtr = (uint8_t  * )[words bytes];

  // determine chk mod
    int chk = [self prefixChk:prefix];
    NSString* result = [prefix stringByAppendingString:@"1"];
    for (int i = 0; i < words.length; ++i) {
        int x = bytePtr[i];
        if ((x >> 5) != 0) {
            @throw [NSException exceptionWithName:@"bech32_encode_2" reason:@"Non 5-bit word" userInfo:nil];
        }
        chk = [self polymodStep:chk] ^ x;
        result = [NSString stringWithFormat:@"%@%c",result,[ALPHABET characterAtIndex:x]];
    }
    
    for (int i = 0; i < 6; ++i) {
        chk = [self polymodStep:chk];
    }
    chk ^= 1;
    
    for (int i = 0; i < 6; ++i) {
        int v = (chk >> ((5 - i) * 5)) & 0x1f;
        result = [NSString stringWithFormat:@"%@%c",result,[ALPHABET characterAtIndex:v]];
    }
    
    return result;
}

-(Bech32Data*)convertBech32ToHex:(NSString*)address{
    if (address.length < 8) {
        @throw [NSException exceptionWithName:@"bech32_decode_1"
                                       reason:[NSString stringWithFormat:@"%@ too short",address]
                                     userInfo:nil];
    }
    if (address.length > 90) {
        @throw [NSException exceptionWithName:@"bech32_decode_2"
                                       reason:@"Exceeds length limit"
                                     userInfo:nil];
    }

  // don't allow mixed case
    NSString* lowered = address.lowercaseString;
    NSString* uppered = address.uppercaseString;
    if (![address isEqualToString:lowered] && ![address isEqualToString:uppered]){
        @throw [NSException exceptionWithName:@"bech32_decode_3"
                                       reason:[NSString stringWithFormat:@"Mixed-case string %@ ",address]
                                     userInfo:nil];
    }
    address = lowered;
    
    if (![address containsString:@"1"]) {
        @throw [NSException exceptionWithName:@"bech32_decode_4"
                                       reason:[NSString stringWithFormat:@"No separator character for %@ ",address]
                                     userInfo:nil];
    }
    NSUInteger split = [address rangeOfString:@"1"].location;
    if (split <= 0) {
        @throw [NSException exceptionWithName:@"bech32_decode_5"
                                       reason:[NSString stringWithFormat:@"Missing prefix for %@ ",address]
                                     userInfo:nil];
    }
    NSString* prefix = [address substringWithRange:NSMakeRange(0, split)];
    NSString* wordChars = [address substringFromIndex:split+1];
    
    if (wordChars.length < 6){
        @throw [NSException exceptionWithName:@"bech32_decode_6"
                                       reason:@"Data too short"
                                     userInfo:nil];
    }

    int chk = [self prefixChk:prefix];
    
    NSMutableData *words = [[NSMutableData alloc] initWithCapacity:89];
    for (int i = 0; i < wordChars.length; ++i) {
        char c = [wordChars characterAtIndex:i];
        NSString* key = [NSString stringWithFormat:@"%c",c];
        if(![[ALPHABET_MAP allKeys] containsObject:key]){
            @throw [NSException exceptionWithName:@"bech32_decode_7"
                                           reason:[NSString stringWithFormat:@"Unknown character %@ ",key]
                                         userInfo:nil];
        };
        int v = [[ALPHABET_MAP objectForKey:key]intValue];
        chk = [self polymodStep:chk] ^ v;
        
        // not in the checksum?
        if (i + 6 >= wordChars.length) {
            continue;
        }
        [words appendData:[NSData dataWithBytes:&v length:1]];
    }

    if (chk != 1) {
        @throw [NSException exceptionWithName:@"bech32_decode_8"
                                       reason:[NSString stringWithFormat:@"Invalid checksum for %@ ",address]
                                     userInfo:nil];
    }
    NSData* resultData = [self convert:words inBits:5 outBits:8 pad:NO];
    NSString* addr = [NSString stringWithFormat:@"0x%@",[ConvertUtils convertDataToHexStr:resultData]];
    return [[Bech32Data alloc]initWithPrefix:prefix address:addr];
}

-(NSData*)convert:(NSData*)data inBits:(int)inBits outBits:(int)outBits pad:(BOOL)pad{
    int value = 0;
    int bits = 0;
    int maxV = (1 << outBits) - 1;
  
    uint8_t * bytePtr = (uint8_t  * )[data bytes];

    NSMutableData *result = [[NSMutableData alloc] initWithCapacity:89];
    for (int i = 0; i < data.length; ++i) {
        value = (value << inBits) | (int)bytePtr[i];
        bits += inBits;

        while (bits >= outBits) {
            bits -= outBits;
            int a = (value >> bits) & maxV;
            [result appendData:[NSData dataWithBytes:&a length:1]];
        }
    }
    if (pad) {
        if (bits > 0) {
            int a = (value << (outBits - bits)) & maxV;
            [result appendData:[NSData dataWithBytes:&a length:1]];
        }
    } else {
        if ((bits >= inBits)) {
            @throw [NSException exceptionWithName:@"bech32_convert_1"
                                           reason:@"Excess padding"
                                         userInfo:nil];
        }
        if (((value << (outBits - bits)) & maxV)) {
            @throw [NSException exceptionWithName:@"bech32_convert_2"
                                           reason:@"Non-zero padding"
                                         userInfo:nil];
        }
    }
    return result;
}

@end

