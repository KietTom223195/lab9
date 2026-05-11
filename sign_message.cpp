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
    std::string msgFile  = (argc > 1) ? argv[1] : "message.txt";
    std::string keyFile  = (argc > 2) ? argv[2] : "private_key.pem";
    std::string sigFile  = (argc > 3) ? argv[3] : "signature.bin";

    // Doc noi dung file message
    std::ifstream ifs(msgFile, std::ios::binary);
    if (!ifs) { std::cerr << "Khong mo duoc " << msgFile << "\n"; return 1; }
    std::vector<unsigned char> message((std::istreambuf_iterator<char>(ifs)), {});
    ifs.close();

    // Doc khoa bi mat
    FILE* keyF = fopen(keyFile.c_str(), "r");
    if (!keyF) { std::cerr << "Khong mo duoc " << keyFile << "\n"; return 1; }
    EVP_PKEY* pkey = PEM_read_PrivateKey(keyF, nullptr, nullptr, nullptr);
    fclose(keyF);
    if (!pkey) { printOpenSSLError("Doc khoa bi mat that bai"); return 1; }

    // Tao chu ky SHA-256 + RSA
    EVP_MD_CTX* mdctx = EVP_MD_CTX_new();
    if (!mdctx) { printOpenSSLError("EVP_MD_CTX_new that bai"); EVP_PKEY_free(pkey); return 1; }

    if (EVP_DigestSignInit(mdctx, nullptr, EVP_sha256(), nullptr, pkey) <= 0) {
        printOpenSSLError("DigestSignInit that bai"); goto cleanup;
    }
    if (EVP_DigestSignUpdate(mdctx, message.data(), message.size()) <= 0) {
        printOpenSSLError("DigestSignUpdate that bai"); goto cleanup;
    }

    {
        size_t sigLen = 0;
        if (EVP_DigestSignFinal(mdctx, nullptr, &sigLen) <= 0) {
            printOpenSSLError("DigestSignFinal (lay do dai) that bai"); goto cleanup;
        }
        std::vector<unsigned char> sig(sigLen);
        if (EVP_DigestSignFinal(mdctx, sig.data(), &sigLen) <= 0) {
            printOpenSSLError("DigestSignFinal that bai"); goto cleanup;
        }

        std::ofstream ofs(sigFile, std::ios::binary);
        if (!ofs) { std::cerr << "Khong mo duoc " << sigFile << "\n"; goto cleanup; }
        ofs.write(reinterpret_cast<char*>(sig.data()), sigLen);
        ofs.close();

        std::cout << "OK:" << sigLen << std::endl;
    }

cleanup:
    EVP_MD_CTX_free(mdctx);
    EVP_PKEY_free(pkey);
    return 0;
}
