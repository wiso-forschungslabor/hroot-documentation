#!/usr/bin/env bash
# ==============================================================================
# HROOT - One-Line Interactive Docker Installer
# Repository: https://github.com/wiso-forschungslabor/hroot-documentation
#
# Usage:
#   bash -c "$(curl -fsSL https://raw.githubusercontent.com/wiso-forschungslabor/hroot-documentation/master/install.sh)"
#   or locally: ./bin/install
# ==============================================================================

set -e

# Ensure current directory and files are writable by the current user
if [ ! -w "." ]; then
  if command -v sudo >/dev/null 2>&1; then
    sudo chown -R "$USER:$(id -gn 2>/dev/null || echo $USER)" . 2>/dev/null || true
  fi
fi

# Helper to read from terminal even when piped via curl | bash (supports automated input via HROOT_NONINTERACTIVE=1)
prompt_read() {
  if [ "${HROOT_NONINTERACTIVE:-}" = "1" ] || [ -n "${CI:-}" ]; then
    read "$@"
  elif [ -t 0 ]; then
    read "$@"
  elif [ -r /dev/tty ] && [ -w /dev/tty ]; then
    read "$@" < /dev/tty
  elif [ -c /dev/tty ] && [ -w /dev/tty ]; then
    read "$@" < /dev/tty
  else
    read "$@"
  fi
}

# Helper to verify sudo access without failing
has_sudo_access() {
  if [ "$(id -u)" -eq 0 ]; then
    return 0
  fi
  if command -v sudo >/dev/null 2>&1; then
    if sudo -v 2>/dev/null; then
      return 0
    fi
  fi
  return 1
}

# Helper function to generate secure random strings
generate_secret() {
  local length="${1:-32}"
  if command -v openssl >/dev/null 2>&1; then
    openssl rand -hex "$length"
  elif [ -c /dev/urandom ]; then
    tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c "$((length * 2))"
  else
    date +%s%N | sha256sum | head -c "$((length * 2))"
  fi
}

