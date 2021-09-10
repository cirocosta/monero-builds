# syntax = docker/dockerfile:experimental

#
# 	Multistage docker build using experimental docker syntax features.
#
# 	- requires docker 17.05+
#	- {"experimental": true} on /etc/docker/daemon.json
#	- DOCKER_BUILDKIT=true
#

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

	COPY --from=nproc /nproc /nproc

	ENV DEBIAN_FRONTEND=noninteractive

	RUN set -ex && \
	    apt-get update && \
	    apt-get --no-install-recommends --yes install \
		autoconf \
		automake \
		bzip2 \
		ca-certificates \
		ccache \
		curl \
		doxygen \
		g++ \
		git \
		gperf \
		graphviz \
		libtool-bin \
		make \
		pkg-config \
		unzip \
		xsltproc \
		cmake

	ENV CFLAGS='-fPIC'
	ENV CXXFLAGS='-fPIC'



#
#	build boost from source
#
FROM builder AS boost

	ARG BOOST_VERSION=1_77_0
	ARG BOOST_VERSION_DOT=1.77.0
	ARG BOOST_HASH=fc9f85fc030e233142908241af7a846e60630aa7388de9a5fafb1f3a26840854

	RUN set -ex \
	    && curl -sSLo boost_${BOOST_VERSION}.tar.bz2 https://sourceforge.net/projects/boost/files/boost/${BOOST_VERSION_DOT}/boost_${BOOST_VERSION}.tar.bz2/download \
	    && echo "${BOOST_HASH}  boost_${BOOST_VERSION}.tar.bz2" | sha256sum -c \
	    && tar -xf boost_${BOOST_VERSION}.tar.bz2 \
	    && cd boost_${BOOST_VERSION} \
	    && mkdir /out \
	    && ./bootstrap.sh --prefix=/out \
	    && ./b2 -j $(cat /nproc) \
		--build-type=minimal  \
		--with-chrono \
		--with-date_time \
		--with-filesystem \
		--with-locale \
		--with-program_options \
		--with-regex \
		--with-serialization \
		--with-system \
		--with-thread \
		cflags="$CFLAGS" \
		cxxflags="$CXXFLAGS" \
		link=static \
		runtime-link=static \
		threadapi=pthread \
		threading=multi \
			install

#
#	build openssl from source
#
FROM builder AS openssl

	ARG OPENSSL_VERSION=1.1.1l
	ARG OPENSSL_HASH=0b7a3e5e59c34827fe0c3a74b7ec8baef302b98fa80088d7f9153aa16fa76bd1

	RUN set -ex \
	    && curl -s -O https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz \
	    && echo "${OPENSSL_HASH}  openssl-${OPENSSL_VERSION}.tar.gz" | sha256sum -c \
	    && tar -xzf openssl-${OPENSSL_VERSION}.tar.gz \
	    && cd openssl-${OPENSSL_VERSION} \
	    && mkdir /out \
	    && ./Configure linux-x86_64 no-shared --prefix=/out --static "$CFLAGS" \
	    && make build_generated -j$(cat /nproc) \
	    && make libcrypto.a -j$(cat /nproc) \
	    && make install_sw && make install_ssldirs -j$(cat /nproc)

#
#	build zmq from source
#
FROM builder AS zmq

	ARG ZMQ_VERSION=v4.3.4
	ARG ZMQ_HASH=4097855ddaaa65ed7b5e8cb86d143842a594eebd

	RUN set -ex \
	    && git clone https://github.com/zeromq/libzmq.git -b ${ZMQ_VERSION} \
	    && cd libzmq \
	    && test `git rev-parse HEAD` = ${ZMQ_HASH} || exit 1 \
	    && ./autogen.sh \
	    && mkdir /out \
	    && ./configure --prefix=/out --enable-static --disable-shared \
	    && make -j$(cat /nproc) \
	    && make install -j$(cat /nproc) \
	    && ldconfig

#
#	build cppzmq from source
#
FROM builder AS cppzmq

	ARG CPPZMQ_VERSION=v4.7.1
	ARG CPPZMQ_HASH=76bf169fd67b8e99c1b0e6490029d9cd5ef97666

	RUN set -ex \
	    && mkdir /out \
	    && git clone https://github.com/zeromq/cppzmq.git -b ${CPPZMQ_VERSION} \
	    && cd cppzmq \
	    && test `git rev-parse HEAD` = ${CPPZMQ_HASH} || exit 1 \
	    && mv *.hpp /out

