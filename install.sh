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

# Reconnect stdin to controlling terminal if piped via curl | bash
if [ ! -t 0 ] && [ -e /dev/tty ]; then
  exec < /dev/tty
fi

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
echo "           🚀 HROOT Bootstrap Installer                         "
echo "=================================================================="
echo -e "${NC}"
echo -e "${YELLOW}ℹ️  Authorization & Licensing Notice:${NC}"
echo -e "An authorized access grant for the private HROOT repository is required for installation."
echo -e "Software licenses and access information can be obtained at ${BOLD}https://uhh.de/wiso-hroot-info${NC}."
echo ""
echo "Please provide your authorized GitHub credentials to proceed."
echo "------------------------------------------------------------------"
echo ""

# 1. GitHub Username
if [ -z "$GITHUB_USER" ]; then
  read -r -p "GitHub Username: " GITHUB_USER
fi

# 2. GitHub Personal Access Token (PAT)
if [ -z "$GITHUB_TOKEN" ]; then
  echo -e "\nEnter your GitHub Personal Access Token (classic with 'repo' & 'read:packages' scopes):"
  read -r -s -p "GitHub Token (PAT): " GITHUB_TOKEN
  echo ""
fi

if [ -z "$GITHUB_USER" ] || [ -z "$GITHUB_TOKEN" ]; then
  echo -e "\n${RED}Error: GitHub username and Personal Access Token are required.${NC}"
  exit 1
fi

# 3. Repository Selection
DEFAULT_REPO="wiso-forschungslabor/hroot"
DEFAULT_BRANCH="master"

echo -e "\n${BOLD}Target Repository:${NC}"
echo "1) Official Upstream (${DEFAULT_REPO}) [Default]"
echo "2) Custom GitHub Fork"
read -r -p "Select repository [1/2]: " REPO_CHOICE

if [ "$REPO_CHOICE" = "2" ]; then
  read -r -p "Enter GitHub repository name (e.g. your-university/hroot): " TARGET_REPO
  TARGET_REPO="${TARGET_REPO:-$DEFAULT_REPO}"
  read -r -p "Enter branch or tag (Default: master): " TARGET_BRANCH
  TARGET_BRANCH="${TARGET_BRANCH:-$DEFAULT_BRANCH}"
  read -r -p "Enter Docker Image Tag (Default: ${TARGET_BRANCH}): " TARGET_TAG
  TARGET_TAG="${TARGET_TAG:-$TARGET_BRANCH}"
  [ "$TARGET_TAG" = "master" ] && TARGET_TAG="latest"
else
  TARGET_REPO="$DEFAULT_REPO"
  TARGET_BRANCH="$DEFAULT_BRANCH"
  TARGET_TAG="latest"
fi

# 4. Authenticate Docker with GitHub Container Registry
if command -v docker >/dev/null 2>&1; then
  echo -e "\n${BOLD}Authenticating with GitHub Container Registry (ghcr.io)...${NC}"
  LOGIN_SUCCESS=false
  if echo "$GITHUB_TOKEN" | docker login ghcr.io -u "$GITHUB_USER" --password-stdin >/dev/null 2>&1; then
    LOGIN_SUCCESS=true
  fi
  if command -v sudo >/dev/null 2>&1; then
    echo "$GITHUB_TOKEN" | sudo docker login ghcr.io -u "$GITHUB_USER" --password-stdin >/dev/null 2>&1 || true
  fi
  if [ "$LOGIN_SUCCESS" = true ]; then
    echo -e "✓ Successfully logged in to ${GREEN}ghcr.io${NC}."
  else
    echo -e "✓ Docker login credentials saved to ${GREEN}ghcr.io${NC}."
  fi
fi

# 5. Fetch and execute the full installer from the private repository
INSTALLER_URL="https://raw.githubusercontent.com/${TARGET_REPO}/${TARGET_BRANCH}/bin/install"
echo -e "\n${BOLD}Fetching installer from ${CYAN}${TARGET_REPO}@${TARGET_BRANCH}${NC}..."

TMP_INSTALLER=$(mktemp /tmp/hroot-installer-XXXXXX.sh)

if curl -fsSL -H "Authorization: token ${GITHUB_TOKEN}" "$INSTALLER_URL" -o "$TMP_INSTALLER" 2>/dev/null; then
  echo -e "✓ Installer downloaded successfully.\n"
  chmod +x "$TMP_INSTALLER"
  
  # Export credentials to subshell
  export GITHUB_USER="$GITHUB_USER"
  export GITHUB_TOKEN="$GITHUB_TOKEN"
  export HROOT_REPO="$TARGET_REPO"
  export HROOT_BRANCH="$TARGET_BRANCH"
  export HROOT_TAG="$TARGET_TAG"
  
  bash "$TMP_INSTALLER"
  rm -f "$TMP_INSTALLER"
else

  echo -e "${RED}Error: Failed to download installer from ${INSTALLER_URL}.${NC}"
  echo "Please verify that your GitHub account has Read access to '${TARGET_REPO}' and your token has the 'repo' scope."
  rm -f "$TMP_INSTALLER"
  exit 1
fi
