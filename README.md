# HealthAI Coach — Guide de démarrage rapide

Application de coaching santé personnalisé combinant recommandations nutritionnelles et sportives via IA.

---

## Prérequis

- [Docker Desktop](https://www.docker.com/products/docker-desktop) (ou Docker Engine + Compose sur Linux)
- Python 3.x
- Git

```bash
docker --version
docker compose version
python --version
```

---

## Mise en place initiale

### 1. Cloner les dépôts

Clonez tous les dépôts dans un même dossier parent :

```
parent/
├── healthAI-config/
├── healthAI-frontend/
├── healthAI-backend-API/
├── healthAI-backend-ETL/
├── healthAI-backend-model-IA/
├── healthAI-database/
├── healthAI-service-nutrition/
├── healthAI-service-exercices/
└── healthAI-application-database/
```

### 2. Configurer les variables d'environnement

Créez un fichier `.env` à la racine du dossier parent à partir du modèle :

```bash
cp healthAI-config/.env.example .env
```

Renseignez ensuite les valeurs dans ce `.env` (voir section Variables ci-dessous).

### 3. Placer le script de lancement

Copiez `run.py` depuis `healthAI-config/` dans le dossier parent :

```bash
cp healthAI-config/run.py .
```

---

## Lancer le projet

Depuis le **dossier parent** :

```bash
python run.py
```

Le menu propose :

| Choix | Action |
|-------|--------|
| `1` | `git pull` sur tous les dépôts + copie des fichiers de config |
| `2` | Lance la stack complète (mode normal) |
| `3` | Lance la stack en mode **offline** (sans appels LLM externes) |
| `4` | Lance la stack en mode **performance** (machines ≥ 4 Go RAM) |

---

## Accès aux services

| Service | URL |
|---------|-----|
| Frontend Angular | http://localhost:4200 |
| API Backend | http://localhost:5000 |
| ETL Backend | http://localhost:8000 |
| Service Nutrition | http://localhost:8001 |
| Service Exercices | http://localhost:8002 |
| Grafana | http://localhost:3000 |
| MinIO Console | http://localhost:9001 |

---

## Comptes par défaut

| Rôle | Email | Mot de passe |
|------|-------|--------------|
| Utilisateur | user@user.fr | 123456789 |
| Administrateur | admin@admin.fr | 123456789 |

---

## Variables d'environnement principales

| Variable | Description |
|----------|-------------|
| `POSTGRES_DB` | Nom de la base de données |
| `POSTGRES_USER` | Utilisateur PostgreSQL |
| `POSTGRES_PASSWORD` | Mot de passe PostgreSQL |
| `JWT_SECRET` | Clé secrète pour les tokens JWT |
| `MINIO_ROOT_USER` | Utilisateur MinIO |
| `MINIO_ROOT_PASSWORD` | Mot de passe MinIO |
| `PDC_TOKEN` | Token Grafana Cloud (optionnel) |

Les services ETL, nutrition et exercices lisent leurs propres `.env` dans leurs dossiers respectifs.

---

## Commandes utiles

```bash
# Voir l'état des conteneurs
docker compose ps

# Suivre les logs en temps réel
docker compose logs -f

# Logs d'un service précis
docker compose logs -f api_backend

# Arrêter la stack
docker compose down

# Vérification santé de l'API
curl http://localhost:5000/health
```

---

## Modes de lancement

**Normal** — stack complète avec tous les services actifs et connexions externes.

**Offline** — désactive les appels vers les APIs externes (Gemini, USDA, Grafana Cloud). Utile sans accès internet ou en démonstration.

**Performance** — limite les ressources CPU/RAM de chaque conteneur. Le service nutrition est remplacé par un mock léger. Recommandé sur les machines avec peu de RAM.

---

## Documentation complète

Consultez `GUIDE_COMPLET_HEALTHAI.md` dans ce dépôt pour l'architecture détaillée, les benchmarks technologiques, les tests et les guides d'accessibilité.
