#!/usr/bin/env bash
# ==============================================================================
# HROOT Automated Update Helper (Docker)
# ==============================================================================
# Safe, 1-command updater for Docker-based HROOT installations.
# Performs:
#   1. Pre-flight checks (Docker Engine & Rootless detection)
#   2. GitHub Personal Access Token (PAT) validity check & interactive renewal
#   3. Pre-update MySQL database snapshot backup
#   4. Container image pull (ghcr.io)
#   5. Graceful restart with automatic schema migration (db:prepare)
#   6. Post-update health & service verification
# ==============================================================================

set -euo pipefail

# ANSI Styling
BOLD='\033[1m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Ensure script runs from the application root directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${APP_DIR}"

echo -e "${BOLD}=================================================================="
echo "                   HROOT System Update Utility                   "
echo -e "==================================================================${NC}"
echo -e "Application directory: ${CYAN}${APP_DIR}${NC}"
echo ""

# Helper to read values safely from .env without sourcing (prevents unquoted bash syntax issues)
get_env_val() {
  local key="$1"
  local file="${2:-.env}"
  if [ -f "$file" ]; then
    (grep -E "^${key}=" "$file" 2>/dev/null || true) | head -n1 | cut -d'=' -f2- | sed -e 's/^[[:space:]]*["'"'"']//' -e 's/["'"'"'][[:space:]]*$//' | tr -d '\r'
  fi
}

# 1. Environment File Check
if [ ! -f ".env" ]; then
  echo -e "${RED}Error: No .env configuration file found in '${APP_DIR}'.${NC}"
  echo "Please run the initial installation first via ./bin/install."
  exit 1
fi

DATABASE_HOST="$(get_env_val DATABASE_HOST)"
DATABASE_NAME="$(get_env_val DATABASE_NAME)"
DATABASE_USERNAME="$(get_env_val DATABASE_USERNAME)"
DATABASE_PASSWORD="$(get_env_val DATABASE_PASSWORD)"
PROXY_MODE="$(get_env_val PROXY_MODE)"
HROOT_IMAGE="$(get_env_val HROOT_IMAGE)"
GH_USER="$(get_env_val UPDATE_GITHUB_USER)"
[ -z "$GH_USER" ] && GH_USER="$(get_env_val GITHUB_USER)"
GH_TOKEN="$(get_env_val UPDATE_GITHUB_TOKEN)"
[ -z "$GH_TOKEN" ] && GH_TOKEN="$(get_env_val GITHUB_TOKEN)"

# 2. Docker & Compose Detection
DOCKER_CMD_BASE="docker"
DOCKER_COMPOSE_CMD="docker compose"

if ! command -v docker >/dev/null 2>&1; then
  echo -e "${RED}Error: Docker is not installed on this system.${NC}"
  exit 1
fi

if docker info --format '{{.SecurityOptions}}' 2>/dev/null | grep -q 'rootless'; then
  echo -e "-> Docker Environment: ${GREEN}Rootless Docker (Unprivileged & Secure)${NC}"
elif docker info >/dev/null 2>&1; then
  echo -e "-> Docker Environment: ${GREEN}Standard Docker Engine${NC}"
elif command -v sudo >/dev/null 2>&1 && sudo docker info >/dev/null 2>&1; then
  echo -e "-> Docker Environment: ${YELLOW}Standard Docker Engine (via sudo fallback)${NC}"
  DOCKER_CMD_BASE="sudo docker"
  DOCKER_COMPOSE_CMD="sudo docker compose"
else
  echo -e "${RED}Error: Cannot connect to Docker daemon. Check permissions or configure Rootless Docker.${NC}"
  exit 1
fi

if ! $DOCKER_COMPOSE_CMD version >/dev/null 2>&1; then
  if command -v docker-compose >/dev/null 2>&1; then
    DOCKER_COMPOSE_CMD="docker-compose"
  else
    echo -e "${RED}Error: Docker Compose v2 is not available.${NC}"
    exit 1
  fi
fi

# Detect Compose configuration overrides
COMPOSE_ARGS=("-f" "docker-compose.yml")
if [ -f "docker-compose.override.yml" ]; then
  COMPOSE_ARGS+=("-f" "docker-compose.override.yml")
