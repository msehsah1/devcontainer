# =============================================================================
#  DevOps Power Container — 40 Essential Tools
#  Base: Ubuntu 22.04 LTS
# =============================================================================

FROM ubuntu:24.04

# ---------------------------------------------------------------------------
# Metadata
# ---------------------------------------------------------------------------
LABEL maintainer="DevOps Team"
LABEL description="Production-grade DevOps dev container with 40 essential tools"
LABEL version="1.0.0"

# ---------------------------------------------------------------------------
# Build args — pin every version for reproducibility
# ---------------------------------------------------------------------------
ARG DEBIAN_FRONTEND=noninteractive
ARG TZ=UTC

# --- Kubernetes & Container Orchestration ---
ARG STERN_VERSION=v1.33.0
ARG SKOPEO_VERSION=1.20.1

# --- Container ---
ARG HADOLINT_VERSION=v2.14.0

# --- Cloud CLIs ---
ARG GCLOUD_VERSION=568.0.0

# --- Developer Tools ---
ARG YQ_VERSION=v4.53.2

# --- Runtimes ---
ARG GO_VERSION=1.22.5
ARG NODE_VERSION=20

# ---------------------------------------------------------------------------
# Environment
# ---------------------------------------------------------------------------
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TZ=UTC \
    TERM=xterm-256color \
    COLORTERM=truecolor \
    GOPATH=/home/vscode/go \
    GOROOT=/usr/local/go \
    PATH=/usr/local/go/bin:/home/vscode/go/bin:/home/vscode/.pulumi/bin:/home/vscode/.local/bin:$PATH \
    PIPX_HOME=/opt/pipx \
    PIPX_BIN_DIR=/usr/local/bin \
    PATH=/usr/local/bin:${PATH}