#
#	build readline from source
#
FROM builder AS readline

	ARG READLINE_VERSION=8.1
	ARG READLINE_HASH=f8ceb4ee131e3232226a17f51b164afc46cd0b9e6cef344be87c65962cb82b02

	RUN set -ex \
	    && curl -s -O https://ftp.gnu.org/gnu/readline/readline-${READLINE_VERSION}.tar.gz \
	    && echo "${READLINE_HASH}  readline-${READLINE_VERSION}.tar.gz" | sha256sum -c \
	    && tar -xzf readline-${READLINE_VERSION}.tar.gz \
	    && cd readline-${READLINE_VERSION} \
	    && mkdir /out \
	    && ./configure --prefix=/out \
	    && make -j$(cat /nproc) \
	    && make install -j$(cat /nproc)

#
#	build sodium from source
#
FROM builder AS sodium

	ARG SODIUM_VERSION=1.0.18
	ARG SODIUM_HASH=4f5e89fa84ce1d178a6765b8b46f2b6f91216677

	RUN set -ex \
	    && git clone https://github.com/jedisct1/libsodium.git -b ${SODIUM_VERSION} \
	    && cd libsodium \
	    && test `git rev-parse HEAD` = ${SODIUM_HASH} || exit 1 \
	    && ./autogen.sh \
	    && mkdir /out \
	    && ./configure --prefix=/out \
	    && make -j$(cat /nproc) \
	    && make check -j$(cat /nproc) \
	    && make install -j$(cat /nproc)

#
#	build udev from source
#
FROM builder AS udev

	ARG UDEV_VERSION=v3.2.10
	ARG UDEV_HASH=be7068512c7512fa67c64fbff3472ab140c277c8

	RUN set -ex \
	    && git clone https://github.com/gentoo/eudev -b ${UDEV_VERSION} \
	    && cd eudev \
	    && test `git rev-parse HEAD` = ${UDEV_HASH} || exit 1 \
	    && echo "" > man/make.sh \
	    && ./autogen.sh \
	    && mkdir /out \
	    && ./configure  --prefix=/out --disable-introspection --disable-hwdb --disable-manpages \
	    && make -j$(cat /nproc) \
	    && make install -j$(cat /nproc)


#
#	build libusb from source
#
FROM builder AS libusb

	COPY --from=udev 	/out 	/usr/local

	ARG USB_VERSION=v1.0.24
	ARG USB_HASH=c6a35c56016ea2ab2f19115d2ea1e85e0edae155

	RUN set -ex \
	    && git clone https://github.com/libusb/libusb.git -b ${USB_VERSION} \
	    && cd libusb \
	    && test `git rev-parse HEAD` = ${USB_HASH} || exit 1 \
	    && ./autogen.sh \
	    && mkdir /out \
	    && ./configure --enable-static --prefix=/out \
	    && make -j$(cat /nproc) \
	    && make install -j$(cat /nproc)

#
#	build hidapi from source
#
FROM builder AS hidapi

	COPY --from=udev 	/out 				/usr/local
	COPY --from=libusb 	/out 				/usr/local
	COPY --from=libusb 	/out/include/libusb-1.0 	/usr/local/include

 	ARG HIDAPI_VERSION=hidapi-0.8.0-rc1
 	ARG HIDAPI_HASH=40cf516139b5b61e30d9403a48db23d8f915f52c

	RUN ldconfig

 	RUN set -ex \
 	    && git clone https://github.com/signal11/hidapi -b ${HIDAPI_VERSION} \
 	    && cd hidapi \
 	    && test `git rev-parse HEAD` = ${HIDAPI_HASH} || exit 1 \
	    && mkdir /out \
 	    && ./bootstrap \
 	    && ./configure --prefix=/out --enable-static \
	    && make -j$(cat /nproc) \
	    && make install -j$(cat /nproc)


