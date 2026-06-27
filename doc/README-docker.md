# 🐳 Documentation des Images Docker — HealthAI Coach

> **Projet** : HealthAI Coach — MSPR TPRE601  
> **Équipe** : Mathis Morales · Arnaud Goldberg · Hugo Lembrez · Mathilde Ageron  
> **Année** : 2025-2026 — EPSI, Certification CDA 3ème année

---

## Sommaire

1. [Vue d'ensemble](#1-vue-densemble)
2. [Images custom (Dockerfile)](#2-images-custom-dockerfile)
   - [api_backend — Node.js / Express](#21-api_backend--nodejs--express)
   - [etl_backend — Python / FastAPI](#22-etl_backend--python--fastapi)
   - [frontend — Angular / Nginx](#23-frontend--angular--nginx)
   - [nutrition_service — Python / FastAPI + PyTorch](#24-nutrition_service--python--fastapi--pytorch)
   - [exercices_service — Python / FastAPI + Gemini](#25-exercices_service--python--fastapi--gemini)
   - [minio — Stockage objet S3](#26-minio--stockage-objet-s3)
3. [Images officielles (pull direct)](#3-images-officielles-pull-direct)
4. [Réseau et volumes](#4-réseau-et-volumes)
5. [Dépendances entre services](#5-dépendances-entre-services)
6. [Variables d'environnement](#6-variables-denvironnement)
7. [Modes de lancement](#7-modes-de-lancement)
8. [Commandes utiles](#8-commandes-utiles)

---

## 1. Vue d'ensemble

La stack HealthAI Coach est entièrement orchestrée via **Docker Compose**. Elle regroupe **12 conteneurs** organisés autour d'un réseau bridge unique (`app_network`).

| Conteneur | Image | Port(s) | Type |
|-----------|-------|---------|------|
| `api_backend` | Custom — `healthAI-backend-API` | `5000` | Build local |
| `etl_backend` | Custom — `healthAI-backend-ETL` | `8000` | Build local |
| `frontend` | Custom — `healthAI-frontend` | `4200` | Build local |
| `nutrition_service` | Custom — `healthAI-service-nutrition` | `8001` | Build local |
| `exercices_service` | Custom — `healthAI-service-exercices` | `8002` | Build local |
| `minio` | Custom — `healthAI-application-database` | `9000` / `9001` | Build local |
| `database` | `postgres:15-alpine` | `5432` | Image officielle |
| `mongodb` | `mongo:7-jammy` | `27017` | Image officielle |
| `monitoring` | `grafana/grafana:latest` | `3000` | Image officielle |
| `pdc_agent` | `grafana/pdc-agent:latest` | — | Image officielle |
| `minio-init` | `minio/mc:latest` | — | Image officielle (init only) |
| `nginx` | `nginx:1.25-alpine` | `80` / `443` | Image officielle |

---

## 2. Images custom (Dockerfile)

Toutes les images custom utilisent un **build multi-étapes** (`multi-stage build`) pour produire des images finales légères, sans outils de build.

### 2.1 `api_backend` — Node.js / Express

**Repo** : `healthAI-backend-API/`  
**Dockerfile** : [`healthAI-backend-API/Dockerfile`](./healthAI-backend-API/Dockerfile)

#### Stratégie de build

| Étape | Image de base | Rôle |
|-------|--------------|------|
| `builder` | `node:22-alpine` | Installation complète (`npm install`) |
| `runner` | `node:22-alpine` | Production (`--omit=dev`) |

#### Détail

```dockerfile
# Étape 1 : Builder
FROM node:22-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install          # Installe dev + prod
COPY . .

# Étape 2 : Runner (image finale)
FROM node:22-alpine AS runner
WORKDIR /app
COPY package*.json ./
RUN npm install --omit=dev   # Production uniquement
COPY --from=builder /app .
EXPOSE 5000
CMD ["npm", "start"]
```

#### Labels OCI

| Label | Valeur |
|-------|--------|
| `image.title` | `healthAI-api` |
| `image.description` | Backend API pour le projet healthAI |
| `image.vendor` | MSPR Team |
| `image.licenses` | MIT |
| `image.source` | https://github.com/TEAM-MSPR-EPSI/healthAI-backend-API |
| `image.version` | 1.0.0 |

#### Dépendances principales

| Package | Rôle |
|---------|------|
| `express ^4.19` | Serveur HTTP |
| `sequelize ^6.37` | ORM PostgreSQL |
| `pg ^8.18` | Driver PostgreSQL |
| `mongoose ^8.19` | ODM MongoDB |
| `jsonwebtoken ^9.0` | Authentification JWT |
| `bcryptjs ^3.0` | Hachage des mots de passe |
| `multer ^2.1` | Upload de fichiers |
| `@aws-sdk/client-s3 ^3.1067` | Intégration MinIO/S3 |
| `swagger-ui-express ^5.0` | Documentation OpenAPI |

#### Volumes (développement)

```yaml
volumes:
  - ./healthAI-backend-API:/app    # Hot-reload en développement
  - /app/node_modules              # Évite d'écraser node_modules de l'hôte
```

---

### 2.2 `etl_backend` — Python / FastAPI

**Repo** : `healthAI-backend-ETL/`  
**Dockerfile** : [`healthAI-backend-ETL/Dockerfile`](./healthAI-backend-ETL/Dockerfile)

#### Stratégie de build

| Étape | Image de base | Rôle |
|-------|--------------|------|
| `builder` | `python:3.11-slim` | Installation des packages dans `/install` |
| `runner` | `python:3.11-slim` | Copie uniquement les packages compilés |

#### Détail

```dockerfile
# Étape 1 : Builder
FROM python:3.11-slim AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# Étape 2 : Runner
FROM python:3.11-slim AS runner
WORKDIR /app
COPY --from=builder /install /usr/local
COPY etl.py etl_ingredient.py etl_exercise.py etl_load.py api.py ./
EXPOSE 8000
CMD ["python", "api.py"]
```

#### Dépendances Python

| Package | Rôle |
|---------|------|
| `fastapi` | Framework API async |
| `uvicorn[standard]` | Serveur ASGI |
| `pandas` | Manipulation des données CSV |
| `sqlalchemy` | ORM pour PostgreSQL |
| `psycopg2-binary` | Driver PostgreSQL |
| `requests` | Appels HTTP vers APIs externes |
| `python-dotenv` | Chargement des variables d'environnement |
| `pytest` / `coverage` / `httpx2` | Tests |

#### Endpoints exposés

| Méthode | Route | Description |
|---------|-------|-------------|
| `GET` | `/health` | Statut du service |
| `POST` | `/etl/extract-transform` | Lance le pipeline ETL complet |
| `POST` | `/etl/extract-transform/ingredient` | ETL ingrédients uniquement |
| `POST` | `/etl/extract-transform/exercise` | ETL exercices uniquement |
| `POST` | `/etl/load-to-db` | Charge les CSV en base de données |
| `POST` | `/etl/load-to-db/ingredient` | Charge les ingrédients |
| `POST` | `/etl/load-to-db/exercise` | Charge les exercices |
| `GET` | `/csv` | Liste les fichiers CSV générés |
| `GET` | `/csv/ingredient` | Données ingrédients (valides + invalides) |
| `PUT` | `/csv/ingredient` | Modifie / corrige un ingrédient |
| `GET` | `/csv/exercise` | Données exercices (valides + invalides) |
| `PUT` | `/csv/exercise` | Modifie / corrige un exercice |

#### Healthcheck Docker

```yaml
healthcheck:
  test: ["CMD", "python", "-c", "import urllib.request; urllib.request.urlopen('http://localhost:8000/health', timeout=5)"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 10s
```

---

### 2.3 `frontend` — Angular / Nginx

**Repo** : `healthAI-frontend/`  
**Dockerfile** : [`healthAI-frontend/Dockerfile`](./healthAI-frontend/Dockerfile)

#### Stratégie de build

| Étape | Image de base | Rôle |
|-------|--------------|------|
| `builder` | `node:22-alpine` | Compilation Angular (`ng build --production`) |
| `runner` | `nginx:alpine` | Sert les fichiers statiques compilés |

> Node.js, Angular CLI et `node_modules` disparaissent entièrement de l'image finale.

#### Détail

```dockerfile
# Étape 1 : Builder Angular
FROM node:22-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install --legacy-peer-deps
COPY . .
RUN npx ng build --configuration=production

# Étape 2 : Runner Nginx
FROM nginx:alpine AS runner
RUN rm -rf /usr/share/nginx/html/*
COPY --from=builder /app/dist/frontend/browser /usr/share/nginx/html
# Config nginx inline : SPA + proxy vers les backends
EXPOSE 4200
CMD ["nginx", "-g", "daemon off;"]
```

#### Configuration Nginx intégrée

Le Dockerfile génère directement la configuration Nginx pour le routing SPA et le reverse proxy :

| Location | Cible | Description |
|----------|-------|-------------|
| `/api/` | `http://api_backend:5000` | API REST principale |
| `/etl/` | `http://etl_backend:8000` | API ETL |
| `/csv` | `http://etl_backend:8000` | Export CSV ETL |
| `/exercices/` | `http://exercices_service:8002` | Service exercices |
| `/nutrition/` | `http://nutrition_service:8001/` | Service nutrition |
| `/` | `index.html` (SPA fallback) | Routes Angular |

#### Dépendances principales (Angular)

- Angular 17+, Angular Material
- Chart.js + ng2-charts (graphiques)
- TypeScript

---

### 2.4 `nutrition_service` — Python / FastAPI + PyTorch

**Repo** : `healthAI-service-nutrition/`  
**Dockerfile** : [`healthAI-service-nutrition/Dockerfile`](./healthAI-service-nutrition/Dockerfile)

#### Stratégie de build

| Étape | Image de base | Rôle |
|-------|--------------|------|
| `builder` | `python:3.11-slim` + `build-essential` | Compilation C + PyTorch CPU-only + requirements |
| `runner` | `python:3.11-slim` + `curl` | Image légère sans compilateur |

> `build-essential` est présent uniquement dans l'étape builder. L'image finale ne contient que `curl` (pour le healthcheck).

#### Détail

```dockerfile
# Étape 1 : Builder
FROM python:3.11-slim AS builder
RUN apt-get install -y build-essential
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install torch \
    --index-url https://download.pytorch.org/whl/cpu
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# Étape 2 : Runner
FROM python:3.11-slim AS runner
RUN apt-get install -y curl
COPY --from=builder /install /usr/local
COPY . .
EXPOSE 8001
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8001"]
```

#### Dépendances Python

| Package | Rôle |
|---------|------|
| `fastapi` / `uvicorn` | Framework API async |
| `torch` (CPU-only) | Inférence modèle ViT (nateraw/food) |
| `transformers` | Modèle HuggingFace food detection |
| `scikit-learn` | Modèle Random Forest (déséquilibres nutritionnels) |
| `pillow` | Traitement d'images |
| `sqlalchemy` / `psycopg2-binary` | Accès PostgreSQL |
| `pymongo` | Accès MongoDB (persistance plans de repas) |
| `python-jose[cryptography]` | Validation JWT |
| `numpy` / `pandas` | Traitement numérique |
| `httpx` | Appels USDA FoodData Central |

#### Endpoints exposés

| Méthode | Route | Description |
|---------|-------|-------------|
| `GET` | `/health` | Statut du service |
| `GET` | `/` | Liens vers la doc OpenAPI |
| `POST` | `/api/nutrition/analyze` | Analyse une photo de repas (ViT + USDA + RF) |
| `POST` | `/api/meal-plan/generate` | Génère un plan de repas hebdomadaire |

#### Volumes

```yaml
volumes:
  - ./healthAI-service-nutrition:/app
  - huggingface_cache:/root/.cache/huggingface   # Cache modèle ViT
```

#### Variables d'environnement spécifiques

| Variable | Description |
|----------|-------------|
| `OMP_NUM_THREADS=1` | Limite les threads OpenMP (stabilité) |
| `TOKENIZERS_PARALLELISM=false` | Désactive le parallélisme HuggingFace |
| `TRANSFORMERS_OFFLINE=0` | Autorise le téléchargement du modèle au 1er démarrage |

#### Healthcheck Docker

```yaml
healthcheck:
  test: ["CMD", "python", "-c", "import urllib.request; urllib.request.urlopen('http://localhost:8001/health', timeout=5)"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 60s    # Délai long : téléchargement du modèle ViT au 1er démarrage
```

---

### 2.5 `exercices_service` — Python / FastAPI + Gemini

**Repo** : `healthAI-service-exercices/`  
**Dockerfile** : [`healthAI-service-exercices/Dockerfile`](./healthAI-service-exercices/Dockerfile)

#### Stratégie de build

| Étape | Image de base | Rôle |
|-------|--------------|------|
| `builder` | `python:3.11-slim` | Installation des packages dans `/install` |
| `runner` | `python:3.11-slim` + `curl` | Image finale légère |

#### Détail

```dockerfile
# Étape 1 : Builder
FROM python:3.11-slim AS builder
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# Étape 2 : Runner
FROM python:3.11-slim AS runner
RUN apt-get install -y curl
COPY --from=builder /install /usr/local
COPY . .
EXPOSE 8002
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8002"]
```

#### Dépendances Python

| Package | Version | Rôle |
|---------|---------|------|
| `fastapi` | 0.111.0 | Framework API async |
| `uvicorn` | 0.27.1 | Serveur ASGI |
| `pydantic` | 2.7.0 | Validation des données |
| `scikit-learn` | 1.4.2 | Modèle de recommandation ML |
| `motor` | 3.4.0 | Driver MongoDB async |
| `pymongo` | 4.7.2 | Driver MongoDB sync |
| `asyncpg` | 0.29.0 | Driver PostgreSQL async |
| `sqlalchemy` | 2.0.30 | ORM |
| `httpx` | 0.27.0 | Appels LLM Gemini 1.5 Flash |
| `numpy` | 1.26.4 | Calculs vectoriels |
| `joblib` | 1.4.2 | Sérialisation modèle ML |

#### Endpoints exposés

| Méthode | Route | Description |
|---------|-------|-------------|
| `GET` | `/health` | Statut du service |
| `POST` | `/exercices/entrainer` | Entraîne le modèle ML sur les exercices en base |
| `POST` | `/exercices/recommander` | Génère un programme sportif personnalisé (ML + Gemini) |

#### Fonctionnement du service

```
Requête utilisateur (profil, objectif, niveau)
        │
        ▼
Modèle ML Python (scikit-learn)
→ Sélection des exercices pertinents depuis la base
        │
        ▼
LLM Gemini 1.5 Flash
→ Génération du programme sportif structuré
        │
        ▼
Réponse JSON avec programme détaillé
```

#### Healthcheck Docker

```yaml
healthcheck:
  test: ["CMD", "python", "-c", "import urllib.request; urllib.request.urlopen('http://localhost:8002/health', timeout=5)"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 40s
```

---

### 2.6 `minio` — Stockage objet S3

**Repo** : `healthAI-application-database/`  
**Dockerfile** : [`healthAI-application-database/Dockerfile`](./healthAI-application-database/Dockerfile)

#### Détail

```dockerfile
FROM minio/minio:latest
EXPOSE 9000 9001
VOLUME ["/data"]
CMD ["server", "/data", "--console-address", ":9001"]
```

> Le MinIO Client (`mc`) est déjà inclus dans l'image officielle `minio/minio`.

#### Buckets créés à l'initialisation

Un conteneur d'init (`minio-init`) utilise `minio/mc:latest` pour configurer MinIO automatiquement :

| Bucket | Accès | Contenu |
|--------|-------|---------|
| `avatars` | Public (lecture anonyme) | Photos de profil utilisateurs |
| `photos` | Public (lecture anonyme) | Photos postées dans le fil social |
| `videos` | Public (lecture anonyme) | Vidéos postées dans le fil social |

#### Politique d'accès applicative

Un compte de service dédié (`APP_ACCESS_KEY` / `APP_SECRET_KEY`) est créé avec une politique JSON restrictive (`social-app-policy`) permettant uniquement les opérations nécessaires à l'application.

#### Healthcheck Docker

```yaml
healthcheck:
  test: ["CMD", "mc", "ready", "local"]
  interval: 30s
  timeout: 10s
  retries: 5
  start_period: 10s
```

---

## 3. Images officielles (pull direct)

### `database` — PostgreSQL 15

```yaml
image: postgres:15-alpine
container_name: postgres_db
ports: ["5432:5432"]
volumes:
  - postgres_data:/var/lib/postgresql/data
  - ./healthAI-database/init.sql:/docker-entrypoint-initdb.d/init.sql
```

- **Initialisation automatique** : le fichier `init.sql` (schéma complet) est exécuté au premier démarrage
- **Healthcheck** : `pg_isready -U postgres` (interval: 10s, retries: 5)
- **Schéma** : 15 tables, 12 types ENUM (voir [README-architecture.md](./README-architecture.md))

### `mongodb` — MongoDB 7

```yaml
image: mongo:7-jammy
container_name: mongodb
ports: ["27017:27017"]
volumes:
  - mongodb_data:/data/db
```

- **Healthcheck** : `mongosh --eval "db.adminCommand('ping')"` (interval: 10s, retries: 5)
- **Collections** : `social_posts`, `user_profiles`
- **Utilisation** : stockage des plans de repas générés et programmes sportifs personnalisés (structure flexible)

### `monitoring` — Grafana

```yaml
image: grafana/grafana:latest
container_name: grafana_monitoring
ports: ["3000:3000"]
environment:
  GF_SECURITY_ADMIN_USER: admin
  GF_SECURITY_ADMIN_PASSWORD: admin
  GF_INSTALL_PLUGINS: grafana-clock-panel
volumes:
  - grafana_data:/var/lib/grafana
```

### `pdc_agent` — Grafana PDC Agent

```yaml
image: grafana/pdc-agent:latest
container_name: pdc_agent
```

- Connecte la stack locale à **Grafana Cloud** pour l'accès aux datasources privées
- Configuré via `PDC_TOKEN`, `PDC_CLUSTER`, `PDC_GRAFANA_ID`
- **Désactivé** en mode offline (remplacé par un conteneur no-op)

### `nginx` — Reverse proxy MinIO

```yaml
image: nginx:1.25-alpine
container_name: minio-nginx
ports: ["80:80", "443:443"]
volumes:
  - ./healthAI-application-database/nginx/nginx.conf:/etc/nginx/nginx.conf:ro
  - ./healthAI-application-database/nginx/conf.d:/etc/nginx/conf.d:ro
  - nginx_cache:/var/cache/nginx
```

- Reverse proxy + cache pour les médias stockés dans MinIO
- Sert les fichiers publics (avatars, photos, vidéos) avec cache

---

## 4. Réseau et volumes

### Réseau

```yaml
networks:
  app_network:
    driver: bridge
```

Tous les conteneurs partagent le réseau `app_network`. La communication inter-services se fait par nom de conteneur (ex. `http://api_backend:5000`).

### Volumes persistants

| Volume | Conteneur | Données stockées |
|--------|-----------|-----------------|
| `postgres_data` | `database` | Données PostgreSQL |
| `grafana_data` | `monitoring` | Dashboards et configuration Grafana |
| `mongodb_data` | `mongodb` | Documents MongoDB |
| `huggingface_cache` | `nutrition_service` | Modèle ViT `nateraw/food` (~500 Mo) |
| `minio_data` | `minio` | Fichiers objets (images, vidéos) |
| `nginx_cache` | `nginx` | Cache des médias MinIO |

---

## 5. Dépendances entre services

```
database (PostgreSQL) ←── api_backend
                     ←── etl_backend
                     ←── nutrition_service
                     ←── exercices_service
                     ←── pdc_agent
                     ←── monitoring

mongodb              ←── nutrition_service
                     ←── exercices_service

minio                ←── minio-init (init uniquement)
                     ←── nginx
                     ←── api_backend (upload/lecture médias)

frontend             ←── (proxy vers api_backend, etl_backend,
                          nutrition_service, exercices_service)
```

> Les services `nutrition_service` et `exercices_service` démarrent uniquement après que `database` **et** `mongodb` soient healthy.

---

## 6. Variables d'environnement

### Fichier `.env` racine (lu par Docker Compose)

| Variable | Exemple | Service(s) |
|----------|---------|------------|
| `POSTGRES_DB` | `myapp_db` | `database`, `api_backend` |
| `POSTGRES_USER` | `postgres` | `database`, `api_backend` |
| `POSTGRES_PASSWORD` | `postgres_password` | `database`, `api_backend` |
| `POSTGRES_URL` | `postgresql://...` | `api_backend` |
| `POSTGRES_HOST` | `database` | `api_backend` |
| `POSTGRES_PORT` | `5432` | `api_backend` |
| `JWT_SECRET` | `494b66fa...` | `api_backend` |
| `NODE_ENV` | `development` | `api_backend` |
| `MONGO_URI` | `mongodb://mongodb:27017/...` | `api_backend` |
| `MINIO_ROOT_USER` | `admin` | `minio`, `minio-init` |
| `MINIO_ROOT_PASSWORD` | `Azerty12!` | `minio`, `minio-init` |
| `MINIO_SITE_NAME` | `social-storage` | `minio` |
| `APP_ACCESS_KEY` | `health_app` | `api_backend`, `minio-init` |
| `APP_SECRET_KEY` | `a3f8c2d1...` | `api_backend`, `minio-init` |
| `PDC_TOKEN` | `glc_eyJ...` | `pdc_agent` |
| `PDC_CLUSTER` | `prod-me-central-1` | `pdc_agent` |
| `PDC_GRAFANA_ID` | `1486387` | `pdc_agent` |

### Variables spécifiques par service

Chaque service Python lit son propre `.env` dans son dossier :
- `healthAI-backend-ETL/.env`
- `healthAI-service-nutrition/.env`
- `healthAI-service-exercices/.env`

---

## 7. Modes de lancement

| Fichier | Commande | Description |
|---------|----------|-------------|
| `docker-compose.yml` | `docker compose up -d` | Stack complète (requiert internet) |
| `docker-compose.offline.yml` | `docker compose -f docker-compose.offline.yml up -d` | Mode hors-ligne (MOCK_MODE) |
| `docker-compose.perf.yml` | `docker compose -f docker-compose.perf.yml up -d` | Mode basse RAM (≥ 4 Go) |

### Script de lancement unifié

```bash
python run.py
```

Le script `run.py` propose un menu interactif pour choisir le mode et met à jour automatiquement les fichiers depuis `healthAI-config/`.

---

## 8. Commandes utiles

```bash
# Démarrer toute la stack
docker compose up -d

# Voir l'état des conteneurs
docker compose ps

# Logs en temps réel (tous les services)
docker compose logs -f

# Logs d'un service précis
docker compose logs -f api_backend
docker compose logs -f nutrition_service
docker compose logs -f etl_backend

# Reconstruire une image après modification du code
docker compose build api_backend
docker compose up -d api_backend

# Arrêter et supprimer les conteneurs
docker compose down

# Arrêter et supprimer conteneurs + volumes (réinitialisation complète)
docker compose down -v

# Vérification de santé des services
curl http://localhost:5000/health    # API Backend
curl http://localhost:8000/health    # ETL Backend
curl http://localhost:8001/health    # Service Nutrition
curl http://localhost:8002/health    # Service Exercices

# Accéder à la console MinIO
# http://localhost:9001  (admin / Azerty12!)

# Accéder à Grafana
# http://localhost:3000  (admin / admin)
```
