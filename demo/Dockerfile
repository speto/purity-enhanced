# Optimized Docker environment for Purity Enhanced demo generation
# Single unified image with multiple entrypoints

FROM ubuntu:22.04

# Multi-arch support
ARG TARGETARCH

# Avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive \
    TERM=xterm-256color \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    DISPLAY=:99 \
    VHS_NO_SANDBOX="true"

# Install all packages in one layer to reduce image size
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    # Core system packages
    zsh git bash curl ca-certificates ncurses-bin \
    # Build tools (will be removed later)
    build-essential \
    # Runtime tools
    python3 python3-pip nodejs npm \
    # Media processing and browser dependencies for VHS
    imagemagick ffmpeg xvfb \
    libnss3 libatk1.0-0 libatk-bridge2.0-0 libdrm2 libxkbcommon0 \
    libxcomposite1 libxdamage1 libxrandr2 libgbm1 libxss1 libgtk-3-0 \
    libasound2 wget gnupg \
    # Fonts for better rendering
    fonts-jetbrains-mono fonts-firacode fonts-liberation && \
    # Install Go for VHS
    GOARCH=$(case ${TARGETARCH} in amd64) echo "amd64" ;; arm64) echo "arm64" ;; *) echo "amd64" ;; esac) && \
    curl --retry 3 -fsSL https://golang.org/dl/go1.21.0.linux-${GOARCH}.tar.gz | tar -C /usr/local -xzf - && \
    # Install VHS
    export GOPATH=/tmp/go && export PATH=/usr/local/go/bin:$PATH && \
    go install github.com/charmbracelet/vhs@latest && \
    cp /tmp/go/bin/vhs /usr/local/bin/ && \
    # Install ttyd
    ARCH=$(case ${TARGETARCH} in amd64) echo "x86_64" ;; arm64) echo "aarch64" ;; *) echo "x86_64" ;; esac) && \
    curl --retry 3 -fsSL "https://github.com/tsl0922/ttyd/releases/latest/download/ttyd.${ARCH}" -o /usr/local/bin/ttyd && \
    chmod +x /usr/local/bin/ttyd && \
    # Install Python and Node.js tools
    python3 -m pip install --no-cache-dir asciinema Pillow && \
    npm install -g svg-term-cli svgo && \
    # Install zsh-async
    git clone https://github.com/mafredri/zsh-async.git /tmp/zsh-async && \
    mkdir -p /usr/share/zsh/site-functions && \
    cp /tmp/zsh-async/async.zsh /usr/share/zsh/site-functions/ && \
    # Configure git globally
    git config --global user.email "demo@purity-enhanced.dev" && \
    git config --global user.name "Demo User" && \
    git config --global init.defaultBranch main && \
    # Clean up to reduce image size
    rm -rf /tmp/go /tmp/zsh-async /usr/local/go && \
    apt-get remove -y build-essential wget gnupg && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /root/.cache /tmp/*

WORKDIR /workspace

# Copy all demo files
COPY . .

# Install theme system-wide and create non-root user
RUN cp purity-enhanced.zsh /etc/zsh/ && \
    echo 'source /usr/share/zsh/site-functions/async.zsh' >> /etc/zsh/zshrc && \
    echo 'source /etc/zsh/purity-enhanced.zsh' >> /etc/zsh/zshrc && \
    echo 'prompt_purity_enhanced_setup' >> /etc/zsh/zshrc && \
    mkdir -p /workspace/output && \
    # Create non-root user for browser operations
    useradd -m -s /bin/bash vhsuser && \
    chown -R vhsuser:vhsuser /workspace && \
    mkdir -p /home/vhsuser/.cache/rod/browser && \
    chown -R vhsuser:vhsuser /home/vhsuser/.cache && \
    # Configure git for vhsuser
    su vhsuser -c 'git config --global user.email "demo@purity-enhanced.dev"' && \
    su vhsuser -c 'git config --global user.name "Demo User"' && \
    su vhsuser -c 'git config --global init.defaultBranch main'

# Create entrypoint scripts for different modes
RUN cat > /workspace/screenshot.sh << 'EOF' && chmod +x /workspace/screenshot.sh
#!/bin/bash
set -e

OUTPUT_DIR="/workspace/output"
mkdir -p "$OUTPUT_DIR"

echo "🎬 Starting screenshot generation..."

# Start virtual display
if command -v Xvfb >/dev/null 2>&1; then
    pkill -f Xvfb || true
    rm -f /tmp/.X*-lock
    
    DISPLAY_NUM=$((RANDOM % 100 + 10))
    Xvfb :$DISPLAY_NUM -ac -screen 0 1280x1024x16 &
    export DISPLAY=:$DISPLAY_NUM
    sleep 3
fi

# Generate screenshot
if [[ -f "demo/screenshot.tape" ]]; then
    echo "📸 Generating screenshot..."
    cd demo
    
    chown -R vhsuser:vhsuser /workspace/output || true
    
    VHS_EXIT_CODE=0
    su vhsuser -c "VHS_NO_SANDBOX=true DISPLAY=:$DISPLAY_NUM timeout 120 vhs screenshot.tape" || VHS_EXIT_CODE=$?
    
    if [[ -f "screenshot.png" ]]; then
        mv screenshot.png "$OUTPUT_DIR/"
        SCREENSHOT_CREATED=true
    else
        SCREENSHOT_CREATED=false
    fi
    
    cd ..
    
    if [[ $VHS_EXIT_CODE -eq 0 && "$SCREENSHOT_CREATED" == "true" && -f "$OUTPUT_DIR/screenshot.png" ]]; then
        echo "✅ Screenshot generation complete!"
        echo "📁 Output: $OUTPUT_DIR/screenshot.png"
    else
        echo "❌ Screenshot generation failed!"
        echo "   VHS exit code: $VHS_EXIT_CODE"
        echo "   Screenshot created: $SCREENSHOT_CREATED"
        echo "   Output file exists: $(test -f "$OUTPUT_DIR/screenshot.png" && echo "yes" || echo "no")"
        echo "💡 Check the logs above for VHS error details"
        exit 1
    fi
else
    echo "❌ Screenshot tape file not found: demo/screenshot.tape"
    exit 1
fi

echo "📁 Output directory contents:"
ls -la "$OUTPUT_DIR" || echo "Could not list output directory"
EOF

RUN cat > /workspace/recording.sh << 'EOF' && chmod +x /workspace/recording.sh
#!/bin/bash
set -e

# Start virtual display
if command -v Xvfb >/dev/null 2>&1; then
    Xvfb :99 -ac -screen 0 1280x1024x16 &
    sleep 2
fi

# Execute the command or start interactive shell
exec "$@"
EOF

# Default entrypoint for recording mode
ENTRYPOINT ["/workspace/recording.sh"]
CMD ["zsh"]