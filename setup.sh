#!/usr/bin/env bash
# =============================================================
#  EON Marketing & General Merchandise — One-Stop Setup Script
#  Run this ONCE at the very start to get everything running.
#
#  Works on: Linux, macOS, Windows (Git Bash / WSL)
#  Requires: Docker Desktop (running)
# =============================================================

set -euo pipefail

# ── Colours ────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; WHITE='\033[1;37m'; DIM='\033[2m'; NC='\033[0m'

# ── Helpers ────────────────────────────────────────────────────
info()    { echo -e "${CYAN}▸${NC} $*"; }
success() { echo -e "${GREEN}✓${NC} $*"; }
warn()    { echo -e "${YELLOW}⚠${NC}  $*"; }
error()   { echo -e "${RED}✗${NC} $*" >&2; exit 1; }
step()    { echo -e "\n${WHITE}━━━  $*  ━━━${NC}"; }

banner() {
  echo -e "${GREEN}"
  echo "  ███████╗ ██████╗ ███╗   ██╗"
  echo "  ██╔════╝██╔═══██╗████╗  ██║"
  echo "  █████╗  ██║   ██║██╔██╗ ██║"
  echo "  ██╔══╝  ██║   ██║██║╚██╗██║"
  echo "  ███████╗╚██████╔╝██║ ╚████║"
  echo "  ╚══════╝ ╚═════╝ ╚═╝  ╚═══╝"
  echo -e "${NC}"
  echo -e "${WHITE}  EON Marketing & General Merchandise${NC}"
  echo -e "${DIM}  Product Catalog — Docker Setup${NC}"
  echo ""
}

# ── Resolve script location ────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# ── Check for --reset flag ─────────────────────────────────────
RESET_VOLUMES=false
FORCE=false
for arg in "$@"; do
  case $arg in
    --reset) RESET_VOLUMES=true ;;
    --force|-f) FORCE=true ;;
  esac
done

# ══════════════════════════════════════════════════════════════
banner
# ══════════════════════════════════════════════════════════════

# ── Step 1: Check requirements ─────────────────────────────────
step "Checking requirements"

if ! command -v docker &>/dev/null; then
  error "Docker is not installed or not in PATH.\n  → Install Docker Desktop from https://www.docker.com/products/docker-desktop"
fi
success "Docker found: $(docker --version | awk '{print $3}' | tr -d ',')"

# Docker Compose v2 (plugin) or v1 (standalone)
if docker compose version &>/dev/null 2>&1; then
  COMPOSE="docker compose"
elif command -v docker-compose &>/dev/null; then
  COMPOSE="docker-compose"
else
  error "Docker Compose is not available.\n  → Update Docker Desktop or install docker-compose separately."
fi
success "Docker Compose found: $($COMPOSE version --short 2>/dev/null || $COMPOSE version)"

# Check Docker daemon is running
if ! docker info &>/dev/null; then
  error "Docker daemon is not running.\n  → Start Docker Desktop and try again."
fi
success "Docker daemon is running"

# ── Step 2: Collect configuration ──────────────────────────────
step "Configuration"

# Load existing .env values if present
if [[ -f .env ]]; then
  set -a; source .env 2>/dev/null || true; set +a
fi
if [[ -f .env.backend ]]; then
  set -a; source .env.backend 2>/dev/null || true; set +a
  if [[ "$FORCE" == false ]]; then
    warn ".env.backend already exists. Using existing settings."
    warn "Run with --force to reconfigure, or --reset to wipe volumes too."
  fi
fi

