#!/usr/bin/env bash
# =============================================================
#  EON Marketing — AWS One-Stop Deploy Script
#  Controls a t3.micro EC2 instance in ap-southeast-1
#
#  Works in: Git Bash (Windows), macOS Terminal, Linux
#  Requires: AWS CLI v2  ·  ssh / scp  ·  tar
#
#  Usage:
#    ./aws-deploy.sh deploy    — full infra + app deploy (first run)
#    ./aws-deploy.sh update    — push code changes & restart
#    ./aws-deploy.sh status    — instance & container health
#    ./aws-deploy.sh logs      — tail all container logs
#    ./aws-deploy.sh logs [svc] — tail one service (mysql/backend/frontend)
#    ./aws-deploy.sh ssh       — open interactive SSH session
#    ./aws-deploy.sh ip        — print public IP
#    ./aws-deploy.sh open      — open app URL in browser
#    ./aws-deploy.sh restart   — restart containers (no rebuild)
#    ./aws-deploy.sh stop      — stop EC2 instance (saves billing)
#    ./aws-deploy.sh start     — start a stopped instance
#    ./aws-deploy.sh destroy   — terminate everything (with confirmation)
# =============================================================

set -euo pipefail

# ── Colours ────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; WHITE='\033[1;37m'; DIM='\033[2m'; NC='\033[0m'
BOLD='\033[1m'

info()    { echo -e "${CYAN}▸${NC} $*"; }
success() { echo -e "${GREEN}✓${NC} $*"; }
warn()    { echo -e "${YELLOW}⚠${NC}  $*"; }
error()   { echo -e "${RED}✗${NC} $*" >&2; exit 1; }
step()    { echo -e "\n${WHITE}━━━  $*  ━━━${NC}"; }
dim()     { echo -e "${DIM}  $*${NC}"; }

banner() {
  echo -e "${GREEN}"
  echo "  ███████╗ ██████╗ ███╗   ██╗"
  echo "  ██╔════╝██╔═══██╗████╗  ██║"
  echo "  █████╗  ██║   ██║██╔██╗ ██║"
  echo "  ██╔══╝  ██║   ██║██║╚██╗██║"
  echo "  ███████╗╚██████╔╝██║ ╚████║"
  echo "  ╚══════╝ ╚═════╝ ╚═╝  ╚═══╝"
  echo -e "${NC}"
  echo -e "${WHITE}  EON Marketing — AWS Deploy${NC}"
  echo -e "${DIM}  ap-southeast-1 (Singapore) · t3.micro · Free Tier${NC}"
  echo ""
}

# ── Config ─────────────────────────────────────────────────────
REGION="ap-southeast-1"
INSTANCE_TYPE="t3.micro"
PROJECT_NAME="eon-marketing"
KEY_NAME="eon-marketing-aws"
KEY_FILE="$HOME/.ssh/${KEY_NAME}.pem"
SG_NAME="${PROJECT_NAME}-sg"
APP_DIR="/home/ec2-user/eon"

# Resolve script location so it works from any CWD
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load .env for APP_PORT (default 9090)
[[ -f "$SCRIPT_DIR/.env" ]] && { set -a; source "$SCRIPT_DIR/.env"; set +a; } || true
APP_PORT="${APP_PORT:-9090}"

# Use Windows OpenSSH (not Git Bash's bundled ssh)
WIN_SSH="/c/Windows/System32/OpenSSH/ssh.exe"
WIN_SCP="/c/Windows/System32/OpenSSH/scp.exe"
SSH_BIN="$([[ -f "$WIN_SSH" ]] && echo "$WIN_SSH" || echo "ssh")"
SCP_BIN="$([[ -f "$WIN_SCP" ]] && echo "$WIN_SCP" || echo "scp")"

# SSH flags reused everywhere
SSH_OPTS="-i $KEY_FILE -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 -o ServerAliveInterval=30"

# ══════════════════════════════════════════════════════════════
# ── Helper: get running/stopped instance ID ───────────────────
# ══════════════════════════════════════════════════════════════
get_instance_id() {
  aws ec2 describe-instances \
    --region "$REGION" \
    --filters \
      "Name=tag:Name,Values=${PROJECT_NAME}" \
      "Name=instance-state-name,Values=running,stopped,stopping,pending" \
    --query 'Reservations[0].Instances[0].InstanceId' \
    --output text 2>/dev/null | grep -v '^None$' || true
}

