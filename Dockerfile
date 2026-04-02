FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TERM=xterm-256color

RUN apt-get update && apt-get install -y \
    ansible \
    build-essential \
    curl \
    git \
    golang \
    htop \
    jq \
    nano \
    net-tools \
    nmap \
    nodejs \
    npm \
    pass \
    pwgen \
    python3 \
    python3-pip \
    python3-venv \
    ripgrep \
    sudo \
    tldr \
    tree \
    unzip \
    vim \
    wget \
    zip \
    zsh \
    && rm -rf /var/lib/apt/lists/*

# Pre-download installers to avoid 429s at child-image build time.
# /var/installers/<tool>/ is the convention — one directory per tool.
RUN mkdir -p /var/installers/claude && \
    curl -fsSL https://claude.ai/install.sh -o /var/installers/claude/install.sh

# OpenCode Installer
RUN mkdir -p /var/installers/opencode && \
    curl -fsSL https://opencode.ai/install -o /var/installers/opencode/install.sh

# Mistral Vibe Installer
RUN mkdir -p /var/installers/mistral-vibe && \
    curl -LsSf https://mistral.ai/vibe/install.sh -o /var/installers/mistral-vibe/install.sh

# aichat — download the musl binary from GitHub Releases and place it system-wide.
# The release archive contains a single file (the binary) at the root of the tar.
RUN curl -fsSL https://github.com/sigoden/aichat/releases/download/v0.30.0/aichat-v0.30.0-x86_64-unknown-linux-musl.tar.gz \
    | tar -xz -C /usr/local/bin aichat && \
    chmod 755 /usr/local/bin/aichat

# Python-based AI tools — installed system-wide as root.
# --break-system-packages is intentional: this is a Docker image, not a managed host.
RUN pip3 install --break-system-packages \
    open-interpreter \
    shell-gpt \
    llm

# asdf-vm — compiled via the system Go toolchain, then exposed system-wide.
# GOPATH defaults to /root/go when running as root; the binary is copied out to /usr/local/bin.
RUN go install github.com/asdf-vm/asdf/cmd/asdf@v0.18.1 && \
    cp /root/go/bin/asdf /usr/local/bin/asdf

# Create the default container user.
# UID 1000 matches the host developer UID to avoid bind-mount permission issues.
# The ubuntu user (also UID 1000) is removed first to free the slot.
RUN userdel -r ubuntu && \
    useradd -m -u 1000 -s /bin/zsh dorfl && \
    echo "dorfl ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/dorfl

# Gemini CLI
# Requires root because npm's global prefix (/usr/local/lib/node_modules) is root-owned.
# Running as root here avoids npm prefix configuration and keeps /usr/local/bin in PATH for all users.
RUN npm install -g @google/gemini-cli

USER dorfl
WORKDIR /home/dorfl

# Extend PATH to include user-local bin directories populated by the installers below.
ENV PATH=/home/dorfl/.local/bin:/home/dorfl/.opencode/bin:${PATH}

# Install Claude Code as dorfl so it lands in /home/dorfl/.local/bin.
# Child images should remove ~/.claude* and replace them with runtime symlinks.
RUN bash /var/installers/claude/install.sh

# OpenCode — pre-downloaded installer; lands in ~/.opencode/bin
RUN bash /var/installers/opencode/install.sh

# Mistral Vibe — pre-downloaded installer; downloads uv on first run, lands in ~/.local/bin
RUN bash /var/installers/mistral-vibe/install.sh
