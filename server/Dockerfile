# syntax=docker/dockerfile:1

############################
# Builder
############################
FROM rust:bookworm AS builder

WORKDIR /app

# ツールチェーン指定を取り込む（cargo が rust-toolchain.toml を参照して自動で揃える）
COPY rust-toolchain.toml ./

# ソース一式をコピーしてビルド
COPY . .
RUN cargo build --release

############################
# Runtime
############################
FROM debian:bookworm-slim

RUN apt-get update \
  && apt-get install -y --no-install-recommends ca-certificates \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=builder /app/target/release/server /app/server

EXPOSE 7878
ENV RUST_LOG=info

CMD ["/app/server"]