# ── Helper: get public IP ──────────────────────────────────────
get_public_ip() {
  local id="$1"
  aws ec2 describe-instances \
    --region "$REGION" \
    --instance-ids "$id" \
    --query 'Reservations[0].Instances[0].PublicIpAddress' \
    --output text 2>/dev/null | grep -v '^None$' || true
}

# ── Helper: get instance state ────────────────────────────────
get_instance_state() {
  local id="$1"
  aws ec2 describe-instances \
    --region "$REGION" \
    --instance-ids "$id" \
    --query 'Reservations[0].Instances[0].State.Name' \
    --output text 2>/dev/null || true
}

# ── Helper: run SSH command on instance ───────────────────────
remote() {
  local ip="$1"; shift
  "$SSH_BIN" $SSH_OPTS "ec2-user@${ip}" "$@"
}

# ── Helper: require existing running instance ──────────────────
require_instance() {
  INSTANCE_ID="$(get_instance_id)"
  [[ -z "$INSTANCE_ID" ]] && error "No ${PROJECT_NAME} instance found. Run: ./aws-deploy.sh deploy"

  STATE="$(get_instance_state "$INSTANCE_ID")"
  [[ "$STATE" != "running" ]] && error "Instance ${INSTANCE_ID} is ${STATE}, not running. Run: ./aws-deploy.sh start"

  PUBLIC_IP="$(get_public_ip "$INSTANCE_ID")"
  [[ -z "$PUBLIC_IP" ]] && error "Instance has no public IP yet. Wait a moment and retry."
  echo "$PUBLIC_IP"
}

# ── Helper: wait for SSH ───────────────────────────────────────
wait_for_ssh() {
  local ip="$1"
  info "Waiting for SSH on ${ip} ..."
  local tries=0 max=40
  until "$SSH_BIN" $SSH_OPTS "ec2-user@${ip}" "exit 0" &>/dev/null; do
    printf "."
    sleep 5
    tries=$((tries + 1))
    [[ $tries -ge $max ]] && { echo ""; error "SSH not available after $((max * 5))s. Check security group / instance state."; }
  done
  echo ""
  success "SSH ready"
}

# ── Helper: get existing Elastic IP allocation ID ─────────────
get_eip_alloc_id() {
  aws ec2 describe-addresses \
    --region "$REGION" \
    --filters "Name=tag:Name,Values=${PROJECT_NAME}-eip" \
    --query 'Addresses[0].AllocationId' \
    --output text 2>/dev/null | grep -v '^None$' || true
}

# ── Helper: get Elastic IP address ────────────────────────────
get_eip_address() {
  aws ec2 describe-addresses \
    --region "$REGION" \
    --filters "Name=tag:Name,Values=${PROJECT_NAME}-eip" \
    --query 'Addresses[0].PublicIp' \
    --output text 2>/dev/null | grep -v '^None$' || true
}

# ── Helper: allocate EIP if needed, then associate ────────────
ensure_eip() {
  local instance_id="$1"
  step "Elastic IP"

  local alloc_id
  alloc_id="$(get_eip_alloc_id)"

  if [[ -z "$alloc_id" ]]; then
    info "Allocating new Elastic IP ..."
    alloc_id=$(aws ec2 allocate-address \
      --region "$REGION" \
      --domain vpc \
      --query 'AllocationId' \
      --output text)
    aws ec2 create-tags --region "$REGION" \
      --resources "$alloc_id" \
      --tags "Key=Name,Value=${PROJECT_NAME}-eip"
    success "Elastic IP allocated"
  else
    success "Elastic IP exists: $(get_eip_address)"
  fi

  info "Associating Elastic IP with ${instance_id} ..."
  aws ec2 associate-address \
    --region "$REGION" \
    --instance-id "$instance_id" \
    --allocation-id "$alloc_id" \
    --allow-reassociation &>/dev/null
  local eip
  eip="$(get_eip_address)"
  success "Elastic IP associated: ${eip} (permanent - survives stop/start)"
  echo "$eip"
}

