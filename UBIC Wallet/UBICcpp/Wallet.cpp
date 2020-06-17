
#include <openssl/ossl_typ.h>
#include <openssl/obj_mac.h>
#include <openssl/bn.h>
#include <openssl/evp.h>
#include <vector>
#include <openssl/rand.h>
#include <openssl/pem.h>
#include "Wallet.h"
#include "Base58.h"
#include "Tools/Hexdump.h"
#include "Crypto/Sha256.h"
#include "Crypto/Ripemd160.h"
#include "Crypto/CreateSignature.h"
#include "AddressHelper.h"
#include "Address.h"
#include "Crypto/ECCtools.h"
#include "Transaction/TransactionHelper.h"
#include "Crypto/Hash256.h"
#include "Tools/Log.h"
#include "Config.h"
#include "FS/FS.h"
#include "Scripts/PkhInScript.h"

void Wallet::setSeed(std::vector<unsigned char> newSeed) {
    this->seed = newSeed;
}

bool Wallet::generateWallet() {

    std::vector<unsigned char> currentPrivKey = this->seed;

    Config& config = Config::Instance();

    Log(LOG_LEVEL_INFO) << "Going to import " << config.getNumberOfAdresses() << " addresses";
    for(int i = 0; i < config.getNumberOfAdresses(); i++) {

        currentPrivKey = Hash256::hash256(FS::concatPaths(currentPrivKey, this->seed));

        EVP_PKEY* privateKey = EVP_PKEY_new();

        BIGNUM* keyBn = BN_new();
        BN_bin2bn(currentPrivKey.data(), (int)currentPrivKey.size(), keyBn);
        EC_KEY* ecKey = EC_KEY_new();
        EC_KEY_set_group(ecKey, Wallet::getDefaultEcGroup());
        EC_KEY_set_private_key(ecKey, keyBn);

        EC_POINT* pubKey = EC_POINT_new(Wallet::getDefaultEcGroup());
        BN_CTX* ctx = BN_CTX_new();
        EC_POINT_mul(Wallet::getDefaultEcGroup(), pubKey, keyBn, NULL, NULL, ctx);
        EC_KEY_set_public_key(ecKey, pubKey);

        EVP_PKEY_assign_EC_KEY(privateKey, ecKey);

        EC_KEY *privateEcKey = EVP_PKEY_get1_EC_KEY(privateKey);
        const BIGNUM* privateKeyBN = EC_KEY_get0_private_key(privateEcKey);
        unsigned char privateKeyChar[256];
        int length = BN_bn2bin(privateKeyBN, privateKeyChar);
        this->privateKeys.emplace_back(std::vector<unsigned char>(privateKeyChar, privateKeyChar+length));
        //Log(LOG_LEVEL_INFO) << "added privateKey " << Hexdump::ucharToHexString(privateKeyChar, length);

        const EC_POINT* pubKeyPoint = EC_KEY_get0_public_key(privateEcKey);

        std::vector<unsigned char> pubkeyVector = ECCtools::ecPointToVector(Wallet::getDefaultEcGroup(), pubKeyPoint);
        this->publicKeys.emplace_back(pubkeyVector);
        //Log(LOG_LEVEL_INFO) << "added pubkeyVector " << pubkeyVector;

        Address address = Wallet::addressFromPublicKey(pubkeyVector);
        this->addressesScript.emplace_back(address.getScript().getScript());
        //Log(LOG_LEVEL_INFO) << "added addressScript " << address.getScript().getScript();

        std::vector<unsigned char> addressLink = AddressHelper::addressLinkFromScript(address.getScript());
        this->addressesLink.emplace_back(addressLink);
        Log(LOG_LEVEL_INFO) << "added addressLink " << addressLink;
    }

    return true;
}

bool Wallet::initWallet() {
    this->privateKeys = std::vector< std::vector<unsigned char> >();
    this->publicKeys = std::vector< std::vector<unsigned char> >();
    this->addressesScript = std::vector< std::vector<unsigned char> >();
    this->addressesLink = std::vector< std::vector<unsigned char> >();

    return this->generateWallet();
}

std::vector<unsigned char> Wallet::signWithAddress(std::vector<unsigned char> address, std::vector<unsigned char> msg) {
    std::vector< std::vector<unsigned char> >::iterator addressIt = std::find(this->addressesLink.begin(), this->addressesLink.end(), address);
    if(addressIt != this->addressesLink.end()) {
        uint32_t index = (uint32_t)(addressIt - this->addressesLink.begin());
        std::vector<unsigned char> privateKey = (std::vector<unsigned char>)this->privateKeys.at(index);
        Log(LOG_LEVEL_INFO) << "Sign with private key: " << privateKey;
        return CreateSignature::sign(privateKey, msg);
    } else {
        Log(LOG_LEVEL_ERROR) << "Address not found " << address;
        return std::vector<unsigned char> ();
    }
}

