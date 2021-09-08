# syntax = docker/dockerfile:experimental

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
		build-essential \
		ca-certificates \
		ccache \
		cmake \
		git \
		libgss-dev \
		libnorm-dev \
		libpgm-dev \
		libsodium-dev \
		libuv1-dev \
		libzmq3-dev


#
#	build p2p from source
#	ps.: static builds are not supported _yet_.
#
#
FROM builder AS p2pool

	WORKDIR /src

	ARG P2POOL_REPOSITORY=https://github.com/SChernykh/p2pool
	ARG P2POOL_REVISION

 	RUN set -ex && \
	    git clone ${P2POOL_REPOSITORY} . && \
	    git checkout ${P2POOL_REVISION} && \
	    git submodule init && \
	    git submodule update

	RUN --mount=type=cache,target=/ccache \
		mkdir build && cd build && \
		cmake .. && \
		make -j$(cat /nproc)


# 
#	final stage that will be included in the container image
#
#
FROM base AS final

	#
	#	yes, this is suboptimal - we can make this better once
	#				  p2pool gets to making static
	#				  builds a thing
	#
	COPY --from=builder /lib/x86_64-linux-gnu/libc.so.6 			/lib/x86_64-linux-gnu/
	COPY --from=builder /lib/x86_64-linux-gnu/libcom_err.so.2 		/lib/x86_64-linux-gnu/
	COPY --from=builder /lib/x86_64-linux-gnu/libdl.so.2 			/lib/x86_64-linux-gnu/
	COPY --from=builder /lib/x86_64-linux-gnu/libgcc_s.so.1 		/lib/x86_64-linux-gnu/
	COPY --from=builder /lib/x86_64-linux-gnu/libkeyutils.so.1 		/lib/x86_64-linux-gnu/
	COPY --from=builder /lib/x86_64-linux-gnu/libm.so.6 			/lib/x86_64-linux-gnu/
	COPY --from=builder /lib/x86_64-linux-gnu/libpthread.so.0 		/lib/x86_64-linux-gnu/
	COPY --from=builder /lib/x86_64-linux-gnu/libresolv.so.2 		/lib/x86_64-linux-gnu/
	COPY --from=builder /usr/lib/x86_64-linux-gnu/libbsd.so.0 		/usr/lib/x86_64-linux-gnu/
	COPY --from=builder /usr/lib/x86_64-linux-gnu/libgssapi_krb5.so.2 	/usr/lib/x86_64-linux-gnu/
	COPY --from=builder /usr/lib/x86_64-linux-gnu/libk5crypto.so.3 		/usr/lib/x86_64-linux-gnu/
	COPY --from=builder /usr/lib/x86_64-linux-gnu/libkrb5.so.3 		/usr/lib/x86_64-linux-gnu/
	COPY --from=builder /usr/lib/x86_64-linux-gnu/libkrb5support.so.0 	/usr/lib/x86_64-linux-gnu/
	COPY --from=builder /usr/lib/x86_64-linux-gnu/libmd.so.0 		/usr/lib/x86_64-linux-gnu/
	COPY --from=builder /usr/lib/x86_64-linux-gnu/libnorm.so.1 		/usr/lib/x86_64-linux-gnu/
	COPY --from=builder /usr/lib/x86_64-linux-gnu/libpgm-5.3.so.0 		/usr/lib/x86_64-linux-gnu/
	COPY --from=builder /usr/lib/x86_64-linux-gnu/libsodium.so.23 		/usr/lib/x86_64-linux-gnu/
	COPY --from=builder /usr/lib/x86_64-linux-gnu/libstdc++.so.6 		/usr/lib/x86_64-linux-gnu/
	COPY --from=builder /usr/lib/x86_64-linux-gnu/libuv.so.1 		/usr/lib/x86_64-linux-gnu/
	COPY --from=builder /usr/lib/x86_64-linux-gnu/libzmq.so.5 		/usr/lib/x86_64-linux-gnu/

	COPY --from=p2pool --chown=nonroot:nonroot 	/src/build/p2pool 	/usr/local/bin/
        USER nonroot:nonroot

        ENTRYPOINT [ "p2pool" ]
