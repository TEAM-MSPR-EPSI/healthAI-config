# GUIDE COMPLET — HealthAI Coach

> Documentation technique unifiée — MSPR 1 & 2  
> Équipe : Mathis Morales · Arnaud Goldberg · Hugo Lembrez · Mathilde Ageron  
> Année scolaire 2025-2026 — EPSI, Certification CDA 3ème année

---

## Sommaire

1. [Présentation du projet](#1-présentation-du-projet)
2. [Architecture générale](#2-architecture-générale)
3. [Déploiement](#3-déploiement)
4. [Benchmarks technologiques](#4-benchmarks-technologiques)
5. [Fonctionnalités IA](#5-fonctionnalités-ia)
6. [Modèle de données](#6-modèle-de-données)
7. [Interface utilisateur et accessibilité](#7-interface-utilisateur-et-accessibilité)
8. [Tests et qualité](#8-tests-et-qualité)
9. [Difficultés rencontrées](#9-difficultés-rencontrées)
10. [Perspectives d'évolution](#10-perspectives-dévolution)

---

## 1. Présentation du projet

HealthAI Coach est une application de coaching santé personnalisé développée en deux phases dans le cadre du titre professionnel Concepteur Développeur d'Applications (CDA).

**MSPR 1** — Collecte, nettoyage, stockage et visualisation de données nutritionnelles et sportives issues d'APIs publiques, exposées via une API REST et consultables par les administrateurs dans des dashboards interactifs.

**MSPR 2** — Évolution vers des fonctionnalités intelligentes : recommandations nutritionnelles et sportives personnalisées via IA, interface utilisateur moderne et accessible conforme RGAA AA.

### Repos du projet

| Dépôt | Rôle |
|-------|------|
| `healthAI-config` | Configuration, docker-compose, scripts de déploiement |
| `healthAI-frontend` | Interface Angular (utilisateur + administration) |
| `healthAI-backend-API` | API REST Node.js / Express |
| `healthAI-backend-ETL` | Pipeline ETL Python / FastAPI |
| `healthAI-backend-model-IA` | Modèle IA Python |
| `healthAI-database` | Schéma SQL PostgreSQL |
| `healthAI-service-nutrition` | Micro-service recommandations nutritionnelles |
| `healthAI-service-exercices` | Micro-service recommandations sportives |
| `healthAI-application-database` | MinIO (stockage objet S3-compatible) |

---

## 2. Architecture générale

La solution repose sur une architecture micro-services orchestrée via Docker Compose.

### Flux de données

```
APIs publiques (OpenFoodFacts, Wger, USDA)
        │
        ▼
   ETL Backend  ──────────────────────────────────────────┐
  (Python/FastAPI)                                        │
        │  CSV / INSERT                                   │
        ▼                                                 │
  PostgreSQL ◄──── API Backend (Node.js) ◄──── Frontend  │
  MongoDB    ◄──── Service Nutrition     ◄────  Angular   │
             ◄──── Service Exercices     ◄────────────────┘
                        │
                    LLM externe (Gemini 1.5 Flash)
```

### Services

| Conteneur | Technologie | Port | Rôle |
|-----------|-------------|------|------|
| `frontend` | Angular | 4200 | Interface utilisateur |
| `api_backend` | Node.js / Express | 5000 | API REST principale |
| `etl_backend` | Python / FastAPI | 8000 | Pipeline ETL + validation données |
| `nutrition_service` | Python / FastAPI | 8001 | Recommandations nutritionnelles |
| `exercices_service` | Python / FastAPI | 8002 | Recommandations sportives |
| `database` | PostgreSQL 15 | 5432 | Base de données relationnelle |
| `mongodb` | MongoDB 7 | 27017 | Stockage plans repas / programmes |
| `minio` | MinIO | 9000/9001 | Stockage objet (images, médias) |
| `monitoring` | Grafana | 3000 | Monitoring et dashboards |
| `nginx` | Nginx 1.25 | 80/443 | Reverse proxy |

---

## 3. Déploiement

### Prérequis

- Docker Desktop (Windows/macOS) ou Docker Engine + Compose (Linux)
- Python 3.x
- Git

### Structure des dossiers

Tous les dépôts doivent être clonés dans un même dossier parent :

```
parent/
├── run.py                        ← copié depuis healthAI-config
├── docker-compose.yml            ← copié depuis healthAI-config
├── docker-compose_offline.yml    ← copié depuis healthAI-config
├── docker-compose_perf.yml       ← copié depuis healthAI-config
├── README.md                     ← copié depuis healthAI-config
├── .env                          ← à créer depuis .env.example
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

### Mise en place

**1. Copier le script de lancement dans le dossier parent**

```bash
cp healthAI-config/run.py .
```

**2. Créer le fichier `.env`**

```bash
cp healthAI-config/.env.example .env
# Puis éditer .env avec vos valeurs
```

**3. Lancer le script**

```bash
python run.py
```

### Menu du script `run.py`

```
═══════════════════════════════════════════════════
   HealthAI — Gestionnaire de déploiement
═══════════════════════════════════════════════════

  1  Mettre à jour les dépôts  (git pull)
  2  Lancer la stack normale   (docker-compose.yml)
  3  Lancer le mode offline    (docker-compose_offline.yml)
  4  Lancer le mode perf       (docker-compose_perf.yml)
  0  Quitter
```

Le script copie automatiquement les fichiers `docker-compose*.yml` et `README.md` depuis `healthAI-config/` vers le dossier parent à chaque exécution.

### Variables d'environnement

**Fichier `.env` racine** (lu par Docker Compose pour la base de données et l'API) :

| Variable | Exemple | Description |
|----------|---------|-------------|
| `POSTGRES_DB` | `healthai_db` | Nom de la base |
| `POSTGRES_USER` | `healthai_user` | Utilisateur PostgreSQL |
| `POSTGRES_PASSWORD` | `password` | Mot de passe PostgreSQL |
| `POSTGRES_HOST` | `database` | Host PostgreSQL (nom du service Docker) |
| `POSTGRES_PORT` | `5432` | Port PostgreSQL |
| `POSTGRES_URL` | `postgresql://...` | URL complète de connexion |
| `JWT_SECRET` | `...` | Clé secrète JWT (longue et aléatoire) |
| `NODE_ENV` | `development` | Environnement Node.js |
| `MINIO_ROOT_USER` | `admin` | Utilisateur MinIO |
| `MINIO_ROOT_PASSWORD` | `password123` | Mot de passe MinIO |
| `APP_ACCESS_KEY` | `app-access-key` | Clé d'accès applicative MinIO |
| `APP_SECRET_KEY` | `app-secret-key` | Clé secrète applicative MinIO |
| `PDC_TOKEN` | `...` | Token Grafana Cloud (optionnel) |

Les services ETL, nutrition et exercices lisent leurs propres `.env` dans leurs dossiers.

### Modes de lancement

**Mode normal** (`docker-compose.yml`)
Stack complète avec tous les services actifs. Requiert une connexion internet pour les APIs LLM (Gemini), USDA FoodData Central et Grafana Cloud.

**Mode offline** (`docker-compose_offline.yml`)
Lance la stack de base en désactivant tous les appels externes :
- L'agent PDC Grafana Cloud est remplacé par un conteneur no-op
- Les services exercices, nutrition et ETL passent en `MOCK_MODE=true`
- Le modèle HuggingFace food detection continue de fonctionner depuis le cache local

**Mode performance** (`docker-compose_perf.yml`)
Adapté aux machines avec peu de RAM (≥ 4 Go) :
- Limites CPU/RAM appliquées à chaque conteneur
- Le service nutrition (PyTorch ~2 Go RAM) est remplacé par un mock Python léger retournant des données de démonstration
- Grafana PDC désactivé

### Comptes par défaut

| Rôle | Email | Mot de passe |
|------|-------|--------------|
| Utilisateur | user@user.fr | 123456789 |
| Administrateur | admin@admin.fr | 123456789 |

### Commandes utiles

```bash
# État des conteneurs
docker compose ps

# Logs en temps réel
docker compose logs -f

# Logs d'un service précis
docker compose logs -f api_backend
docker compose logs -f nutrition_service

# Arrêter la stack
docker compose down

# Vérification santé
curl http://localhost:5000/health
```

---

## 4. Benchmarks technologiques

### 4.1 Frontend

Comparatif React / Vue.js / Angular :

| Critère | React | Vue.js | Angular |
|---------|-------|--------|---------|
| Type | Librairie UI | Framework progressif | Framework complet |
| Langage | JS / TS | JS / TS | TypeScript |
| Architecture intégrée | Partielle | Moyenne | Complète |
| Outils natifs (routing, forms, DI) | Dépend librairies | Dépend librairies | Inclus |
| Maintenabilité gros projet | Bonne | Bonne | Très bonne |
| Adapté aux dashboards | Oui | Oui | Très adapté |
| Accessibilité / composants UI | Dépend bibliothèques | Dépend bibliothèques | Angular Material |

**Angular retenu** pour son architecture complète TypeScript, ses fonctionnalités natives (routing, formulaires, injection de dépendances, tests) et l'excellente intégration d'Angular Material pour l'accessibilité RGAA.

Bibliothèques complémentaires : Angular Material (UI), Chart.js + ng2-charts (graphiques).

### 4.2 ETL

Comparatif Pandas / PySpark / Node.js sur un CSV de 5M lignes (~800 Mo) :

| Scénario | Pandas | PySpark (local) | Node.js |
|----------|--------|-----------------|---------|
| Lecture CSV | 8.7 s / 2.3 Go RAM | 22.4 s / 3.8 Go RAM | 11.2 s / 0.9 Go RAM |
| Groupby + join | 4.3 s | 18.2 s | 38.5 s |
| Écriture Parquet | 1.6 s | 4.2 s | Non natif |
| Écriture PostgreSQL | 9.1 s | 18.5 s | 7.3 s |

**Pandas retenu** : standard data engineering Python, compatible SQLAlchemy et FastAPI, backend Apache Arrow intégré, volumes < 5 Go dans sa zone de confort.

### 4.3 API

Comparatif FastAPI / Flask / Express (benchmark wrk, 10s, 100 connexions) :

| Framework | Req/s | Latence moy. | Latence p99 |
|-----------|-------|--------------|-------------|
| FastAPI | 12 400 | 8 ms | 21 ms |
| Express | 14 100 | 7 ms | 18 ms |
| Flask | 3 200 | 31 ms | 74 ms |

**FastAPI retenu** pour les services Python (ETL, nutrition, exercices) : validation automatique Pydantic, documentation Swagger/OpenAPI native, performances async, compatibilité totale stack Python.

**Node.js / Express retenu** pour l'API principale : légèreté, modèle asynchrone non bloquant, parfaitement adapté à un serveur HTTP exposant des données relationnelles.

### 4.4 LLM

| LLM | Req/min | Req/jour | Tokens/min | Coût au-delà |
|-----|---------|----------|------------|--------------|
| Gemini 1.5 Flash | 15 | 1 500 | 1 000 000 | $0.075/1M tok |
| Claude 3 Haiku | — | — | — | $0.25/1M tok |
| Mistral Small | 1 | 500 | 2 000 | €0.10/1M tok |

**Gemini 1.5 Flash retenu** : seul LLM offrant un tier gratuit généreux suffisant pour le développement actif. SDK Python officiel, latence très faible pour des appels temps réel depuis FastAPI.

### 4.5 Modèle IA (runtime)

Inférence sur 10 000 prédictions :

| Runtime | Temps total | Temps/prédiction | RAM |
|---------|-------------|------------------|-----|
| Python | 0.31 s | 0.031 ms | 180 Mo |
| Node.js | 1.84 s | 0.184 ms | 310 Mo |

**Python retenu** : écosystème ML sans équivalent (scikit-learn, PyTorch, TensorFlow, XGBoost, Hugging Face), cohérence totale avec la stack, inférence 6x plus rapide.

---

## 5. Fonctionnalités IA

### 5.1 Service de recommandations nutritionnelles

Micro-service indépendant Python / FastAPI — port 8001.

**Endpoints :**
- `POST /api/nutrition/analyze` — Analyse une photo de repas : identification des aliments, calcul des macronutriments, recommandations personnalisées via ML
- `POST /api/meal-plan/generate` — Génère un plan de repas hebdomadaire selon le profil, les allergies et le régime alimentaire

**Détection des aliments :**
Modèle `nateraw/food` (Vision Transformer, dataset Food-101), exécuté localement dans le conteneur Docker. Avantage : aucun quota, aucune dépendance réseau. Limitation connue : 101 plats cuisinés reconnus, pas les ingrédients bruts isolés.

**Données nutritionnelles :**
API USDA FoodData Central (clé gratuite, quota généreux). Open Food Facts testé et écarté pour la variabilité de qualité de ses données contributives.

**Modèle ML :**
Algorithme Random Forest pour prédire le type de déséquilibre nutritionnel d'un repas selon sa composition et l'objectif utilisateur.

### 5.2 Service de recommandations d'activités physiques

Micro-service indépendant Python / FastAPI — port 8002.

**Endpoints :**
- `POST /exercices/entrainer` — Entraîne le modèle avec les exercices disponibles en base
- `POST /exercices/recommander` — Génère un programme sportif personnalisé en deux étapes :
  1. Le modèle Python sélectionne les exercices pertinents selon le profil utilisateur
  2. Un LLM (Gemini 1.5 Flash) génère le programme sportif structuré

---

## 6. Modèle de données

Base de données relationnelle PostgreSQL avec 15 tables et 12 types ENUM.

### Tables principales

| Table | Rôle |
|-------|------|
| `user_` | Utilisateurs (rôle, infos personnelles, métriques) |
| `user_health_profile` | Profil santé et objectifs |
| `user_allergy` | Allergies déclarées |
| `user_biometric` | Données biométriques (poids, sommeil, pas) |
| `user_subscription` | Abonnements utilisateur |
| `session_progress` | Progression sportive |
| `company` | Entreprises (abonnements B2B) |
| `subscription` | Offres d'abonnement (Freemium, Premium, B2B) |
| `sport_program` | Programmes sportifs |
| `sport_session` | Séances d'entraînement |
| `sport_exercise` | Exercices (difficulté, groupe musculaire, calories) |
| `recipe` | Recettes (type, description, instructions) |
| `ingredient` | Ingrédients (valeurs nutritionnelles, allergènes) |

### Bonnes pratiques appliquées

- **Normalisation 3NF** — pas de redondance
- **Intégrité** — clés primaires/étrangères, contraintes NOT NULL
- **Sécurité** — mots de passe hashés bcrypt (`user_hashpwd`)
- **Extensibilité** — types ENUM et tables de liaison pour les relations many-to-many

### Stockage complémentaire

**MongoDB** : plans de repas générés et programmes sportifs personnalisés (structure flexible, évolution sans migration de schéma).

**MinIO** : stockage objet S3-compatible pour les images de repas et médias utilisateurs. Accessible via Nginx (reverse proxy + cache).

---

## 7. Interface utilisateur et accessibilité

### Conception

L'interface s'inspire des applications bien-être mobiles (Duolingo, FizzUp) : mécanismes simples, ludiques et motivants. Conçue autour du persona Lucas M. (26 ans, développeur web, utilisateur intermédiaire actif mais pressé), elle minimise la charge cognitive avec une hiérarchie visuelle claire.

Charte graphique : tons verts naturels associés au bien-être, contrastes respectant les seuils RGAA (≥ 4,5:1 pour les textes), logo minimaliste compatible modes clair/sombre.

### Conformité RGAA AA — critères implémentés

**Navigation clavier**
- Skip-link vers le contenu principal
- Focus visible 3px sur tous les éléments interactifs
- Ordre de tabulation logique
- Interface entièrement utilisable sans souris

**Contrastes**
- Texte normal ≥ 4,5:1 (ex. `#2f2d28` sur `#ffffff` = 13:1)
- Messages d'erreur : couleur `#8b3a37` = 8,5:1
- Aucune information transmise par la couleur seule

**Structure HTML sémantique**
- `<nav>`, `<main>`, `<header>`, `<button>`, `<a>` utilisés correctement
- Hiérarchie de titres h1 → h6 respectée
- Pas de `<div>` pour des interactions

**Formulaires**
- `mat-label` sur chaque champ
- Champs obligatoires : `*` + `aria-required="true"`
- Erreurs liées au champ via `aria-describedby`
- Erreurs annoncées via `role="alert"` + `aria-live="assertive"`

**Attributs ARIA**
- `aria-current="page"` sur l'item de navigation actif
- `aria-hidden="true"` sur les icônes décoratives
- `aria-label` sur les boutons iconiques

**Responsive**
- Cibles tactiles ≥ 44×44 px
- Zoom 200% sans casse ni scroll horizontal
- Navigation mobile adaptée

### Patterns de référence

```html
<!-- Bouton avec icône -->
<button mat-flat-button>
  <mat-icon aria-hidden="true">send</mat-icon>
  <span>Envoyer</span>
</button>

<!-- Navigation active -->
<a routerLink="/recipes" [attr.aria-current]="isActive ? 'page' : null">Recettes</a>

<!-- Message d'erreur accessible -->
<input aria-describedby="email-error" />
<p id="email-error" role="alert" aria-live="assertive">Adresse email invalide.</p>
```

### Outils de vérification recommandés

Lighthouse, Axe DevTools, WebAIM Contrast Checker, NVDA, VoiceOver.

---

## 8. Tests et qualité

### Résumé des couvertures

| Composant | Framework | Tests | Couverture |
|-----------|-----------|-------|------------|
| Frontend Angular (unitaires) | Jasmine + Karma | 10 | 40,42% |
| Frontend Angular (E2E) | Playwright | 15 (3 navigateurs × 5) | — |
| Backend API Node.js | node --test | 8 | 97,85% |
| Backend ETL Python | Pytest | 112 | 86% |
| Service nutrition Python | Pytest | 5 | 56% |

### Frontend Angular — tests unitaires

Exécution : `cd healthAI-frontend && npm run test:coverage`

- **app.spec.ts** — création du composant racine, affichage du titre
- **auth.service.spec.ts** — connexion, récupération profil, gestion erreurs, déconnexion
- **api.service.spec.ts** — mapping des données API, normalisation des ingrédients
- **subscribe.spec.ts** — page abonnement, SnackBar de confirmation, fallback image

### Frontend Angular — tests E2E (Playwright)

Exécution : `cd healthAI-frontend && npm run test:e2e`

5 scénarios × 3 navigateurs (Chromium, Firefox, WebKit) :
- Redirection automatique de la splash screen vers `/welcome`
- Navigation publique (liens, boutons)
- Validation du formulaire de connexion avec affichage d'erreur
- Navigation vers l'inscription
- Connexion mockée avec interception des appels API et vérification du dashboard

### Backend API Node.js

Exécution : `cd healthAI-backend-API && npm run test:coverage`

- Rejet des mots de passe trop faibles à l'inscription
- Hachage bcrypt avant stockage (jamais en clair)
- Génération de JWT valide à la connexion (rôle + ID inclus)
- Rejet d'identifiants incorrects
- Parseur SQL : découpe sur `;`, préservation des blocs `$$`
- Blocage des instructions `DROP TABLE`
- Import SQL avec `ON CONFLICT DO NOTHING` dans une transaction
- Import forcé avec `TRUNCATE ... CASCADE` avant réinsertion

### Backend ETL Python

Exécution : `cd healthAI-backend-ETL && npm run test:coverage` *(ou pytest selon config)*

112 tests couvrant :
- Transformations : nettoyage (`_sanitize`, `_strip_html`), déduplication, validation métier des ingrédients et exercices
- Appels HTTP : gestion timeout, HTTP 404, JSON invalide, retry, pagination
- Routes FastAPI : GET/PUT/POST, codes 200/422/500/504, validation Pydantic
- Écriture CSV et insertion BDD (cas limites : fichier vide, inexistant, erreur SQLAlchemy)

### Service nutrition Python

Exécution : `cd healthAI-service-nutrition && python -m pytest`

- Endpoint `/health` → `{"status": "ok", "service": "nutrition-recommendation"}`
- Racine `/` avec liens vers la doc OpenAPI
- Génération d'un plan de repas hebdomadaire (2 jours, 4 repas/jour, profil végétalien)
- Division par zéro sur apport calorique nul → retour 1800 kcal par défaut
- Détection de déséquilibres : déficit protéines, déficit glucides, excès lipides

---

## 9. Difficultés rencontrées

**Qualité des données sources (MSPR 1)**
Les APIs OpenFoodFacts et Wger retournaient des incohérences de format, des valeurs manquantes et des doublons. L'implémentation des règles de nettoyage ETL s'est révélée plus complexe et chronophage que prévue.

**Structure initiale de la base de données (MSPR 2)**
Relations manquantes, types inadaptés (VARCHAR pour valeurs numériques), absence de contraintes NOT NULL/UNIQUE. Reprise partielle du schéma nécessaire avant de poursuivre le développement.

**Communication entre services Docker**
La mise en réseau des conteneurs et la gestion des dépendances au démarrage (healthchecks) ont demandé plusieurs ajustements avant d'obtenir un environnement stable.

**Choix LLM**
Plusieurs arbitrages entre simplicité d'intégration, qualité des résultats et dépendance aux services externes. Claude 3 Haiku et Mistral Small écartés pour des raisons de quota ou de coût.

**Grafana Cloud (MSPR 1)**
Initialement prévu pour la visualisation, rendu indisponible suite à des pertes de données liées aux conflits géopolitiques. Remplacé par Chart.js intégré directement dans Angular.

---

## 10. Perspectives d'évolution

**Court terme**
- Rendre l'application installable comme PWA pour une meilleure expérience mobile
- Héberger la solution en ligne pour un accès universel
- Intégrer axe-core ou Lighthouse CI pour les tests d'accessibilité automatisés

**Moyen terme**
- Étendre la couverture de tests frontend (objectif > 70%)
- Ajouter un système d'alertes automatiques sur l'exécution de l'ETL
- Intégrer des sources de données supplémentaires (Spoonacular, Edamam)

**Long terme**
- IA locale pour limiter la dépendance aux APIs externes et améliorer la confidentialité
- Passage en production avec monitoring complet (Prometheus + Grafana)
- Application mobile native (iOS / Android)

---

*Documentation générée et consolidée depuis les rapports MSPR 1 & 2, les guides d'accessibilité et les documents techniques du projet HealthAI Coach.*
