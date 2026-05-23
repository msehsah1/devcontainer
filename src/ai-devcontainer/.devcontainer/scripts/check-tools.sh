#!/usr/bin/env bash
# =============================================================================
#  check-tools — Comprehensive DevOps tool inventory
#  Covers: installed tools + networking + debugging + system + crypto + DB
# =============================================================================

BOLD='\033[1m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
DIM='\033[2m'
RESET='\033[0m'

SUMMARY_MODE=false
CATEGORY_FILTER=""

usage() {
  echo "Usage: check-tools [--summary] [--category <name>]"
  echo ""
  echo "  --summary              Print only pass/fail counts, no details"
  echo "  --category <name>      Filter to one category (case-insensitive)"
  echo ""
  echo "  Categories: vcs, container, kubernetes, iac, security, cloud,"
  echo "              languages, data, networking, debugging, system,"
  echo "              crypto, database, shell, editors"
  echo ""
  exit 0
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --summary)   SUMMARY_MODE=true ;;
    --category)  CATEGORY_FILTER="${2,,}"; shift ;;
    --help|-h)   usage ;;
  esac
  shift
done

# ─── Counters ──────────────────────────────────────────────────────────────────
declare -A CAT_PASS
declare -A CAT_FAIL
PASS=0
FAIL=0
TOTAL=0
WARN=0

# ─── check() ─────────────────────────────────────────────────────────────────
# Usage: check <display-name> <category> <binary> [version-flag] [note]
check() {
  local name="$1"
  local category="${2,,}"
  local cmd="$3"
  local version_flag="${4:---version}"
  local note="${5:-}"

  # Filter by category if requested
  [[ -n "$CATEGORY_FILTER" && "$category" != "$CATEGORY_FILTER" ]] && return

  TOTAL=$((TOTAL + 1))

  if command -v "$cmd" &>/dev/null; then
    local ver
    ver=$($cmd $version_flag 2>&1 | head -1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1)
    ver="${ver:-?}"

    CAT_PASS[$category]=$(( ${CAT_PASS[$category]:-0} + 1 ))
    PASS=$((PASS + 1))

    if [ "$SUMMARY_MODE" = false ]; then
      local note_str=""
      [[ -n "$note" ]] && note_str=" ${DIM}(${note})${RESET}"
      printf "  ${GREEN}✓${RESET} %-22s ${DIM}%-28s${RESET} ${CYAN}v%-16s${RESET}%s\n" \
        "$name" "$cmd" "$ver" "$note_str"
    fi
  else
    CAT_FAIL[$category]=$(( ${CAT_FAIL[$category]:-0} + 1 ))
    FAIL=$((FAIL + 1))

    if [ "$SUMMARY_MODE" = false ]; then
      local note_str=""
      [[ -n "$note" ]] && note_str=" ${DIM}(${note})${RESET}"
      printf "  ${RED}✗${RESET} %-22s ${RED}not found${RESET}%s\n" "$name" "$note_str"
    fi
  fi
}

# check_cmd: for tools where version extraction needs a full custom command
# Usage: check_cmd <display-name> <category> <binary> <version-cmd> [note]
check_cmd() {
  local name="$1"
  local category="${2,,}"
  local cmd="$3"
  local ver_cmd="$4"
  local note="${5:-}"

  [[ -n "$CATEGORY_FILTER" && "$category" != "$CATEGORY_FILTER" ]] && return

  TOTAL=$((TOTAL + 1))

  if command -v "$cmd" &>/dev/null; then
    local ver
    ver=$(eval "$ver_cmd" 2>&1 | head -1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1)
    ver="${ver:-?}"

    CAT_PASS[$category]=$(( ${CAT_PASS[$category]:-0} + 1 ))
    PASS=$((PASS + 1))

    if [ "$SUMMARY_MODE" = false ]; then
      local note_str=""
      [[ -n "$note" ]] && note_str=" ${DIM}(${note})${RESET}"
      printf "  ${GREEN}✓${RESET} %-22s ${DIM}%-28s${RESET} ${CYAN}v%-16s${RESET}%s\n" \
        "$name" "$cmd" "$ver" "$note_str"
    fi
  else
    CAT_FAIL[$category]=$(( ${CAT_FAIL[$category]:-0} + 1 ))
    FAIL=$((FAIL + 1))

    if [ "$SUMMARY_MODE" = false ]; then
      local note_str=""
      [[ -n "$note" ]] && note_str=" ${DIM}(${note})${RESET}"
      printf "  ${RED}✗${RESET} %-22s ${RED}not found${RESET}%s\n" "$name" "$note_str"
    fi
  fi
}