# ── Helper: bootstrap Docker on a fresh Amazon Linux 2023 ─────
bootstrap_docker() {
  local ip="$1"
  info "Installing Docker + Compose + Buildx on instance (idempotent) ..."
  remote "$ip" bash <<'BOOTSTRAP'
set -e
PLUGIN_DIR="/usr/local/lib/docker/cli-plugins"
sudo mkdir -p "$PLUGIN_DIR"

# ── Docker engine ──────────────────────────────────────────────
if ! command -v docker &>/dev/null; then
  sudo dnf install -y docker
  sudo systemctl enable --now docker
  sudo usermod -aG docker ec2-user
  echo "Docker installed."
else
  sudo systemctl start docker 2>/dev/null || true
  echo "Docker already installed."
fi

# ── Docker Compose plugin ──────────────────────────────────────
COMPOSE_PLUGIN="${PLUGIN_DIR}/docker-compose"
if [[ ! -f "$COMPOSE_PLUGIN" ]]; then
  LATEST=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
  sudo curl -fsSL "https://github.com/docker/compose/releases/download/${LATEST}/docker-compose-linux-x86_64" \
    -o "$COMPOSE_PLUGIN"
  sudo chmod +x "$COMPOSE_PLUGIN"
  echo "Docker Compose ${LATEST} installed."
else
  echo "Docker Compose already installed."
fi

# ── Docker Buildx plugin (required by compose build >= 2.25) ──
BUILDX_PLUGIN="${PLUGIN_DIR}/docker-buildx"
NEED_BUILDX=false
if [[ ! -f "$BUILDX_PLUGIN" ]]; then
  NEED_BUILDX=true
else
  # Upgrade if version < 0.17.0
  CURRENT=$(docker buildx version 2>/dev/null | grep -oP 'v\K[0-9]+\.[0-9]+' | head -1 || echo "0.0")
  MAJOR=$(echo "$CURRENT" | cut -d. -f1)
  MINOR=$(echo "$CURRENT" | cut -d. -f2)
  if [[ "$MAJOR" -eq 0 && "$MINOR" -lt 17 ]]; then
    NEED_BUILDX=true
    echo "Buildx ${CURRENT} is too old, upgrading..."
  else
    echo "Buildx v${CURRENT} is up to date."
  fi
fi

if [[ "$NEED_BUILDX" == "true" ]]; then
  BX_VER=$(curl -s https://api.github.com/repos/docker/buildx/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
  sudo curl -fsSL "https://github.com/docker/buildx/releases/download/${BX_VER}/buildx-${BX_VER}.linux-amd64" \
    -o "$BUILDX_PLUGIN"
  sudo chmod +x "$BUILDX_PLUGIN"
  echo "Buildx ${BX_VER} installed."
fi
BOOTSTRAP
  success "Docker + Compose + Buildx ready"
}

# ── Helper: transfer project files ────────────────────────────
transfer_files() {
  local ip="$1"
  step "Transferring project files"

  # Check .env files exist
  [[ ! -f "$SCRIPT_DIR/.env" ]]         && error ".env not found. Run ./setup.sh first."
  [[ ! -f "$SCRIPT_DIR/.env.backend" ]] && error ".env.backend not found. Run ./setup.sh first."

  # Create tarball (exclude dev artifacts)
  local TMP_TAR
  TMP_TAR="$(mktemp /tmp/eon-deploy-XXXXXX.tar.gz)"
  info "Packing project files ..."
  tar -czf "$TMP_TAR" \
    --exclude='./.git' \
    --exclude='./backend/node_modules' \
    --exclude='./frontend/node_modules' \
    --exclude='./frontend/dist' \
    --exclude='./uploads' \
    --exclude='./.env' \
    --exclude='./.env.backend' \
    -C "$SCRIPT_DIR" .

  info "Uploading archive ($(du -h "$TMP_TAR" | cut -f1)) ..."
  "$SCP_BIN" $SSH_OPTS "$TMP_TAR" "ec2-user@${ip}:/home/ec2-user/eon-deploy.tar.gz"
  rm -f "$TMP_TAR"

  # Extract on remote
  remote "$ip" bash <<EXTRACT
mkdir -p ${APP_DIR}
tar -xzf /home/ec2-user/eon-deploy.tar.gz -C ${APP_DIR}
rm -f /home/ec2-user/eon-deploy.tar.gz
EXTRACT

  # Upload env files separately (they are gitignored / secret)
  info "Uploading env files ..."
  "$SCP_BIN" $SSH_OPTS "$SCRIPT_DIR/.env"         "ec2-user@${ip}:${APP_DIR}/.env"
  "$SCP_BIN" $SSH_OPTS "$SCRIPT_DIR/.env.backend" "ec2-user@${ip}:${APP_DIR}/.env.backend"

  success "Files transferred to ${APP_DIR}"
}

# ── Helper: start containers ──────────────────────────────────
start_containers() {
  local ip="$1"
  local rebuild="${2:-true}"
  step "Starting containers"
  if [[ "$rebuild" == "true" ]]; then
    remote "$ip" "cd ${APP_DIR} && docker compose up --build -d 2>&1"
  else
    remote "$ip" "cd ${APP_DIR} && docker compose up -d 2>&1"
  fi
  success "Containers started"
}

# ── Helper: wait for app ──────────────────────────────────────
wait_for_app() {
  local ip="$1"
  step "Waiting for app to be healthy"
  local tries=0 max=30
  printf "  "
  until remote "$ip" "curl -fso /dev/null http://localhost:${APP_PORT}" &>/dev/null; do
    printf "."
    sleep 5
    tries=$((tries + 1))
    if [[ $tries -ge $max ]]; then
      echo ""
      warn "App health check timed out (containers may still be starting)."
      warn "Check logs with: ./aws-deploy.sh logs"
      return
    fi
  done
  echo ""
  success "App is live"
}

# ── Helper: print final URL box ───────────────────────────────
print_urls() {
  local ip="$1"
  echo ""
  echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${GREEN}  ✓  EON Marketing is live on AWS!${NC}"
  echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
  echo -e "  ${WHITE}Store (client site)${NC}"
  echo -e "  → ${CYAN}http://${ip}:${APP_PORT}${NC}"
  echo ""
  echo -e "  ${WHITE}Admin Panel${NC}"
  echo -e "  → ${CYAN}http://${ip}:${APP_PORT}/admin/login${NC}"
  echo ""
  echo -e "  ${WHITE}Backend API health${NC}"
  echo -e "  → ${CYAN}http://${ip}:${APP_PORT}/api/health${NC}"
  echo ""
  echo -e "  ${WHITE}Quick commands${NC}"
  dim "./aws-deploy.sh logs          # tail all container logs"
  dim "./aws-deploy.sh logs backend  # backend logs only"
  dim "./aws-deploy.sh ssh           # SSH into instance"
  dim "./aws-deploy.sh update        # push code changes"
  dim "./aws-deploy.sh stop          # stop instance (saves billing)"
  echo ""
  echo -e "  ${WHITE}Instance${NC}: ${DIM}${INSTANCE_ID}${NC}  ${WHITE}IP${NC}: ${DIM}${ip}${NC}"
  echo ""
}

# ══════════════════════════════════════════════════════════════
# ── COMMAND: deploy ───────────────────────────────────────────
# ══════════════════════════════════════════════════════════════
cmd_deploy() {
  banner

  # ── 1. Prerequisites ──────────────────────────────────────────
  step "Checking prerequisites"

  command -v aws  &>/dev/null || error "AWS CLI not found. Install from https://aws.amazon.com/cli/"
  command -v ssh  &>/dev/null || error "ssh not found. Install OpenSSH."
  command -v scp  &>/dev/null || error "scp not found. Install OpenSSH."
  command -v tar  &>/dev/null || error "tar not found."
  command -v curl &>/dev/null || error "curl not found."

  # Verify AWS credentials
  aws sts get-caller-identity --region "$REGION" &>/dev/null \
    || error "AWS credentials not configured. Run: aws configure"
  success "AWS CLI authenticated ($(aws sts get-caller-identity --query Account --output text))"

  # ── 2. Key Pair ───────────────────────────────────────────────
  step "Key pair: ${KEY_NAME}"
  mkdir -p "$HOME/.ssh"

  if [[ -f "$KEY_FILE" ]]; then
    success "Key already exists: ${KEY_FILE}"
  else
    # Check if key exists in AWS but .pem is missing
    if aws ec2 describe-key-pairs --key-names "$KEY_NAME" --region "$REGION" &>/dev/null 2>&1; then
      warn "Key '${KEY_NAME}' exists in AWS but ${KEY_FILE} is missing locally."
      warn "You cannot recover the private key from AWS."
      read -rp "  Delete the AWS key and create a new one? [y/N]: " CONFIRM
      [[ "${CONFIRM:-N}" =~ ^[Yy]$ ]] || error "Aborting. Restore ${KEY_FILE} manually."
      aws ec2 delete-key-pair --key-name "$KEY_NAME" --region "$REGION"
    fi

    info "Creating key pair ..."
    aws ec2 create-key-pair \
      --key-name "$KEY_NAME" \
      --region "$REGION" \
      --query 'KeyMaterial' \
      --output text > "$KEY_FILE"
    chmod 600 "$KEY_FILE"
    success "Key saved: ${KEY_FILE}"
  fi

  # ── 3. Security Group ─────────────────────────────────────────
  step "Security group: ${SG_NAME}"
  SG_ID=$(aws ec2 describe-security-groups \
    --region "$REGION" \
    --filters "Name=group-name,Values=${SG_NAME}" \
    --query 'SecurityGroups[0].GroupId' \
    --output text 2>/dev/null | grep -v '^None$' || true)

  if [[ -n "$SG_ID" ]]; then
    success "Security group exists: ${SG_ID}"
  else
    SG_ID=$(aws ec2 create-security-group \
      --group-name "$SG_NAME" \
      --description "EON Marketing - SSH and App" \
      --region "$REGION" \
      --output text \
      --query 'GroupId')
    success "Security group created: ${SG_ID}"

    info "Adding inbound rules ..."
    # SSH
    aws ec2 authorize-security-group-ingress --group-id "$SG_ID" --region "$REGION" \
      --protocol tcp --port 22 --cidr 0.0.0.0/0 &>/dev/null
    # App port (frontend)
    aws ec2 authorize-security-group-ingress --group-id "$SG_ID" --region "$REGION" \
      --protocol tcp --port "${APP_PORT}" --cidr 0.0.0.0/0 &>/dev/null
    success "Rules added: SSH (22), App (${APP_PORT})"
  fi

  # ── 4. EC2 Instance ───────────────────────────────────────────
  step "EC2 instance"
  INSTANCE_ID="$(get_instance_id)"

  if [[ -n "$INSTANCE_ID" ]]; then
    STATE="$(get_instance_state "$INSTANCE_ID")"
    warn "Instance already exists: ${INSTANCE_ID} (${STATE})"
    if [[ "$STATE" == "stopped" ]]; then
      info "Starting stopped instance ..."
      aws ec2 start-instances --instance-ids "$INSTANCE_ID" --region "$REGION" &>/dev/null
    fi
  else
    # Query latest Amazon Linux 2023 AMI for ap-southeast-1
    info "Finding latest Amazon Linux 2023 AMI ..."
    AMI_ID=$(aws ec2 describe-images \
      --region "$REGION" \
      --owners amazon \
      --filters \
        "Name=name,Values=al2023-ami-*-x86_64" \
        "Name=state,Values=available" \
        "Name=virtualization-type,Values=hvm" \
      --query 'Images | sort_by(@, &CreationDate) | [-1].ImageId' \
      --output text)
    [[ -z "$AMI_ID" || "$AMI_ID" == "None" ]] && error "Could not find Amazon Linux 2023 AMI in ${REGION}."
    success "AMI: ${AMI_ID}"

    info "Launching t3.micro instance ..."
    INSTANCE_ID=$(aws ec2 run-instances \
      --region "$REGION" \
      --image-id "$AMI_ID" \
      --instance-type "$INSTANCE_TYPE" \
      --key-name "$KEY_NAME" \
      --security-group-ids "$SG_ID" \
      --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${PROJECT_NAME}}]" \
      --block-device-mappings '[{"DeviceName":"/dev/xvda","Ebs":{"VolumeSize":30,"VolumeType":"gp3","DeleteOnTermination":true}}]' \
      --query 'Instances[0].InstanceId' \
      --output text)
    success "Instance launched: ${INSTANCE_ID}"
  fi

  # ── 5. Wait for instance to be running ────────────────────────
  step "Waiting for instance to be running"
  printf "  "
  until [[ "$(get_instance_state "$INSTANCE_ID")" == "running" ]]; do
    printf "."
    sleep 5
  done
  echo ""
  success "Instance is running"

  # Wait for status checks
  info "Waiting for system status checks ..."
  aws ec2 wait instance-status-ok --instance-ids "$INSTANCE_ID" --region "$REGION"
  success "Status checks passed"

  # ── 5b. Elastic IP ────────────────────────────────────────────
  PUBLIC_IP="$(ensure_eip "$INSTANCE_ID")"

  # ── 6. Wait for SSH ───────────────────────────────────────────
  wait_for_ssh "$PUBLIC_IP"

  # ── 7. Bootstrap Docker ───────────────────────────────────────
  bootstrap_docker "$PUBLIC_IP"

  # ── 8. Transfer files ─────────────────────────────────────────
  transfer_files "$PUBLIC_IP"

  # ── 9. Start containers ───────────────────────────────────────
  # Re-login needed after usermod docker group (newgrp doesn't persist across SSH sessions)
  # We run docker via sudo for the first invocation to be safe
  remote "$PUBLIC_IP" bash <<COMPOSE_UP
cd ${APP_DIR}
# Use sg to get docker group without re-login
newgrp docker 2>/dev/null || true
docker compose up --build -d
COMPOSE_UP
  success "Containers launched"

  # ── 10. Wait for app ──────────────────────────────────────────
  wait_for_app "$PUBLIC_IP"

  print_urls "$PUBLIC_IP"
}

