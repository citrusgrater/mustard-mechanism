# mustard-mechanism

A base Ubuntu 24.04 Docker image with common development tools pre-installed. Built and pushed to GHCR weekly.

## Table of Contents

- [Usage](#usage)
- [What's Included](#whats-included)
- [Pre-downloaded Installers](#pre-downloaded-installers)

## Usage

```bash
docker pull ghcr.io/citrusgrater/mustard-mechanism:latest
```

As a base image:

```dockerfile
FROM ghcr.io/citrusgrater/mustard-mechanism:latest
```

## What's Included

| Tool | Source |
|------|--------|
| build-essential, curl, git, wget, unzip, zip, sudo | apt |
| golang, nodejs, npm | apt |
| python3, python3-pip, python3-venv | apt |
| zsh, vim, nano, htop | apt |
| jq, ripgrep | apt |
| gemini-cli | npm |

## Pre-downloaded Installers

Some tools have their installers fetched at base-image build time and stored under `/var/installers/<tool>/`, so child images can run them without making outbound requests at build time.

| Tool | Path |
|------|------|
| Claude Code | `/var/installers/claude/install.sh` |

To use in a child image:

```dockerfile
RUN bash /var/installers/claude/install.sh
```