std::vector<unsigned char> Wallet::sign(std::vector<unsigned char> msg) {
    std::vector<unsigned char> privateKey = (std::vector<unsigned char>)this->privateKeys.at(0);
    return CreateSignature::sign(privateKey, msg);
}

std::vector<unsigned char> Wallet::getRandomPrivateKeyFromWallet() {
    unsigned char randCharArr[4];
    RAND_bytes(randCharArr, 4);
    uint32_t randNbr = *reinterpret_cast<uint32_t*>(randCharArr);
    uint32_t selectedNbr = (uint32_t) (randNbr % this->privateKeys.size());

    return this->privateKeys.at(selectedNbr);
}

std::vector<unsigned char> Wallet::getRandomAddressScriptVectorFromWallet() {
    unsigned char randCharArr[4];
    RAND_bytes(randCharArr, 4);
    uint32_t randNbr = *reinterpret_cast<uint32_t*>(randCharArr);
    uint32_t selectedNbr = (uint32_t) (randNbr % this->addressesScript.size());

    return this->addressesScript.at(selectedNbr);
}

Address Wallet::getRandomAddressFromWallet() {
    std::vector<unsigned char> pkhScript =  Wallet::getRandomAddressScriptVectorFromWallet();
    Address address;

    UScript script;
    script.setScriptType(SCRIPT_PKH);
    script.setScript(pkhScript);
    address.setScript(script);

    return address;
}

Transaction* Wallet::signTransaction(Transaction* transaction) {
    std::vector<unsigned char> txId = TransactionHelper::getTxId(transaction);
    std::vector<TxIn> txInList;
    for(TxIn txIn: transaction->getTxIns()) {

        std::vector<unsigned char> signature = this->signWithAddress(txIn.getInAddress(), txId);

        PkhInScript pkhInScript;
        pkhInScript.setPublicKey(this->getPublicKeyFromAddressLink(txIn.getInAddress()));
        pkhInScript.setSignature(signature);
        pkhInScript.setVersion(PKH_SECP256K1_VERSION);
        CDataStream s(SER_DISK, 1);
        s << pkhInScript;

        Log(LOG_LEVEL_INFO) << "pkhInScript: " << s;
        Log(LOG_LEVEL_INFO) << "pubkey: " << this->getPublicKeyFromAddressLink(txIn.getInAddress());
        Log(LOG_LEVEL_INFO) << "signature: " << signature;

        UScript script;
        script.setScriptType(SCRIPT_PKH);
        script.setScript(std::vector<unsigned char>(s.data(), s.data() + s.size()));
        txIn.setScript(script);
        txInList.emplace_back(txIn);
    }
    transaction->setTxIns(txInList);

    return transaction;
}

UScript Wallet::getRandomPKHScriptFromWallet() {
    std::vector<unsigned char> randomAddressScript = this->getRandomAddressScriptVectorFromWallet();
    UScript script;
    script.setScript(randomAddressScript);
    script.setScriptType(SCRIPT_PKH);

    return script;
}

bool Wallet::isMine(std::vector<unsigned char> scriptLink) {
    std::vector<std::vector<unsigned char> >::iterator addressIt = std::find(this->addressesLink.begin(),
                                                                             this->addressesLink.end(),
                                                                             scriptLink);
    return addressIt != this->addressesLink.end();
}

std::vector<unsigned char> Wallet::getPublicKeyFromAddressLink(std::vector<unsigned char> address) {
    std::vector< std::vector<unsigned char> >::iterator addressIt = std::find(this->addressesLink.begin(), this->addressesLink.end(), address);
    if(addressIt != this->addressesLink.end()) {
        uint32_t index = (uint32_t) (addressIt - this->addressesLink.begin());
        return this->publicKeys.at(index);
    }

    return std::vector<unsigned char>();
}

Address Wallet::addressFromPublicKey(std::vector<unsigned char> publicKey) {
    std::vector<unsigned char> sha256 = Sha256::sha256(publicKey);
    std::vector<unsigned char> ripemd160 = Ripemd160::ripemd160(sha256);

    UScript* script = new UScript();
    script->setScriptType(SCRIPT_PKH);
    script->setScript(ripemd160);

    Address* addressObj = new Address();
    addressObj->setScript(*script);
    return *addressObj;
}

Address Wallet::addressFromPrivateKey(EVP_PKEY *privateKey) {

    EC_KEY *privateEcKey = EVP_PKEY_get1_EC_KEY(privateKey);
    const BIGNUM* privateKeyBN = EC_KEY_get0_private_key(privateEcKey);
    unsigned char privateKeyChar[256];
    int length = BN_bn2bin(privateKeyBN, privateKeyChar);

    const EC_POINT* pubKeyPoint = EC_KEY_get0_public_key(privateEcKey);

    std::vector<unsigned char> pubkeyVector = ECCtools::ecPointToVector(Wallet::getDefaultEcGroup(), pubKeyPoint);

    Address address = Wallet::addressFromPublicKey(pubkeyVector);

    return address;
}