# ══════════════════════════════════════════════════════════════
# ── COMMAND: update ───────────────────────────────────────────
# ══════════════════════════════════════════════════════════════
cmd_update() {
  banner
  step "Updating deployment"
  PUBLIC_IP="$(require_instance)"
  transfer_files "$PUBLIC_IP"
  start_containers "$PUBLIC_IP" "true"
  wait_for_app "$PUBLIC_IP"
  echo ""
  success "Update complete → http://${PUBLIC_IP}:${APP_PORT}"
}

# ══════════════════════════════════════════════════════════════
# ── COMMAND: status ───────────────────────────────────────────
# ══════════════════════════════════════════════════════════════
cmd_status() {
  banner
  INSTANCE_ID="$(get_instance_id)"
  [[ -z "$INSTANCE_ID" ]] && { warn "No ${PROJECT_NAME} instance found."; return; }

  STATE="$(get_instance_state "$INSTANCE_ID")"
  PUBLIC_IP="$(get_public_ip "$INSTANCE_ID" || true)"

  local EIP_ADDR
  EIP_ADDR="$(get_eip_address || true)"

  echo -e "  ${WHITE}Instance${NC}      : ${INSTANCE_ID}"
  echo -e "  ${WHITE}State${NC}         : $( [[ "$STATE" == "running" ]] && echo "${GREEN}${STATE}${NC}" || echo "${YELLOW}${STATE}${NC}" )"
  echo -e "  ${WHITE}Region${NC}        : ${REGION}"
  echo -e "  ${WHITE}Type${NC}          : ${INSTANCE_TYPE}"
  [[ -n "$EIP_ADDR" ]] && echo -e "  ${WHITE}Elastic IP${NC}    : ${GREEN}${EIP_ADDR}${NC} ${DIM}(permanent)${NC}"
  echo -e "  ${WHITE}Public IP${NC}     : ${PUBLIC_IP:-N/A}"
  local DISPLAY_IP="${EIP_ADDR:-$PUBLIC_IP}"
  [[ -n "$DISPLAY_IP" ]] && echo -e "  ${WHITE}App URL${NC}       : ${CYAN}http://${DISPLAY_IP}:${APP_PORT}${NC}"
  echo ""

  if [[ "$STATE" == "running" && -n "$PUBLIC_IP" ]]; then
    info "Container status:"
    remote "$PUBLIC_IP" "cd ${APP_DIR} && docker compose ps 2>/dev/null || echo '  (no containers running)'" || true
  fi
}

