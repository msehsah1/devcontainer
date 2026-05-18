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
ARG KUBECTL_VERSION=v1.36.0
ARG HELM_VERSION=v4.0.0
ARG KUSTOMIZE_VERSION=v5.4.1
ARG KUBECTX_VERSION=v0.10.0
ARG STERN_VERSION=v1.33.0
ARG SKOPEO_VERSION=1.20.1

# --- Infrastructure as Code ---
ARG TERRAFORM_VERSION=1.15.3
ARG PULUMI_VERSION=v3.237.0

# --- Security & Secrets ---
ARG VAULT_VERSION=2.0.0
ARG SOPS_VERSION=v3.13.1

# --- Container ---
ARG HADOLINT_VERSION=v2.14.0

# --- Cloud CLIs ---
ARG AWSCLI_VERSION=2.34.45
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
    mysql-client \
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

# ---------------------------------------------------------------------------
# 4 — kubectl   (Tool #3)
# ---------------------------------------------------------------------------
RUN curl -fsSL "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" \
    -o /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl \
    && kubectl version --client

# ---------------------------------------------------------------------------
# 5 — Helm   (Tool #4)
# ---------------------------------------------------------------------------
RUN curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | \
    DESIRED_VERSION=${HELM_VERSION} bash \
    && helm version


# ---------------------------------------------------------------------------
# 7 — kustomize   (Tool #6)
# ---------------------------------------------------------------------------
RUN curl -fsSL "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2F${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_amd64.tar.gz" \
    | tar -xz -C /usr/local/bin kustomize \
    && chmod +x /usr/local/bin/kustomize \
    && kustomize version

# ---------------------------------------------------------------------------
# 8 — kubectx + kubens   (Tool #7)
# ---------------------------------------------------------------------------
RUN curl -fsSL "https://github.com/ahmetb/kubectx/releases/download/${KUBECTX_VERSION}/kubectx_${KUBECTX_VERSION}_linux_x86_64.tar.gz" \
    | tar -xz -C /usr/local/bin kubectx \
    && curl -fsSL "https://github.com/ahmetb/kubectx/releases/download/${KUBECTX_VERSION}/kubens_${KUBECTX_VERSION}_linux_x86_64.tar.gz" \
    | tar -xz -C /usr/local/bin kubens \
    && chmod +x /usr/local/bin/kubectx /usr/local/bin/kubens

# ---------------------------------------------------------------------------
# 9 — stern (Kubernetes log tailing)   (Tool #8)
# ---------------------------------------------------------------------------
RUN curl -fsSL "https://github.com/stern/stern/releases/download/${STERN_VERSION}/stern_${STERN_VERSION#v}_linux_amd64.tar.gz" \
    | tar -xz -C /usr/local/bin stern \
    && chmod +x /usr/local/bin/stern \
    && stern --version

# ---------------------------------------------------------------------------
# 10 — Terraform   (Tool #9)
# ---------------------------------------------------------------------------
RUN wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
    > /etc/apt/sources.list.d/hashicorp.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
    terraform=${TERRAFORM_VERSION}-1 \
    vault \
    && rm -rf /var/lib/apt/lists/* \
    && terraform version

# ---------------------------------------------------------------------------
# 13 — Ansible   (Tool #12)
# ---------------------------------------------------------------------------
RUN apt-get update \
    && apt-get install -y --no-install-recommends pipx \
    && rm -rf /var/lib/apt/lists/* \
    && pipx install ansible \
    && pipx install ansible-lint \
    && pipx ensurepath

# ---------------------------------------------------------------------------
# 14 — Pulumi   (Tool #13)
# ---------------------------------------------------------------------------
RUN curl -fsSL https://get.pulumi.com | sh -s -- --version ${PULUMI_VERSION#v} \
    && install -m 0755 /root/.pulumi/bin/pulumi /usr/local/bin/pulumi \
    && pulumi version

# ---------------------------------------------------------------------------
# 15 — AWS CLI v2   (Tool #14)
# ---------------------------------------------------------------------------
RUN curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWSCLI_VERSION}.zip" \
    -o /tmp/awscliv2.zip \
    && unzip -q /tmp/awscliv2.zip -d /tmp \
    && /tmp/aws/install \
    && rm -rf /tmp/awscliv2.zip /tmp/aws \
    && aws --version

# ---------------------------------------------------------------------------
# 16 — Azure CLI   (Tool #15)
# ---------------------------------------------------------------------------
RUN curl -fsSL https://aka.ms/InstallAzureCLIDeb | bash \
    && az --version | head -1

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
# 19 — SOPS (Secret OPerationS)   (Tool #18)
# ---------------------------------------------------------------------------
RUN curl -fsSL "https://github.com/getsops/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux.amd64" \
    -o /usr/local/bin/sops \
    && chmod +x /usr/local/bin/sops \
    && sops --version

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
    && pre-commit --version \
    && http --version \
    && poetry --version \
    && pipenv --version

# ---------------------------------------------------------------------------
# 37 — Skopeo (container image inspection)   (Tool #37)
# ---------------------------------------------------------------------------
RUN apt-get update \
    && apt-get install -y --no-install-recommends skopeo \
    && rm -rf /var/lib/apt/lists/* \
    && skopeo --version

# ---------------------------------------------------------------------------
# 39 — flux CLI (GitOps)   (Tool #39)
# ---------------------------------------------------------------------------
RUN curl -fsSL https://fluxcd.io/install.sh | bash \
    && flux --version

# ---------------------------------------------------------------------------
# 40 — argocd CLI   (Tool #40)
# ---------------------------------------------------------------------------
RUN ARGOCD_VERSION=$(curl -fsSL https://api.github.com/repos/argoproj/argo-cd/releases/latest \
    | jq -r '.tag_name') \
    && curl -fsSL "https://github.com/argoproj/argo-cd/releases/download/${ARGOCD_VERSION}/argocd-linux-amd64" \
    -o /usr/local/bin/argocd \
    && chmod +x /usr/local/bin/argocd \
    && argocd version --client

# ---------------------------------------------------------------------------
# User setup — non-root vscode user
# ---------------------------------------------------------------------------
RUN groupadd --gid 1001 vscode \
    && useradd --uid 1001 --gid vscode --shell /bin/zsh \
    --create-home --home-dir /home/vscode vscode \
    && echo "vscode ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/vscode \
    && chmod 0440 /etc/sudoers.d/vscode \
    && mkdir -p /home/vscode/.ssh \
    /home/vscode/.kube \
    /home/vscode/.aws \
    /home/vscode/.azure \
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