# The image service.yml publishes: `users` on Ubuntu, with the Swift runtime linked statically and jemalloc as
# its allocator. Each command runs as its own container of this image: `users serve`, `users migrate`.

FROM swift:6.4-noble AS build

RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q install -y --no-install-recommends libjemalloc-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# Resolves at the committed Package.resolved; a private dependency's token is mounted, never copied.
COPY Package.swift Package.resolved ./
RUN --mount=type=secret,id=netrc,target=/root/.netrc swift package --disable-automatic-resolution resolve

COPY . .
RUN swift build --configuration release --disable-automatic-resolution --static-swift-stdlib \
    -Xlinker -ljemalloc --product users

WORKDIR /staging
RUN bin_path="$(swift build --package-path /build --configuration release --show-bin-path)" \
    && cp "$bin_path/users" ./ \
    && cp /usr/libexec/swift/linux/swift-backtrace-static ./ \
    && find -L "$bin_path/" -regex '.*\.resources$' -exec cp -Ra {} ./ \;

FROM ubuntu:noble

RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q install -y --no-install-recommends ca-certificates tzdata libjemalloc2 \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd --gid 10001 harbor-users \
    && useradd --uid 10001 --gid 10001 --no-create-home --home-dir /app --shell /usr/sbin/nologin harbor-users

WORKDIR /app
COPY --from=build --chown=10001:10001 /staging /app

ENV SWIFT_BACKTRACE=enable=yes,sanitize=yes,threads=all,images=all,interactive=no,swift-backtrace=./swift-backtrace-static

USER 10001:10001
ENTRYPOINT ["./users"]
