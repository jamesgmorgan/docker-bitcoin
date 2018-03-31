#!/bin/bash -e

bitcoin_version="0.16.0"
url="https://bitcoin.org/bin/bitcoin-core-${bitcoin_version}/SHA256SUMS.asc"
archive="bitcoin-${bitcoin_version}-x86_64-linux-gnu.tar.gz"
bitcoin_sha256=$(curl --silent $url | awk -v a="$archive" '$2==a {print $1}')

docker build --build-arg bitcoin_version=${bitcoin_version} --build-arg bitcoin_sha256=${bitcoin_sha256} . -t jamesgmorgan/bitcoind
