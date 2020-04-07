//
//  Nativelib.h
//  UBIC Wallet
//
//  Created by Jan Moritz on 13.10.19.
//  Copyright © 2019 Bondi. All rights reserved.
//

#ifndef Nativelib_h
#define Nativelib_h

#include <string>

class Nativelib {
public:
    static std::string getAddress(unsigned char* seed);
    static std::string getPassportTransaction(unsigned char* seed, unsigned char* sod, int sodLen);
    static std::string getTransaction(unsigned char* seed, std::string readableAddress, int currency, uint64_t amount, uint64_t fee, int nonce);
    static std::string getKycTransaction(
            unsigned char*  seed,
            unsigned char*  sodFile,
            int sodFileSize,
            unsigned char*  dg1File,
            int dg1FileSize,
            unsigned char*  dg2File,
            int dg2FileSize,
            int mode,
            std::string challenge);
};

#endif /* Nativelib_h */
