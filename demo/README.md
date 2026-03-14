# Purity Enhanced Demo System

Automated screenshot and demo generation for the Purity Enhanced ZSH theme. This system eliminates the need for manual screenshots by providing comprehensive automation for creating promotional materials.

## Quick Start

Generate all demo materials for a new release:

```bash
# Generate everything at once
make demo-all

# Or generate specific formats
make screenshot      # Static PNG for README
make demo-gif       # Animated GIF 
make demo-video     # MP4 video
make demo-svg       # SVG animation (lightweight)
```

## Available Formats

### 📸 Screenshots (`make screenshot`)
- Generates static PNG images perfect for README hero images
- Uses VHS to capture terminal sessions at specific moments
- Automatically copies result to `screenshot.png` in project root

### 🎬 Animated GIF (`make demo-gif`)  
- High-quality animated GIF showcasing all theme features
- Perfect for social media and documentation
- Generated using VHS (Charm's terminal recorder)
- Result saved as `demo.gif`

### 🎥 MP4 Video (`make demo-video`)
- High-resolution MP4 video for presentations
- Better quality and smaller file size than GIF for longer demos
- Generated using VHS
- Result saved as `demo.mp4`

### 🎨 SVG Animation (`make demo-svg`)
- Lightweight SVG animation using Asciinema + svg-term
- Perfect for embedding in web pages and documentation
- Scalable vector graphics with small file size
- Result saved as `demo.svg`

### 📹 Asciinema Recording (`make demo-asciinema`)
- Interactive recording that can be uploaded to asciinema.org
- Allows viewers to copy text from the demo
- Great for sharing on social platforms
- Supports optional upload to asciinema.org

## Demo Features Showcased

The automated demos showcase all Purity Enhanced features:

### Core Features
- ✨ **Clean prompt** - Minimal design in clean directories
- ⏱️ **Execution time** - Commands taking >5 seconds show duration
- 🔴 **Error indication** - Prompt turns red on command failure
- 📁 **Directory context** - Path information and navigation

### Git Status Indicators
- `✓` **Staged changes** - Files ready for commit
- `✶` **Modified files** - Edited but not staged  
- `✩` **Untracked files** - New files not in git
- `✗` **Deleted files** - Removed files
- `➜` **Renamed files** - Moved/renamed files
- `═` **Unmerged files** - Merge conflicts
- `⚑` **Stashed changes** - Work saved with git stash
- `↑N` **Ahead of remote** - Commits ready to push
- `↓N` **Behind remote** - Commits available to pull

### Git Actions in Progress
- `rebase-i` - Interactive rebase in progress
- `merge` - Merge operation in progress  
- `cherry-pick` - Cherry-pick operation in progress
- `bisect` - Git bisect session active

### Development Context Detection
- `🐍 3.11` **Python** - Virtual environments and version detection
- `⬢ 18` **Node.js** - Package.json projects
- `🐹 1.21` **Go** - Go modules and version
- `🦀 1.75` **Rust** - Cargo projects
- `☕ 17` **Java** - Maven/Gradle projects  
- `💎 3.1` **Ruby** - Gemfile projects
- `🐘 8.2` **PHP** - Composer projects

### Infrastructure Context
- `🐳 2/5` **Docker Compose** - Running/total containers
- `☸ production` **Kubernetes** - Current context
- `☁ aws-prod` **AWS Profile** - Active AWS credentials
- `🏗️ staging` **Terraform** - Current workspace
- `☁️ my-project` **Google Cloud** - Active GCP project
- `🌐 production` **Azure** - Active subscription
- `📦 dev` **Pulumi** - Current stack

### Environment Indicators
- `[✦2]` **Background jobs** - Suspended/background processes
- `user@host` **SSH sessions** - Remote connection context
- `(venv-name)` **Virtual environments** - Active Python venv

## Architecture

### Demo Scripts

#### `showcase.sh`
Main automation script that creates realistic development scenarios:
- Sets up git repositories in various states
- Creates language project files (Python, Node.js, Go, etc.)
- Simulates different git workflows (commits, stashes, rebases)
- Demonstrates all theme features systematically

#### `asciinema-demo.sh` 
Specialized script for Asciinema recording:
- Records terminal session as JSON
- Converts to SVG using svg-term-cli
- Supports upload to asciinema.org
- Generates multiple output formats

#### `setup-mock-env.sh`
Creates comprehensive mock development environments:
- Multiple project types with realistic file structures
- Git repositories in various states
- Infrastructure configurations (Docker, K8s, Terraform)
- Background jobs and process simulation

### Docker Architecture

The demo system uses multi-stage Docker builds:

- **`base`** - Ubuntu with ZSH, git, and basic dependencies
- **`tools`** - Adds Go, VHS, Asciinema, svg-term-cli
- **`demo`** - Interactive demo environment
- **`recording`** - Automated recording environment  
- **`screenshot`** - Screenshot generation with display server
- **`development`** - Full development environment with tools

### VHS Configuration

The `showcase.tape` file defines:
- Terminal appearance (theme, fonts, dimensions)
- Typing speed and timing
- Command sequences to demonstrate features
- Output formats and quality settings

## Development & Testing

### Interactive Development
```bash
# Start development environment
make demo-dev

# This opens an interactive shell with:
# - All recording tools pre-installed
# - Theme configured and ready
# - Helper scripts available
# - Access to generated outputs
```

### Testing Demo Scripts
```bash
# Test individual components
cd demo
./showcase.sh           # Interactive feature demo
./asciinema-demo.sh     # Record asciinema session  
./setup-mock-env.sh     # Create test environments
```

### Manual Recording
```bash
# Use the demo environment for manual recording
make demo-dev

# Inside container:
vhs showcase.tape                    # Generate VHS recording
asciinema rec demo.cast             # Record asciinema session
./setup-mock-env.sh /tmp/test       # Create test environment
```

## Customization

### Modifying Demo Content

**Add new features to showcase:**
1. Edit `showcase.sh` - Add new demo scenarios
2. Update `showcase.tape` - Add VHS commands for new features
3. Modify `asciinema-demo.sh` - Include in asciinema recording

**Change visual appearance:**
1. Edit `showcase.tape` VHS settings:
   ```tape
   Set Theme "Dracula"          # Terminal theme
   Set FontFamily "JetBrains Mono"  # Font choice
   Set FontSize 14              # Text size
   Set Width 1200               # Terminal width
   Set Height 800               # Terminal height
   ```

**Adjust timing:**
- VHS: Modify `Sleep` and `TypingSpeed` in `showcase.tape`
- Asciinema: Edit sleep values in `asciinema-demo.sh`
- Scripts: Change `SLEEP_*` variables in `showcase.sh`

### Adding New Output Formats

1. **Add new Makefile target:**
   ```makefile
   demo-format:
   	docker build -f demo/Dockerfile --target recording -t purity-recording .
   	docker run --rm -v "$(PWD)/demo/output:/workspace/output" purity-recording \
   		sh -c "your-command-here"
   ```

2. **Create specialized Docker stage:**
   ```dockerfile
   FROM recording AS your-format
   RUN install-your-tools
   CMD ["your-generation-script"]
   ```

3. **Update `demo-all` target** to include new format

## Troubleshooting

### Common Issues

**VHS recording fails:**
- Ensure Docker has sufficient resources (2GB+ RAM)  
- Check that display server is running (handled automatically)
- Verify VHS tape syntax with `vhs validate showcase.tape`

**Asciinema recording hangs:**
- Default timeout is 300 seconds (5 minutes)
- Interactive prompts may cause hanging - ensure all commands are automated
- Check that svg-term-cli is properly installed

**Screenshot generation produces blank images:**
- Virtual display may not be initializing properly
- Try increasing sleep times in demo scripts
- Verify ImageMagick/ffmpeg dependencies are installed

**Demo scripts don't show theme features:**
- Ensure theme is properly sourced in container
- Check that zsh-async is available
- Verify git configuration is set up

### Debug Mode

Enable verbose output for troubleshooting:

```bash
# Run with debug output  
docker run --rm -v "$(PWD)/demo/output:/workspace/output" purity-recording \
    sh -c "set -x; cd demo && vhs showcase.tape"

# Check generated files
ls -la demo/output/
```

### Performance Optimization

For faster generation:
- Use `docker build --cache-from` for incremental builds
- Mount `/tmp` as tmpfs for faster I/O
- Run on machines with sufficient CPU/RAM (4GB+ recommended)

## Output Management

### File Locations
- **Source files:** `demo/` directory
- **Intermediate outputs:** `demo/output/` (temporary)
- **Final outputs:** Project root (`screenshot.png`, `demo.gif`, etc.)

### Cleanup
```bash
# Remove generated files
make clean-demo

# This removes:
# - All output files (GIF, MP4, SVG, PNG)
# - Temporary output directory
# - Docker images for demo system
```

### File Sizes
Typical output sizes:
- **screenshot.png:** ~200KB (1200x800 PNG)
- **demo.gif:** ~2-5MB (depends on length/quality)
- **demo.mp4:** ~1-3MB (better compression than GIF)
- **demo.svg:** ~50-200KB (vector format, very efficient)
- **demo.cast:** ~10-50KB (Asciinema JSON format)

## Integration with CI/CD

### GitHub Actions Example
```yaml
name: Generate Demo Materials
on:
  release:
    types: [published]

jobs:
  demo:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Generate demos
        run: make demo-all
      - name: Upload artifacts
        uses: actions/upload-artifact@v3
        with:
          name: demo-materials
          path: |
            screenshot.png
            demo.gif
            demo.mp4
            demo.svg
```

### Automated Updates
The demo system is designed to be triggered automatically on:
- New releases (to update promotional materials)
- Theme changes (to reflect new features)
- Documentation updates (to keep demos current)

This ensures that screenshots and demos are always up-to-date with the latest theme features and never become stale.

## Contributing

To contribute to the demo system:

1. **Test your changes:**
   ```bash
   make demo-dev  # Interactive testing
   make demo-all  # Full generation test
   ```

2. **Follow conventions:**
   - Keep demo scenarios realistic and representative
   - Ensure timing allows features to be clearly visible
   - Test on different terminal sizes and themes

3. **Document new features:**
   - Add to this README
   - Update demo scripts to showcase new functionality
   - Ensure new features are covered in all output formats

The goal is to maintain a comprehensive, automated system that showcases all theme features without requiring manual intervention, making it easy to keep promotional materials current with each release.