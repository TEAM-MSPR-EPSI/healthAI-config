#!/usr/bin/env bash
# =============================================================================
# HealthAI — Remise à zéro complète
# Usage : ./healthAI-config/scripts/reset.sh [--yes]
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

echo -e "${YELLOW}"
echo "  ╔══════════════════════════════════════════════════╗"
echo "  ║           REMISE À ZÉRO — HEALTHAI              ║"
echo "  ║                                                  ║"
echo "  ║  Cette commande va supprimer :                   ║"
echo "  ║    • Tous les conteneurs Docker du projet        ║"
echo "  ║    • Tous les volumes (base de données, médias)  ║"
echo "  ║    • Les images construites localement           ║"
echo "  ║                                                  ║"
echo "  ║  Les données de démo seront rechargées           ║"
echo "  ║  automatiquement au prochain start.sh            ║"
echo -e "  ╚══════════════════════════════════════════════════╝${NC}"
echo ""

if [[ "${1:-}" == "--yes" ]]; then
  CONFIRM="oui"
else
  read -rp "  Confirmer la remise à zéro ? (tapez 'oui' pour continuer) : " CONFIRM
fi

if [ "${CONFIRM}" != "oui" ]; then
  echo "  Annulé."
  exit 0
fi

echo ""

# -----------------------------------------------------------------------------
# Sauvegarde automatique avant reset (optionnelle)
# -----------------------------------------------------------------------------
AUTO_BACKUP=false
if [[ "${1:-}" != "--yes" ]]; then
  read -rp "  Effectuer une sauvegarde avant la remise à zéro ? (oui/non) : " DO_BACKUP
  [[ "${DO_BACKUP}" == "oui" ]] && AUTO_BACKUP=true
fi

if [ "${AUTO_BACKUP}" = "true" ]; then
  echo ""
  echo -e "  ${CYAN}Sauvegarde en cours...${NC}"
  bash "${SCRIPT_DIR}/backup.sh" "pre-reset"
fi

echo ""
echo -e "  ${CYAN}Arrêt et suppression des conteneurs + volumes...${NC}"
docker compose down --volumes --remove-orphans 2>/dev/null || true
echo -e "  ${GREEN}✓ Conteneurs et volumes supprimés${NC}"

echo -e "  ${CYAN}Suppression des images construites localement...${NC}"
docker compose down --rmi local 2>/dev/null || true
echo -e "  ${GREEN}✓ Images locales supprimées${NC}"

echo -e "  ${CYAN}Nettoyage des réseaux Docker orphelins...${NC}"
docker network prune -f 2>/dev/null || true
echo -e "  ${GREEN}✓ Réseaux nettoyés${NC}"

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  ✅  Remise à zéro terminée.${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "  Pour relancer le projet avec les données de démo :"
echo "    ./healthAI-config/start.sh"
echo ""
