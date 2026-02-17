#!/bin/bash

echo "========================================="
echo "🚀 Starting diagnostic and compilation"
echo "========================================="

# Diagnostic information
echo "📋 System Information:"
echo "Current directory: $(pwd)"
echo "Files in current directory:"
ls -la
echo ""

# Check if source file exists
echo "📄 Checking for source file:"
if [ -f "lab_practice_v3.cpp" ]; then
    echo "✅ Source file found: lab_practice_v3.cpp"
    echo "File size: $(wc -l < lab_practice_v3.cpp) lines"
    echo "First 10 lines of source:"
    head -10 lab_practice_v3.cpp
else
    echo "❌ Source file NOT found!"
    echo "Files in /build:"
    ls -la /build/
    exit 1
fi

echo ""
echo "========================================="
echo "🔨 Attempting compilation"
echo "========================================="

# Attempt compilation with verbose output
x86_64-w64-mingw32-g++ -static -O2 -s -o lab_practice_v3.exe lab_practice_v3.cpp \
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
    -std=c++17 \
    -v 2>&1 | tee compilation_log.txt

COMPILE_RESULT=${PIPESTATUS[0]}

echo ""
echo "========================================="
echo "📊 Compilation Result"
echo "========================================="

if [ $COMPILE_RESULT -eq 0 ] && [ -f "lab_practice_v3.exe" ]; then
    echo "✅ COMPILATION SUCCESSFUL!"
    echo "Executable details:"
    file lab_practice_v3.exe
    ls -lh lab_practice_v3.exe
    
    # Copy to output directory
    mkdir -p /output
    cp lab_practice_v3.exe /output/
    echo "✅ Executable copied to /output/"
else
    echo "❌ COMPILATION FAILED with code: $COMPILE_RESULT"
    echo ""
    echo "Last 50 lines of compilation log:"
    tail -50 compilation_log.txt
    echo ""
    echo "Common issues:"
    echo "1. Missing Windows headers - Check if mingw-w64 is properly installed"
    echo "2. Missing libraries - Some -l flags might not be available"
    echo "3. Source code errors - Check for syntax errors"
fi

echo ""
echo "========================================="
echo "🌐 Starting web server"
echo "========================================="

# Get the port Render assigns
PORT=${PORT:-10000}

# Create output directory if it doesn't exist
mkdir -p /output

# Create index.html with status
cat > /output/index.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Build Status</title>
    <style>
        body { font-family: Arial; margin: 40px; background: #f5f5f5; }
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; }
        .success { color: green; }
        .error { color: red; }
        pre { background: #1e1e1e; color: #d4d4d4; padding: 15px; border-radius: 5px; overflow-x: auto; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Windows Executable Builder</h1>
        <div id="status">
EOF

if [ -f "lab_practice_v3.exe" ]; then
    echo "<h2 class='success'>✅ Build Successful</h2>" >> /output/index.html
    echo "<p><a href='/lab_practice_v3.exe' download>📥 Click here to download lab_practice_v3.exe</a></p>" >> /output/index.html
    echo "<p>File size: $(ls -lh lab_practice_v3.exe | awk '{print $5}')</p>" >> /output/index.html
else
    echo "<h2 class='error'>❌ Build Failed</h2>" >> /output/index.html
    echo "<p>Check the compilation log below for errors.</p>" >> /output/index.html
fi

echo "</div>" >> /output/index.html
echo "<h3>Compilation Log:</h3>" >> /output/index.html
echo "<pre>" >> /output/index.html
if [ -f compilation_log.txt ]; then
    cat compilation_log.txt >> /output/index.html
else
    echo "No compilation log available" >> /output/index.html
fi
echo "</pre>" >> /output/index.html
echo "</div></body></html>" >> /output/index.html

# Copy executable to output if it exists
if [ -f "lab_practice_v3.exe" ]; then
    cp lab_practice_v3.exe /output/
fi

# Start web server
cd /output
echo "📁 Serving files from: $(pwd)"
echo "📋 Directory contents:"
ls -la
echo "🌐 Starting HTTP server on port $PORT"
exec python3 -m http.server $PORT --bind 0.0.0.0