# ══════════════════════════════════════════════════════════════
# ── COMMAND: logs ─────────────────────────────────════════════
# ══════════════════════════════════════════════════════════════
cmd_logs() {
  local service="${1:-}"
  PUBLIC_IP="$(require_instance)"
  if [[ -n "$service" ]]; then
    info "Tailing logs for service: ${service}  (Ctrl+C to stop)"
    remote "$PUBLIC_IP" "cd ${APP_DIR} && docker compose logs -f --tail=100 ${service}"
  else
    info "Tailing all logs  (Ctrl+C to stop)"
    remote "$PUBLIC_IP" "cd ${APP_DIR} && docker compose logs -f --tail=50"
  fi
}

# ══════════════════════════════════════════════════════════════
# ── COMMAND: ssh ──────────────────────────────────────────────
# ══════════════════════════════════════════════════════════════
cmd_ssh() {
  PUBLIC_IP="$(require_instance)"
  info "Opening SSH session → ec2-user@${PUBLIC_IP}"
  "$SSH_BIN" $SSH_OPTS "ec2-user@${PUBLIC_IP}"
}

# ══════════════════════════════════════════════════════════════
# ── COMMAND: ip ───────────────────────────────────────────────
# ══════════════════════════════════════════════════════════════
cmd_ip() {
  PUBLIC_IP="$(require_instance)"
  echo "$PUBLIC_IP"
}

