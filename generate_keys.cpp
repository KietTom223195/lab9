#include <iostream>
#include <openssl/rsa.h>
#include <openssl/pem.h>
#include <openssl/err.h>
#include <openssl/evp.h>

void printOpenSSLError(const std::string& msg) {
    std::cerr << "[LOI] " << msg << std::endl;
    ERR_print_errors_fp(stderr);
}

int main() {
    EVP_PKEY_CTX* ctx = EVP_PKEY_CTX_new_id(EVP_PKEY_RSA, nullptr);
    if (!ctx) { printOpenSSLError("Khong the tao EVP_PKEY_CTX"); return 1; }
    if (EVP_PKEY_keygen_init(ctx) <= 0) { printOpenSSLError("keygen_init that bai"); EVP_PKEY_CTX_free(ctx); return 1; }
    if (EVP_PKEY_CTX_set_rsa_keygen_bits(ctx, 2048) <= 0) { printOpenSSLError("set_bits that bai"); EVP_PKEY_CTX_free(ctx); return 1; }

    EVP_PKEY* pkey = nullptr;
    if (EVP_PKEY_keygen(ctx, &pkey) <= 0) { printOpenSSLError("keygen that bai"); EVP_PKEY_CTX_free(ctx); return 1; }
    EVP_PKEY_CTX_free(ctx);

    FILE* privFile = fopen("private_key.pem", "w");
    if (!privFile) { std::cerr << "Khong mo duoc private_key.pem\n"; EVP_PKEY_free(pkey); return 1; }
    if (!PEM_write_PrivateKey(privFile, pkey, nullptr, nullptr, 0, nullptr, nullptr)) {
        printOpenSSLError("Ghi khoa bi mat that bai"); fclose(privFile); EVP_PKEY_free(pkey); return 1;
    }
    fclose(privFile);

    FILE* pubFile = fopen("public_key.pem", "w");
    if (!pubFile) { std::cerr << "Khong mo duoc public_key.pem\n"; EVP_PKEY_free(pkey); return 1; }
    if (!PEM_write_PUBKEY(pubFile, pkey)) {
        printOpenSSLError("Ghi khoa cong khai that bai"); fclose(pubFile); EVP_PKEY_free(pkey); return 1;
    }
    fclose(pubFile);

    std::cout << "OK:" << EVP_PKEY_get_bits(pkey) << std::endl;
    EVP_PKEY_free(pkey);
    return 0;
}
