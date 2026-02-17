FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install all required packages
RUN apt-get update && apt-get install -y \
    mingw-w64 \
    g++-mingw-w64-x86-64 \
    mingw-w64-tools \
    mingw-w64-x86-64-dev \
    wget \
    git \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Download and install nlohmann/json
RUN git clone https://github.com/nlohmann/json.git && \
    mkdir -p /usr/x86_64-w64-mingw32/include/nlohmann && \
    cp json/single_include/nlohmann/json.hpp /usr/x86_64-w64-mingw32/include/nlohmann/ && \
    rm -rf json

# Verify compiler installation
RUN x86_64-w64-mingw32-g++ --version

WORKDIR /build

# Copy the diagnostic serve script
COPY serve.sh .
RUN chmod +x serve.sh

# Copy source file (will be mounted from GitHub)
COPY lab_practice_v3.cpp .

EXPOSE 8080

CMD ["/build/serve.sh"]
