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

# TODO: Install asdf-vm

# Create the default container user.
# UID 1000 matches the host developer UID to avoid bind-mount permission issues.
# The ubuntu user (also UID 1000) is removed first to free the slot.
RUN userdel -r ubuntu && \
    useradd -m -u 1000 -s /bin/zsh dorfl && \
    echo "dorfl ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/dorfl

# Gemini CLI
# Requires root because npm's global prefix (/usr/local/lib/node_modules) is root-owned.
# Running as root here avoids npm prefix configuration and keeps /usr/local/bin in PATH for all users.
# To enable: uncomment the line below, then rebuild.
# RUN npm install -g @google/gemini-cli

USER dorfl
WORKDIR /home/dorfl

# Install Claude Code as dorfl so it lands in /home/dorfl/.local/bin.
# Child images should remove ~/.claude* and replace them with runtime symlinks.
RUN bash /var/installers/claude/install.sh
