# syntax = docker/dockerfile:1.3

ARG RUST_IMAGE=rust:1.55.0-bullseye
ARG DISTROLESS_IMAGE=gcr.io/distroless/base-debian11:nonroot

FROM ${RUST_IMAGE} AS rust
FROM ${DISTROLESS_IMAGE} AS base


FROM rust AS xmrbtcswap

	ARG XMRBTCSWAP_REPOSITORY=https://github.com/comit-network/xmr-btc-swap
	ARG XMRBTCSWAP_REVISION

	WORKDIR /src

	RUN set -ex && \
		git clone ${XMRBTCSWAP_REPOSITORY} . && \
		git checkout ${XMRBTCSWAP_REVISION}

	RUN --mount=type=cache,target=/usr/local/cargo/registry \
	    --mount=type=cache,target=/usr/local/cargo/git \
		cargo build --release


FROM base AS final

	COPY --from=xmrbtcswap	/lib/x86_64-linux-gnu/libz.so.1		/lib/x86_64-linux-gnu
	COPY --from=xmrbtcswap	/lib/x86_64-linux-gnu/libgcc_s.so.1 	/lib/x86_64-linux-gnu

	COPY --from=xmrbtcswap	/src/target/release/asb			/usr/local/bin/asb
	COPY --from=xmrbtcswap	/src/target/release/swap		/usr/local/bin/swap
	COPY --from=xmrbtcswap	/src/target/release/kraken_ticker	/usr/local/bin/kraken_ticker
