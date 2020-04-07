#include <openssl/ossl_typ.h>
#include <vector>

#ifndef NTPESK_NTPRSKSIGNATUREREQUESTOBJECT_H
#define NTPESK_NTPRSKSIGNATUREREQUESTOBJECT_H

#endif //NTPESK_NTPRSKSIGNATUREREQUESTOBJECT_H

class NtpRskSignatureRequestObject {
private:
    const BIGNUM* e;
    const BIGNUM* n;
    BIGNUM* signature;
    BIGNUM* m;
    BIGNUM* paddedM;
    BIGNUM* nm;
    RSA* rsa;
    uint16_t mdAlg;
    std::vector<unsigned char> signedPayload;
public:
    const BIGNUM *getE() const {
        return this->e;
    }
    
    void setE(const BIGNUM *e) {
        this->e = e;
    }
    
    const BIGNUM *getN() const {
        return this->n;
    }
    
    void setN(const BIGNUM *n) {
        this->n = n;
    }
    
    BIGNUM *getSignature() const {
        return this->signature;
    }
    
    void setSignature(BIGNUM *signature) {
        this->signature = signature;
    }
    
    BIGNUM *getPaddedM() {
        return paddedM;
    }
    
    void setPaddedM(BIGNUM *paddedM) {
        this->paddedM = paddedM;
    }
    
    BIGNUM *getM() const {
        return this->m;
    }
    
    void setM(BIGNUM *m) {
        this->m = m;
    }
    
    BIGNUM *getNm() const {
        return this->nm;
    }
    
    void setNm(BIGNUM *nm) {
        this->nm = nm;
    }
    
    RSA *getRsa() {
        return rsa;
    }
    
    void setRsa(RSA *rsa) {
        this->rsa = rsa;
    }
    
    uint16_t getMdAlg() const {
        return mdAlg;
    }
    
    void setMdAlg(uint16_t mdAlg) {
        NtpRskSignatureRequestObject::mdAlg = mdAlg;
    }
    
    const std::vector<unsigned char> &getSignedPayload() const {
        return signedPayload;
    }
    
    void setSignedPayload(const std::vector<unsigned char> &signedPayload) {
        NtpRskSignatureRequestObject::signedPayload = signedPayload;
    }
};
