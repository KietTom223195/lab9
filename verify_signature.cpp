#include <iostream>
#include <fstream>
#include <vector>
#include <openssl/evp.h>
#include <openssl/pem.h>
#include <openssl/err.h>

void printOpenSSLError(const std::string& msg) {
    std::cerr << "[LOI] " << msg << std::endl;
    ERR_print_errors_fp(stderr);
}

int main(int argc, char* argv[]) {
    std::string msgFile = (argc > 1) ? argv[1] : "message.txt";
    std::string pubFile = (argc > 2) ? argv[2] : "public_key.pem";
    std::string sigFile = (argc > 3) ? argv[3] : "signature.bin";

    std::ifstream mfs(msgFile, std::ios::binary);
    if (!mfs) { std::cerr << "Khong mo duoc " << msgFile << "\n"; return 1; }
    std::vector<unsigned char> message((std::istreambuf_iterator<char>(mfs)), {});
    mfs.close();

    std::ifstream sfs(sigFile, std::ios::binary);
    if (!sfs) { std::cerr << "Khong mo duoc " << sigFile << "\n"; return 1; }
    std::vector<unsigned char> sig((std::istreambuf_iterator<char>(sfs)), {});
    sfs.close();

    FILE* pubF = fopen(pubFile.c_str(), "r");
    if (!pubF) { std::cerr << "Khong mo duoc " << pubFile << "\n"; return 1; }
    EVP_PKEY* pkey = PEM_read_PUBKEY(pubF, nullptr, nullptr, nullptr);
    fclose(pubF);
    if (!pkey) { printOpenSSLError("Doc khoa cong khai that bai"); return 1; }

    EVP_MD_CTX* mdctx = EVP_MD_CTX_new();
    if (!mdctx) { printOpenSSLError("EVP_MD_CTX_new that bai"); EVP_PKEY_free(pkey); return 1; }

    int result = 0;
    if (EVP_DigestVerifyInit(mdctx, nullptr, EVP_sha256(), nullptr, pkey) <= 0) {
        printOpenSSLError("DigestVerifyInit that bai"); goto cleanup;
    }
    if (EVP_DigestVerifyUpdate(mdctx, message.data(), message.size()) <= 0) {
        printOpenSSLError("DigestVerifyUpdate that bai"); goto cleanup;
    }
    result = EVP_DigestVerifyFinal(mdctx, sig.data(), sig.size());
    if (result == 1) std::cout << "VALID" << std::endl;
    else if (result == 0) std::cout << "INVALID" << std::endl;
    else { printOpenSSLError("DigestVerifyFinal that bai"); }

cleanup:
    EVP_MD_CTX_free(mdctx);
    EVP_PKEY_free(pkey);
    return (result == 1) ? 0 : 1;
}