# ══════════════════════════════════════════════════════════════
# ── COMMAND: open ─────────────────────────────────────────────
# ══════════════════════════════════════════════════════════════
cmd_open() {
  PUBLIC_IP="$(require_instance)"
  URL="http://${PUBLIC_IP}:${APP_PORT}"
  info "Opening ${URL}"
  if command -v xdg-open &>/dev/null; then xdg-open "$URL"
  elif command -v open &>/dev/null;    then open "$URL"
  elif command -v cmd.exe &>/dev/null; then cmd.exe /c start "$URL"
  else echo "$URL"
  fi
}

# ══════════════════════════════════════════════════════════════
# ── COMMAND: restart ──────────────────────────────────────────
# ══════════════════════════════════════════════════════════════
cmd_restart() {
  PUBLIC_IP="$(require_instance)"
  step "Restarting containers (no rebuild)"
  remote "$PUBLIC_IP" "cd ${APP_DIR} && docker compose restart"
  success "Containers restarted → http://${PUBLIC_IP}:${APP_PORT}"
}

# ══════════════════════════════════════════════════════════════
# ── COMMAND: stop ─────────────────────────────────────────────
# ══════════════════════════════════════════════════════════════
cmd_stop() {
  INSTANCE_ID="$(get_instance_id)"
  [[ -z "$INSTANCE_ID" ]] && error "No ${PROJECT_NAME} instance found."
  STATE="$(get_instance_state "$INSTANCE_ID")"
  [[ "$STATE" == "stopped" ]] && { warn "Instance is already stopped."; return; }

  PUBLIC_IP="$(get_public_ip "$INSTANCE_ID" || true)"
  if [[ -n "$PUBLIC_IP" ]]; then
    info "Stopping containers gracefully ..."
    remote "$PUBLIC_IP" "cd ${APP_DIR} && docker compose stop" 2>/dev/null || true
  fi

  info "Stopping EC2 instance ${INSTANCE_ID} ..."
  aws ec2 stop-instances --instance-ids "$INSTANCE_ID" --region "$REGION" &>/dev/null
  aws ec2 wait instance-stopped --instance-ids "$INSTANCE_ID" --region "$REGION"
  success "Instance stopped. Your data is preserved. Resume with: ./aws-deploy.sh start"
}

