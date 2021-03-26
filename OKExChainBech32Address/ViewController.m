//
//  ViewController.m
//  OKExChainBech32Address
//
//  Created by Xing on 2021/3/26.
//

#import "ViewController.h"
#import "Bech32.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString* bech32Address = @"okexchain1rn30p0rkrlgmhcdek3dug2r96zx4vq956pz77q";
    NSString* hexAddress = @"0x1cE2F0bc761Fd1bbe1b9B45bc42865D08D5600b4";
    
    Bech32* b = [[Bech32 alloc]init];
    
    //covert 0x address to okexchain address
    @try {
        NSString* bech32Address = [b convertHexToBech32:hexAddress prefix:@"okexchain"];
        NSLog(@"convertHexToBech32: %@",bech32Address);
    } @catch (NSException *exception) {
        NSLog(@"%@",exception.reason);
    }
    
    // covert okexchain address to 0x address
    @try {
        Bech32Data* dataModel = [b convertBech32ToHex:bech32Address];
        NSLog(@"convertBech32ToHex: %@",dataModel.address);
        NSLog(@"convertBech32ToHex: %@",dataModel.prefix);
    } @catch (NSException *exception) {
        NSLog(@"%@",exception.reason);
    }
    
}
@end
