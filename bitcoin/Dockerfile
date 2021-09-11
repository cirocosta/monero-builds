# syntax = docker/dockerfile:1.3

ARG DEBIAN_IMAGE=debian:bullseye
ARG DISTROLESS_IMAGE=gcr.io/distroless/base-debian11:nonroot

FROM ${DEBIAN_IMAGE} AS debian
FROM ${DISTROLESS_IMAGE} AS base


#
#	make available the number of parallel jobs that we want to run
#	whenever we can
#
FROM debian AS nproc

	ARG NPROC
	RUN test -z "$NPROC" && nproc > /nproc || echo -n "$NPROC" > /nproc


#
#	setup build dependencies
#
FROM debian AS builder

	ENV DEBIAN_FRONTEND=noninteractive

	RUN set -ex && \
	    apt-get update && \
	    apt-get --no-install-recommends --yes install \
		automake \
		autotools-dev \
		bsdmainutils \
		build-essential \
		ca-certificates \
		clang \
		curl \
		git \
		libboost-dev \
		libboost-filesystem-dev \
		libboost-system-dev \
		libboost-test-dev \
		libevent-dev \
		libtool \
		pkg-config \
		python3

	ENV CXX=clang++
	ENV CC=clang

	COPY --from=nproc /nproc /nproc



FROM builder AS bitcoin

	WORKDIR /src

	ARG BITCOIN_REPOSITORY=https://github.com/bitcoin/bitcoin
	ARG BITCOIN_REVISION

	RUN set -ex && \
		git clone    $BITCOIN_REPOSITORY . && \
		git checkout $BITCOIN_REVISION

	RUN set -ex && \
		./autogen.sh && \
		./configure CXX=clang++ CC=clang \
			--without-bdb \
			--without-miniupnpc \
			--without-natpmp \
			--without-gui \
			--enable-hardening

	RUN make -j$(cat /nproc)


FROM base AS final

	COPY --from=bitcoin /lib/x86_64-linux-gnu/libgcc_s.so.1 			/lib/x86_64-linux-gnu/
	COPY --from=bitcoin /usr/lib/x86_64-linux-gnu/libboost_filesystem.so.1.74.0  	/usr/lib/x86_64-linux-gnu/
	COPY --from=bitcoin /usr/lib/x86_64-linux-gnu/libboost_system.so.1.74.0      	/usr/lib/x86_64-linux-gnu/
	COPY --from=bitcoin /usr/lib/x86_64-linux-gnu/libevent-2.1.so.7              	/usr/lib/x86_64-linux-gnu/
	COPY --from=bitcoin /usr/lib/x86_64-linux-gnu/libevent_core-2.1.so.7 		/usr/lib/x86_64-linux-gnu/
	COPY --from=bitcoin /usr/lib/x86_64-linux-gnu/libevent_pthreads-2.1.so.7     	/usr/lib/x86_64-linux-gnu/
	COPY --from=bitcoin /usr/lib/x86_64-linux-gnu/libstdc++.so.6                 	/usr/lib/x86_64-linux-gnu/

	COPY --from=bitcoin /src/src/bitcoind 		/usr/local/bin/bitcoind
	COPY --from=bitcoin /src/src/bitcoin-cli 	/usr/local/bin/bitcoin-cli
	COPY --from=bitcoin /src/src/bitcoin-tx 	/usr/local/bin/bitcoin-tx
	COPY --from=bitcoin /src/src/bitcoin-util 	/usr/local/bin/bitcoin-util
