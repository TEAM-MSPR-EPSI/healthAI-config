#!/usr/bin/env bash
# =============================================================================
# HealthAI — Sauvegarde locale (PostgreSQL + MongoDB)
# Usage : ./healthAI-config/scripts/backup.sh [nom_optionnel]
# Résultat : ./backups/YYYYMMDD_HHMMSS/
# =============================================================================
set -euo pipefail

# Toujours s'exécuter depuis la racine du projet
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$ROOT_DIR"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

LABEL="${1:-}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="${TIMESTAMP}${LABEL:+_$LABEL}"
BACKUP_DIR="./backups/${BACKUP_NAME}"

echo -e "${CYAN}[HealthAI] Sauvegarde démarrée : ${BACKUP_NAME}${NC}"
echo ""

# -----------------------------------------------------------------------------
# Vérification que les conteneurs tournent
# -----------------------------------------------------------------------------
check_container() {
  local name=$1
  if ! docker inspect --format='{{.State.Running}}' "$name" 2>/dev/null | grep -q "true"; then
    echo -e "${RED}✗ Le conteneur '$name' n'est pas démarré. Lancez './healthAI-config/start.sh' d'abord.${NC}"
    exit 1
  fi
}

check_container "postgres_db"
check_container "mongodb"

mkdir -p "${BACKUP_DIR}"

# -----------------------------------------------------------------------------
# Récupération des variables depuis le conteneur
# -----------------------------------------------------------------------------
POSTGRES_USER=$(docker exec postgres_db printenv POSTGRES_USER)
POSTGRES_DB=$(docker exec postgres_db printenv POSTGRES_DB)

# -----------------------------------------------------------------------------
# PostgreSQL — pg_dump
# -----------------------------------------------------------------------------
echo -e "  ${CYAN}PostgreSQL...${NC}"
docker exec postgres_db pg_dump \
  -U "${POSTGRES_USER}" \
  --no-password \
  --format=plain \
  --clean \
  --if-exists \
  "${POSTGRES_DB}" \
  > "${BACKUP_DIR}/postgres.sql"

PG_SIZE=$(du -sh "${BACKUP_DIR}/postgres.sql" | cut -f1)
echo -e "  ${GREEN}✓ postgres.sql (${PG_SIZE})${NC}"

# -----------------------------------------------------------------------------
# MongoDB — mongodump (archive binaire)
# -----------------------------------------------------------------------------
echo -e "  ${CYAN}MongoDB...${NC}"
docker exec mongodb mongodump \
  --quiet \
  --archive \
  > "${BACKUP_DIR}/mongodb.archive"

MONGO_SIZE=$(du -sh "${BACKUP_DIR}/mongodb.archive" | cut -f1)
echo -e "  ${GREEN}✓ mongodb.archive (${MONGO_SIZE})${NC}"

# -----------------------------------------------------------------------------
# Métadonnées
# -----------------------------------------------------------------------------
cat > "${BACKUP_DIR}/backup.info" <<EOF
date=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
label=${LABEL:-auto}
postgres_db=${POSTGRES_DB}
postgres_user=${POSTGRES_USER}
postgres_file=postgres.sql
mongodb_file=mongodb.archive
EOF

echo ""
TOTAL_SIZE=$(du -sh "${BACKUP_DIR}" | cut -f1)
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  ✅  Sauvegarde terminée (${TOTAL_SIZE} total)${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "  Dossier   : ${BACKUP_DIR}"
echo "  Restaurer : ./healthAI-config/scripts/restore.sh ${BACKUP_DIR}"
echo ""

if [ -d "./backups" ]; then
  echo -e "  ${CYAN}Sauvegardes disponibles :${NC}"
  ls -1t ./backups/ | head -5 | while read -r b; do
    echo "    ./backups/$b"
  done
  echo ""
fi