header() {
  local label="$1"
  local cat="${2,,}"

  [[ -n "$CATEGORY_FILTER" && "$cat" != "$CATEGORY_FILTER" ]] && return

  if [ "$SUMMARY_MODE" = false ]; then
    echo -e "\n${BOLD}${BLUE}┌─ ${CYAN}${label}${RESET}"
  fi
}

cat_summary() {
  local cat="${1,,}"
  local label="$2"

  [[ -n "$CATEGORY_FILTER" && "$cat" != "$CATEGORY_FILTER" ]] && return

  local p="${CAT_PASS[$cat]:-0}"
  local f="${CAT_FAIL[$cat]:-0}"
  local t=$((p + f))

  if [ "$SUMMARY_MODE" = false ]; then
    if [ "$f" -eq 0 ]; then
      echo -e "  ${DIM}└ ${GREEN}${p}/${t} installed${RESET}"
    else
      echo -e "  ${DIM}└ ${GREEN}${p}/${t} installed  ${RED}${f} missing${RESET}"
    fi
  fi
}

# ═══════════════════════════════════════════════════════════════════════════════
echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}║           DevOps Power Container — Tool Inventory                ║${RESET}"
echo -e "${BOLD}╚══════════════════════════════════════════════════════════════════╝${RESET}"
[[ -n "$CATEGORY_FILTER" ]] && echo -e "  ${DIM}Filtering by category: ${CYAN}${CATEGORY_FILTER}${RESET}"

# ─────────────────────────────────────────────────────────────────────────────
# 1. VERSION CONTROL
# ─────────────────────────────────────────────────────────────────────────────
header "Version Control" "vcs"
check "Git"                "vcs"  "git"
check "Git LFS"            "vcs"  "git-lfs"        "version"
check "lazygit"            "vcs"  "lazygit"
check "GitHub CLI"         "vcs"  "gh"                                    "gh auth status"
check "GitLab CLI"         "vcs"  "glab"
check "delta"              "vcs"  "delta"                                  "git diff pager"
cat_summary "vcs" "Version Control"

# ─────────────────────────────────────────────────────────────────────────────
# 2. CONTAINERS & IMAGES
# ─────────────────────────────────────────────────────────────────────────────
header "Container & Image Tools" "container"
check "Docker CLI"         "container"  "docker"
check_cmd "Docker Compose" "container"  "docker"   "docker compose version"
check "Skopeo"             "container"  "skopeo"
check "hadolint"           "container"  "hadolint"
check "dive"               "container"  "dive"                            "Docker image layer analyzer"
check "buildx"             "container"  "docker"   "buildx version"
cat_summary "container" "Container"

# ─────────────────────────────────────────────────────────────────────────────
# 3. KUBERNETES
# ─────────────────────────────────────────────────────────────────────────────
header "Kubernetes" "kubernetes"
check_cmd "kubectl"        "kubernetes" "kubectl"  "kubectl version --client --short 2>/dev/null || kubectl version --client"
check "Helm"               "kubernetes" "helm"
check "k9s"                "kubernetes" "k9s"
check "kustomize"          "kubernetes" "kustomize"
check "kubectx"            "kubernetes" "kubectx"                         "context switcher"
check "kubens"             "kubernetes" "kubens"                          "namespace switcher"
check "stern"              "kubernetes" "stern"                           "multi-pod log tailing"
check "kubeseal"           "kubernetes" "kubeseal"                        "Sealed Secrets"
check "flux"               "kubernetes" "flux"                            "GitOps"
check "argocd"             "kubernetes" "argocd"   "version --client"
check "istioctl"           "kubernetes" "istioctl"                        "service mesh"
check "cilium"             "kubernetes" "cilium"                          "eBPF networking"
check_cmd "kubeconform"    "kubernetes" "kubeconform" "kubeconform -v"    "manifest validator"
check "popeye"             "kubernetes" "popeye"                          "cluster sanitizer"
cat_summary "kubernetes" "Kubernetes"