# Helper function to detect host routing table and Docker networks to find collision-free RFC 1918 subnets
detect_free_docker_subnets() {
  local OCCUPIED=""
  if command -v ip >/dev/null 2>&1; then
    OCCUPIED=$(ip route show 2>/dev/null | awk '{print $1}' | grep -E '^[0-9]+\.[0-9]+' || true)
  elif command -v netstat >/dev/null 2>&1; then
    OCCUPIED=$(netstat -rn 2>/dev/null | awk '{print $1}' | grep -E '^[0-9]+\.[0-9]+' || true)
  fi

  if command -v docker >/dev/null 2>&1; then
    local DOCKER_SUBNETS
    DOCKER_SUBNETS=$($DOCKER_BASE network inspect $($DOCKER_BASE network ls -q 2>/dev/null) 2>/dev/null | grep -oE '"Subnet": "[^"]+"' | cut -d'"' -f4 || true)
    OCCUPIED=$(printf "%s\n%s\n172.17.0.0/16\n" "$OCCUPIED" "$DOCKER_SUBNETS")
  else
    OCCUPIED=$(printf "%s\n172.17.0.0/16\n" "$OCCUPIED")
  fi

  local CANDIDATE_PAIRS=(
    "10.201.1.0/24 10.201.0.0/24"
    "10.202.1.0/24 10.202.0.0/24"
    "10.210.1.0/24 10.210.0.0/24"
    "10.240.1.0/24 10.240.0.0/24"
    "192.168.210.0/24 192.168.211.0/24"
    "192.168.220.0/24 192.168.221.0/24"
    "172.30.10.0/24 172.30.11.0/24"
  )

  # Check with python3 if available for accurate bitwise CIDR overlap detection
  if command -v python3 >/dev/null 2>&1 && python3 -c "import ipaddress" >/dev/null 2>&1; then
    local SELECTED
    SELECTED=$(python3 -c '
import ipaddress, sys

occupied_raw = sys.stdin.read().split()
occupied = []
for item in occupied_raw:
    try:
        occupied.append(ipaddress.ip_network(item.strip(), strict=False))
    except Exception:
        pass

pairs = [
    ("10.201.1.0/24", "10.201.0.0/24"),
    ("10.202.1.0/24", "10.202.0.0/24"),
    ("10.210.1.0/24", "10.210.0.0/24"),
    ("10.240.1.0/24", "10.240.0.0/24"),
    ("192.168.210.0/24", "192.168.211.0/24"),
    ("192.168.220.0/24", "192.168.221.0/24"),
    ("172.30.10.0/24", "172.30.11.0/24")
]

for app_net, proxy_net in pairs:
    app_obj = ipaddress.ip_network(app_net)
    proxy_obj = ipaddress.ip_network(proxy_net)
    if not any(app_obj.overlaps(o) or proxy_obj.overlaps(o) for o in occupied):
        print(f"{app_net} {proxy_net}")
        sys.exit(0)

print("10.201.1.0/24 10.201.0.0/24")
' <<< "$OCCUPIED")
    echo "$SELECTED"
    return 0
  fi

  # Pure bash fallback
  for pair in "${CANDIDATE_PAIRS[@]}"; do
    local app_cand="${pair%% *}"
    local proxy_cand="${pair##* }"
    local prefix_app="${app_cand%.*.*}"
    local prefix_proxy="${proxy_cand%.*.*}"

    if ! echo "$OCCUPIED" | grep -qE "(${prefix_app}\.|${prefix_proxy}\.)"; then
      echo "$pair"
      return 0
    fi
  done

  echo "10.201.1.0/24 10.201.0.0/24"
}


# ANSI Color formatting
BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${CYAN}${BOLD}"
echo "=================================================================="
echo "           HROOT Docker Installation Wizard                      "
echo "=================================================================="
echo -e "${NC}"
echo -e "${YELLOW}Notice: Authorization & Licensing Requirements${NC}"
echo -e "An authorized access grant for the private HROOT repository is required for installation."
echo -e "Software licenses and access information can be obtained at ${BOLD}https://uhh.de/wiso-hroot-info${NC}."
echo ""
echo "This installer sets up HROOT using precompiled Docker containers."
echo "You can use the official image or connect your own custom fork."
echo "------------------------------------------------------------------"
echo ""


# ==============================================================================
# 1. Pre-Flight System & Docker Check
# ==============================================================================
echo -e "${BOLD}1. Pre-Flight System & Docker Check:${NC}"
DOCKER_CMD="docker compose"
DOCKER_BASE="docker"
CAN_START=false
IS_ROOTLESS=false
DEFAULT_DOCKER_SOCKET="/var/run/docker.sock"

# Check for user-level rootless runtime socket
if [ -n "${XDG_RUNTIME_DIR:-}" ] && [ -S "${XDG_RUNTIME_DIR}/docker.sock" ]; then
  DEFAULT_DOCKER_SOCKET="${XDG_RUNTIME_DIR}/docker.sock"
elif [ -S "/run/user/$(id -u)/docker.sock" ]; then
  DEFAULT_DOCKER_SOCKET="/run/user/$(id -u)/docker.sock"
fi

if command -v docker >/dev/null 2>&1; then
  if docker compose version >/dev/null 2>&1; then
    DOCKER_CMD="docker compose"
    CAN_START=true
  elif command -v docker-compose >/dev/null 2>&1; then
    DOCKER_CMD="docker-compose"
    CAN_START=true
  fi

  if docker info --format '{{.SecurityOptions}}' 2>/dev/null | grep -q 'rootless'; then
    IS_ROOTLESS=true
    echo -e "-> Docker Engine: ${GREEN}Running in Rootless Mode (Secure & Unprivileged)${NC}"
    CTX_HOST=$(docker context inspect --format '{{.Endpoints.docker.Host}}' 2>/dev/null | sed 's#unix://##' || true)
    if [ -S "$CTX_HOST" ]; then
      DEFAULT_DOCKER_SOCKET="$CTX_HOST"
    fi
  elif docker info >/dev/null 2>&1; then
    echo -e "-> Docker Engine: ${GREEN}Running and accessible${NC}"
  else
    echo -e "${YELLOW}Notice: Docker is installed, but user '${USER}' cannot access Docker daemon without sudo in the current session.${NC}"
    ROOTLESS_SETUP=false
    if command -v dockerd-rootless-setuptool.sh >/dev/null 2>&1; then
      prompt_read -r -p "Initialize Rootless Docker for '${USER}' now? (Recommended for secure, root-free operations) [Y/n]: " DO_ROOTLESS
      DO_ROOTLESS="${DO_ROOTLESS:-Y}"
      if [[ "$DO_ROOTLESS" =~ ^[Yy]$ ]]; then
        if command -v loginctl >/dev/null 2>&1 && has_sudo_access; then
          sudo loginctl enable-linger "$USER" 2>/dev/null || true
        fi
        if dockerd-rootless-setuptool.sh install; then
          systemctl --user enable --now docker 2>/dev/null || true
          export DOCKER_HOST="unix:///run/user/$(id -u)/docker.sock"
          DEFAULT_DOCKER_SOCKET="/run/user/$(id -u)/docker.sock"
          IS_ROOTLESS=true
          CAN_START=true
          DOCKER_CMD="docker compose"
          DOCKER_BASE="docker"
          ROOTLESS_SETUP=true
          echo -e "${GREEN}-> Rootless Docker initialized and started successfully.${NC}"
        fi
      fi
    fi

    if [ "$ROOTLESS_SETUP" != true ]; then
      if has_sudo_access; then
        echo -e "-> Continuing with sudo-based Docker commands for deployment tasks."
        DOCKER_CMD="sudo $DOCKER_CMD"
        DOCKER_BASE="sudo docker"
      else
        echo -e "   Tip: Run deployment commands with sudo:"
        echo -e "   ${BOLD}sudo docker compose up -d${NC}"
        echo -e "   Or run: ${BOLD}dockerd-rootless-setuptool.sh install && systemctl --user enable --now docker${NC}"
      fi
    fi
  fi
else
  echo -e "${YELLOW}Notice: Docker is not installed on this system.${NC}"
  HAS_PKG_MGR=false
  PKG_MGR_NAME=""
  if command -v apt-get >/dev/null 2>&1; then
    HAS_PKG_MGR=true
    PKG_MGR_NAME="apt (Debian/Ubuntu)"
  elif command -v dnf >/dev/null 2>&1; then
    HAS_PKG_MGR=true
    PKG_MGR_NAME="dnf (RHEL/AlmaLinux/Rocky/Fedora)"
  elif command -v yum >/dev/null 2>&1; then
    HAS_PKG_MGR=true
    PKG_MGR_NAME="yum (CentOS/RHEL)"
  elif command -v pacman >/dev/null 2>&1; then
    HAS_PKG_MGR=true
    PKG_MGR_NAME="pacman (Arch Linux)"
  fi

  if [ "$HAS_PKG_MGR" = true ] && has_sudo_access; then
    echo -e "\nOptions:"
    echo "1) Install Standard Docker & Compose (via ${PKG_MGR_NAME} & sudo) [Default]"
    echo "2) Install Rootless Docker (Recommended: isolated, secure & root-free daemon)"
    echo "3) Continue anyway (generate configuration files only, install Docker later)"
    echo "4) Abort installation"
    prompt_read -r -p "Select option [1/2/3/4]: " DOCKER_CHOICE
    DOCKER_CHOICE="${DOCKER_CHOICE:-1}"

    if [ "$DOCKER_CHOICE" = "1" ]; then
      echo -e "\nInstalling Docker and Docker Compose plugin..."
      INSTALL_OK=false
      if command -v apt-get >/dev/null 2>&1; then
        if sudo apt-get update -y && sudo apt-get install -y docker.io docker-compose-v2; then
          INSTALL_OK=true
        fi
      elif command -v dnf >/dev/null 2>&1; then
        if sudo dnf install -y docker docker-compose-plugin 2>/dev/null || sudo dnf install -y docker-ce docker-compose-plugin; then
          sudo systemctl enable --now docker 2>/dev/null || true
          INSTALL_OK=true
        fi
      elif command -v yum >/dev/null 2>&1; then
        if sudo yum install -y docker docker-compose-plugin 2>/dev/null; then
          sudo systemctl enable --now docker 2>/dev/null || true
          INSTALL_OK=true
        fi
      elif command -v pacman >/dev/null 2>&1; then
        if sudo pacman -Sy --noconfirm docker docker-compose; then
          sudo systemctl enable --now docker 2>/dev/null || true
          INSTALL_OK=true
        fi
      fi

      if [ "$INSTALL_OK" = true ]; then
        echo -e "${GREEN}-> Docker installed successfully.${NC}"
        CAN_START=true
        DOCKER_CMD="sudo docker compose"
        DOCKER_BASE="sudo docker"
      else
        echo -e "${RED}Error: Automated package installation encountered an issue.${NC}"
        echo -e "Please ask your system administrator to install Docker & Docker Compose v2."
      fi
    elif [ "$DOCKER_CHOICE" = "2" ]; then
      echo -e "\nInstalling Rootless Docker dependencies..."
      ROOTLESS_OK=false
      if command -v apt-get >/dev/null 2>&1; then
        if sudo apt-get update -y && sudo apt-get install -y uidmap slirp4netns dbus-user-session docker.io docker-compose-v2; then
          ROOTLESS_OK=true
        fi
      elif command -v dnf >/dev/null 2>&1; then
        if sudo dnf install -y shadow-utils slirp4netns fuse-overlayfs docker docker-compose-plugin; then
          ROOTLESS_OK=true
        fi
      fi

      if [ "$ROOTLESS_OK" = true ]; then
        # Configure unprivileged ports for 80 and 443
        if [ -d /etc/sysctl.d ]; then
          echo "net.ipv4.ip_unprivileged_port_start=80" | sudo tee /etc/sysctl.d/50-rootless-docker.conf >/dev/null 2>&1 || true
          sudo sysctl -w net.ipv4.ip_unprivileged_port_start=80 >/dev/null 2>&1 || true
        fi
        # Enable lingering so user services persist after logout
        if command -v loginctl >/dev/null 2>&1; then
          sudo loginctl enable-linger "$USER" 2>/dev/null || true
        fi
        if command -v dockerd-rootless-setuptool.sh >/dev/null 2>&1; then
          dockerd-rootless-setuptool.sh install || true
          systemctl --user enable --now docker 2>/dev/null || true
          export DOCKER_HOST="unix:///run/user/$(id -u)/docker.sock"
          DEFAULT_DOCKER_SOCKET="/run/user/$(id -u)/docker.sock"
          IS_ROOTLESS=true
          CAN_START=true
          DOCKER_CMD="docker compose"
          DOCKER_BASE="docker"
          echo -e "${GREEN}-> Rootless Docker initialized successfully.${NC}"
        else
          echo -e "${YELLOW}Notice: Standard Docker packages installed. Run dockerd-rootless-setuptool.sh install to complete rootless setup.${NC}"
          CAN_START=true
          DOCKER_CMD="sudo docker compose"
          DOCKER_BASE="sudo docker"
        fi
      else
        echo -e "${RED}Error: Could not install Rootless Docker packages.${NC}"
      fi
    elif [ "$DOCKER_CHOICE" = "4" ]; then
      echo -e "\nInstallation aborted. Please install Docker and restart the installer."
      exit 0
    else
      echo -e "\nContinuing in configuration-only mode..."
    fi
  else
    echo -e "   Notice: Docker is not installed and automated privilege is unavailable."
    echo -e "   Please ask your system administrator to install Docker Engine and Docker Compose v2."
    echo -e "   Ubuntu/Debian: ${BOLD}sudo apt update && sudo apt install -y docker.io docker-compose-v2${NC}"
    echo -e "   RHEL/AlmaLinux: ${BOLD}sudo dnf install -y docker docker-compose-plugin${NC}\n"
    prompt_read -r -p "Do you want to continue generating configuration files only? [y/N]: " CONT_CONF
    CONT_CONF="${CONT_CONF:-N}"
    if [[ ! "$CONT_CONF" =~ ^[Yy]$ ]]; then
      echo -e "\nInstallation aborted."
      exit 0
    fi
  fi
fi
echo ""


# ==============================================================================
# 2. GitHub Authorization & Registry Authentication
# ==============================================================================
echo -e "${BOLD}2. GitHub Authorization Credentials:${NC}"
echo "Please provide your authorized GitHub credentials to access the container registry."

if [ -z "$GITHUB_USER" ]; then
  prompt_read -r -p "GitHub Username: " GITHUB_USER
fi

if [ -z "$GITHUB_TOKEN" ]; then
  echo -e "\nEnter your GitHub Personal Access Token (classic with 'repo' & 'read:packages' scopes):"
  prompt_read -r -s -p "GitHub Token (PAT): " GITHUB_TOKEN
  echo ""
fi

if [ -z "$GITHUB_USER" ] || [ -z "$GITHUB_TOKEN" ]; then
  echo -e "\n${RED}Error: GitHub username and Personal Access Token are required.${NC}"
  exit 1
fi

if command -v docker >/dev/null 2>&1; then
  if echo "$GITHUB_TOKEN" | $DOCKER_BASE login ghcr.io -u "$GITHUB_USER" --password-stdin >/dev/null 2>&1; then
    echo -e "-> Successfully authenticated with ${GREEN}ghcr.io${NC}."
  elif command -v sudo >/dev/null 2>&1; then
    if echo "$GITHUB_TOKEN" | sudo docker login ghcr.io -u "$GITHUB_USER" --password-stdin >/dev/null 2>&1; then
      echo -e "-> Authenticated with ${GREEN}ghcr.io${NC} (via sudo fallback)."
    fi
  fi
fi
echo ""


# ==============================================================================
# 3. Installation Directory
# ==============================================================================
if [ -f "Gemfile" ] && [ -f "docker/Dockerfile" ]; then
  DEFAULT_DIR="$(pwd)"
else
  DEFAULT_DIR="$(pwd)/hroot"
fi
echo -e "${BOLD}3. Installation Directory:${NC}"
echo -e "Where should HROOT be installed? (Default: ${CYAN}${DEFAULT_DIR}${NC})"
prompt_read -r -p "Target folder: " INPUT_DIR
TARGET_DIR="${INPUT_DIR:-$DEFAULT_DIR}"
mkdir -p "$TARGET_DIR"
cd "$TARGET_DIR"

if [ ! -w "." ] || ([ -f "docker-compose.yml" ] && [ ! -w "docker-compose.yml" ]); then
  if command -v sudo >/dev/null 2>&1; then
    sudo chown -R "$USER:$(id -gn 2>/dev/null || echo $USER)" . 2>/dev/null || true
  fi
fi

echo -e "-> Using installation directory: ${GREEN}${TARGET_DIR}${NC}\n"


# ==============================================================================
# 4. Docker Image Source
# ==============================================================================
echo -e "${BOLD}4. Docker Image Source:${NC}"
DEFAULT_IMAGE="ghcr.io/wiso-forschungslabor/hroot:latest"
echo "1) Official Upstream (${DEFAULT_IMAGE}) [Default]"
echo "2) Custom GitHub Fork (ghcr.io/<your-account>/hroot:<tag>)"
prompt_read -r -p "Select image source [1/2]: " IMAGE_CHOICE

if [ "$IMAGE_CHOICE" = "2" ]; then
  prompt_read -r -p "Enter your GitHub repository name (e.g. your-university/hroot): " FORK_REPO
  FORK_REPO="${FORK_REPO:-wiso-forschungslabor/hroot}"
  prompt_read -r -p "Enter Docker image tag (Default: latest, or e.g. v4.0-beta5): " FORK_TAG
  FORK_TAG="${FORK_TAG:-latest}"
  HROOT_IMAGE="ghcr.io/${FORK_REPO}:${FORK_TAG}"
  UPDATE_REPO="$FORK_REPO"
  TARGET_BRANCH_NAME="master"
else
  HROOT_IMAGE="$DEFAULT_IMAGE"
  UPDATE_REPO="wiso-forschungslabor/hroot"
  TARGET_BRANCH_NAME="master"
fi
echo -e "-> Using Docker Image: ${GREEN}${HROOT_IMAGE}${NC}\n"


# ==============================================================================
# 5. Network, Domain & SSL Configuration
# ==============================================================================
echo -e "${BOLD}5. Network & Domain Configuration:${NC}"
echo "Enter your target domain (e.g. hroot.example.org or localhost:3000):"
prompt_read -r -p "Domain (Default: localhost:3000): " INPUT_DOMAIN
APP_DOMAIN="${INPUT_DOMAIN:-localhost:3000}"

ENABLE_SSL=false
FORCE_SSL=false
PROXY_MODE="none"
LETSENCRYPT_EMAIL=""
CONTACT_EMAIL=""

if [[ "$APP_DOMAIN" == *"localhost"* ]] || [[ "$APP_DOMAIN" == *"127.0.0.1"* ]]; then
  APP_PROTOCOL="http"
  APP_PORT="${APP_DOMAIN##*:}"
  [ "$APP_PORT" = "$APP_DOMAIN" ] && APP_PORT="3000"
else
  APP_PROTOCOL="https"
  APP_PORT="3000"

  echo -e "\n${BOLD}Reverse Proxy & SSL Architecture:${NC}"
  echo "1) Standard: Built-in NGINX Proxy + Let's Encrypt SSL (Ports 80 & 443) [Default]"
  echo "2) Shared Proxy: Connect to central 'proxy-network' (Multi-Instance setup)"
  echo "3) Standalone / Host Proxy: Expose Port 3000 directly (use existing host Nginx/Apache)"
  prompt_read -r -p "Select architecture [1/2/3]: " PROXY_CHOICE
  PROXY_CHOICE="${PROXY_CHOICE:-1}"

  if [ "$PROXY_CHOICE" = "1" ]; then
    PROXY_MODE="builtin"
    ENABLE_SSL=true
    FORCE_SSL=true

    # Check port availability for 80 and 443
    PORT_CONFLICT=false
    if command -v ss >/dev/null 2>&1; then
      if ss -tuln 2>/dev/null | grep -E ':(80|443) ' >/dev/null 2>&1; then
        PORT_CONFLICT=true
      fi
    elif command -v netstat >/dev/null 2>&1; then
      if netstat -tuln 2>/dev/null | grep -E ':(80|443) ' >/dev/null 2>&1; then
        PORT_CONFLICT=true
      fi
    elif command -v lsof >/dev/null 2>&1; then
      if lsof -i :80 -i :443 >/dev/null 2>&1; then
        PORT_CONFLICT=true
      fi
    fi

    if [ "$PORT_CONFLICT" = true ]; then
      echo -e "${YELLOW}Warning: Port 80 and/or 443 appear to be already in use on this host.${NC}"
      echo "If another webserver (e.g. Apache/Nginx) is running, the built-in proxy cannot bind to 80/443."
      prompt_read -r -p "Continue with built-in proxy anyway? [y/N]: " CONT_PROXY
      CONT_PROXY="${CONT_PROXY:-N}"
      if [[ ! "$CONT_PROXY" =~ ^[Yy]$ ]]; then
        PROXY_MODE="none"
        ENABLE_SSL=false
        FORCE_SSL=false
        APP_PROTOCOL="http"
        echo -e "-> Switched to Standalone mode (Port 3000).\n"
      fi
    fi

    if [ "$ENABLE_SSL" = true ]; then
      echo -e "\nEnter administrator email for Let's Encrypt certificate renewal notices:"
      prompt_read -r -p "Let's Encrypt Email: " LETSENCRYPT_EMAIL
      CONTACT_EMAIL="${LETSENCRYPT_EMAIL}"
    fi
  elif [ "$PROXY_CHOICE" = "2" ]; then
    PROXY_MODE="shared"
    ENABLE_SSL=true
    FORCE_SSL=true
    echo -e "\nEnter administrator email for Let's Encrypt certificate renewal notices:"
    prompt_read -r -p "Let's Encrypt Email: " LETSENCRYPT_EMAIL
    CONTACT_EMAIL="${LETSENCRYPT_EMAIL}"
  else
    PROXY_MODE="none"
    ENABLE_SSL=false
    FORCE_SSL=false
    APP_PROTOCOL="http"
  fi
fi
echo -e "-> Application URL: ${GREEN}${APP_PROTOCOL}://${APP_DOMAIN}${NC}\n"

# Docker IPAM & Subnet Collision Detection
echo -e "${BOLD}Docker Internal Network & Subnet Configuration:${NC}"
echo "Scanning host routing table and Docker networks for RFC 1918 collisions..."
FREE_SUBNET_PAIR=$(detect_free_docker_subnets)
SUGGESTED_APP_SUBNET="${FREE_SUBNET_PAIR%% *}"
SUGGESTED_PROXY_SUBNET="${FREE_SUBNET_PAIR##* }"

echo -e "-> Detected collision-free Docker subnet: ${GREEN}${SUGGESTED_APP_SUBNET}${NC}"
prompt_read -r -p "Application Docker Subnet (Default: ${SUGGESTED_APP_SUBNET}): " INPUT_DOCKER_SUBNET
DOCKER_SUBNET="${INPUT_DOCKER_SUBNET:-$SUGGESTED_APP_SUBNET}"

if [ "$PROXY_MODE" = "shared" ]; then
  echo -e "-> Detected collision-free Shared Proxy subnet: ${GREEN}${SUGGESTED_PROXY_SUBNET}${NC}"
  prompt_read -r -p "Shared Proxy Network Subnet (Default: ${SUGGESTED_PROXY_SUBNET}): " INPUT_PROXY_SUBNET
  DOCKER_PROXY_SUBNET="${INPUT_PROXY_SUBNET:-$SUGGESTED_PROXY_SUBNET}"

  # Ensure proxy-network exists in docker with explicit subnet
  if command -v docker >/dev/null 2>&1; then
    if ! $DOCKER_BASE network inspect proxy-network >/dev/null 2>&1; then
      $DOCKER_BASE network create --subnet="${DOCKER_PROXY_SUBNET}" proxy-network 2>/dev/null || $DOCKER_BASE network create proxy-network 2>/dev/null || true
    fi
  fi
else
  DOCKER_PROXY_SUBNET="$SUGGESTED_PROXY_SUBNET"
fi
echo -e "-> Docker Subnet set: ${GREEN}${DOCKER_SUBNET}${NC}\n"



# ==============================================================================
# 6. Application Timezone Configuration
# ==============================================================================
echo -e "${BOLD}6. Application Timezone Configuration:${NC}"
HOST_TZ="Europe/Berlin"
if [ -f "/etc/timezone" ]; then
  HOST_TZ=$(cat /etc/timezone | tr -d '\r\n ')
elif [ -L "/etc/localtime" ]; then
  HOST_TZ=$(readlink /etc/localtime | sed -n 's/.*zoneinfo\///p')
fi
[ -z "$HOST_TZ" ] && HOST_TZ="Europe/Berlin"

prompt_read -r -p "Application Timezone (Default: ${HOST_TZ}): " INPUT_TIMEZONE
APP_TIMEZONE="${INPUT_TIMEZONE:-$HOST_TZ}"
echo -e "-> Timezone set: ${GREEN}${APP_TIMEZONE}${NC}\n"


# ==============================================================================
# 7. Database Configuration
# ==============================================================================
echo -e "${BOLD}7. Database Configuration:${NC}"
echo "1) Internal Docker MySQL Container (Default — for fresh install or restore from .sql dump)"
echo "2) External / Existing MySQL Database Server (e.g. existing v3 server or university cluster)"
prompt_read -r -p "Select database architecture [1/2]: " DB_CHOICE

if [ "$DB_CHOICE" = "2" ]; then
  prompt_read -r -p "Database Host (e.g. 192.168.1.50 or db.example.org): " CFG_DB_HOST
  CFG_DB_HOST="${CFG_DB_HOST:-localhost}"
  prompt_read -r -p "Database Port (Default: 3306): " CFG_DB_PORT
  CFG_DB_PORT="${CFG_DB_PORT:-3306}"
  prompt_read -r -p "Database Name (Default: hroot_production): " CFG_DB_NAME
  CFG_DB_NAME="${CFG_DB_NAME:-hroot_production}"
  prompt_read -r -p "Database Username (Default: hroot): " CFG_DB_USER
  CFG_DB_USER="${CFG_DB_USER:-hroot}"
  prompt_read -r -p "Database Password: " CFG_DB_PASS
  
  DATABASE_HOST="$CFG_DB_HOST"
  DATABASE_PORT="$CFG_DB_PORT"
  DATABASE_NAME="$CFG_DB_NAME"
  DATABASE_USERNAME="$CFG_DB_USER"
  DATABASE_PASSWORD="$CFG_DB_PASS"
  DB_ROOT_PW=""
else
  DATABASE_HOST="db"
  DATABASE_PORT="3306"
  DATABASE_NAME="hroot_production"
  DATABASE_USERNAME="hroot"
  DATABASE_PASSWORD=$(generate_secret 16)
  DB_ROOT_PW=$(generate_secret 16)
fi
echo -e "-> Database Target: ${GREEN}${DATABASE_USERNAME}@${DATABASE_HOST}:${DATABASE_PORT}/${DATABASE_NAME}${NC}\n"


# ==============================================================================
# 8. In-Browser Setup Security Token
# ==============================================================================
echo -e "${BOLD}8. In-Browser Setup Security Token:${NC}"
DEFAULT_TOKEN=$(generate_secret 16)
echo "Enter a secure token to protect the web setup wizard at /setup."
prompt_read -r -p "Setup Token (Press Enter for auto-generated token: ${DEFAULT_TOKEN}): " INPUT_TOKEN
SETUP_TOKEN="${INPUT_TOKEN:-$DEFAULT_TOKEN}"
echo -e "-> Setup Token set: ${GREEN}${SETUP_TOKEN}${NC}\n"


# ==============================================================================
# 9. SMS Gateway Configuration
# ==============================================================================
echo -e "${BOLD}9. SMS Gateway Configuration:${NC}"
echo "HROOT can dispatch SMS session reminders via an Android Smartphone Gateway."
prompt_read -r -p "Enable SMS Notifications Gateway? [Y/n]: " ENABLE_SMS_INPUT
ENABLE_SMS_INPUT="${ENABLE_SMS_INPUT:-Y}"

SMS_PRIVATE_TOKEN=$(generate_secret 24)

if [[ "$ENABLE_SMS_INPUT" =~ ^[Yy]$ ]]; then
  ENABLE_SMS=true
  COMPOSE_PROFILES="sms"

  echo -e "\n${BOLD}SMS Gateway Routing Architecture:${NC}"
  echo "1) Subpath: ${APP_PROTOCOL}://${APP_DOMAIN}/sms-gateway [Default — uses main domain SSL, no extra DNS]"
  echo "2) Subdomain: ${APP_PROTOCOL}://sms.${APP_DOMAIN} (requires DNS A/CNAME record pointing to this server)"
  prompt_read -r -p "Select SMS architecture [1/2]: " SMS_ROUTING_CHOICE
  SMS_ROUTING_CHOICE="${SMS_ROUTING_CHOICE:-1}"

  if [ "$SMS_ROUTING_CHOICE" = "2" ]; then
    prompt_read -r -p "SMS Gateway Subdomain (Default: sms.${APP_DOMAIN}): " INPUT_SMS_DOMAIN
    SMS_GATEWAY_DOMAIN="${INPUT_SMS_DOMAIN:-sms.${APP_DOMAIN}}"
    SMS_GATEWAY_API_URL="${APP_PROTOCOL}://${SMS_GATEWAY_DOMAIN}/api/3rdparty/v1/messages"
    echo -e "-> SMS Gateway Subdomain: ${GREEN}${SMS_GATEWAY_DOMAIN}${NC}"
  else
    SMS_GATEWAY_DOMAIN=""
    SMS_GATEWAY_API_URL="${APP_PROTOCOL}://${APP_DOMAIN}/sms-gateway/api/3rdparty/v1/messages"
    echo -e "-> SMS Gateway Subpath: ${GREEN}${APP_PROTOCOL}://${APP_DOMAIN}/sms-gateway${NC}"
  fi
  echo -e "-> Android Pairing Token: ${GREEN}${SMS_PRIVATE_TOKEN}${NC}\n"
else
  ENABLE_SMS=false
  COMPOSE_PROFILES=""
  SMS_GATEWAY_DOMAIN=""
  SMS_GATEWAY_API_URL=""
  echo -e "-> SMS Gateway disabled.\n"
fi


# ==============================================================================
# 10. Orchestration Files & Security Keys
# ==============================================================================
echo -e "${BOLD}10. Generating Orchestration Files & Security Keys...${NC}"

if [ ! -f "docker-compose.yml" ]; then
  if [ "$PROXY_MODE" = "builtin" ]; then
    cat <<'EOFCOMPOSE' > docker-compose.yml
services:
  db:
    image: mysql:8.0
    restart: unless-stopped
    command: --default-authentication-plugin=mysql_native_password --sql-mode="STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION"
    volumes:
      - db_data:/var/lib/mysql
      - ./docker/mysql:/docker-entrypoint-initdb.d
    environment:
      TZ: ${APP_TIMEZONE:-Europe/Berlin}
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD:-rootpassword}
      MYSQL_DATABASE: ${DATABASE_NAME:-hroot_production}
      MYSQL_USER: ${DATABASE_USERNAME:-hroot}
      MYSQL_PASSWORD: ${DATABASE_PASSWORD:-hrootpassword}
    ports:
      - "127.0.0.1:${DB_PORT:-3306}:3306"
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 10s
      timeout: 5s
      retries: 5

  web:
    image: ${HROOT_IMAGE:-ghcr.io/wiso-forschungslabor/hroot:latest}
    restart: unless-stopped
    command: ./bin/rails server -b 0.0.0.0
    labels:
      - "com.centurylinklabs.watchtower.enable=true"
    env_file:
      - .env
    volumes:
      - ./.env:/rails/.env
      - ./uploads:/rails/public/uploads
    environment:
      TZ: ${APP_TIMEZONE:-Europe/Berlin}
      RAILS_ENV: ${RAILS_ENV:-production}
      RAILS_MASTER_KEY: ${RAILS_MASTER_KEY:-}
      DATABASE_HOST: ${DATABASE_HOST:-db}
      DATABASE_USERNAME: ${DATABASE_USERNAME:-hroot}
      DATABASE_PASSWORD: ${DATABASE_PASSWORD:-hrootpassword}
      DATABASE_NAME: ${DATABASE_NAME:-hroot_production}
      VIRTUAL_HOST: ${APP_DOMAIN}
      VIRTUAL_PORT: 3000
      LETSENCRYPT_HOST: ${APP_DOMAIN}
      LETSENCRYPT_EMAIL: ${LETSENCRYPT_EMAIL:-${CONTACT_EMAIL}}
    ports:
      - "127.0.0.1:${APP_PORT:-3000}:3000"
    depends_on:
      db:
        condition: service_healthy

  cron:
    image: ${HROOT_IMAGE:-ghcr.io/wiso-forschungslabor/hroot:latest}
    restart: unless-stopped
    command: ./docker/cron-entrypoint.sh
    user: root
    labels:
      - "com.centurylinklabs.watchtower.enable=true"
    env_file:
      - .env
    volumes:
      - ./.env:/rails/.env
      - ./uploads:/rails/public/uploads
    environment:
      TZ: ${APP_TIMEZONE:-Europe/Berlin}
      RAILS_ENV: ${RAILS_ENV:-production}
      DATABASE_HOST: ${DATABASE_HOST:-db}
      DATABASE_USERNAME: ${DATABASE_USERNAME:-hroot}
      DATABASE_PASSWORD: ${DATABASE_PASSWORD:-hrootpassword}
      DATABASE_NAME: ${DATABASE_NAME:-hroot_production}
    depends_on:
      db:
        condition: service_healthy

  updater:
    image: containrrr/watchtower
    restart: unless-stopped
    volumes:
      - ${DOCKER_SOCKET:-/var/run/docker.sock}:/var/run/docker.sock
    environment:
      - DOCKER_API_VERSION=1.44
      - WATCHTOWER_HTTP_API_UPDATE=true
      - WATCHTOWER_HTTP_API_TOKEN=${UPDATE_WEBHOOK_SECRET:-hroot-updater-secret}
      - WATCHTOWER_CLEANUP=true
      - WATCHTOWER_LABEL_ENABLE=true
      - REPO_USER=${UPDATE_GITHUB_USER:-${GITHUB_USER:-}}
      - REPO_PASS=${UPDATE_GITHUB_TOKEN:-}

  sms-gateway:
    image: ghcr.io/android-sms-gateway/server:latest
    profiles: ["sms"]
    restart: unless-stopped
    environment:
      VIRTUAL_HOST: ${SMS_GATEWAY_DOMAIN:-}
      VIRTUAL_PORT: 3000
      LETSENCRYPT_HOST: ${SMS_GATEWAY_DOMAIN:-}
      LETSENCRYPT_EMAIL: ${CONTACT_EMAIL:-}
      DATABASE_HOST: ${DATABASE_HOST:-db}
      DATABASE_USER: ${DATABASE_USERNAME:-hroot}
      DATABASE_PASSWORD: ${DATABASE_PASSWORD:-hrootpassword}
      DATABASE_DATABASE: sms_gateway
      PRIVATE_TOKEN: ${SMS_GATEWAY_PRIVATE_TOKEN:-dev-sms-token}
    volumes:
      - ./docker/sms-gateway/config.yml:/app/config.yml:ro
    ports:
      - "3001:3000"
    depends_on:
      db:
        condition: service_healthy

  sms-gateway-worker:
    image: ghcr.io/android-sms-gateway/server:latest
    profiles: ["sms"]
    restart: unless-stopped
    command: /app/app worker
    environment:
      DATABASE_HOST: ${DATABASE_HOST:-db}
      DATABASE_USER: ${DATABASE_USERNAME:-hroot}
      DATABASE_PASSWORD: ${DATABASE_PASSWORD:-hrootpassword}
      DATABASE_DATABASE: sms_gateway
      DATABASE__HOST: ${DATABASE_HOST:-db}
      DATABASE__USER: ${DATABASE_USERNAME:-hroot}
      DATABASE__PASSWORD: ${DATABASE_PASSWORD:-hrootpassword}
      DATABASE__DATABASE: sms_gateway
    volumes:
      - ./docker/sms-gateway/config.yml:/app/config.yml:ro
    depends_on:
      db:
        condition: service_healthy
      sms-gateway:
        condition: service_started

  sms-dashboard:
    image: ghcr.io/android-sms-gateway/web-dashboard:latest
    profiles: ["sms"]
    restart: unless-stopped
    environment:
      HTTP__ADDRESS: 0.0.0.0:3000
      GATEWAY__URL: http://sms-gateway:3000/api/3rdparty/v1
    ports:
      - "3002:3000"
    depends_on:
      sms-gateway:
        condition: service_started

  proxy:
    image: nginxproxy/nginx-proxy
    container_name: nginx-proxy
    restart: unless-stopped
    ports:
      - "${PROXY_HTTP_PORT:-80}:80"
      - "${PROXY_HTTPS_PORT:-443}:443"
    volumes:
      - ${DOCKER_SOCKET:-/var/run/docker.sock}:/tmp/docker.sock:ro
      - certs:/etc/nginx/certs
      - ./docker/nginx/vhost.d:/etc/nginx/vhost.d
      - html:/usr/share/nginx/html
    depends_on:
      - web

  acme:
    image: nginxproxy/acme-companion
    container_name: acme-companion
    restart: unless-stopped
    environment:
      NGINX_PROXY_CONTAINER: nginx-proxy
      CERTS_UPDATE_INTERVAL: 86400
    volumes:
      - ${DOCKER_SOCKET:-/var/run/docker.sock}:/var/run/docker.sock:ro
      - certs:/etc/nginx/certs
      - ./docker/nginx/vhost.d:/etc/nginx/vhost.d
      - html:/usr/share/nginx/html
      - acme:/etc/acme.sh
    depends_on:
      - proxy