# ── Prompt for settings (skip if already set) ──────────────────
if [[ -z "${ADMIN_PASSWORD_HASH:-}" ]] || [[ "$FORCE" == true ]]; then

  echo ""
  echo -e "${WHITE}Configure admin account:${NC}"

  # Admin username
  read -rp "  Admin username [admin]: " INPUT_USER
  ADMIN_USERNAME="${INPUT_USER:-admin}"

  # Admin password
  while true; do
    read -rsp "  Admin password [Admin@1234]: " INPUT_PASS
    echo ""
    ADMIN_PASSWORD="${INPUT_PASS:-Admin@1234}"
    if [[ ${#ADMIN_PASSWORD} -ge 6 ]]; then break; fi
    warn "Password must be at least 6 characters. Try again."
  done

  echo ""
  echo -e "${WHITE}Application settings:${NC}"
  read -rp "  App port (browser access) [8080]: " INPUT_PORT
  APP_PORT="${INPUT_PORT:-8080}"

  read -rp "  Database password [eon_secret]: " INPUT_DBPASS
  DB_PASSWORD="${INPUT_DBPASS:-eon_secret}"

  # Generate a random JWT secret
  JWT_SECRET=$(LC_ALL=C tr -dc 'A-Za-z0-9!@#$%^&*' </dev/urandom 2>/dev/null | head -c 48 || \
               echo "eon_jwt_$(date +%s)_$(od -An -N4 -tu4 /dev/urandom 2>/dev/null | tr -d ' ' || echo '1234')")

  DB_NAME="product_catalog"

  # ── Generate bcrypt hash ──────────────────────────────────────
  step "Generating password hash"
  info "Pulling node:20-alpine image (used for hashing only)..."

  # Try local node first (fast)
  if command -v node &>/dev/null && node -e "require('bcryptjs')" &>/dev/null 2>&1; then
    ADMIN_PASSWORD_HASH=$(node -e "const b=require('bcryptjs');console.log(b.hashSync('$ADMIN_PASSWORD',10))")
    success "Generated hash using local Node.js"
  else
    # Use Docker to generate hash — no local Node needed
    docker pull node:20-alpine -q
    ADMIN_PASSWORD_HASH=$(docker run --rm node:20-alpine \
      sh -c "mkdir /nh && cd /nh && npm init -y >/dev/null 2>&1 && npm install bcryptjs >/dev/null 2>&1 && node -e \"process.stdout.write(require('bcryptjs').hashSync('$ADMIN_PASSWORD',10))\"")
    success "Generated hash using Docker"
  fi

else
  info "Skipping configuration (using existing .env files)"
  # Source existing values
  if [[ -f .env ]]; then set -a; source .env 2>/dev/null || true; set +a; fi
  ADMIN_USERNAME="${ADMIN_USERNAME:-admin}"
  ADMIN_PASSWORD="${ADMIN_PASSWORD:-Admin@1234}"
  APP_PORT="${APP_PORT:-8080}"
  DB_PASSWORD="${DB_PASSWORD:-eon_secret}"
  DB_NAME="${DB_NAME:-product_catalog}"
  JWT_SECRET="${JWT_SECRET:-eon_jwt_change_me}"
fi

# ── Step 3: Write env files ────────────────────────────────────
step "Writing env files"

# Root .env — used by docker-compose for port/DB vars (no $ hash here)
cat > .env <<ROOTENV
# Generated by setup.sh — $(date)
APP_PORT=${APP_PORT}
DB_NAME=${DB_NAME}
DB_PASSWORD=${DB_PASSWORD}
ROOTENV

# .env.backend — loaded via env_file: in docker-compose, NOT interpolated
# This is the safe way to pass bcrypt hashes (which contain literal $ chars)
printf '%s\n' \
  "PORT=3000" \
  "DB_HOST=mysql" \
  "DB_PORT=3306" \
  "DB_USER=root" \
  "DB_PASSWORD=${DB_PASSWORD}" \
  "DB_NAME=${DB_NAME}" \
  "JWT_SECRET=${JWT_SECRET}" \
  "JWT_EXPIRES_IN=24h" \
  "ADMIN_USERNAME=${ADMIN_USERNAME}" \
  "ADMIN_PASSWORD=${ADMIN_PASSWORD}" \
  "ADMIN_PASSWORD_HASH=${ADMIN_PASSWORD_HASH}" \
  > .env.backend

success ".env and .env.backend written"

# ── Step 4: Reset volumes (optional) ──────────────────────────
if [[ "$RESET_VOLUMES" == true ]]; then
  step "Resetting volumes (--reset flag)"
  warn "This will DELETE all database data and uploads."
  read -rp "  Are you sure? [y/N]: " CONFIRM
  if [[ "${CONFIRM:-N}" =~ ^[Yy]$ ]]; then
    $COMPOSE down -v --remove-orphans 2>/dev/null || true
    success "Volumes cleared"
  else
    info "Skipping volume reset"
  fi
else
  # Just stop any running containers before rebuild
  $COMPOSE down --remove-orphans 2>/dev/null || true
fi

# ── Step 5: Build images ───────────────────────────────────────
step "Building Docker images"
info "This may take 3–5 minutes on first run..."
$COMPOSE build --parallel
success "Images built"

# ── Step 6: Start services ─────────────────────────────────────
step "Starting services"
$COMPOSE up -d
success "Containers started"

# ── Step 7: Wait for MySQL ─────────────────────────────────────
step "Waiting for MySQL to be ready"
MAX_WAIT=90
WAIT=0
printf "  "
until docker exec eon_mysql mysqladmin ping -u root "-p${DB_PASSWORD}" --silent 2>/dev/null; do
  printf "."
  sleep 3
  WAIT=$((WAIT + 3))
  if [[ $WAIT -ge $MAX_WAIT ]]; then
    echo ""
    error "MySQL didn't become ready within ${MAX_WAIT}s.\n  Check logs: docker logs eon_mysql"
  fi
done
echo ""
success "MySQL is ready"

# ── Step 8: Wait for backend ───────────────────────────────────
step "Waiting for backend API"
MAX_WAIT=60
WAIT=0
printf "  "
until docker exec eon_backend wget -qO- http://localhost:3000/api/health &>/dev/null; do
  printf "."
  sleep 3
  WAIT=$((WAIT + 3))
  if [[ $WAIT -ge $MAX_WAIT ]]; then
    echo ""
    error "Backend didn't start within ${MAX_WAIT}s.\n  Check logs: docker logs eon_backend"
  fi
done
echo ""
success "Backend API is healthy"

# ── Step 9: Wait for frontend ──────────────────────────────────
step "Waiting for frontend (Nginx)"
MAX_WAIT=30
WAIT=0
printf "  "
until docker exec eon_frontend wget -qO- http://localhost/ &>/dev/null; do
  printf "."
  sleep 2
  WAIT=$((WAIT + 2))
  if [[ $WAIT -ge $MAX_WAIT ]]; then
    echo ""
    warn "Frontend health check timed out — it may still be building. Continue anyway."
    break
  fi
done
echo ""
success "Frontend is live"

# ── Step 10: Verify product seed ──────────────────────────────
step "Verifying seed data"
PRODUCT_COUNT=$(docker exec eon_mysql mysql -u root "-p${DB_PASSWORD}" -D "${DB_NAME}" \
  -se "SELECT COUNT(*) FROM products;" 2>/dev/null || echo "0")
success "Database contains ${PRODUCT_COUNT} products"

# ══════════════════════════════════════════════════════════════
# ── Done! ─────────────────────────────────────────────────────
# ══════════════════════════════════════════════════════════════
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  ✓  Everything is running!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${WHITE}Store (client site)${NC}"
echo -e "  → ${CYAN}http://localhost:${APP_PORT}${NC}"
echo ""
echo -e "  ${WHITE}Admin Panel${NC}"
echo -e "  → ${CYAN}http://localhost:${APP_PORT}/admin/login${NC}"
echo -e "     Username : ${YELLOW}${ADMIN_USERNAME}${NC}"
echo -e "     Password : ${YELLOW}${ADMIN_PASSWORD}${NC}"
echo ""
echo -e "  ${WHITE}Backend API${NC}"
echo -e "  → ${CYAN}http://localhost:3000/api/health${NC}"
echo ""
echo -e "  ${WHITE}Useful commands${NC}"
echo -e "  ${DIM}docker compose logs -f          # stream all logs${NC}"
echo -e "  ${DIM}docker compose logs -f backend  # backend logs only${NC}"
echo -e "  ${DIM}docker compose stop             # stop without deleting data${NC}"
echo -e "  ${DIM}bash setup.sh --reset           # wipe DB and start fresh${NC}"
echo -e "  ${DIM}bash setup.sh --force           # reconfigure credentials${NC}"
echo ""

# Try to auto-open in browser (best-effort, non-fatal)
URL="http://localhost:${APP_PORT}"
if command -v xdg-open &>/dev/null; then
  xdg-open "$URL" &>/dev/null &
elif command -v open &>/dev/null; then
  open "$URL" &>/dev/null &
elif command -v cmd.exe &>/dev/null; then
  cmd.exe /c start "$URL" &>/dev/null &
fi
