#import "OCWrapper.h"
//#include <string.h>
#include "../UBICcpp/Nativelib.h"

@implementation OCWrapper

+ (NSString*) getAddress:(NSData*) seed {
    auto address = Nativelib::getAddress((unsigned char*)[seed bytes]);
    
    return @(address.c_str());
}

+ (NSString*) getPassportTransaction:(NSData*) seed
                                 sod:(NSData*)sod {
    auto passportTransaction = Nativelib::getPassportTransaction(
        (unsigned char*)[seed bytes],
        (unsigned char*)[sod bytes],
        (int) [sod length]
    );
    
    return @(passportTransaction.c_str());
}

+ (NSString*) getTransaction:(NSData*)seed
             readableAddress:(NSString*) readableAddress
                    currency:(int) currency
                      amount:(UInt64) amount
                      fee:(UInt64) fee
                       nonce:(int) nonce   {
    NSLog(@"amount: %d fee: %d", amount, fee);
    auto transactionString = Nativelib::getTransaction(
        (unsigned char*)[seed bytes],
        std::string([readableAddress UTF8String]),
        currency,
        (uint64_t) amount,
        (uint64_t) fee,
        nonce
    );
    
    return @(transactionString.c_str());
}

+ (NSString*) getKycTransaction:(NSData*)seed
                        sodFile:(NSData*) sodFile
                        dg1File:(NSData*) dg1File
                        dg2File:(NSData*) dg2File
                           mode:(int) mode
          challenge:(NSString*) challenge   {

    auto transactionString = Nativelib::getKycTransaction(
            (unsigned char*)[seed bytes],
            (unsigned char*)[sodFile bytes],
            (int) [sodFile length],
            (unsigned char*)[dg1File bytes],
            (int) [dg1File length],
            (unsigned char*)[dg2File bytes],
            (int) [dg2File length],
            (int) mode,
            std::string([challenge UTF8String]));
    
    return @(transactionString.c_str());
}

@end
