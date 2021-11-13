# ================================
# Build image
# ================================
FROM swift:5.5.1 as build
WORKDIR /build

# First just resolve dependencies.
# This creates a cached layer that can be reused
# as long as your Package.swift/Package.resolved
# files do not change.
COPY ./PufferyServer/Package.* ./
COPY ./APIDefinition ../APIDefinition
RUN swift package resolve

# Copy entire repo into container
COPY ./PufferyServer .

# Compile with optimizations
RUN swift build \
    --enable-test-discovery \
    -c release \
    -Xswiftc -g

# ================================
# Run image
# ================================
FROM vapor/ubuntu:18.04
WORKDIR /app

# Copy build artifacts
COPY --from=build /build/.build/release /app
# Copy Swift runtime libraries
COPY --from=build /usr/lib/swift/ /usr/lib/swift/
# Uncomment the next line if you need to load resources from the `Public` directory
#COPY --from=build /build/Public /app/Public

ENTRYPOINT ["./puffery"]
CMD ["serve", "--env", "production", "--hostname", "0.0.0.0", "--auto-migrate"]