volumes:
  db_data:
  certs:
  html:
  acme:

networks:
  default:
    ipam:
      driver: default
      config:
        - subnet: ${DOCKER_SUBNET:-10.201.1.0/24}
EOFCOMPOSE
  elif [ "$PROXY_MODE" = "shared" ]; then
    cat <<'EOFCOMPOSE' > docker-compose.yml
services:
  db:
    image: mysql:8.0
    restart: unless-stopped
    command: --default-authentication-plugin=mysql_native_password --sql-mode="STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION"
    volumes:
      - db_data:/var/lib/mysql
      - ./docker/mysql:/docker-entrypoint-initdb.d
    environment:
      TZ: ${APP_TIMEZONE:-Europe/Berlin}
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD:-rootpassword}
      MYSQL_DATABASE: ${DATABASE_NAME:-hroot_production}
      MYSQL_USER: ${DATABASE_USERNAME:-hroot}
      MYSQL_PASSWORD: ${DATABASE_PASSWORD:-hrootpassword}
    ports:
      - "127.0.0.1:${DB_PORT:-3306}:3306"
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 10s
      timeout: 5s
      retries: 5

  web:
    image: ${HROOT_IMAGE:-ghcr.io/wiso-forschungslabor/hroot:latest}
    restart: unless-stopped
    command: ./bin/rails server -b 0.0.0.0
    labels:
      - "com.centurylinklabs.watchtower.enable=true"
    env_file:
      - .env
    volumes:
      - ./.env:/rails/.env
      - ./uploads:/rails/public/uploads
    environment:
      TZ: ${APP_TIMEZONE:-Europe/Berlin}
      RAILS_ENV: ${RAILS_ENV:-production}
      RAILS_MASTER_KEY: ${RAILS_MASTER_KEY:-}
      DATABASE_HOST: ${DATABASE_HOST:-db}
      DATABASE_USERNAME: ${DATABASE_USERNAME:-hroot}
      DATABASE_PASSWORD: ${DATABASE_PASSWORD:-hrootpassword}
      DATABASE_NAME: ${DATABASE_NAME:-hroot_production}
      VIRTUAL_HOST: ${APP_DOMAIN}
      VIRTUAL_PORT: 3000
      LETSENCRYPT_HOST: ${APP_DOMAIN}
      LETSENCRYPT_EMAIL: ${LETSENCRYPT_EMAIL:-${CONTACT_EMAIL}}
    ports:
      - "127.0.0.1:${APP_PORT:-3000}:3000"
    networks:
      - proxy-network
      - default
    depends_on:
      db:
        condition: service_healthy

  cron:
    image: ${HROOT_IMAGE:-ghcr.io/wiso-forschungslabor/hroot:latest}
    restart: unless-stopped
    command: ./docker/cron-entrypoint.sh
    user: root
    labels:
      - "com.centurylinklabs.watchtower.enable=true"
    env_file:
      - .env
    volumes:
      - ./.env:/rails/.env
      - ./uploads:/rails/public/uploads
    environment:
      TZ: ${APP_TIMEZONE:-Europe/Berlin}
      RAILS_ENV: ${RAILS_ENV:-production}
      DATABASE_HOST: ${DATABASE_HOST:-db}
      DATABASE_USERNAME: ${DATABASE_USERNAME:-hroot}
      DATABASE_PASSWORD: ${DATABASE_PASSWORD:-hrootpassword}
      DATABASE_NAME: ${DATABASE_NAME:-hroot_production}
    depends_on:
      db:
        condition: service_healthy

  updater:
    image: containrrr/watchtower
    restart: unless-stopped
    volumes:
      - ${DOCKER_SOCKET:-/var/run/docker.sock}:/var/run/docker.sock
    environment:
      - DOCKER_API_VERSION=1.44
      - WATCHTOWER_HTTP_API_UPDATE=true
      - WATCHTOWER_HTTP_API_TOKEN=${UPDATE_WEBHOOK_SECRET:-hroot-updater-secret}
      - WATCHTOWER_CLEANUP=true
      - WATCHTOWER_LABEL_ENABLE=true
      - REPO_USER=${UPDATE_GITHUB_USER:-${GITHUB_USER:-}}
      - REPO_PASS=${UPDATE_GITHUB_TOKEN:-}