# ─────────────────────────────────────────────────────────────────────────────
# 4. INFRASTRUCTURE AS CODE
# ─────────────────────────────────────────────────────────────────────────────
header "Infrastructure as Code" "iac"
check "Terraform"          "iac"  "terraform"
check "Terragrunt"         "iac"  "terragrunt"
check "Ansible"            "iac"  "ansible"
check "ansible-lint"       "iac"  "ansible-lint"
check "Pulumi"             "iac"  "pulumi"
check "Packer"             "iac"  "packer"                                "image builder"
cat_summary "iac" "IaC"

# ─────────────────────────────────────────────────────────────────────────────
# 5. SECURITY & SECRETS
# ─────────────────────────────────────────────────────────────────────────────
header "Security & Secrets" "security"
check "Vault CLI"          "security"  "vault"
check "Trivy"              "security"  "trivy"
check "SOPS"               "security"  "sops"
check "age"                "security"  "age"
check "age-keygen"         "security"  "age-keygen"
check "hadolint"           "security"  "hadolint"                         "Dockerfile linter"
check "pre-commit"         "security"  "pre-commit"
check "cosign"             "security"  "cosign"                           "container signing"
check "grype"              "security"  "grype"                            "vulnerability scanner"
check "syft"               "security"  "syft"                             "SBOM generator"
cat_summary "security" "Security"

# ─────────────────────────────────────────────────────────────────────────────
# 6. CLOUD CLIs
# ─────────────────────────────────────────────────────────────────────────────
header "Cloud CLIs" "cloud"
check "AWS CLI"            "cloud"  "aws"
check "Azure CLI"          "cloud"  "az"
check "gcloud"             "cloud"  "gcloud"
check "act"                "cloud"  "act"                                 "GitHub Actions locally"
cat_summary "cloud" "Cloud"

# ─────────────────────────────────────────────────────────────────────────────
# 7. NETWORKING & HTTP
# ─────────────────────────────────────────────────────────────────────────────
header "Networking & HTTP" "networking"
check "curl"               "networking"  "curl"
check "wget"               "networking"  "wget"
check "httpie"             "networking"  "http"                           "human-friendly HTTP"
check "grpcurl"            "networking"  "grpcurl"                        "gRPC client"
check "nmap"               "networking"  "nmap"                           "port/host scanner"
check "ncat"               "networking"  "ncat"                           "netcat reimplemented"
check "socat"              "networking"  "socat"                          "socket relay"
check "mtr"                "networking"  "mtr"                            "traceroute + ping"
check "dig"                "networking"  "dig"                            "DNS lookup"
check "nslookup"           "networking"  "nslookup"                       "DNS query"
check "host"               "networking"  "host"                           "DNS lookup (simple)"
check "ping"               "networking"  "ping"
check "traceroute"         "networking"  "traceroute"
check "ss"                 "networking"  "ss"                             "socket statistics (netstat replacement)"
check "ip"                 "networking"  "ip"                             "routing/interfaces (ifconfig replacement)"
check "arp"                "networking"  "arp"
check "tcpdump"            "networking"  "tcpdump"                        "packet capture"
check "tshark"             "networking"  "tshark"                         "Wireshark CLI"
check "iperf3"             "networking"  "iperf3"                         "bandwidth measurement"
check "openssl"            "networking"  "openssl"                        "TLS/cert testing"
cat_summary "networking" "Networking"

# ─────────────────────────────────────────────────────────────────────────────
# 8. DEBUGGING & TRACING
# ─────────────────────────────────────────────────────────────────────────────
header "Debugging & Tracing" "debugging"
check "strace"             "debugging"  "strace"                          "syscall tracer"
check "ltrace"             "debugging"  "ltrace"                          "library call tracer"
check "lsof"               "debugging"  "lsof"                            "list open files/sockets"
check "pstree"             "debugging"  "pstree"                          "process tree"
check "fuser"              "debugging"  "fuser"                           "who uses a file/port"
check "gdb"                "debugging"  "gdb"                             "GNU debugger"
check "perf"               "debugging"  "perf"                            "Linux perf events"
check "dmesg"              "debugging"  "dmesg"                           "kernel ring buffer"
check "journalctl"         "debugging"  "journalctl"                      "systemd log viewer"
check "inotifywait"        "debugging"  "inotifywait"                     "filesystem event watcher"
check "stdbuf"             "debugging"  "stdbuf"                          "buffer control for pipes"
check "timeout"            "debugging"  "timeout"                         "run cmd with time limit"
cat_summary "debugging" "Debugging"

