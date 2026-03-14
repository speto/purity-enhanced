#!/usr/bin/env zsh

# Asciinema + svg-term Demo Script for Purity Enhanced
# Records terminal session and converts to SVG animation

set -e

DEMO_DIR="$(dirname "$0")"
DEMO_ROOT="/tmp/purity-asciinema-demo"
CAST_FILE="$DEMO_DIR/demo.cast"
SVG_FILE="$DEMO_DIR/demo.svg"

# Configuration
TYPING_SPEED=50  # milliseconds between characters
PAUSE_SHORT=1000 # 1 second
PAUSE_MEDIUM=2000 # 2 seconds  
PAUSE_LONG=3000  # 3 seconds

echo_info() {
    echo "\033[36m▶ $1\033[0m"
}

echo_success() {
    echo "\033[32m✅ $1\033[0m"
}

echo_error() {
    echo "\033[31m❌ $1\033[0m"
}

# Check dependencies
check_dependencies() {
    local missing=()
    
    if ! command -v asciinema >/dev/null 2>&1; then
        missing+=("asciinema")
    fi
    
    if ! command -v svg-term-cli >/dev/null 2>&1; then
        missing+=("svg-term-cli")
    fi
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        echo_error "Missing dependencies: ${missing[*]}"
        echo "Install with:"
        for dep in "${missing[@]}"; do
            case $dep in
                "asciinema")
                    echo "  pip install asciinema"
                    ;;
                "svg-term-cli")
                    echo "  npm install -g svg-term-cli"
                    ;;
            esac
        done
        exit 1
    fi
}

# Create automated demo script that asciinema will execute
create_demo_script() {
    local script_file="/tmp/asciinema-demo-script.zsh"
    
    cat > "$script_file" << 'EOF'
#!/usr/bin/env zsh

# Automated demo script for asciinema recording
source ~/.zshrc 2>/dev/null || true

# Helper functions for delays
sleep_short() { sleep 0.8; }
sleep_medium() { sleep 1.5; }
sleep_long() { sleep 2.5; }

# Setup demo environment
setup_demo() {
    rm -rf /tmp/purity-demo 2>/dev/null || true
    mkdir -p /tmp/purity-demo
    cd /tmp/purity-demo
    
    # Configure git
    git config --global user.email "demo@example.com" 2>/dev/null || true
    git config --global user.name "Demo User" 2>/dev/null || true
    git config --global init.defaultBranch main 2>/dev/null || true
}

# Demo sequence
main() {
    clear
    echo "╔════════════════════════════════════════╗"
    echo "║      Purity Enhanced ZSH Theme         ║"
    echo "║                                        ║"  
    echo "║    Beautiful • Fast • Feature Rich    ║"
    echo "╚════════════════════════════════════════╝"
    echo
    sleep_long
    
    setup_demo
    
    echo "🏠 Clean directory - minimal prompt"
    sleep_medium
    
    pwd
    sleep_short
    
    echo
    echo "📝 Creating git repository..."
    git init
    sleep_short
    
    echo
    echo "📄 Adding files..."
    echo "Feature implementation" > feature.txt
    echo "Documentation" > README.md
    sleep_short
    
    echo
    echo "✨ Untracked files indicator (✩)"
    sleep_medium
    
    git add feature.txt
    echo
    echo "✅ Staged changes indicator (✓)"  
    sleep_medium
    
    git commit -m "Add feature"
    echo
    echo "🎯 Clean repository after commit"
    sleep_short
    
    echo "Updated feature" >> feature.txt
    echo
    echo "🔄 Modified files indicator (✶)"
    sleep_medium
    
    echo "New file" > new.txt
    git add feature.txt
    echo
    echo "🔀 Mixed state: staged (✓) + untracked (✩)"
    sleep_medium
    
    echo
    echo "⏱️  Command execution time demo..."
    echo "Running slow command..."
    sleep 6
    echo "Command completed (execution time shown)"
    sleep_short
    
    echo
    echo "❌ Error state demo..."
    nonexistent_command 2>/dev/null || true
    echo "Prompt turns red on command failure"
    sleep_medium
    
    echo "✅ Success - prompt returns to normal"
    sleep_short
    
    echo
    echo "🐍 Language context detection..."
    cat > pyproject.toml << 'PYPROJECT'
[project]
name = "demo-project"
version = "1.0.0"
PYPROJECT
    echo "Python project detected"
    sleep_medium
    
    cat > package.json << 'PACKAGE'
{
  "name": "demo-app",
  "version": "1.0.0"
}
PACKAGE
    echo "⬢ Node.js project detected"
    sleep_medium
    
    cat > docker-compose.yml << 'DOCKER'
version: '3.8'
services:
  web:
    image: nginx:alpine
  db:
    image: postgres:13
DOCKER
    echo "🐳 Docker Compose detected"
    sleep_medium
    
    git stash push -m "Work in progress" 2>/dev/null || git stash 2>/dev/null || true
    echo
    echo "📦 Stashed changes indicator (⚑)"
    sleep_medium
    
    echo
    echo "🎉 Demo complete!"
    echo
    echo "Features shown:"
    echo "• Git status indicators (✓ ✶ ✩ ⚑)"
    echo "• Execution time tracking"  
    echo "• Error state indication"
    echo "• Language context detection"
    echo "• Infrastructure awareness"
    echo
    echo "Install: github.com/speto/purity-enhanced"
    sleep_long
}

main
EOF

    chmod +x "$script_file"
    echo "$script_file"
}