networks:
  proxy-network:
    external: true
  default:
    ipam:
      driver: default
      config:
        - subnet: ${DOCKER_SUBNET:-10.201.1.0/24}

volumes:
  db_data:
EOFCOMPOSE
  else
    cat <<'EOFCOMPOSE' > docker-compose.yml
services:
  db:
    image: mysql:8.0
    restart: unless-stopped
    command: --default-authentication-plugin=mysql_native_password --sql-mode="STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION"
    volumes:
      - db_data:/var/lib/mysql
      - ./docker/mysql:/docker-entrypoint-initdb.d
    environment:
      TZ: ${APP_TIMEZONE:-Europe/Berlin}
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD:-rootpassword}
      MYSQL_DATABASE: ${DATABASE_NAME:-hroot_production}
      MYSQL_USER: ${DATABASE_USERNAME:-hroot}
      MYSQL_PASSWORD: ${DATABASE_PASSWORD:-hrootpassword}
    ports:
      - "127.0.0.1:${DB_PORT:-3306}:3306"
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 10s
      timeout: 5s
      retries: 5

  web:
    image: ${HROOT_IMAGE:-ghcr.io/wiso-forschungslabor/hroot:latest}
    restart: unless-stopped
    command: ./bin/rails server -b 0.0.0.0
    labels:
      - "com.centurylinklabs.watchtower.enable=true"
    env_file:
      - .env
    volumes:
      - ./.env:/rails/.env
      - ./uploads:/rails/public/uploads
    environment:
      TZ: ${APP_TIMEZONE:-Europe/Berlin}
      RAILS_ENV: ${RAILS_ENV:-production}
      RAILS_MASTER_KEY: ${RAILS_MASTER_KEY:-}
      DATABASE_HOST: ${DATABASE_HOST:-db}
      DATABASE_USERNAME: ${DATABASE_USERNAME:-hroot}
      DATABASE_PASSWORD: ${DATABASE_PASSWORD:-hrootpassword}
      DATABASE_NAME: ${DATABASE_NAME:-hroot_production}
      VIRTUAL_HOST: ${APP_DOMAIN}
      LETSENCRYPT_HOST: ${APP_DOMAIN}
      LETSENCRYPT_EMAIL: ${CONTACT_EMAIL}
    ports:
      - "${APP_PORT:-3000}:3000"
    depends_on:
      db:
        condition: service_healthy

  cron:
    image: ${HROOT_IMAGE:-ghcr.io/wiso-forschungslabor/hroot:latest}
    restart: unless-stopped
    command: ./docker/cron-entrypoint.sh
    user: root
    labels:
      - "com.centurylinklabs.watchtower.enable=true"
    env_file:
      - .env
    volumes:
      - ./.env:/rails/.env
      - ./uploads:/rails/public/uploads
    environment:
      TZ: ${APP_TIMEZONE:-Europe/Berlin}
      RAILS_ENV: ${RAILS_ENV:-production}
      DATABASE_HOST: ${DATABASE_HOST:-db}
      DATABASE_USERNAME: ${DATABASE_USERNAME:-hroot}
      DATABASE_PASSWORD: ${DATABASE_PASSWORD:-hrootpassword}
      DATABASE_NAME: ${DATABASE_NAME:-hroot_production}
    depends_on:
      db:
        condition: service_healthy

  updater:
    image: containrrr/watchtower
    restart: unless-stopped
    volumes:
      - ${DOCKER_SOCKET:-/var/run/docker.sock}:/var/run/docker.sock
    environment:
      - DOCKER_API_VERSION=1.44
      - WATCHTOWER_HTTP_API_UPDATE=true
      - WATCHTOWER_HTTP_API_TOKEN=${UPDATE_WEBHOOK_SECRET:-hroot-updater-secret}
      - WATCHTOWER_CLEANUP=true
      - WATCHTOWER_LABEL_ENABLE=true
      - REPO_USER=${UPDATE_GITHUB_USER:-${GITHUB_USER:-}}
      - REPO_PASS=${UPDATE_GITHUB_TOKEN:-}

  sms-gateway:
    image: ghcr.io/android-sms-gateway/server:latest
    profiles: ["sms"]
    restart: unless-stopped
    environment:
      VIRTUAL_HOST: ${SMS_GATEWAY_DOMAIN:-}
      VIRTUAL_PORT: 3000
      DATABASE_HOST: ${DATABASE_HOST:-db}
      DATABASE_USER: ${DATABASE_USERNAME:-hroot}
      DATABASE_PASSWORD: ${DATABASE_PASSWORD:-hrootpassword}
      DATABASE_DATABASE: sms_gateway
      DATABASE__HOST: ${DATABASE_HOST:-db}
      DATABASE__USER: ${DATABASE_USERNAME:-hroot}
      DATABASE__PASSWORD: ${DATABASE_PASSWORD:-hrootpassword}
      DATABASE__DATABASE: sms_gateway
      PRIVATE_TOKEN: ${SMS_GATEWAY_PRIVATE_TOKEN:-dev-sms-token}
      GATEWAY__PRIVATE_TOKEN: ${SMS_GATEWAY_PRIVATE_TOKEN:-dev-sms-token}
    volumes:
      - ./docker/sms-gateway/config.yml:/app/config.yml:ro
    ports:
      - "3001:3000"
    depends_on:
      db:
        condition: service_healthy

  sms-gateway-worker:
    image: ghcr.io/android-sms-gateway/server:latest
    profiles: ["sms"]
    restart: unless-stopped
    command: /app/app worker
    environment:
      DATABASE_HOST: ${DATABASE_HOST:-db}
      DATABASE_USER: ${DATABASE_USERNAME:-hroot}
      DATABASE_PASSWORD: ${DATABASE_PASSWORD:-hrootpassword}
      DATABASE_DATABASE: sms_gateway
      DATABASE__HOST: ${DATABASE_HOST:-db}
      DATABASE__USER: ${DATABASE_USERNAME:-hroot}
      DATABASE__PASSWORD: ${DATABASE_PASSWORD:-hrootpassword}
      DATABASE__DATABASE: sms_gateway
    volumes:
      - ./docker/sms-gateway/config.yml:/app/config.yml:ro
    depends_on:
      db:
        condition: service_healthy
      sms-gateway:
        condition: service_started

  sms-dashboard:
    image: ghcr.io/android-sms-gateway/web-dashboard:latest
    profiles: ["sms"]
    restart: unless-stopped
    environment:
      HTTP__ADDRESS: 0.0.0.0:3000
      GATEWAY__URL: http://sms-gateway:3000/api/3rdparty/v1
    ports:
      - "3002:3000"
    depends_on:
      sms-gateway:
        condition: service_started