# ─────────────────────────────────────────────────────────────────────────────
# 9. SYSTEM & PERFORMANCE
# ─────────────────────────────────────────────────────────────────────────────
header "System & Performance" "system"
check "btop"               "system"  "btop"                               "resource monitor (TUI)"
check "htop"               "system"  "htop"                               "process viewer"
check "iotop"              "system"  "iotop"                              "I/O monitor"
check "vmstat"             "system"  "vmstat"                             "VM/process/IO stats"
check "iostat"             "system"  "iostat"                             "CPU/disk I/O stats"
check "sar"                "system"  "sar"                                "system activity reporter"
check "free"               "system"  "free"                               "memory usage"
check "df"                 "system"  "df"                                 "disk free"
check "du"                 "system"  "du"                                 "disk usage"
check "lscpu"              "system"  "lscpu"                              "CPU architecture info"
check "lsblk"              "system"  "lsblk"                              "block devices"
check "tmux"               "system"  "tmux"                               "terminal multiplexer"
cat_summary "system" "System"

# ─────────────────────────────────────────────────────────────────────────────
# 10. CRYPTO & CERTIFICATES
# ─────────────────────────────────────────────────────────────────────────────
header "Crypto & Certificates" "crypto"
check "openssl"            "crypto"  "openssl"                            "TLS certs, encryption"
check "cfssl"              "crypto"  "cfssl"                              "CloudFlare PKI toolkit"
check "cfssljson"          "crypto"  "cfssljson"                          "CloudFlare PKI JSON"
check "step"               "crypto"  "step"                               "smallstep CLI (ACME/mTLS)"
check "gpg"                "crypto"  "gpg"                                "GNU Privacy Guard"
check "ssh"                "crypto"  "ssh"                                "OpenSSH client"
check "ssh-keygen"         "crypto"  "ssh-keygen"
check "base64"             "crypto"  "base64"
check "age"                "crypto"  "age"                                "modern encryption"
cat_summary "crypto" "Crypto"

# ─────────────────────────────────────────────────────────────────────────────
# 11. DATABASE CLIENTS
# ─────────────────────────────────────────────────────────────────────────────
header "Database Clients" "database"
check "psql"               "database"  "psql"                             "PostgreSQL client"
check "pgcli"              "database"  "pgcli"                            "PostgreSQL (enhanced)"
check "mysql"              "database"  "mysql"                            "MySQL client"
check "redis-cli"          "database"  "redis-cli"                        "Redis client"
check "mongosh"            "database"  "mongosh"                          "MongoDB shell"
check "sqlite3"            "database"  "sqlite3"                          "SQLite client"
check "usql"               "database"  "usql"                             "universal SQL client"
cat_summary "database" "Database"

# ─────────────────────────────────────────────────────────────────────────────
# 12. DATA & TEXT PROCESSING
# ─────────────────────────────────────────────────────────────────────────────
header "Data & Text Processing" "data"
check "jq"                 "data"  "jq"                                   "JSON processor"
check "yq"                 "data"  "yq"                                   "YAML/JSON/TOML processor"
check "gron"               "data"  "gron"                                 "make JSON greppable"
check "fx"                 "data"  "fx"                                   "interactive JSON viewer"
check "xsv"                "data"  "xsv"                                  "CSV toolkit"
check "awk"                "data"  "awk"
check "sed"                "data"  "sed"
check "grep"               "data"  "grep"
check "ripgrep"            "data"  "rg"                                   "fast grep"
check "column"             "data"  "column"                               "tabulate text"
check "envsubst"           "data"  "envsubst"                             "env var substitution"
check "base64"             "data"  "base64"
check "xxd"                "data"  "xxd"                                  "hex dump"
check "bc"                 "data"  "bc"                                   "arbitrary precision calc"
cat_summary "data" "Data"