# ══════════════════════════════════════════════════════════════
# ── COMMAND: start ────────────────────────────────────────────
# ══════════════════════════════════════════════════════════════
cmd_start() {
  INSTANCE_ID="$(get_instance_id)"
  [[ -z "$INSTANCE_ID" ]] && error "No ${PROJECT_NAME} instance found. Run: ./aws-deploy.sh deploy"
  STATE="$(get_instance_state "$INSTANCE_ID")"
  [[ "$STATE" == "running" ]] && { warn "Instance is already running."; cmd_status; return; }

  info "Starting instance ${INSTANCE_ID} ..."
  aws ec2 start-instances --instance-ids "$INSTANCE_ID" --region "$REGION" &>/dev/null
  aws ec2 wait instance-running --instance-ids "$INSTANCE_ID" --region "$REGION"
  aws ec2 wait instance-status-ok --instance-ids "$INSTANCE_ID" --region "$REGION"

  # Re-associate Elastic IP (it detaches on stop)
  PUBLIC_IP="$(ensure_eip "$INSTANCE_ID")"

  wait_for_ssh "$PUBLIC_IP"

  info "Starting containers ..."
  remote "$PUBLIC_IP" "cd ${APP_DIR} && docker compose up -d 2>/dev/null || docker compose start 2>/dev/null"
  wait_for_app "$PUBLIC_IP"
  success "App live → http://${PUBLIC_IP}:${APP_PORT}"
}

