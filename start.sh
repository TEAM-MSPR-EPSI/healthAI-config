#!/usr/bin/env bash
# =============================================================================
# HealthAI — Démarrage en une commande
# Usage : ./healthAI-config/start.sh [--no-build]
# =============================================================================
set -euo pipefail

# Toujours s'exécuter depuis la racine du projet
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT_DIR"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

BUILD_FLAG="--build"
if [[ "${1:-}" == "--no-build" ]]; then
  BUILD_FLAG=""
fi

echo -e "${CYAN}"
echo "  ██╗  ██╗███████╗ █████╗ ██╗  ████████╗██╗  ██╗ █████╗ ██╗"
echo "  ██║  ██║██╔════╝██╔══██╗██║  ╚══██╔══╝██║  ██║██╔══██╗██║"
echo "  ███████║█████╗  ███████║██║     ██║   ███████║███████║██║"
echo "  ██╔══██║██╔══╝  ██╔══██║██║     ██║   ██╔══██║██╔══██║██║"
echo "  ██║  ██║███████╗██║  ██║███████╗██║   ██║  ██║██║  ██║██║"
echo "  ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝"
echo -e "${NC}"

# -----------------------------------------------------------------------------
# 1. Prérequis
# -----------------------------------------------------------------------------
echo -e "${CYAN}[1/4] Vérification des prérequis...${NC}"

check_cmd() {
  if ! command -v "$1" &>/dev/null; then
    echo -e "${RED}✗ '$1' introuvable. Installez Docker Desktop : https://www.docker.com/products/docker-desktop${NC}"
    exit 1
  fi
}
check_cmd docker

if ! docker info &>/dev/null; then
  echo -e "${RED}✗ Docker ne répond pas. Assurez-vous que Docker Desktop est lancé.${NC}"
  exit 1
fi

echo -e "  ${GREEN}✓ Docker disponible${NC}"

# -----------------------------------------------------------------------------
# 2. Variables d'environnement
# -----------------------------------------------------------------------------
echo -e "${CYAN}[2/4] Configuration de l'environnement...${NC}"

if [ ! -f .env ]; then
  if [ -f .env.example ]; then
    cp .env.example .env
    echo -e "  ${YELLOW}⚠  .env absent — copié depuis .env.example (vérifiez vos clés API)${NC}"
  else
    echo -e "${RED}✗ Fichier .env introuvable et pas de .env.example. Voir le README.md.${NC}"
    exit 1
  fi
else
  echo -e "  ${GREEN}✓ .env trouvé${NC}"
fi

# Copier les .env des services si absents
for service_env in \
  "healthAI-backend-ETL/.env healthAI-backend-ETL/.env.example" \
  "healthAI-service-exercices/.env healthAI-service-exercices/.env.example"; do
  dest=$(echo "$service_env" | cut -d' ' -f1)
  src=$(echo "$service_env" | cut -d' ' -f2)
  if [ ! -f "$dest" ] && [ -f "$src" ]; then
    cp "$src" "$dest"
    echo -e "  ${YELLOW}⚠  Copié $src → $dest${NC}"
  fi
done

# -----------------------------------------------------------------------------
# 3. Construction et démarrage
# -----------------------------------------------------------------------------
echo -e "${CYAN}[3/4] Démarrage de la stack Docker...${NC}"
echo "  (première exécution : le build peut prendre 3-5 minutes)"
echo ""

# shellcheck disable=SC2086
docker compose up -d $BUILD_FLAG

# -----------------------------------------------------------------------------
# 4. Attente des healthchecks
# -----------------------------------------------------------------------------
echo ""
echo -e "${CYAN}[4/4] Attente que les services soient prêts...${NC}"

wait_healthy() {
  local container=$1
  local label=$2
  local max_wait=120
  local elapsed=0

  printf "  %-30s" "$label"
  while [ $elapsed -lt $max_wait ]; do
    status=$(docker inspect --format='{{.State.Health.Status}}' "$container" 2>/dev/null || echo "none")
    if [ "$status" = "healthy" ]; then
      echo -e "${GREEN}✓${NC}"
      return 0
    fi
    if [ "$status" = "none" ]; then
      running=$(docker inspect --format='{{.State.Running}}' "$container" 2>/dev/null || echo "false")
      if [ "$running" = "true" ]; then
        echo -e "${GREEN}✓${NC}"
        return 0
      fi
    fi
    printf "."
    sleep 3
    elapsed=$((elapsed + 3))
  done
  echo -e "${RED}✗ timeout${NC}"
  echo -e "  ${YELLOW}→ Consultez les logs : docker compose logs $container${NC}"
  return 1
}

wait_healthy "postgres_db"        "PostgreSQL"
wait_healthy "mongodb"            "MongoDB"
wait_healthy "minio"              "MinIO (stockage média)"
wait_healthy "api_backend"        "API Backend (Node.js)"
wait_healthy "etl_backend"        "ETL (Python/FastAPI)"
wait_healthy "angular_frontend"   "Frontend (Angular)"

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  ✅  Stack HealthAI démarrée avec succès !${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${CYAN}Services :${NC}"
echo "    Frontend    →  http://localhost:4200"
echo "    API         →  http://localhost:5000"
echo "    ETL         →  http://localhost:8000/docs"
echo "    MinIO       →  http://localhost:9001"
echo "    Grafana     →  http://localhost:3000"
echo ""
echo -e "  ${CYAN}Comptes de démonstration :${NC}"
echo "    Admin  →  admin@admin.fr  /  123456789"
echo "    User   →  user@user.fr   /  123456789"
echo ""
echo -e "  ${CYAN}Gestion :${NC}"
echo "    Sauvegarde   →  ./healthAI-config/scripts/backup.sh"
echo "    Restauration →  ./healthAI-config/scripts/restore.sh <dossier>"
echo "    Remise à zéro → ./healthAI-config/scripts/reset.sh"
echo ""