# Record demo with asciinema
record_demo() {
    echo_info "Recording asciinema demo..."
    
    local script_file
    script_file=$(create_demo_script)
    
    # Remove existing cast file
    rm -f "$CAST_FILE"
    
    # Record the demo
    ASCIINEMA_REC=1 asciinema rec \
        --overwrite \
        --title "Purity Enhanced ZSH Theme Demo" \
        --command "zsh $script_file" \
        --idle-time-limit 3 \
        "$CAST_FILE"
    
    echo_success "Recording saved to $CAST_FILE"
    
    # Clean up
    rm -f "$script_file"
}

# Convert to SVG using svg-term-cli
convert_to_svg() {
    echo_info "Converting to SVG animation..."
    
    if [[ ! -f "$CAST_FILE" ]]; then
        echo_error "Cast file not found: $CAST_FILE"
        exit 1
    fi
    
    svg-term-cli \
        --cast="$CAST_FILE" \
        --out="$SVG_FILE" \
        --window \
        --width=100 \
        --height=30 \
        --term=iterm2 \
        --profile=Dracula
    
    echo_success "SVG animation saved to $SVG_FILE"
}

# Upload to asciinema.org (optional)
upload_demo() {
    if [[ "$1" == "--upload" ]]; then
        echo_info "Uploading to asciinema.org..."
        asciinema upload "$CAST_FILE"
        echo_success "Demo uploaded to asciinema.org"
    fi
}

# Generate multiple formats
generate_formats() {
    echo_info "Generating additional formats..."
    
    # Generate PNG screenshot from SVG (requires ImageMagick)
    if command -v convert >/dev/null 2>&1; then
        convert -background white -density 150 "$SVG_FILE" "${SVG_FILE%.svg}.png"
        echo_success "PNG screenshot generated"
    fi
    
    # Generate optimized SVG for README
    if command -v svgo >/dev/null 2>&1; then
        svgo "$SVG_FILE" -o "${SVG_FILE%.svg}-optimized.svg"
        echo_success "Optimized SVG generated"
    fi
}

# Display file sizes and info
show_results() {
    echo_info "Generated files:"
    echo
    
    for file in "$CAST_FILE" "$SVG_FILE" "${SVG_FILE%.svg}.png" "${SVG_FILE%.svg}-optimized.svg"; do
        if [[ -f "$file" ]]; then
            local size
            size=$(du -h "$file" | cut -f1)
            echo "  📄 $(basename "$file") (${size})"
        fi
    done
    
    echo
    echo_success "Demo generation complete!"
    echo
    echo "Usage:"
    echo "  📺 View recording: asciinema play $CAST_FILE"  
    echo "  🌐 Embed SVG in README: <img src=\"demo.svg\" width=\"800\">"
    echo "  📤 Upload to share: asciinema upload $CAST_FILE"
}

# Main execution
main() {
    echo_info "Purity Enhanced - Asciinema Demo Generator"
    echo
    
    check_dependencies
    record_demo
    convert_to_svg  
    upload_demo "$@"
    generate_formats
    show_results
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi