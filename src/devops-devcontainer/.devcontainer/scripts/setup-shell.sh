#!/usr/bin/env bash
# =============================================================================
#  setup-shell.sh — Configure zsh with Oh My Zsh, plugins, and dotfiles
#  Runs as the vscode user during image build
# =============================================================================
set -euo pipefail

echo "⚙️  Setting up shell environment..."

# ─── Oh My Zsh ───────────────────────────────────────────────────────────────
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
  "" --unattended

ZSH_CUSTOM="${HOME}/.oh-my-zsh/custom"

# ─── Oh My Zsh plugins ───────────────────────────────────────────────────────
echo "📦  Installing zsh plugins..."

# zsh-autosuggestions
git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions \
  "${ZSH_CUSTOM}/plugins/zsh-autosuggestions"

# zsh-syntax-highlighting
git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting \
  "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting"

# zsh-completions
git clone --depth 1 https://github.com/zsh-users/zsh-completions \
  "${ZSH_CUSTOM}/plugins/zsh-completions"

# fzf-tab
git clone --depth 1 https://github.com/Aloxaf/fzf-tab \
  "${ZSH_CUSTOM}/plugins/fzf-tab"

# ─── .zshrc ──────────────────────────────────────────────────────────────────
echo "✍️   Writing .zshrc..."

cat > "${HOME}/.zshrc" << 'ZSHRC'
# =============================================================================
#  .zshrc — DevOps Power Shell
# =============================================================================

# ── Oh My Zsh ─────────────────────────────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""   # disabled — using starship instead

plugins=(
  git
  git-extras
  docker
  docker-compose
  kubectl
  helm
  terraform
  aws
  gcloud
  ansible
  python
  pip
  node
  npm
  yarn
  golang
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-completions
  sudo
  copypath
  copyfile
  history
  command-not-found
  colored-man-pages
  tmux
)

source "$ZSH/oh-my-zsh.sh"

# ── Git shortcuts ─────────────────────────────────────────────────────────────
alias g='git'
alias gs='git status -sb'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gpl='git pull --rebase'
alias gco='git checkout'
alias gbr='git branch -a'
alias glog='git log --oneline --graph --decorate --all'

# ── Kubernetes ───────────────────────────────────────────────────────────────
alias k='kubectl'
alias kx='kubectx'
alias kn='kubens'
alias kgp='kubectl get pods'
alias kgs='kubectl get svc'
alias kgd='kubectl get deploy'
alias kgn='kubectl get nodes'
alias kdp='kubectl describe pod'
alias kaf='kubectl apply -f'
alias kdf='kubectl delete -f'
alias kl='kubectl logs -f'
alias ke='kubectl exec -it'
alias kctx='kubectx'
alias kns='kubens'

# ── Terraform ────────────────────────────────────────────────────────────────
alias tf='terraform'
alias tfi='terraform init'
alias tfp='terraform plan'
alias tfa='terraform apply'
alias tfd='terraform destroy'
alias tfw='terraform workspace'
alias tg='terragrunt'

# ── Docker ───────────────────────────────────────────────────────────────────
alias d='docker'
alias dc='docker compose'
alias dps='docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dpsa='docker ps -a --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias di='docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedSince}}"'
alias drm='docker rm $(docker ps -aq)'
alias drmi='docker rmi $(docker images -q)'
alias dprune='docker system prune -af --volumes'
alias dlogs='docker logs -f'

# ── Cloud ─────────────────────────────────────────────────────────────────────
alias awswho='aws sts get-caller-identity'
alias awsregion='aws configure get region'

# ── Networking ───────────────────────────────────────────────────────────────
alias myip='curl -s https://ifconfig.me && echo'
alias ports='ss -tulnp'
alias listening='lsof -i -P -n | grep LISTEN'

# ── Productivity ──────────────────────────────────────────────────────────────
alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias ip='ip --color=auto'
alias df='df -h'
alias du='du -sh'
alias free='free -h'
alias top='btop'
alias vim='nvim'
alias vi='nvim'
alias cls='clear'
alias reload='source ~/.zshrc'
alias path='echo $PATH | tr ":" "\n"'

# ── Useful functions ─────────────────────────────────────────────────────────

# kubectl fuzzy pod exec

# switch AWS profile interactively
awsp() {
  local profile
  profile=$(aws configure list-profiles | fzf)
  export AWS_PROFILE="$profile"
  echo "✅ AWS_PROFILE=$AWS_PROFILE"
}

# decode base64 kubectl secret
ksecret() {
  kubectl get secret "$1" -o json | jq '.data | map_values(@base64d)'
}

# git worktree list pretty
gwl() {
  git worktree list | column -t
}

# Quick HTTP server in current dir
serve() {
  python3 -m http.server "${1:-8080}"
}

# ── PATH extras ──────────────────────────────────────────────────────────────
export GOPATH="$HOME/go"
export GOROOT="/usr/local/go"
export PATH="$GOROOT/bin:$GOPATH/bin:$HOME/.pulumi/bin:$HOME/.local/bin:$PATH"

# ── History ───────────────────────────────────────────────────────────────────
export HISTSIZE=100000
export HISTFILESIZE=100000
export HISTCONTROL=ignoreboth:erasedups
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt INC_APPEND_HISTORY_TIME
setopt EXTENDED_HISTORY
export HISTFILE="$HOME/.zsh_history_dir/.zsh_history"

# ── Completions ───────────────────────────────────────────────────────────────
autoload -Uz compinit && compinit -u
source <(kubectl completion zsh)
source <(helm completion zsh)
source <(flux completion zsh)
complete -C '/usr/bin/aws_completer' aws
eval "$(register-python-argcomplete pipx)" 2>/dev/null || true

# ── Welcome message ───────────────────────────────────────────────────────────
echo "🚀 DevOps Power Container ready — type 'check-tools' to verify all 40 tools"
ZSHRC

echo "✅  Shell setup complete"
