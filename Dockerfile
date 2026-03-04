FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TERM=xterm-256color

RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    golang \
    htop \
    jq \
    nano \
    nodejs \
    npm \
    python3 \
    python3-pip \
    python3-venv \
    ripgrep \
    sudo \
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

# Gemini has no install script — npm install IS the download.
RUN npm install -g @google/gemini-cli
