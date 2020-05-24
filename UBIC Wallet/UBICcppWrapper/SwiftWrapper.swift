
import Foundation

class SwiftWrapper {
    
    static func getAddress(seed: Data) -> String {
        return OCWrapper.getAddress(seed);
    }
    
    static func getPassportTransaction(seed: Data, sod: Data) -> String {
        return OCWrapper.getPassportTransaction(seed, sod:sod);
    }
    
    static func getPassportTransaction(seed: Data,
                                       readableAddress: String,
                                       currency: Int32,
                                       amount: UInt64,
                                       fee: UInt64,
                                       nonce: Int32) -> String {
    return OCWrapper.getTransaction(seed,
            readableAddress:readableAddress,
                   currency:currency,
                     amount:amount,
                        fee:fee,
                      nonce: nonce)
    }
    
    static func getKycTransaction(seed: Data,
                                  sodFile: Data,
                                  dg1File: Data,
                                  dg2File: Data,
                                  mode: Int,
                                  challenge: String) -> String {
    return OCWrapper.getKycTransaction(seed,
                  sodFile:sodFile,
                  dg1File:dg1File,
                  dg2File:dg2File,
                  mode:Int32(mode),
                     challenge:challenge)
    }
}
