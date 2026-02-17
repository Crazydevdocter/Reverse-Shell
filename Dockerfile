FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# Install essential build tools
RUN apt-get update && apt-get install -y \
    build-essential \
    wget \
    git \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Download MinGW binaries directly
RUN wget https://github.com/mstorsjo/llvm-mingw/releases/download/20250114/llvm-mingw-20250114-ucrt-ubuntu-20.04-x86_64.tar.xz && \
    tar -xf llvm-mingw-20250114-ucrt-ubuntu-20.04-x86_64.tar.xz && \
    mv llvm-mingw-20250114-ucrt-ubuntu-20.04-x86_64 /opt/llvm-mingw && \
    rm llvm-mingw-20250114-ucrt-ubuntu-20.04-x86_64.tar.xz

# Add to PATH
ENV PATH="/opt/llvm-mingw/bin:${PATH}"

# Download nlohmann/json
RUN git clone https://github.com/nlohmann/json.git && \
    mkdir -p /opt/llvm-mingw/x86_64-w64-mingw32/include/nlohmann && \
    cp json/single_include/nlohmann/json.hpp /opt/llvm-mingw/x86_64-w64-mingw32/include/nlohmann/ && \
    rm -rf json

WORKDIR /build

# Compilation script
RUN echo '#!/bin/bash' > compile.sh && \
    echo 'x86_64-w64-mingw32-clang++ -static -O2 -s -o lab_practice_v3.exe lab_practice_v3.cpp \' >> compile.sh && \
    echo '    -lws2_32 -lwininet -liphlpapi -lwlanapi -ladvapi32 -lgdiplus -lshell32 \' >> compile.sh && \
    echo '    -lwinhttp -lcrypt32 -lnetapi32 -std=c++17 \' >> compile.sh && \
    echo '    -I/opt/llvm-mingw/x86_64-w64-mingw32/include' >> compile.sh && \
    chmod +x compile.sh

# Web server script
RUN echo '#!/bin/bash' > serve.sh && \
    echo 'mkdir -p /output' >> serve.sh && \
    echo 'if [ -f "lab_practice_v3.exe" ]; then' >> serve.sh && \
    echo '    cp lab_practice_v3.exe /output/' >> serve.sh && \
    echo 'fi' >> serve.sh && \
    echo 'cd /output' >> serve.sh && \
    echo 'python3 -m http.server 8080' >> serve.sh && \
    chmod +x serve.sh

EXPOSE 8080

CMD ["/build/serve.sh"]