volumes:
  db_data:

networks:
  default:
    ipam:
      driver: default
      config:
        - subnet: ${DOCKER_SUBNET:-10.201.1.0/24}
EOFCOMPOSE
  fi
  echo -e "-> Created docker-compose.yml"
else
  echo -e "-> docker-compose.yml already present"
fi

# Ensure persistent directories and config files exist
mkdir -p uploads docker/mysql docker/sms-gateway docker/nginx/vhost.d docker/overrides
if [ ! -f "docker/mysql/init.sql" ]; then
  cat <<'EOFSQL' > docker/mysql/init.sql
CREATE DATABASE IF NOT EXISTS hroot_test;
CREATE DATABASE IF NOT EXISTS sms_gateway;
GRANT ALL PRIVILEGES ON *.* TO 'hroot'@'%';
GRANT ALL PRIVILEGES ON sms_gateway.* TO 'hroot'@'%';
FLUSH PRIVILEGES;
EOFSQL
fi

# Ensure docker/overrides/ext-db.yml exists for reference
if [ ! -f "docker/overrides/ext-db.yml" ]; then
  cat <<'EOFOVERRIDE' > docker/overrides/ext-db.yml
# docker/overrides/ext-db.yml
# Use this when connecting to an external MySQL database server (e.g. university cluster).
#
# Usage:
#   docker compose -f docker-compose.yml -f docker/overrides/ext-db.yml up -d
# Or copy/link as docker-compose.override.yml in the application root (automatically loaded).
services:
  # Disable domestic database container by replacing it with an immediately healthy dummy service
  db:
    image: busybox:1.36
    command: ["sh", "-c", "echo 'External database configured - domestic DB service disabled'; tail -f /dev/null"]
    ports: []
    volumes: []
    healthcheck:
      test: ["CMD", "sh", "-c", "exit 0"]
      interval: 1s
      timeout: 1s
      retries: 1
    restart: "no"