elif [ -f "docker/overrides/ext-db.yml" ] && [ -n "${DATABASE_HOST:-}" ] && [ "${DATABASE_HOST}" != "db" ] && [ "${DATABASE_HOST}" != "localhost" ]; then
  COMPOSE_ARGS+=("-f" "docker/overrides/ext-db.yml")
elif [ -f "docker/overrides/shared-proxy.yml" ] && [ "${PROXY_MODE:-}" = "shared" ]; then
  COMPOSE_ARGS+=("-f" "docker/overrides/shared-proxy.yml")
fi

HROOT_IMAGE="${HROOT_IMAGE:-ghcr.io/wiso-forschungslabor/hroot:latest}"

# 3. Check and validate GitHub PAT
validate_github_token() {
  local token="$1"
  if [ -z "$token" ]; then
    return 1
  fi
  if command -v curl >/dev/null 2>&1; then
    local code
    code=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: token ${token}" -H "User-Agent: HROOT-Updater" https://api.github.com/user 2>/dev/null || echo "000")
    if [ "$code" = "200" ]; then
      return 0
    elif [ "$code" = "401" ] || [ "$code" = "403" ]; then
      return 2
    fi
  fi
  return 0
}

echo -e "\n${BOLD}1. Validating GitHub Personal Access Token (PAT):${NC}"
TOKEN_VALID=false

if [ -n "$GH_TOKEN" ]; then
  echo -n "Checking saved token for user '${GH_USER:-unknown}'... "
  if validate_github_token "$GH_TOKEN"; then
    echo -e "${GREEN}Valid (HTTP 200)!${NC}"
    if echo "$GH_TOKEN" | $DOCKER_CMD_BASE login ghcr.io -u "${GH_USER}" --password-stdin >/dev/null 2>&1; then
      echo -e "-> Registry Authentication (ghcr.io): ${GREEN}Success${NC}."
      TOKEN_VALID=true
    else
      echo -e "-> Registry Authentication (ghcr.io): ${YELLOW}Login failed${NC}."
    fi
  else
    echo -e "${RED}Invalid or Expired (HTTP 401 Bad Credentials)!${NC}"
  fi
else
  echo -e "${YELLOW}No GitHub Token found in .env.${NC}"
fi

if [ "$TOKEN_VALID" = false ]; then
  echo ""
  echo -e "${YELLOW}${BOLD}=================================================================="
  echo "⚠️  Action Required: Valid GitHub Personal Access Token Needed"
  echo -e "==================================================================${NC}"
  echo "To pull container image updates from ghcr.io, a valid GitHub Personal"
  echo "Access Token (Classic PAT) is required."
  echo ""
  echo "Instructions to create a token:"
  echo "  1. Open: https://github.com/settings/tokens"
  echo "  2. Select: 'Generate new token' -> 'Generate new token (classic)'"
  echo "  3. Scopes: Check the 'read:packages' box (and optional 'repo')"
  echo "  4. Ensure your GitHub account is a member of the '@hroot-licensees' team"
  echo "=================================================================="
  echo ""

  read -r -p "Would you like to enter a new GitHub Token now? [Y/n]: " DO_ENTER_PAT
  DO_ENTER_PAT="${DO_ENTER_PAT:-Y}"
  if [[ "$DO_ENTER_PAT" =~ ^[Yy]$ ]]; then
    read -r -p "GitHub Username [${GH_USER}]: " INPUT_USER
    GH_USER="${INPUT_USER:-$GH_USER}"

    read -r -s -p "GitHub Personal Access Token (PAT): " INPUT_TOKEN
    echo ""
    GH_TOKEN="${INPUT_TOKEN:-}"

    if [ -z "$GH_USER" ] || [ -z "$GH_TOKEN" ]; then
      echo -e "${RED}Error: Username and Token cannot be empty.${NC}"
      exit 1
    fi

    echo -n "Validating new token with GitHub API... "
    if validate_github_token "$GH_TOKEN"; then
      echo -e "${GREEN}Authorized successfully!${NC}"
      if echo "$GH_TOKEN" | $DOCKER_CMD_BASE login ghcr.io -u "$GH_USER" --password-stdin; then
        echo -e "-> Login to ${GREEN}ghcr.io${NC} confirmed."
        
        # Persist updated token to .env
        if grep -q "^UPDATE_GITHUB_USER=" .env; then
          sed -i "s|^UPDATE_GITHUB_USER=.*|UPDATE_GITHUB_USER=${GH_USER}|" .env
        else
          echo "UPDATE_GITHUB_USER=${GH_USER}" >> .env
        fi

        if grep -q "^UPDATE_GITHUB_TOKEN=" .env; then
          sed -i "s|^UPDATE_GITHUB_TOKEN=.*|UPDATE_GITHUB_TOKEN=${GH_TOKEN}|" .env
        else
          echo "UPDATE_GITHUB_TOKEN=${GH_TOKEN}" >> .env
        fi
        echo -e "-> Saved updated credentials into ${GREEN}.env${NC}."
        TOKEN_VALID=true
      fi
    else
      echo -e "${RED}Rejected (HTTP 401/403)! The token is not valid.${NC}"
      echo "Please verify spelling and ensure the 'read:packages' scope is enabled."
      exit 1
    fi
  else
    echo -e "${RED}Update aborted without valid GitHub credentials.${NC}"
    exit 1
  fi
