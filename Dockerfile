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

# Install Claude Code via native installer
RUN curl -fsSL https://claude.ai/install.sh | sh

ENV PATH="/root/.local/bin:$PATH"

RUN npm install -g @google/gemini-cli