EOFOVERRIDE
fi

# Automatically disable domestic DB container if external database was chosen
if [ "$DB_CHOICE" = "2" ]; then
  if [ ! -f "docker-compose.override.yml" ]; then
    cp docker/overrides/ext-db.yml docker-compose.override.yml
    echo -e "-> Generated docker-compose.override.yml to disable domestic DB container"
  else
    echo -e "-> docker-compose.override.yml already present"
  fi
fi

# Ensure NGINX default_location is prepared for SMS Gateway & Dashboard (supports retroactive activation)
if [ "$PROXY_MODE" = "builtin" ] && [ "${SMS_ROUTING_CHOICE:-1}" != "2" ]; then
  if [ ! -f "docker/nginx/vhost.d/default_location" ]; then
    cat <<'EOFNGINX' > docker/nginx/vhost.d/default_location
# Docker internal DNS resolver for on-demand container resolution
resolver 127.0.0.11 valid=30s;

# Proxy routing for Android SMS Gateway running as subpath
location /sms-gateway/ {
    set $upstream_sms_gw http://sms-gateway:3000;
    proxy_pass $upstream_sms_gw/;
    proxy_http_version 1.1;

    # Support WebSockets / Server-Sent Events for Android device communication
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";

    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;

    # Timeouts for persistent device polling/connections
    proxy_read_timeout 600s;
    proxy_send_timeout 600s;
}