# ---------------------------------------------------------------------------
# 1 — Base system packages
# ---------------------------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Core utilities
    apt-transport-https \
    apt-utils \
    bash-completion \
    build-essential \
    ca-certificates \
    coreutils \
    curl \
    dnsutils \
    file \
    findutils \
    git \
    git-lfs \
    gnupg \
    gpg \
    htop \
    iproute2 \
    iputils-ping \
    jq \
    less \
    lsb-release \
    lsof \
    make \
    man-db \
    mtr \
    ncat \
    net-tools \
    netcat-openbsd \
    nmap \
    openssh-client \
    parallel \
    rsync \
    software-properties-common \
    sudo \
    tar \
    tmux \
    tree \
    tzdata \
    unzip \
    vim \
    watch \
    wget \
    xz-utils \
    zip \
    zsh \
    # Python
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    # PostgreSQL client
    postgresql-client \
    # Redis client
    redis-tools \
    # MySQL client
    && rm -rf /var/lib/apt/lists/*

# ---------------------------------------------------------------------------
# 2 — Git LFS init
# ---------------------------------------------------------------------------
RUN git lfs install --system

# ---------------------------------------------------------------------------
# 3 — Docker CLI + Compose v2   (Tool #1, #2)
# ---------------------------------------------------------------------------
RUN install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
    && chmod a+r /etc/apt/keyrings/docker.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    > /etc/apt/sources.list.d/docker.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
    docker-ce-cli \
    docker-compose-plugin \
    docker-buildx-plugin \
    && rm -rf /var/lib/apt/lists/* \
    && docker compose version


#----------------------------------------------------------------------------
# 4 — pipx (Python package installer for CLI tools)   (Tool #3)
#----------------------------------------------------------------------------
RUN apt-get update \
    && apt-get install -y --no-install-recommends pipx \
    && rm -rf /var/lib/apt/lists/* 

# ---------------------------------------------------------------------------
# 17 — Google Cloud SDK   (Tool #16)
# ---------------------------------------------------------------------------
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] \
    https://packages.cloud.google.com/apt cloud-sdk main" \
    > /etc/apt/sources.list.d/google-cloud-sdk.list \
    && curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg \
    | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
    google-cloud-cli \
    google-cloud-cli-gke-gcloud-auth-plugin \
    && rm -rf /var/lib/apt/lists/* \
    && gcloud version



# ---------------------------------------------------------------------------
# 21 — hadolint (Dockerfile linter)   (Tool #20)
# ---------------------------------------------------------------------------
RUN curl -fsSL "https://github.com/hadolint/hadolint/releases/download/${HADOLINT_VERSION}/hadolint-Linux-x86_64" \
    -o /usr/local/bin/hadolint \
    && chmod +x /usr/local/bin/hadolint \
    && hadolint --version

# ---------------------------------------------------------------------------
# 22 — yq (YAML processor)   (Tool #21)
# ---------------------------------------------------------------------------
RUN curl -fsSL "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64" \
    -o /usr/local/bin/yq \
    && chmod +x /usr/local/bin/yq \
    && yq --version

# ---------------------------------------------------------------------------
# 23 — Go   (Tool #22)
# ---------------------------------------------------------------------------
RUN rm -rf /usr/local/go \
    && curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" \
    | tar -xz -C /usr/local \
    && /usr/local/go/bin/go version

ENV PATH="/usr/local/go/bin:${PATH}"

# ---------------------------------------------------------------------------
# 24 — Node.js LTS + npm + yarn   (Tool #23, #24)
# ---------------------------------------------------------------------------
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && npm install -g yarn pnpm \
    && rm -rf /var/lib/apt/lists/* \
    && node --version && npm --version

# ---------------------------------------------------------------------------
# 25 — Python tools   (Tool #25)
# ---------------------------------------------------------------------------
RUN pipx install pre-commit \
    && pipx install httpie \
    && pipx install poetry \
    && pipx install pipenv \
    && pipx install uv \
    && pre-commit --version \
    && http --version \
    && poetry --version \
    && pipenv --version


# ---------------------------------------------------------------------------
# 26 — OpenAI Codex CLI   (Tool #26)
# ---------------------------------------------------------------------------
RUN npm install -g @openai/codex \
    && codex --version


# ---------------------------------------------------------------------------
# 27 — Anthropic Claude Code CLI   (Tool #27)
# ---------------------------------------------------------------------------
RUN npm install -g @anthropic-ai/claude-code

#---------------------------------------------------------------------------
# 28 — Google Gemini CLI   (Tool #28)
#---------------------------------------------------------------------------    
RUN npm install -g @google/gemini-cli \
    && gemini --version
# ---------------------------------------------------------------------------
# User setup — non-root vscode user
# ---------------------------------------------------------------------------
RUN groupadd --gid 1001 vscode \
    && useradd --uid 1001 --gid vscode --shell /bin/zsh \
    --create-home --home-dir /home/vscode vscode \
    && echo "vscode ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/vscode \
    && chmod 0440 /etc/sudoers.d/vscode \
    && mkdir -p /home/vscode/.ssh \
    /home/vscode/.config/gcloud \
    /home/vscode/.zsh_history_dir \
    /home/vscode/go/bin \
    && chown -R vscode:vscode /home/vscode


# ---------------------------------------------------------------------------
# Shell configuration — copy dotfiles
# ---------------------------------------------------------------------------
COPY scripts/setup-shell.sh /tmp/setup-shell.sh
RUN chmod +x /tmp/setup-shell.sh \
    && su - vscode -c "bash /tmp/setup-shell.sh" \
    && rm /tmp/setup-shell.sh

# ---------------------------------------------------------------------------
# Health check script
# ---------------------------------------------------------------------------
COPY scripts/check-tools.sh /usr/local/bin/check-tools
RUN chmod +x /usr/local/bin/check-tools

# ---------------------------------------------------------------------------
# Final
# ---------------------------------------------------------------------------
USER vscode
WORKDIR /workspace
RUN ls
CMD ["/bin/zsh"]