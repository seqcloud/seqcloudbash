# Use latest OpenSSL stable release.
# https://www.openssl.org/source/
# 2018-09-11

date="2018-09-11"
version="1.1.1"

echo "Installing openssl ${version} (${date})"

echo "sudo is required for this script"
sudo -v

curl -O "https://www.openssl.org/source/openssl-${version}.tar.gz"
tar -xvzf "openssl-${version}.tar.gz"
cd "openssl-${version}"
./Configure darwin64-x86_64-cc
make
make test
sudo make install
cd ..

unset -v date version

cat << EOF
openssl installed successfully.
Reload the shell and check version.
which openssl
openssl version
EOF
