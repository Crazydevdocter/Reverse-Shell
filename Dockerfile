# Use Ubuntu as base
FROM ubuntu:22.04

# Install MinGW-w64 compiler
RUN apt-get update && apt-get install -y \
    mingw-w64 \
    g++-mingw-w64-x86-64 \
    wget \
    unzip \
    git \
    && rm -rf /var/lib/apt/lists/*

# Create working directory
WORKDIR /build

# Copy source file (will be mounted from GitHub)
COPY lab_practice_v3.cpp .

# Compile the Windows executable
RUN x86_64-w64-mingw32-g++ -static -O2 -s -o lab_practice_v3.exe lab_practice_v3.cpp \
    -lws2_32 \
    -lwininet \
    -liphlpapi \
    -lwlanapi \
    -ladvapi32 \
    -lgdiplus \
    -lshell32 \
    -lwinhttp \
    -lcrypt32 \
    -lnetapi32 \
    -static-libgcc \
    -static-libstdc++ \
    -std=c++17

# Create output directory and copy the executable
RUN mkdir /output && cp lab_practice_v3.exe /output/

# Create a simple web server to serve the file
RUN apt-get install -y python3

# Create download page
RUN echo '#!/bin/bash' > /serve.sh && \
    echo 'cd /output' >> /serve.sh && \
    echo 'echo "Content-type: text/html"' > index.html && \
    echo 'echo "" >> index.html' >> index.html && \
    echo '<html><head><title>Build Complete</title>' >> index.html && \
    echo '<style>body{font-family:Arial;margin:50px;background:#f0f0f0;}' >> index.html && \
    echo '.container{background:white;padding:30px;border-radius:10px;}' >> index.html && \
    echo 'a{background:#0078d7;color:white;padding:10px 20px;' >> index.html && \
    echo 'text-decoration:none;border-radius:5px;display:inline-block;}' >> index.html && \
    echo 'a:hover{background:#005a9e;}</style>' >> index.html && \
    echo '</head><body><div class="container">' >> index.html && \
    echo '<h1>✅ Build Complete</h1>' >> index.html && \
    echo '<p>Your Windows executable is ready:</p>' >> index.html && \
    echo '<a href="/lab_practice_v3.exe">Download lab_practice_v3.exe</a>' >> index.html && \
    echo '<p><small>File size: ' >> index.html && \
    echo $(ls -lh /output/lab_practice_v3.exe | awk '{print $5}') >> index.html && \
    echo '</small></p></div></body></html>' >> index.html && \
    echo 'python3 -m http.server 8080' >> /serve.sh && \
    chmod +x /serve.sh

EXPOSE 8080

CMD ["/serve.sh"]
