### okexchain 


#####covert 0x address to okexchain address


```

    @try {
        NSString* bech32Address = [b convertHexToBech32:hexAddress prefix:@"okexchain"];
        NSLog(@"convertHexToBech32: %@",bech32Address);
    } @catch (NSException *exception) {
        NSLog(@"%@",exception.reason);
    }
    
```    
    
#####covert okexchain address to 0x address


```

    @try {
        Bech32Data* dataModel = [b convertBech32ToHex:bech32Address];
        NSLog(@"convertBech32ToHex: %@",dataModel.address);
        NSLog(@"convertBech32ToHex: %@",dataModel.prefix);
    } @catch (NSException *exception) {
        NSLog(@"%@",exception.reason);
    }
    
```