# syntax = docker/dockerfile:1.3

ARG RUST_IMAGE=rust:1.55.0-bullseye
ARG DISTROLESS_IMAGE=gcr.io/distroless/base-debian11:nonroot

FROM ${RUST_IMAGE} AS rust
FROM ${DISTROLESS_IMAGE} AS base


FROM rust AS electrs

	ARG ELECTRS_REPOSITORY=https://github.com/romanz/electrs
	ARG ELECTRS_REVISION

	WORKDIR /src

	RUN set -ex && \
		apt update && apt install -y clang

	RUN set -ex && \
		git clone    ${ELECTRS_REPOSITORY} . && \
		git checkout ${ELECTRS_REVISION}

	RUN --mount=type=cache,target=/usr/local/cargo/registry \
	    --mount=type=cache,target=/usr/local/cargo/git \
		cargo build --release


FROM base AS final

	COPY --from=electrs	/src/target/release/electrs	/usr/local/bin/
