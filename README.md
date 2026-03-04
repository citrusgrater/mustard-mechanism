# mustard-mechanism

A base Ubuntu 24.04 Docker image with common development tools pre-installed. Built and pushed to GHCR weekly.

## Table of Contents

- [Usage](#usage)
- [What's Included](#whats-included)

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
| claude (Claude Code) | native installer |
| gemini-cli | npm |