# ══════════════════════════════════════════════════════════════
# ── COMMAND: destroy ──────────────────────────────────────────
# ══════════════════════════════════════════════════════════════
cmd_destroy() {
  banner
  warn "This will PERMANENTLY TERMINATE the EC2 instance and DELETE all data."
  warn "This cannot be undone. Your .env files and key pair will be kept locally."
  echo ""
  read -rp "  Type 'destroy' to confirm: " CONFIRM
  [[ "$CONFIRM" != "destroy" ]] && { info "Aborted."; exit 0; }

  INSTANCE_ID="$(get_instance_id)"
  if [[ -n "$INSTANCE_ID" ]]; then
    info "Terminating instance ${INSTANCE_ID} ..."
    aws ec2 terminate-instances --instance-ids "$INSTANCE_ID" --region "$REGION" &>/dev/null
    aws ec2 wait instance-terminated --instance-ids "$INSTANCE_ID" --region "$REGION"
    success "Instance terminated"
  else
    warn "No instance found."
  fi

  local eip_alloc
  eip_alloc="$(get_eip_alloc_id || true)"
  if [[ -n "$eip_alloc" ]]; then
    read -rp "  Also release Elastic IP ($(get_eip_address))? [y/N]: " DEL_EIP
    if [[ "${DEL_EIP:-N}" =~ ^[Yy]$ ]]; then
      aws ec2 release-address --allocation-id "$eip_alloc" --region "$REGION" 2>/dev/null || true
      success "Elastic IP released"
    fi
  fi

  read -rp "  Also delete security group '${SG_NAME}'? [y/N]: " DEL_SG
  if [[ "${DEL_SG:-N}" =~ ^[Yy]$ ]]; then
    SG_ID=$(aws ec2 describe-security-groups \
      --region "$REGION" \
      --filters "Name=group-name,Values=${SG_NAME}" \
      --query 'SecurityGroups[0].GroupId' --output text 2>/dev/null | grep -v '^None$' || true)
    if [[ -n "$SG_ID" ]]; then
      aws ec2 delete-security-group --group-id "$SG_ID" --region "$REGION" 2>/dev/null || \
        warn "Security group still has dependencies — delete manually later."
      success "Security group deleted"
    fi
  fi

  read -rp "  Also delete AWS key pair '${KEY_NAME}'? [y/N]: " DEL_KEY
  if [[ "${DEL_KEY:-N}" =~ ^[Yy]$ ]]; then
    aws ec2 delete-key-pair --key-name "$KEY_NAME" --region "$REGION" 2>/dev/null || true
    success "Key pair deleted from AWS (local ${KEY_FILE} preserved)"
  fi

  success "Destroy complete."
}

# ══════════════════════════════════════════════════════════════
# ── Entry point ───────────────────────────────────────────────
# ══════════════════════════════════════════════════════════════
CMD="${1:-help}"

case "$CMD" in
  deploy)  cmd_deploy ;;
  update)  cmd_update ;;
  status)  cmd_status ;;
  logs)    cmd_logs "${2:-}" ;;
  ssh)     cmd_ssh ;;
  ip)      cmd_ip ;;
  open)    cmd_open ;;
  restart) cmd_restart ;;
  stop)    cmd_stop ;;
  start)   cmd_start ;;
  destroy) cmd_destroy ;;
  help|--help|-h|"")
    banner
    echo -e "  ${WHITE}Usage:${NC}  ./aws-deploy.sh <command>"
    echo ""
    echo -e "  ${CYAN}deploy${NC}       Full infrastructure + app deploy (first run)"
    echo -e "  ${CYAN}update${NC}       Push code changes & rebuild containers"
    echo -e "  ${CYAN}status${NC}       Instance and container health overview"
    echo -e "  ${CYAN}logs${NC}         Tail all container logs"
    echo -e "  ${CYAN}logs <svc>${NC}   Tail one service: mysql, backend, frontend"
    echo -e "  ${CYAN}ssh${NC}          Open interactive SSH session"
    echo -e "  ${CYAN}ip${NC}           Print the instance public IP"
    echo -e "  ${CYAN}open${NC}         Open app URL in browser"
    echo -e "  ${CYAN}restart${NC}      Restart containers (no rebuild)"
    echo -e "  ${CYAN}stop${NC}         Stop EC2 instance (billing-safe pause)"
    echo -e "  ${CYAN}start${NC}        Start a stopped instance"
    echo -e "  ${CYAN}destroy${NC}      Terminate everything (with confirmation)"
    echo ""
    echo -e "  ${DIM}Region: ${REGION}  ·  Type: ${INSTANCE_TYPE}  ·  Key: ${KEY_FILE}${NC}"
    echo ""
    ;;
  *)
    error "Unknown command: ${CMD}. Run ./aws-deploy.sh help for usage."
    ;;
esac
