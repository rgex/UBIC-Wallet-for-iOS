#import <Foundation/Foundation.h>

@interface OCWrapper: NSObject

+ (NSString*) getAddress:(NSData*) seed;
+ (NSString*) getPassportTransaction:(NSData*) seed sod:(NSData*)sod;
+ (NSString*) getTransaction:(NSData*)seed
            readableAddress:(NSString*) readableAddress
                   currency:(int) currency
                     amount:(UInt64) amount
                        fee:(UInt64) fee
                      nonce:(int) nonce;
+ (NSString*) getKycTransaction:(NSData*)seed
              sodFile:(NSData*) sodFile
              dg1File:(NSData*) dg1File
              dg2File:(NSData*) dg2File
                 mode:(int) mode
                      challenge:(NSString*) challenge;
@end
