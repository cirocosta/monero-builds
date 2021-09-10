# syntax = docker/dockerfile:experimental

FROM debian:bullseye AS debian
FROM gcr.io/distroless/base-debian11:nonroot AS base


#
#	make available the number of parallel jobs that we want to run
#	whenever we can
#
FROM debian AS nproc

	ARG NPROC
	RUN test -z "$NPROC" && nproc > /nproc || echo -n "$NPROC" > /nproc


# 
#	setup base build dependencies shared by most targets
#
FROM debian AS builder

	COPY --from=nproc /nproc /nproc

	ENV DEBIAN_FRONTEND=noninteractive

	RUN set -ex && \
	    apt-get update && \
	    apt-get --no-install-recommends --yes install \
		autoconf \
		automake \
		build-essential \
		ca-certificates \
		ccache \
		cmake \
		curl \
		git \
		libtool-bin

#
#	build libuv from source
#
FROM builder AS libuv

	WORKDIR /src

	ARG LIBUV_VERSION=1.42.0
	ARG LIBUV_HASH=371e5419708f6aaeb8656671f89400b92a9bba6443369af1bb70bcd6e4b3c764

	RUN set -ex \
	    && curl -sSLO https://github.com/libuv/libuv/archive/v${LIBUV_VERSION}.tar.gz \
	    && echo "${LIBUV_HASH}  v${LIBUV_VERSION}.tar.gz" | sha256sum -c \
	    && tar -xzf v${LIBUV_VERSION}.tar.gz --strip-components=1 \
	    && ./autogen.sh \
	    && ./configure --disable-shared --enable-static

	RUN make -j$(cat /nproc)


#
#	build hwloc from source
#
FROM builder AS hwloc

	WORKDIR /src

	ARG HWLOC_VERSION=2.5.0
	ARG HWLOC_HASH=38aa8102faec302791f6b4f0d23960a3ffa25af3af6af006c64dbecac23f852c

	RUN set -ex \
	    && curl -sSLO https://download.open-mpi.org/release/hwloc/v2.5/hwloc-${HWLOC_VERSION}.tar.gz \
	    && echo "${HWLOC_HASH}  hwloc-${HWLOC_VERSION}.tar.gz" | sha256sum -c \
	    && tar -xzf hwloc-${HWLOC_VERSION}.tar.gz --strip-components=1 \
	    && ./configure --disable-shared --enable-static --disable-io --disable-libudev --disable-libxml2

	RUN make -j$(cat /nproc)


#
#	build openssl from source
#
FROM builder AS openssl

	WORKDIR /src

	ARG OPENSSL_VERSION=1.1.1l
	ARG OPENSSL_HASH=0b7a3e5e59c34827fe0c3a74b7ec8baef302b98fa80088d7f9153aa16fa76bd1

	RUN set -ex \
	    && curl -s -O https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz \
	    && echo "${OPENSSL_HASH}  openssl-${OPENSSL_VERSION}.tar.gz" | sha256sum -c \
	    && tar -xzf openssl-${OPENSSL_VERSION}.tar.gz --strip-components=1 \
	    && ./config --static -no-shared -no-asm -no-zlib -no-comp -no-dgram -no-filenames -no-cms

	RUN make -j$(cat /nproc)


#
#	build xmrig from source consuming the artifacts from previous
#	dependency targets
#
FROM builder AS xmrig

	WORKDIR /src

	ARG XMRIG_REPOSITORY=https://github.com/xmrig/xmrig
	ARG XMRIG_REVISION

 	RUN set -ex && \
	    git clone ${XMRIG_REPOSITORY} . && \
	    git checkout ${XMRIG_REVISION}


	COPY --from=openssl	/src/include 			/openssl/include
	COPY --from=openssl	/src/libcrypto.a 		/openssl/lib/libcrypto.a
	COPY --from=openssl	/src/libssl.a 			/openssl/lib/libssl.a

	COPY --from=hwloc 	/src/include 			/hwloc/include
	COPY --from=hwloc 	/src/hwloc/.libs 		/hwloc/lib/

	COPY --from=libuv 	/src/include 			/uv/include
	COPY --from=libuv 	/src/.libs	 		/uv/lib


	RUN --mount=type=cache,target=/ccache \
		mkdir build && cd build && \
		cmake \
			-DBUILD_STATIC=ON \
			-DHWLOC_INCLUDE_DIR=/hwloc/include \
			-DHWLOC_LIBRARY=/hwloc/lib \
			-DOPENSSL_ROOT_DIR=/openssl \
			-DOPENSSL_INCLUDE_DIR=/openssl/include \
			-DUV_INCLUDE_DIR=/uv/include \
			-DUV_LIBRARY=/uv/lib \
			.. && \
		make -j$(cat /nproc)


# 
#	final stage that will be included in the final container image
#
#
FROM base AS final

	COPY --from=xmrig --chown=nonroot:nonroot 	/src/build/xmrig 	/usr/local/bin/
        USER nonroot:nonroot

        ENTRYPOINT [ "xmrig" ]
