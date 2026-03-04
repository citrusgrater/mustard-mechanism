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

# Install Claude Code via native installer, then expose it system-wide
RUN curl -fsSL https://claude.ai/install.sh | bash && \
    ln -sf /root/.local/bin/claude /usr/local/bin/claude

RUN npm install -g @google/gemini-cli
