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
