# mustard-mechanism

A base Docker image for a sandboxed development environment, designed for use with [Colima](https://github.com/abiosoft/colima) on macOS.

## Table of Contents

- [Description](#description)
- [Installation](#installation)
- [Usage](#usage)
- [Project Structure](#project-structure)

## Description

This image provides a consistent, reproducible Ubuntu 24.04 base with common development tools pre-installed. It is intended as a foundation for project-specific images or as a direct sandbox environment via Colima. The image is automatically rebuilt weekly and pushed to GHCR.

## Installation

### Pull from GHCR

```bash
docker pull ghcr.io/OWNER/mustard-mechanism:latest
```

Replace `OWNER` with the GitHub username or organisation that owns this repository.

### Build locally

```bash
docker build -t mustard-mechanism .
```

## Usage

### With Colima

Start Colima if it isn't already running:

```bash
colima start
```

Run an interactive shell in the container:

```bash
docker run -it --rm ghcr.io/OWNER/mustard-mechanism:latest zsh
```

Mount your local project directory into the container:

```bash
docker run -it --rm -v "$PWD":/workspace -w /workspace ghcr.io/OWNER/mustard-mechanism:latest zsh
```

### As a base image

```dockerfile
FROM ghcr.io/OWNER/mustard-mechanism:latest

# your project-specific layers here
```

## Project Structure

```
.
├── Dockerfile                        # Image definition
└── .github/
    └── workflows/
        └── build.yml                 # Weekly rebuild and GHCR push
```

## What's Included

| Tool | Source |
|------|--------|
| curl, git, wget, unzip, zip | apt |
| build-essential | apt |
| python3, pip, venv | apt |
| golang | apt |
| nodejs, npm | apt |
| zsh, vim, nano, htop, sudo | apt |
| jq, ripgrep | apt |
| claude (Claude Code) | [native installer](https://claude.ai/install.sh) |
| gemini-cli | npm |
