#!/usr/bin/env bash
# Called once during Docker image build (as root).
# Centralises all external downloads so child images inherit cached layers
# and don't re-fetch on every rebuild.
#
# Convention:
#   Shell-based installers → /var/installers/<tool>/install.sh (run later by dorfl)
#   Binary tools           → /usr/local/bin/<tool>             (installed here as root)

set -euo pipefail

# ── Architecture detection ────────────────────────────────────────────────────

ARCH=$(uname -m)
case "$ARCH" in
    x86_64)
        MUSL_ARCH="x86_64-unknown-linux-musl"   # aichat/uv release target
        GO_ARCH="amd64"                          # asdf/tea release target
        ;;
    aarch64)
        MUSL_ARCH="aarch64-unknown-linux-musl"
        GO_ARCH="arm64"
        ;;
    *)
        echo "ERROR: unsupported architecture: $ARCH" >&2
        exit 1
        ;;
esac

echo "==> Architecture: $ARCH  (musl=${MUSL_ARCH}  go=${GO_ARCH})"

# ── Versions ─────────────────────────────────────────────────────────────────

AICHAT_VERSION="0.30.0"
ASDF_VERSION="0.18.1"
TEA_VERSION="0.12.0"

# ── Helpers ───────────────────────────────────────────────────────────────────

step() { echo; echo "==> $*"; }

# ── Shell-based installers (run later by dorfl) ──────────────────────────────

step "Downloading Claude installer..."
mkdir -p /var/installers/claude
curl -fsSL https://claude.ai/install.sh \
    -o /var/installers/claude/install.sh

step "Downloading OpenCode installer..."
mkdir -p /var/installers/opencode
curl -fsSL https://opencode.ai/install \
    -o /var/installers/opencode/install.sh

step "Downloading Mistral Vibe installer..."
mkdir -p /var/installers/mistral-vibe
# Installs uv (if absent) then runs: uv tool install mistral-vibe.
# Because uv is pre-installed system-wide by this script, the uv-install step is skipped.
curl -LsSf https://mistral.ai/vibe/install.sh \
    -o /var/installers/mistral-vibe/install.sh

# ── Binary tools (installed directly to /usr/local/bin) ─────────────────────

step "Installing uv (${MUSL_ARCH})..."
# uv is the Python tool runner used for open-interpreter, shell-gpt, llm, and mistral-vibe.
# Installing system-wide here so all users get it and the mistral-vibe installer skips its own uv step.
curl -LsSf https://astral.sh/uv/install.sh \
    | UV_INSTALL_DIR=/usr/local/bin sh

step "Installing aichat v${AICHAT_VERSION} (${MUSL_ARCH})..."
# Release archive contains a single binary at the root.
curl -fsSL \
    "https://github.com/sigoden/aichat/releases/download/v${AICHAT_VERSION}/aichat-v${AICHAT_VERSION}-${MUSL_ARCH}.tar.gz" \
    | tar -xz -C /usr/local/bin aichat
chmod 755 /usr/local/bin/aichat

step "Installing asdf v${ASDF_VERSION} (linux-${GO_ARCH})..."
# go install requires Go 1.24.9+ but Ubuntu 24.04 ships 1.22, so use the pre-compiled release.
curl -fsSL \
    "https://github.com/asdf-vm/asdf/releases/download/v${ASDF_VERSION}/asdf-linux-${GO_ARCH}.tar.gz" \
    | tar -xz -C /usr/local/bin asdf
chmod 755 /usr/local/bin/asdf

step "Installing tea v${TEA_VERSION} (linux-${GO_ARCH})..."
# go.mod requires Go 1.26 (unreleased); use the pre-compiled binary from dl.gitea.com.
curl -fsSL \
    "https://dl.gitea.com/tea/v${TEA_VERSION}/tea-v${TEA_VERSION}-linux-${GO_ARCH}" \
    -o /usr/local/bin/tea
chmod 755 /usr/local/bin/tea

echo
echo "==> All downloads complete."