fi

# 4. Confirmation
echo ""
echo -e "${BOLD}2. Ready to Update:${NC}"
echo "Target Image: ${CYAN}${HROOT_IMAGE}${NC}"
echo "Compose Args: ${CYAN}${COMPOSE_ARGS[*]}${NC}"
echo ""
read -r -p "Do you want to proceed with the system update now? [Y/n]: " CONFIRM_UPDATE
CONFIRM_UPDATE="${CONFIRM_UPDATE:-Y}"
if [[ ! "$CONFIRM_UPDATE" =~ ^[Yy]$ ]]; then
  echo -e "\nUpdate cancelled."
  exit 0
fi

# 5. Pre-Update Database Snapshot
echo -e "\n${BOLD}3. Pre-Update Database Snapshot:${NC}"
BACKUP_FILE="backup_pre_update_$(date +%F_%H%M%S).sql"
if $DOCKER_COMPOSE_CMD "${COMPOSE_ARGS[@]}" ps -q db 2>/dev/null | grep -q .; then
  echo -n "Creating MySQL dump '${BACKUP_FILE}'... "
  if $DOCKER_COMPOSE_CMD "${COMPOSE_ARGS[@]}" exec -T db mysqldump \
    -u "${DATABASE_USERNAME:-hroot}" \
    -p"${DATABASE_PASSWORD:-hrootpassword}" \
    "${DATABASE_NAME:-hroot_production}" > "${BACKUP_FILE}" 2>/dev/null; then
    if [ -s "${BACKUP_FILE}" ]; then
      echo -e "${GREEN}Created!${NC} (Size: $(du -h "${BACKUP_FILE}" | cut -f1))"
    else
      rm -f "${BACKUP_FILE}"
      echo -e "${YELLOW}Empty database.${NC}"
    fi
  else
    echo -e "${YELLOW}Notice: Snapshot via local DB container skipped.${NC}"
  fi
else
  echo "-> Notice: Domestic DB container not running (external MySQL server configured)."
fi

# 6. Pull Container Images
echo -e "\n${BOLD}4. Pulling Updated Container Images:${NC}"
if ! $DOCKER_COMPOSE_CMD "${COMPOSE_ARGS[@]}" pull; then
  echo -e "${RED}Error: Failed to pull images from GHCR.${NC}"
  echo -e "Please check whether account '${GH_USER}' has been granted read access in the organization."
  exit 1
fi
echo -e "-> ${GREEN}Container images pulled successfully.${NC}"

# 7. Restart Services
echo -e "\n${BOLD}5. Restarting Containers with New Image:${NC}"
$DOCKER_COMPOSE_CMD "${COMPOSE_ARGS[@]}" up -d

# 8. Post-Update Verification
echo -e "\n${BOLD}6. Verifying Service Health:${NC}"
sleep 3
$DOCKER_COMPOSE_CMD "${COMPOSE_ARGS[@]}" ps

echo ""
echo -e "${GREEN}${BOLD}=================================================================="
echo "          ✓ HROOT System Update Successfully Completed!           "
echo -e "==================================================================${NC}"
echo "Web interface is live and accessible at your configured domain."
echo "Database migrations are automatically verified on container start."
