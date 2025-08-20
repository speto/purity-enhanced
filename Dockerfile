# Base with zsh-async installed properly
FROM ubuntu:22.04 AS base
# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    zsh git bash curl ca-certificates ncurses-bin && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
# Install zsh-async to standard zsh site-functions
RUN git clone https://github.com/mafredri/zsh-async.git /tmp/zsh-async && \
    mkdir -p /usr/share/zsh/site-functions && \
    cp /tmp/zsh-async/async.zsh /usr/share/zsh/site-functions/ && \
    rm -rf /tmp/zsh-async

# Test target - add zunit and revolver
FROM base AS test
# Set environment for proper terminal and encoding support
ENV TERM=xterm
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
# Install basic test dependencies  
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    bc procps psmisc time python3 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
# Configure git for tests
RUN git config --global user.email "test@example.com" && \
    git config --global user.name "Test User"
# Build and install zunit
RUN git clone https://github.com/zunit-zsh/zunit.git /tmp/zunit && \
    cd /tmp/zunit && \
    zsh build.zsh && \
    cp zunit /usr/local/bin/ && \
    cd / && \
    rm -rf /tmp/zunit
# Install revolver (required dependency for zunit)
RUN git clone https://github.com/molovo/revolver.git /tmp/revolver && \
    cp /tmp/revolver/revolver /usr/local/bin/ && \
    chmod +x /usr/local/bin/revolver && \
    rm -rf /tmp/revolver
# Mock tools will be created by test helpers instead of installing real ones
WORKDIR /workspace
COPY . .
CMD ["zsh", "tests/run.sh"]

# Example target - interactive demo
FROM base AS example  
RUN apt-get update && \
    apt-get install -y --no-install-recommends python3 nodejs npm && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
RUN useradd -m -s /bin/zsh demo
USER demo
WORKDIR /home/demo
COPY purity-enhanced.zsh /home/demo/.config/
RUN echo 'source /usr/share/zsh/site-functions/async.zsh' >> ~/.zshrc && \
    echo 'source ~/.config/purity-enhanced.zsh' >> ~/.zshrc && \
    echo 'prompt_purity_enhanced_setup' >> ~/.zshrc
CMD ["zsh"]