location = /sms-gateway {
    return 301 $scheme://$http_host/sms-gateway/;
}

# Proxy routing for SMS Gateway Web Dashboard
location /sms-dashboard/ {
    set $upstream_sms_dash http://sms-dashboard:3000;
    proxy_pass $upstream_sms_dash/;
    proxy_http_version 1.1;

    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";

    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}

location = /sms-dashboard {
    return 301 $scheme://$http_host/sms-dashboard/;
}

location /_app/ {
    set $upstream_sms_dash http://sms-dashboard:3000;
    proxy_pass $upstream_sms_dash/_app/;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}

# Proxy routing for SMS Gateway Web Dashboard API (auth, devices, messages)
location /api/ {
    set $upstream_sms_dash http://sms-dashboard:3000;
    proxy_pass $upstream_sms_dash/api/;
    proxy_http_version 1.1;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}
EOFNGINX
  else
    # Ensure /api/ route is present in existing default_location
    if ! grep -q "location /api/" "docker/nginx/vhost.d/default_location" 2>/dev/null; then
      cat <<'EOFNGINX' >> "docker/nginx/vhost.d/default_location"

# Proxy routing for SMS Gateway Web Dashboard API (auth, devices, messages)
location /api/ {
    proxy_pass http://sms-dashboard:3000/api/;
    proxy_http_version 1.1;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}
EOFNGINX
    fi
  fi
fi

if [ "$ENABLE_SMS" = true ] || [ ! -f "docker/sms-gateway/config.yml" ]; then
  cat <<EOFCONFIG > docker/sms-gateway/config.yml
database:
  host: db
  port: 3306
  user: hroot
  password: ${DATABASE_PASSWORD:-hrootpassword}
  database: sms_gateway
  timezone: UTC

gateway:
  mode: private
  private_token: ${SMS_GATEWAY_PRIVATE_TOKEN:-${SMS_PRIVATE_TOKEN:-dev-sms-token}}

http:
  listen: 0.0.0.0:3000
  proxies:
    - "0.0.0.0/0"
  api:
    path: /api

jwt:
  secret: $(generate_secret 16)
  access_ttl: 15m
  refresh_ttl: 720h
EOFCONFIG
fi

SECRET_KEY=$(generate_secret 32)

cat <<EOF > .env
# ==============================================================================
# HROOT Production Environment Configuration
# Generated by HROOT Installer on $(date -u +"%Y-%m-%dT%H:%M:%SZ")
# ==============================================================================

# Core Application Settings
APP_DOMAIN=${APP_DOMAIN}
APP_PORT=${APP_PORT}
APP_PROTOCOL=${APP_PROTOCOL}
APP_TIMEZONE=${APP_TIMEZONE}
ENABLE_SSL=${ENABLE_SSL}
FORCE_SSL=${FORCE_SSL:-false}
LETSENCRYPT_EMAIL=${LETSENCRYPT_EMAIL}
CONTACT_EMAIL=${CONTACT_EMAIL}
RAILS_ENV=production
RAILS_SERVE_STATIC_FILES=true
RAILS_LOG_TO_STDOUT=true

# In-Browser Setup Wizard Security
HROOT_SETUP_WIZARD=true
HROOT_SETUP_TOKEN=${SETUP_TOKEN}

# Container Image & Update Tracking
HROOT_IMAGE=${HROOT_IMAGE}
UPDATE_GITHUB_REPO=${UPDATE_REPO}
UPDATE_BRANCH=${TARGET_BRANCH_NAME}
UPDATE_GITHUB_USER=${GITHUB_USER}
UPDATE_GITHUB_TOKEN=${GITHUB_TOKEN}
# Docker Daemon Socket (defaults to /var/run/docker.sock, or user runtime socket for Rootless Docker)
DOCKER_SOCKET=${DEFAULT_DOCKER_SOCKET}

# Automatic Updates (Watchtower)
UPDATE_WEBHOOK_URL=http://updater:8080/v1/update
UPDATE_WEBHOOK_SECRET=$(generate_secret 16)

# Application Secrets
SECRET_KEY_BASE=${SECRET_KEY}

# Database Configuration
DATABASE_HOST=${DATABASE_HOST}
DATABASE_PORT=${DATABASE_PORT}
DATABASE_NAME=${DATABASE_NAME}
DATABASE_USERNAME=${DATABASE_USERNAME}
DATABASE_PASSWORD=${DATABASE_PASSWORD}
MYSQL_ROOT_PASSWORD=${DB_ROOT_PW:-rootpassword}

# Optional Service Profiles (e.g. 'sms' to start SMS Gateway containers)
COMPOSE_PROFILES=${COMPOSE_PROFILES}

