#!/usr/bin/env bash
# =============================================================================
# HealthAI — Restauration depuis une sauvegarde locale
# Usage : ./healthAI-config/scripts/restore.sh <dossier_backup>
#   Ex  : ./healthAI-config/scripts/restore.sh ./backups/20240610_143022
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

# -----------------------------------------------------------------------------
# Arguments
# -----------------------------------------------------------------------------
BACKUP_DIR="${1:-}"

if [ -z "${BACKUP_DIR}" ]; then
  echo -e "${CYAN}Usage : ./healthAI-config/scripts/restore.sh <dossier_backup>${NC}"
  echo ""
  if [ -d "./backups" ] && [ -n "$(ls -A ./backups 2>/dev/null)" ]; then
    echo -e "  ${CYAN}Sauvegardes disponibles :${NC}"
    ls -1t ./backups/ | while read -r b; do
      echo "    ./backups/$b"
    done
  else
    echo "  Aucune sauvegarde trouvée dans ./backups/"
  fi
  exit 1
fi

if [ ! -d "${BACKUP_DIR}" ]; then
  echo -e "${RED}✗ Dossier introuvable : ${BACKUP_DIR}${NC}"
  exit 1
fi

# -----------------------------------------------------------------------------
# Validation du contenu du backup
# -----------------------------------------------------------------------------
HAS_PG=false
HAS_MONGO=false
[ -f "${BACKUP_DIR}/postgres.sql" ]     && HAS_PG=true
[ -f "${BACKUP_DIR}/mongodb.archive" ]  && HAS_MONGO=true

if [ "${HAS_PG}" = "false" ] && [ "${HAS_MONGO}" = "false" ]; then
  echo -e "${RED}✗ Aucun fichier de sauvegarde valide dans : ${BACKUP_DIR}${NC}"
  echo "  Attendu : postgres.sql et/ou mongodb.archive"
  exit 1
fi

if [ -f "${BACKUP_DIR}/backup.info" ]; then
  echo -e "${CYAN}[HealthAI] Informations de la sauvegarde :${NC}"
  while IFS='=' read -r key value; do
    printf "  %-20s %s\n" "$key" "$value"
  done < "${BACKUP_DIR}/backup.info"
  echo ""
fi

# -----------------------------------------------------------------------------
# Confirmation
# -----------------------------------------------------------------------------
echo -e "${YELLOW}⚠  ATTENTION : cette opération remplacera toutes les données actuelles.${NC}"
echo "   Source : ${BACKUP_DIR}"
echo ""
read -rp "Confirmer la restauration ? (tapez 'oui' pour continuer) : " CONFIRM
if [ "${CONFIRM}" != "oui" ]; then
  echo "Annulé."
  exit 0
fi
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

# -----------------------------------------------------------------------------
# Restauration PostgreSQL
# -----------------------------------------------------------------------------
if [ "${HAS_PG}" = "true" ]; then
  check_container "postgres_db"
  POSTGRES_USER=$(docker exec postgres_db printenv POSTGRES_USER)
  POSTGRES_DB=$(docker exec postgres_db printenv POSTGRES_DB)

  echo -e "  ${CYAN}Restauration PostgreSQL...${NC}"
  docker exec postgres_db psql -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" \
    -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public; GRANT ALL ON SCHEMA public TO ${POSTGRES_USER};" \
    --quiet

  docker exec -i postgres_db psql \
    -U "${POSTGRES_USER}" \
    -d "${POSTGRES_DB}" \
    --quiet \
    < "${BACKUP_DIR}/postgres.sql"

  echo -e "  ${GREEN}✓ PostgreSQL restauré${NC}"
fi

# -----------------------------------------------------------------------------
# Restauration MongoDB
# -----------------------------------------------------------------------------
if [ "${HAS_MONGO}" = "true" ]; then
  check_container "mongodb"

  echo -e "  ${CYAN}Restauration MongoDB...${NC}"
  docker exec -i mongodb mongorestore \
    --quiet \
    --drop \
    --archive \
    < "${BACKUP_DIR}/mongodb.archive"

  echo -e "  ${GREEN}✓ MongoDB restauré${NC}"
fi

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  ✅  Restauration terminée depuis : ${BACKUP_DIR}${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
