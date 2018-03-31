FROM debian:stretch-slim

ARG bitcoin_version
ARG bitcoin_sha256

RUN groupadd -r bitcoin && useradd -r -m -g bitcoin bitcoin

RUN set -ex \
    && apt-get update \
    && apt-get install -qq --no-install-recommends ca-certificates dirmngr gosu gpg wget \
    && rm -rf /var/lib/apt/lists/*

ENV BITCOIN_VERSION ${bitcoin_version}
ENV BITCOIN_URL https://bitcoin.org/bin/bitcoin-core-${bitcoin_version}/bitcoin-${bitcoin_version}-x86_64-linux-gnu.tar.gz
ENV BITCOIN_SHA256 ${bitcoin_sha256}
ENV BITCOIN_ASC_URL https://bitcoin.org/bin/bitcoin-core-${bitcoin_version}/SHA256SUMS.asc
ENV BITCOIN_PGP_KEY 01EA5486DE18A882D4C2684590C8019E36C2E964

# install bitcoin binaries
RUN set -ex \
    && cd /tmp \
    && wget -qO bitcoin.tar.gz "$BITCOIN_URL" \
    && echo "$BITCOIN_SHA256 bitcoin.tar.gz" | sha256sum -c - \
    && gpg --keyserver keyserver.ubuntu.com --recv-keys "$BITCOIN_PGP_KEY" \
    && wget -qO bitcoin.asc "$BITCOIN_ASC_URL" \
    && gpg --verify bitcoin.asc \
    && tar -xzvf bitcoin.tar.gz -C /usr/local --strip-components=1 --exclude=*-qt \
    && rm -rf /tmp/*

# create data directory
ENV BITCOIN_DATA /data
RUN mkdir "$BITCOIN_DATA" \
    && chown -R bitcoin:bitcoin "$BITCOIN_DATA" \
    && ln -sfn "$BITCOIN_DATA" /home/bitcoin/.bitcoin \
    && chown -h bitcoin:bitcoin /home/bitcoin/.bitcoin
VOLUME /data

COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 8332 8333 18332 18333
CMD ["bitcoind"]