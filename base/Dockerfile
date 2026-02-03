# Base image for ATProto lexicon operations using goat CLI
FROM alpine:3.23

# Install dependencies
# hadolint ignore=DL3018
RUN apk add --no-cache \
    bash \
    curl \
    jq \
    tar

# Set architecture for goat download
ARG TARGETARCH

# Install goat CLI from GitHub releases
RUN ARCH=$([ "$TARGETARCH" = "arm64" ] && echo "arm64" || echo "x86_64") && \
    curl -sSL "https://github.com/bluesky-social/goat/releases/latest/download/goat_Linux_${ARCH}.tar.gz" -o goat.tar.gz && \
    tar -xzf goat.tar.gz -C /usr/local/bin && \
    chmod +x /usr/local/bin/goat && \
    rm goat.tar.gz

# Set the working directory
WORKDIR /github/workspace
