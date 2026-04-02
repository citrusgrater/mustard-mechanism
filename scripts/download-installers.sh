#!/usr/bin/env bash
# Called once during Docker image build (as root).
# Centralises all external downloads so child images inherit cached layers
# and don't re-fetch on every rebuild.
#
# Convention:
#   Shell-based installers → /var/installers/<tool>/install.sh (run later by dorfl)
#   Binary tools           → /usr/local/bin/<tool>             (installed here as root)

set -euo pipefail

AICHAT_VERSION="0.30.0"
ASDF_VERSION="0.18.1"
TEA_VERSION="0.12.0"

# ── Shell-based installers (run later by dorfl) ──────────────────────────────

mkdir -p /var/installers/claude
curl -fsSL https://claude.ai/install.sh \
    -o /var/installers/claude/install.sh

mkdir -p /var/installers/opencode
curl -fsSL https://opencode.ai/install \
    -o /var/installers/opencode/install.sh

mkdir -p /var/installers/mistral-vibe
# This script installs uv (if absent) then runs: uv tool install mistral-vibe
curl -LsSf https://mistral.ai/vibe/install.sh \
    -o /var/installers/mistral-vibe/install.sh

# ── Binary tools (installed directly to /usr/local/bin) ─────────────────────

# aichat: Rust binary — release archive contains a single file at root.
curl -fsSL \
    "https://github.com/sigoden/aichat/releases/download/v${AICHAT_VERSION}/aichat-v${AICHAT_VERSION}-x86_64-unknown-linux-musl.tar.gz" \
    | tar -xz -C /usr/local/bin aichat
chmod 755 /usr/local/bin/aichat

# asdf-vm: Go binary — go install requires Go 1.24.9+ (Ubuntu 24.04 ships 1.22),
# so we take the pre-compiled release archive produced by go-release-action.
curl -fsSL \
    "https://github.com/asdf-vm/asdf/releases/download/v${ASDF_VERSION}/asdf-linux-amd64.tar.gz" \
    | tar -xz -C /usr/local/bin asdf
chmod 755 /usr/local/bin/asdf

# tea (Gitea CLI): go.mod requires Go 1.26 (unreleased), so use the pre-compiled
# binary served from dl.gitea.com — no archive, direct binary.
curl -fsSL \
    "https://dl.gitea.com/tea/v${TEA_VERSION}/tea-v${TEA_VERSION}-linux-amd64" \
    -o /usr/local/bin/tea
chmod 755 /usr/local/bin/tea