# SMS Gateway Configuration
SMS_FEATURE_ENABLED=${ENABLE_SMS}
SMS_SEND_MODE=api
SMS_GATEWAY_DOMAIN=${SMS_GATEWAY_DOMAIN}
SMS_GATEWAY_API_URL=${SMS_GATEWAY_API_URL}
SMS_GATEWAY_PRIVATE_TOKEN=${SMS_PRIVATE_TOKEN}
SMS_GATEWAY_API_USERNAME=
SMS_GATEWAY_API_PASSWORD=

# Docker Network IPAM Configuration (Collision-free RFC 1918 subnet)
DOCKER_SUBNET=${DOCKER_SUBNET}
DOCKER_PROXY_SUBNET=${DOCKER_PROXY_SUBNET}


EOF

chmod 600 .env 2>/dev/null || true
echo -e "-> Created ${GREEN}.env${NC} with secured credentials.\n"


# ==============================================================================
# 11. Launch HROOT Services
# ==============================================================================
echo -e "${BOLD}11. Launching HROOT Services:${NC}"

COMPOSE_ARGS=""
if [ "$PROXY_MODE" = "shared" ] && [ -f "docker/overrides/shared-proxy.yml" ]; then
  COMPOSE_ARGS="-f docker-compose.yml -f docker/overrides/shared-proxy.yml"
  if [ -f "docker-compose.override.yml" ]; then
    COMPOSE_ARGS="$COMPOSE_ARGS -f docker-compose.override.yml"
  fi
fi

if [ "$CAN_START" = true ]; then
  prompt_read -r -p "Do you want to start HROOT containers now? [Y/n]: " START_NOW
  START_NOW="${START_NOW:-Y}"
  if [[ "$START_NOW" =~ ^[Yy]$ ]]; then
    echo -e "\nPulling container images..."
    PULL_SUCCESS=true
    if ! $DOCKER_CMD $COMPOSE_ARGS pull; then
      if command -v sudo >/dev/null 2>&1 && sudo $DOCKER_CMD $COMPOSE_ARGS pull; then
        DOCKER_CMD="sudo $DOCKER_CMD"
      else
        PULL_SUCCESS=false
      fi
    fi

    if [ "$PULL_SUCCESS" = false ]; then
      echo -e "\n${YELLOW}${BOLD}=================================================================="
      echo "⚠️  Notice: Docker Image '${HROOT_IMAGE}' not found in GHCR"
      echo -e "==================================================================${NC}"
      echo ""
      echo "If this is a custom fork (or fresh repository), the container image"
      echo "has not been built and published yet."
      echo ""
      echo "To build and publish the image using GitHub Actions in your repository:"
      echo ""
      echo "1. Enable GitHub Actions in your Fork (First time only):"
      echo "   • Open your repository on GitHub: https://github.com/${UPDATE_REPO}"
      echo "   • Navigate to the 'Actions' tab."
      echo "   • Click the green button: 'I understand my workflows, go ahead and enable them'."
      echo ""
      echo "2. Trigger the automated container build:"
      echo "   • Option A (Via Release Tag - Recommended):"
      echo "     Create and push a release tag matching 'v*':"
      echo "       git tag v4.0.0"
      echo "       git push origin v4.0.0"
      echo "   • Option B (Manual trigger in browser):"
      echo "     In your repository, go to 'Actions' -> 'Build and Publish Docker Image' -> 'Run workflow'."
      echo ""
      echo "Once the GitHub Action completes building (approx. 2-3 minutes),"
      echo "simply re-run this installation command to start HROOT."
      echo "=================================================================="
      exit 0
    fi

    echo -e "\nStarting containers in background..."
    if ! $DOCKER_CMD $COMPOSE_ARGS up -d 2>/dev/null; then
      if command -v sudo >/dev/null 2>&1 && sudo $DOCKER_CMD $COMPOSE_ARGS up -d; then
        DOCKER_CMD="sudo $DOCKER_CMD"
        echo -e "-> Containers started successfully (via sudo)."
      else
        echo -e "${RED}Error: Failed to connect to Docker daemon.${NC}"
        echo "If you received a permission denied error, run this installer as a deploy/admin user with sudo access."
      fi
    else
      echo -e "-> Containers started."
    fi
  fi
else
  echo -e "${YELLOW}Notice: Docker is not ready on this system.${NC}"
  echo "Configuration (.env, docker-compose.yml) has been generated successfully."
  echo "Once Docker is installed, start HROOT by navigating to ${TARGET_DIR} and running:"
  if [ -n "$COMPOSE_ARGS" ]; then
    echo "  docker compose $COMPOSE_ARGS up -d"
  else
    echo "  docker compose up -d"
  fi
fi


# ==============================================================================
# Final Summary Banner
# ==============================================================================
echo ""
echo -e "${GREEN}${BOLD}=================================================================="
echo "           HROOT SETUP READY FOR INITIALIZATION / UPGRADE         "
echo -e "==================================================================${NC}"

echo ""
echo -e "${BOLD}Open in Browser:${NC} ${CYAN}${APP_PROTOCOL}://${APP_DOMAIN}/setup${NC}"
echo -e "${BOLD}Setup Token:${NC}     ${YELLOW}${SETUP_TOKEN}${NC}"
if [ "$ENABLE_SMS" = true ]; then
  echo -e "${BOLD}SMS Gateway URL:${NC} ${CYAN}${SMS_GATEWAY_API_URL%/api/3rdparty/v1/messages}${NC}"
  echo -e "${BOLD}SMS Pairing Token:${NC} ${YELLOW}${SMS_PRIVATE_TOKEN}${NC}"
fi
echo ""
echo "Supported Scenarios in the Web Wizard:"
echo "• Fresh Installation: Initializes a new database and creates your first Banking Admin."
echo "• Major Upgrade (v3 → v4): Connects your existing v3 database, preserves all data, promotes an admin, and applies schema migrations."
if [ "$PROXY_MODE" = "none" ]; then
  echo ""
  echo -e "${YELLOW}${BOLD}Host Reverse Proxy Notice (External Apache / Nginx):${NC}"
  echo "Because you selected Standalone mode, configure your host webserver:"
  echo ""
  echo -e "${CYAN}Apache 2.4 VirtualHost (*:443):${NC}"
  echo "  # Main Rails Application (Port 3000):"
  echo "  ProxyPass / http://127.0.0.1:${APP_PORT:-3000}/ retry=0"
  echo "  ProxyPassReverse / http://127.0.0.1:${APP_PORT:-3000}/"
  echo ""
  echo "  # If SMS Gateway is enabled (Ports 3001 & 3002):"
  echo "  RewriteEngine On"
  echo "  RewriteCond %{HTTP:Upgrade} websocket [NC]"
  echo "  RewriteCond %{HTTP:Connection} upgrade [NC]"
  echo "  RewriteRule ^/sms-gateway/?(.*) \"ws://127.0.0.1:3001/\$1\" [P,L]"
  echo "  ProxyPass /sms-gateway/ http://127.0.0.1:3001/ retry=0 timeout=600"
  echo "  ProxyPassReverse /sms-gateway/ http://127.0.0.1:3001/"
  echo "  ProxyPass /sms-dashboard/ http://127.0.0.1:3002/ retry=0"
  echo "  ProxyPassReverse /sms-dashboard/ http://127.0.0.1:3002/"
  echo "  ProxyPass /_app/ http://127.0.0.1:3002/_app/ retry=0"
  echo "  ProxyPassReverse /_app/ http://127.0.0.1:3002/_app/"
  echo "  ProxyPass /api/ http://127.0.0.1:3002/api/ retry=0"
  echo "  ProxyPassReverse /api/ http://127.0.0.1:3002/api/"
fi
echo ""
echo -e "Useful Commands in ${TARGET_DIR}:"
if [ -n "$COMPOSE_ARGS" ]; then
  echo "  $DOCKER_CMD $COMPOSE_ARGS ps              # Check container status"
  echo "  $DOCKER_CMD $COMPOSE_ARGS logs -f web     # View web application logs"
  echo "  $DOCKER_CMD $COMPOSE_ARGS down            # Stop services"
else
  echo "  $DOCKER_CMD ps              # Check container status"
  echo "  $DOCKER_CMD logs -f web     # View web application logs"
  if [ "$PROXY_MODE" = "builtin" ]; then
    echo "  $DOCKER_CMD logs -f acme    # View Let's Encrypt SSL certificate provisioning status"
    echo "  $DOCKER_CMD logs -f proxy   # View NGINX reverse proxy access & SSL routing"
  fi
  echo "  $DOCKER_CMD down            # Stop services"
fi
echo "=================================================================="
