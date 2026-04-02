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
    libportaudio2 \
    libsecret-1-0 \
    nano \
    net-tools \
    nmap \
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

# Node.js 22 via NodeSource — Ubuntu 24.04's default nodejs (v18) is too old
# for gemini-cli (requires >=20) and opencode.
# NodeSource bundles npm, so no separate npm install is needed.
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Download all external installers and pre-compiled binaries in one layer.
# Versions and URLs live in the script — edit there, not here.
COPY scripts/download-installers.sh /tmp/download-installers.sh
RUN bash /tmp/download-installers.sh

# Python-based AI tools — installed system-wide as root.
# --break-system-packages is intentional: this is a Docker image, not a managed host.
RUN pip3 install --break-system-packages --ignore-installed \
    open-interpreter \
    shell-gpt \
    llm

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

# Extend PATH to include:
#   ~/.local/bin      — Claude Code, uv, mistral-vibe (vibe), and other uv-managed tools
#   ~/.opencode/bin   — OpenCode
#   ~/.asdf/shims     — asdf-managed runtimes (populated after: asdf plugin add <name> && asdf install)
ENV PATH=/home/dorfl/.asdf/shims:/home/dorfl/.local/bin:/home/dorfl/.opencode/bin:${PATH}

# Install Claude Code as dorfl so it lands in /home/dorfl/.local/bin.
# Child images should remove ~/.claude* and replace them with runtime symlinks.
RUN bash /var/installers/claude/install.sh

# OpenCode — pre-downloaded installer; lands in ~/.opencode/bin
RUN bash /var/installers/opencode/install.sh

# Mistral Vibe — pre-downloaded installer; fetches uv then runs: uv tool install mistral-vibe
# Result: uv → ~/.local/bin/uv, vibe → ~/.local/bin/vibe
RUN bash /var/installers/mistral-vibe/install.sh