std::vector<unsigned char> Wallet::addressVectorFromAddress(Address address) {
    CDataStream s(SER_DISK, 1);
    s << address;

    std::vector<unsigned char> addressVector((unsigned char*)s.data(), (unsigned char*)s.data() + s.size());
    return addressVector;
}

std::string Wallet::readableAddressFromAddress(Address address) {
    std::vector<unsigned char> addressVector = Wallet::addressVectorFromAddress(address);
    Log(LOG_LEVEL_INFO) << "addressVector:" << addressVector;
    std::vector<unsigned char> checksum = Hash256::hash256(FS::concatPaths(addressVector, "UBIC"));
    addressVector.insert(addressVector.end(), checksum.begin(), checksum.begin() + 3);

    return Base58::EncodeBase58(addressVector.data(), addressVector.data() + addressVector.size());
}

void Wallet::readableAddresstoCharAddress(std::string readableAddress, unsigned char* address, uint8_t *addressLength) {
    Base58::DecodeBase58((unsigned char*)readableAddress.c_str(), address, addressLength);
}

bool Wallet::verifyReadableAddressChecksum(std::string readableAddress) {
    Wallet& wallet = Wallet::Instance();
    std::vector<unsigned char> readableAddressVector = wallet.readableAddressToVectorAddressWithChecksum(readableAddress);
    std::vector<unsigned char> readableAddressVectorWithoutChecksum(
            readableAddressVector.begin(),
            readableAddressVector.begin() + (readableAddressVector.size() - 3)
    );

    std::vector<unsigned char> readableAddressVectorChecksum(
            readableAddressVector.begin() + (readableAddressVector.size() - 3),
            readableAddressVector.begin() + readableAddressVector.size()
    );

    Log(LOG_LEVEL_INFO) << "readableAddressVector:" << readableAddressVector;
    Log(LOG_LEVEL_INFO) << "readableAddressVectorWithoutChecksum:" << readableAddressVectorWithoutChecksum;
    Log(LOG_LEVEL_INFO) << "readableAddressVectorChecksum:" << readableAddressVectorChecksum;

    std::vector<unsigned char> entireChecksum = Hash256::hash256(FS::concatPaths(readableAddressVectorWithoutChecksum, "UBIC"));
    Log(LOG_LEVEL_INFO) << "entireChecksum:" << entireChecksum;

    std::vector<unsigned char> checksum(
            entireChecksum.begin(),
            entireChecksum.begin() + 3
    );
    Log(LOG_LEVEL_INFO) << "checksum:" << checksum;

    return readableAddressVectorChecksum == checksum;
}

std::vector<unsigned char> Wallet::readableAddressToVectorAddressWithChecksum(std::string readableAddress) {
    unsigned char address[10000];
    uint8_t addressLength;
    Base58::DecodeBase58((unsigned char*)readableAddress.c_str(), address, &addressLength);

    return std::vector<unsigned char>(address, address + addressLength);
}

std::vector<unsigned char> Wallet::readableAddressToVectorAddress(std::string readableAddress) {
    std::vector<unsigned char> addressWithChecksum = readableAddressToVectorAddressWithChecksum(readableAddress);
    std::vector<unsigned char> vectorAddress(
            addressWithChecksum.begin(),
            addressWithChecksum.begin() + (addressWithChecksum.size() - 3)
    );

    return vectorAddress;
}

EC_GROUP *Wallet::getDefaultEcGroup() {
    EC_GROUP *ecGroup = EC_GROUP_new_by_curve_name(NID_secp256k1);
    EC_GROUP_set_asn1_flag(ecGroup, OPENSSL_EC_NAMED_CURVE);
    point_conversion_form_t form = POINT_CONVERSION_UNCOMPRESSED;
    EC_GROUP_set_point_conversion_form(ecGroup, form);

    return ecGroup;
}

bool Wallet::generatePrivateKey(EVP_PKEY *privateKey) {
    EC_KEY* ecKey = EC_KEY_new();
    EC_KEY_set_group(ecKey, Wallet::getDefaultEcGroup());
    EC_KEY_generate_key(ecKey);
    EVP_PKEY_assign_EC_KEY(privateKey,ecKey);

    return true;
}

std::vector<std::vector<unsigned char> > Wallet::getAddressesScript() {
    return addressesScript;
}

std::vector<std::vector<unsigned char> > Wallet::getAddressesLink() {
    return addressesLink;
}
