CXX      = g++
CXXFLAGS = -std=c++17 -Wall -O2
LIBS     = -lssl -lcrypto

all: generate_keys sign_message verify_signature

generate_keys: generate_keys.cpp
	$(CXX) $(CXXFLAGS) -o $@ $< $(LIBS)

sign_message: sign_message.cpp
	$(CXX) $(CXXFLAGS) -o $@ $< $(LIBS)

verify_signature: verify_signature.cpp
	$(CXX) $(CXXFLAGS) -o $@ $< $(LIBS)

demo: all
	@echo "=== DEMO RSA Lab ==="
	./generate_keys
	echo "Day la thong diep thu nghiem RSA SHA-256." > message.txt
	./sign_message
	./verify_signature
	@echo "=== Tamper test ==="
	echo "Tin nhan gia mao" > tampered.txt
	./verify_signature tampered.txt public_key.pem signature.bin || true

clean:
	rm -f generate_keys sign_message verify_signature
	rm -f *.pem *.bin message.txt tampered.txt
