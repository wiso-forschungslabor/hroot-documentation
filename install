#!/usr/bin/env bash
# ==============================================================================
# HROOT Public Bootstrap Installer
# Repository: https://github.com/wiso-forschungslabor/hroot-documentation
#
# Usage:
#   bash -c "$(curl -fsSL https://raw.githubusercontent.com/wiso-forschungslabor/hroot-documentation/master/install.sh)"
#   or: curl -fsSL https://raw.githubusercontent.com/wiso-forschungslabor/hroot-documentation/master/install.sh | bash
# ==============================================================================

set -e

# Helper to read from terminal even when piped via curl | bash
prompt_read() {
  if [ -t 0 ]; then
    read "$@"
  elif [ -r /dev/tty ]; then
    read "$@" < /dev/tty
  elif [ -c /dev/tty ]; then
    read "$@" < /dev/tty
  else
    read "$@"
  fi
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
echo "           HROOT Bootstrap Installer                             "
echo "=================================================================="
echo -e "${NC}"
echo -e "${YELLOW}Notice: Authorization & Licensing Requirements${NC}"
echo -e "An authorized access grant for the private HROOT repository is required for installation."
echo -e "Software licenses and access information can be obtained at ${BOLD}https://uhh.de/wiso-hroot-info${NC}."
echo ""
echo "------------------------------------------------------------------"
echo ""

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

# 1. Pre-Flight System & Docker Check
echo -e "${BOLD}1. Pre-Flight System & Docker Check:${NC}"
if command -v docker >/dev/null 2>&1; then
  if docker info >/dev/null 2>&1; then
    echo -e "-> Docker Engine: ${GREEN}Running and accessible (unprivileged)${NC}"
  else
    echo -e "${YELLOW}Notice: Docker is installed, but user '${USER}' cannot access Docker daemon without sudo.${NC}"
    if has_sudo_access; then
      prompt_read -r -p "Add '${USER}' to docker group with sudo now? [Y/n]: " ADD_GRP
      ADD_GRP="${ADD_GRP:-Y}"
      if [[ "$ADD_GRP" =~ ^[Yy]$ ]]; then
        if sudo usermod -aG docker "$USER" 2>/dev/null; then
          echo -e "-> Added '${USER}' to docker group."
        fi
      fi
    else
      echo -e "   Tip: To run HROOT unprivileged, ask your administrator to run:"
      echo -e "   ${BOLD}sudo usermod -aG docker ${USER} && newgrp docker${NC}"
    fi
  fi
else
  echo -e "${YELLOW}Notice: Docker is not installed on this system.${NC}"
  if command -v apt-get >/dev/null 2>&1 && has_sudo_access; then
    echo -e "\nOptions:"
    echo "1) Install Docker & Compose automatically now (via apt & sudo) [Default]"
    echo "2) Continue anyway (generate configuration files only, install Docker later)"
    echo "3) Abort installation"
    prompt_read -r -p "Select option [1/2/3]: " DOCKER_CHOICE
    DOCKER_CHOICE="${DOCKER_CHOICE:-1}"

    if [ "$DOCKER_CHOICE" = "1" ]; then
      echo -e "\nInstalling docker.io and docker-compose-v2..."
      if sudo apt-get update -y && sudo apt-get install -y docker.io docker-compose-v2; then
        sudo usermod -aG docker "$USER" 2>/dev/null || true
        echo -e "${GREEN}-> Docker installed successfully.${NC}"
      else
        echo -e "${RED}Error: Package installation failed.${NC}"
        echo -e "Ask your administrator to install Docker: ${BOLD}sudo apt update && sudo apt install -y docker.io docker-compose-v2 && sudo usermod -aG docker ${USER}${NC}"
      fi
    elif [ "$DOCKER_CHOICE" = "3" ]; then
      echo -e "\nInstallation aborted. Please install Docker and restart the installer."
      exit 0
    else
      echo -e "\nContinuing in configuration-only mode..."
    fi
  else
    echo -e "   Notice: User '${USER}' does not have sudo privileges to install packages."
    echo -e "   Please ask your system administrator to install Docker:"
    echo -e "   ${BOLD}sudo apt update && sudo apt install -y docker.io docker-compose-v2 && sudo usermod -aG docker ${USER}${NC}\n"
    prompt_read -r -p "Do you want to continue generating configuration files only? [y/N]: " CONT_CONF
    CONT_CONF="${CONT_CONF:-N}"
    if [[ ! "$CONT_CONF" =~ ^[Yy]$ ]]; then
      echo -e "\nInstallation aborted."
      exit 0
    fi
  fi
fi
echo ""

# 2. GitHub Authentication
echo -e "${BOLD}2. GitHub Authorization Credentials:${NC}"
echo "Please provide your authorized GitHub credentials to proceed."

# GitHub Username
if [ -z "$GITHUB_USER" ]; then
  prompt_read -r -p "GitHub Username: " GITHUB_USER
fi

# GitHub Personal Access Token (PAT)
if [ -z "$GITHUB_TOKEN" ]; then
  echo -e "\nEnter your GitHub Personal Access Token (classic with 'repo' & 'read:packages' scopes):"
  prompt_read -r -s -p "GitHub Token (PAT): " GITHUB_TOKEN
  echo ""
fi

if [ -z "$GITHUB_USER" ] || [ -z "$GITHUB_TOKEN" ]; then
  echo -e "\n${RED}Error: GitHub username and Personal Access Token are required.${NC}"
  exit 1
fi

# Container Registry Authentication
if command -v docker >/dev/null 2>&1; then
  if echo "$GITHUB_TOKEN" | docker login ghcr.io -u "$GITHUB_USER" --password-stdin >/dev/null 2>&1; then
    echo -e "-> Successfully authenticated with ${GREEN}ghcr.io${NC}."
  elif command -v sudo >/dev/null 2>&1; then
    if echo "$GITHUB_TOKEN" | sudo docker login ghcr.io -u "$GITHUB_USER" --password-stdin >/dev/null 2>&1; then
      echo -e "-> Authenticated with ${GREEN}ghcr.io${NC} (via sudo fallback)."
    fi
  fi
fi

# 3. Repository Selection
DEFAULT_REPO="wiso-forschungslabor/hroot"
DEFAULT_BRANCH="master"

echo -e "\n${BOLD}3. Target Repository:${NC}"
echo "1) Official Upstream (${DEFAULT_REPO}) [Default]"
echo "2) Custom GitHub Fork"
prompt_read -r -p "Select repository [1/2]: " REPO_CHOICE

if [ "$REPO_CHOICE" = "2" ]; then
  prompt_read -r -p "Enter GitHub repository name (e.g. your-university/hroot): " TARGET_REPO
  TARGET_REPO="${TARGET_REPO:-$DEFAULT_REPO}"
  prompt_read -r -p "Enter branch or release tag (Default: master): " TARGET_REF
  TARGET_REF="${TARGET_REF:-master}"
  TARGET_BRANCH="$TARGET_REF"
  if [ "$TARGET_REF" = "master" ] || [ "$TARGET_REF" = "main" ]; then
    TARGET_TAG="latest"
  else
    TARGET_TAG="$TARGET_REF"
  fi
else
  TARGET_REPO="$DEFAULT_REPO"
  TARGET_BRANCH="master"
  TARGET_TAG="latest"
fi


# 4. Fetch and execute the full installer from the repository
TMP_INSTALLER=$(mktemp /tmp/hroot-installer-XXXXXX.sh)
DOWNLOAD_SUCCESS=false

while [ "$DOWNLOAD_SUCCESS" = false ]; do
  INSTALLER_URL="https://raw.githubusercontent.com/${TARGET_REPO}/${TARGET_BRANCH}/bin/install"
  echo -e "\n${BOLD}Fetching installer from ${CYAN}${TARGET_REPO}@${TARGET_BRANCH}${NC}..."

  if curl -fsSL -H "Authorization: token ${GITHUB_TOKEN}" "$INSTALLER_URL" -o "$TMP_INSTALLER" 2>/dev/null; then
    DOWNLOAD_SUCCESS=true
    echo -e "-> Installer downloaded successfully.\n"
  else
    echo -e "${YELLOW}Notice: 'bin/install' not found at ${TARGET_REPO}@${TARGET_BRANCH}.${NC}"
    echo "If your code or installer is located on a specific branch or release tag (e.g. hamburg_development_2502 or v4.0-beta5):"
    prompt_read -r -p "Enter alternative branch or release tag (or 'q' to abort): " ALT_REF
    if [ -z "$ALT_REF" ] || [ "$ALT_REF" = "q" ] || [ "$ALT_REF" = "exit" ]; then
      echo -e "\n${RED}Installation aborted: Installer script could not be downloaded.${NC}"
      rm -f "$TMP_INSTALLER"
      exit 1
    fi
    TARGET_BRANCH="$ALT_REF"
    if [ "$ALT_REF" = "master" ] || [ "$ALT_REF" = "main" ]; then
      TARGET_TAG="latest"
    else
      TARGET_TAG="$ALT_REF"
    fi
  fi
done

chmod +x "$TMP_INSTALLER"

# Export credentials to subshell
export GITHUB_USER="$GITHUB_USER"
export GITHUB_TOKEN="$GITHUB_TOKEN"
export HROOT_REPO="$TARGET_REPO"
export HROOT_BRANCH="$TARGET_BRANCH"
export HROOT_TAG="$TARGET_TAG"

bash "$TMP_INSTALLER"
rm -f "$TMP_INSTALLER"