# ─────────────────────────────────────────────────────────────────────────────
# 13. LANGUAGES & RUNTIMES
# ─────────────────────────────────────────────────────────────────────────────
header "Languages & Runtimes" "languages"
check "Python 3"           "languages"  "python3"
check "pip"                "languages"  "pip3"
check "poetry"             "languages"  "poetry"
check "Node.js"            "languages"  "node"
check "npm"                "languages"  "npm"
check "yarn"               "languages"  "yarn"
check "pnpm"               "languages"  "pnpm"
check "Go"                 "languages"  "go"
check "Rust (rustc)"       "languages"  "rustc"
check "cargo"              "languages"  "cargo"
check "Ruby"               "languages"  "ruby"
check "Java"               "languages"  "java"
check "Make"               "languages"  "make"
check "gcc"                "languages"  "gcc"
cat_summary "languages" "Languages"

# ─────────────────────────────────────────────────────────────────────────────
# 14. SHELL & DEVELOPER UX
# ─────────────────────────────────────────────────────────────────────────────
header "Shell & Developer UX" "shell"
check "zsh"                "shell"  "zsh"
check "bash"               "shell"  "bash"
check "btop"               "shell"  "btop"                                "resource monitor"
check "direnv"             "shell"  "direnv"                              "per-dir env vars"
check "tree"               "shell"  "tree"                                "directory tree"
check "tldr"               "shell"  "tldr"                                "simplified man pages"
check "cheat"              "shell"  "cheat"                               "cheatsheets in terminal"
check "act"                "shell"  "act"                                 "run GitHub Actions locally"
cat_summary "shell" "Shell"

# ─────────────────────────────────────────────────────────────────────────────
# SUMMARY
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}══════════════════════════════════════════════════════════════════${RESET}"

if [ "$SUMMARY_MODE" = true ] || [ -n "$CATEGORY_FILTER" ]; then
  # Per-category breakdown
  declare -A CAT_LABELS
  CAT_LABELS=(
    [vcs]="Version Control"
    [container]="Container Tools"
    [kubernetes]="Kubernetes"
    [iac]="Infrastructure as Code"
    [security]="Security & Secrets"
    [cloud]="Cloud CLIs"
    [networking]="Networking & HTTP"
    [debugging]="Debugging & Tracing"
    [system]="System & Performance"
    [crypto]="Crypto & Certificates"
    [database]="Database Clients"
    [data]="Data & Text"
    [languages]="Languages & Runtimes"
    [shell]="Shell & DevUX"
  )

  ORDER=(vcs container kubernetes iac security cloud networking debugging system crypto database data languages shell)

  for cat in "${ORDER[@]}"; do
    [[ -n "$CATEGORY_FILTER" && "$cat" != "$CATEGORY_FILTER" ]] && continue
    local_p="${CAT_PASS[$cat]:-0}"
    local_f="${CAT_FAIL[$cat]:-0}"
    local_t=$((local_p + local_f))
    [[ $local_t -eq 0 ]] && continue

    label="${CAT_LABELS[$cat]}"
    if [ "$local_f" -eq 0 ]; then
      printf "  ${GREEN}✓${RESET} %-28s ${GREEN}%d/%d${RESET}\n" "$label" "$local_p" "$local_t"
    else
      printf "  ${YELLOW}~${RESET} %-28s ${GREEN}%d${RESET}/${local_t}  ${RED}(%d missing)${RESET}\n" \
        "$label" "$local_p" "$local_f"
    fi
  done
  echo ""
fi

if [ "$FAIL" -eq 0 ]; then
  echo -e "${BOLD}${GREEN}✅  All ${PASS}/${TOTAL} tools are installed and ready!${RESET}"
else
  PCT=$(( (PASS * 100) / TOTAL ))
  echo -e "${BOLD}${YELLOW}⚠️   ${PASS}/${TOTAL} installed (${PCT}%)  —  ${RED}${FAIL} not found${RESET}"
  echo ""
  echo -e "${DIM}Missing tools are optional unless your workflow requires them.${RESET}"
  echo -e "${DIM}To install missing tools, update the Dockerfile and rebuild.${RESET}"
fi

echo ""
echo -e "${DIM}Tips:${RESET}"
echo -e "${DIM}  check-tools --summary              → counts per category${RESET}"
echo -e "${DIM}  check-tools --category networking  → filter one category${RESET}"
echo ""

exit 0