#
#	build expat from source
#
 FROM builder AS libexpat

 	ARG LIBEXPAT_VERSION=2.4.1
 	ARG LIBEXPAT_VERSION_UNDERSCORE=2_4_1
 	ARG LIBEXPAT_HASH=2f9b6a580b94577b150a7d5617ad4643a4301a6616ff459307df3e225bcfbf40

 	RUN set -ex \
	    && curl -SOL https://github.com/libexpat/libexpat/releases/download/R_${LIBEXPAT_VERSION_UNDERSCORE}/expat-${LIBEXPAT_VERSION}.tar.bz2 \
	    && echo "${LIBEXPAT_HASH} expat-${LIBEXPAT_VERSION}.tar.bz2" | sha256sum -c \
	    && tar -xf expat-${LIBEXPAT_VERSION}.tar.bz2 --strip-components=1 \
	    && mkdir /out \
	    && ./configure \
	    	--enable-static \
		--disable-shared \
		--prefix=/out \
	    && make -j$(cat /nproc) \
	    && make install -j$(cat /nproc)

#
#	build unbound from source
#
 FROM builder AS unbound

 	ARG UNBOUND_VERSION=1.13.2
 	ARG UNBOUND_HASH=0a13b547f3b92a026b5ebd0423f54c991e5718037fd9f72445817f6a040e1a83

	COPY --from=libexpat 	/out 	/usr/local/libexpat
	COPY --from=openssl 	/out 	/usr/local/openssl

 	RUN set -ex \
	    && curl -SOL https://www.nlnetlabs.nl/downloads/unbound/unbound-${UNBOUND_VERSION}.tar.gz \
	    && echo "${UNBOUND_HASH} unbound-${UNBOUND_VERSION}.tar.gz" | sha256sum -c \
	    && tar xzf unbound-${UNBOUND_VERSION}.tar.gz --strip-components=1 \
	    && ./configure \
	    	--disable-shared \
		--enable-static \
		--without-pyunbound \
		--prefix=/out \
		--with-libexpat=/usr/local/libexpat \
		--with-ssl=/usr/local/openssl \
		--with-libevent=no \
		--without-pythonmodule \
		--disable-flto \
		--with-pthreads \
		--with-libunbound-only \
		--with-pic \
	    && make -j$(cat /nproc) \
	    && make install -j$(cat /nproc)


#
#	build monero from source
#
FROM builder AS monero

	WORKDIR /src

	ENV BOOST_ROOT 		/usr/local/boost
	ENV OPENSSL_ROOT_DIR	/usr/local/openssl
 	ENV USE_SINGLE_BUILDDIR 1
	ENV BOOST_DEBUG         1
	ENV CCACHE_DIR		/ccache

	ARG MONERO_REPOSITORY=https://github.com/monero-project/monero
	ARG MONERO_REVISION

 	RUN set -ex && \
	    git clone ${MONERO_REPOSITORY} . && \
	    git checkout ${MONERO_REVISION} && \
	    git submodule init && \
	    git submodule update

	COPY --from=boost   	/out 	/usr/local/boost
	COPY --from=openssl 	/out 	/usr/local/openssl
	COPY --from=zmq 	/out 	/usr/local
	COPY --from=cppzmq 	/out 	/usr/local/include
	COPY --from=readline 	/out 	/usr/local
	COPY --from=sodium 	/out 	/usr/local
	COPY --from=libusb 	/out 	/usr/local
	COPY --from=udev 	/out 	/usr/local
	COPY --from=hidapi 	/out 	/usr/local
	COPY --from=unbound 	/out 	/usr/local


	RUN ldconfig
	RUN --mount=type=cache,target=/ccache \
		make -j$(cat /nproc) release-static

	# unecessary for this stage in particular, but allows us to copy over
	# with a `chown` mutating its user so we can force a particular uid:gid
	# for that directory.
	#
	RUN mkdir /data


#
#	final stage that will be included in the container image
#
#	note.: the sha256sum of this will not necessarily match the ones
#	       produced by gitian-base builds.
#
FROM base AS final

	COPY --from=monero --chown=nonroot:nonroot /src/build/release/bin /usr/local/bin/
        COPY --from=monero --chown=nonroot:nonroot /data                  /data
        USER nonroot:nonroot

        ENTRYPOINT [ "monerod", "--non-interactive", "--data-dir=/data" ]
