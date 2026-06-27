# 📊 Documentation du Système de Supervision — HealthAI Coach

> **Projet** : HealthAI Coach — MSPR TPRE601  
> **Équipe** : Mathis Morales · Arnaud Goldberg · Hugo Lembrez · Mathilde Ageron  
> **Année** : 2025-2026 — EPSI, Certification CDA 3ème année

---

## Sommaire

1. [Vue d'ensemble du système de supervision](#1-vue-densemble-du-système-de-supervision)
2. [Stack de monitoring](#2-stack-de-monitoring)
3. [Données collectées](#3-données-collectées)
   - [3.1 Données métier — PostgreSQL](#31-données-métier--postgresql)
   - [3.2 Données applicatives — MongoDB](#32-données-applicatives--mongodb)
   - [3.3 Données techniques — Docker & Conteneurs](#33-données-techniques--docker--conteneurs)
   - [3.4 Données ETL — Pipeline de données](#34-données-etl--pipeline-de-données)
   - [3.5 Données IA & ML](#35-données-ia--ml)
4. [Accès aux interfaces de supervision](#4-accès-aux-interfaces-de-supervision)
5. [Healthchecks Docker](#5-healthchecks-docker)
6. [Logs applicatifs](#6-logs-applicatifs)
7. [Alertes et seuils](#7-alertes-et-seuils)
8. [Modes de supervision](#8-modes-de-supervision)

---

## 1. Vue d'ensemble du système de supervision

Le système de supervision de HealthAI Coach repose sur plusieurs couches complémentaires :

```
┌─────────────────────────────────────────────────────────┐
│                   COUCHE VISUALISATION                  │
│   Grafana (port 3000)  ·  Swagger UI  ·  Logs Docker   │
└─────────────────────────────────────────────────────────┘
                           │
┌─────────────────────────────────────────────────────────┐
│                   COUCHE COLLECTE                       │
│  Grafana PDC Agent  ·  Healthchecks Docker  ·  Logs    │
└─────────────────────────────────────────────────────────┘
                           │
┌─────────────────────────────────────────────────────────┐
│                   SOURCES DE DONNÉES                    │
│  PostgreSQL · MongoDB · Conteneurs Docker · APIs Python │
└─────────────────────────────────────────────────────────┘
```

### Composants impliqués

| Composant | Rôle | Accès |
|-----------|------|-------|
| **Grafana** (`monitoring`) | Dashboard principal, visualisation des métriques | `http://localhost:3000` |
| **Grafana PDC Agent** (`pdc_agent`) | Connexion Grafana Cloud ↔ datasources privées | Interne |
| **Healthchecks Docker** | Surveillance de l'état de chaque conteneur | `docker compose ps` |
| **Logs Docker** | Traces applicatives de chaque service | `docker compose logs` |
| **Swagger UI** (ETL, Nutrition, Exercices) | Supervision des APIs via documentation interactive | Ports 8000/8001/8002 |

---

## 2. Stack de monitoring

### Grafana

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

Grafana est configuré pour se connecter aux sources de données privées de la stack locale via le **PDC Agent** (Private Data source Connect).

### Grafana PDC Agent

```yaml
image: grafana/pdc-agent:latest
container_name: pdc_agent
environment:
  - PDC_TOKEN=${PDC_TOKEN}
  - PDC_CLUSTER=${PDC_CLUSTER}
  - PDC_GRAFANA_ID=${PDC_GRAFANA_ID}
```

Le PDC Agent crée un tunnel sécurisé entre Grafana Cloud et les datasources de la stack locale (PostgreSQL notamment), permettant la visualisation dans des dashboards Grafana Cloud sans exposer la base de données publiquement.

> **Note** : En mode offline ou performance, le PDC Agent est désactivé ou remplacé par un conteneur no-op. La visualisation des données reste accessible via les dashboards Angular intégrés (Chart.js).

### Dashboards Angular (Chart.js)

En complément de Grafana, l'interface Angular embarque des graphiques interactifs via **Chart.js + ng2-charts** directement dans l'application, accessibles aux administrateurs sans configuration externe.

---

## 3. Données collectées

### 3.1 Données métier — PostgreSQL

La base PostgreSQL (`database`) est la source principale de données supervisées. Grafana s'y connecte via le PDC Agent pour alimenter les dashboards administrateurs.

#### Table `user_` — Utilisateurs

| Colonne | Type | Description supervisée |
|---------|------|----------------------|
| `user_id` | INTEGER | Identifiant unique |
| `user_username` | VARCHAR(50) | Nom d'utilisateur |
| `user_firstname` / `user_lastname` | VARCHAR(50) | Prénom / Nom |
| `user_birth` | DATE | Date de naissance |
| `user_role` | ENUM | `admin` / `user` / `company_admin` |
| `user_gender` | ENUM | Genre déclaré |
| `user_city` / `user_country` | VARCHAR(50) | Localisation géographique |
| `user_size` | INT | Taille en cm |
| `user_weight` | DECIMAL(4,1) | Poids actuel en kg |
| `user_last_weight` | DECIMAL(4,1) | Poids précédent en kg |
| `user_inscription` | DATE | Date d'inscription |

> **Métriques supervisées** : nombre total d'utilisateurs, répartition par rôle, répartition par pays, évolution des inscriptions (courbe temporelle).

#### Table `user_biometric` — Données biométriques

| Colonne | Type | Description |
|---------|------|-------------|
| `biometric_id` | INTEGER | Identifiant |
| `biometric_date` | DATE | Date de mesure |
| `biometric_sleep` | INT | Durée de sommeil (minutes) |
| `biometric_steps` | INT | Nombre de pas quotidiens |
| `biometric_weight` | DECIMAL(4,1) | Poids mesuré (kg) |
| `user_id` | INT (FK) | Référence utilisateur |

> **Métriques supervisées** : évolution du poids des utilisateurs, moyenne de pas journaliers, qualité du sommeil (agrégats par période).

#### Table `user_health_profile` — Profil santé

| Colonne | Type | Description |
|---------|------|-------------|
| `user_health_profile_objective` | ENUM | `weight_loss` / `muscle_gain` / `endurance` / `flexibility` / `maintenance` |
| `user_health_profile_activity` | ENUM | `sedentary` / `lightly_active` / `moderately_active` / `very_active` / `extra_active` |
| `user_health_profile_food_diet` | ENUM | `vegan` / `vegetarian` / `pescatarian` / `gluten_free` / `lactose_free` / `halal` / `kosher` / `none` |

> **Métriques supervisées** : répartition des objectifs utilisateurs, répartition des régimes alimentaires, répartition des niveaux d'activité.

#### Table `session_progress` — Progression sportive

| Colonne | Type | Description |
|---------|------|-------------|
| `session_progress_id` | INTEGER | Identifiant |
| `session_progress_start` | DATE | Date de début de séance |
| `session_progress_end` | DATE | Date de fin de séance |
| `sport_session_id` | INT (FK) | Séance réalisée |
| `user_id` | INT (FK) | Utilisateur |
| `sport_program_id` | INT (FK) | Programme suivi |
| `program_session_rank` | INT | Rang de la séance dans le programme |

> **Métriques supervisées** : nombre de séances complétées par période, progression des utilisateurs dans leurs programmes, taux de complétion des programmes.

#### Table `user_subscription` — Abonnements

| Colonne | Type | Description |
|---------|------|-------------|
| `user_subscription_start` | DATE | Date de début |
| `user_subscription_end` | DATE | Date de fin |
| `user_subscription_is_active` | BOOLEAN | Statut actif |
| `subscription_id` | INT (FK) | Type d'abonnement |

> **Métriques supervisées** : répartition Freemium / Premium / Premium+ / B2B, taux de conversion, abonnements actifs vs expirés.

#### Table `consume` — Consommation alimentaire

| Colonne | Type | Description |
|---------|------|-------------|
| `consume_id` | INTEGER | Identifiant |
| `user_id` | INT (FK) | Utilisateur |
| `ingredient_id` | INT (FK) | Ingrédient consommé |
| `ingredient_quantity` | DECIMAL(6,1) | Quantité en grammes |
| `consume_date` | DATE | Date de consommation |

> **Métriques supervisées** : aliments les plus consommés, évolution des apports caloriques journaliers, tendances nutritionnelles globales.

#### Table `ingredient` — Base nutritionnelle

| Colonne | Type | Description |
|---------|------|-------------|
| `ingredient_name` | VARCHAR(100) | Nom de l'ingrédient |
| `ingredient_type` | ENUM | `vegetable` / `fruit` / `meat` / `fish` / `dairy` / `grain` / `legume` / `other` |
| `ingredient_energy_100g` | DECIMAL(6,1) | Calories pour 100g |
| `ingredient_protein_100g` | DECIMAL(6,2) | Protéines (g/100g) |
| `ingredient_fiber_100g` | DECIMAL(6,2) | Fibres (g/100g) |
| `ingredient_sugars_100g` | DECIMAL(6,2) | Sucres (g/100g) |
| `ingredient_carbohydrate_100g` | DECIMAL(6,2) | Glucides (g/100g) |
| `ingredient_salt_100g` | DECIMAL(6,2) | Sel (g/100g) |
| `ingredient_fats_100g` | DECIMAL(6,2) | Lipides (g/100g) |
| `ingredient_saturated_fats_100g` | DECIMAL(6,2) | Acides gras saturés (g/100g) |

> **Métriques supervisées** : nombre total d'ingrédients en base, répartition par type, couverture nutritionnelle (% d'ingrédients avec valeurs complètes).

#### Table `sport_exercise` — Exercices physiques

| Colonne | Type | Description |
|---------|------|-------------|
| `sport_exercise_name` | VARCHAR(255) | Nom de l'exercice |
| `sport_exercise_objective` | ENUM | Objectif (weight_loss, muscle_gain…) |
| `sport_exercise_difficulty` | ENUM | `beginner` / `intermediate` / `advanced` |
| `sport_exercise_duration` | INTEGER | Durée en minutes |
| `sport_exercise_muscle_group` | ENUM | Groupe musculaire ciblé |
| `sport_exercise_cal_burned` | INT | Calories brûlées estimées |

> **Métriques supervisées** : nombre d'exercices disponibles par difficulté, par groupe musculaire, répartition par objectif.

#### Table `company` — Entreprises (B2B)

| Colonne | Type | Description |
|---------|------|-------------|
| `company_name` | VARCHAR(50) | Nom de l'entreprise |
| `company_email` | VARCHAR(255) | Email de contact |
| `company_inscription` | DATE | Date d'inscription |

> **Métriques supervisées** : nombre d'entreprises clientes, évolution des contrats B2B.

---

### 3.2 Données applicatives — MongoDB

MongoDB (`mongodb`, port `27017`, base `healthai_social`) stocke les données générées par les services IA :

#### Collection `social_posts`

Index créés :
- `authorUserId` (croissant) — recherche par auteur
- `createdAt` (décroissant) — tri chronologique

> **Données** : publications sociales des utilisateurs (photos de repas partagées, activités sportives). **Métriques supervisées** : volume de publications, activité sociale par période.

#### Collection `user_profiles`

Index créé :
- `userId` (unique) — accès direct au profil

> **Données** : profils utilisateurs étendus côté applicatif, plans de repas générés, programmes sportifs personnalisés (structure flexible JSON).

**Données IA stockées dans MongoDB** :
- Plans de repas hebdomadaires générés par le service nutrition (JSON)
- Programmes sportifs personnalisés générés par Gemini (JSON)
- Historique des recommandations par utilisateur

---

### 3.3 Données techniques — Docker & Conteneurs

#### Healthchecks par service

| Service | Commande de vérification | Intervalle | Timeout | Retries |
|---------|--------------------------|-----------|---------|---------|
| `database` (PostgreSQL) | `pg_isready -U postgres` | 10s | 5s | 5 |
| `mongodb` | `mongosh --eval "db.adminCommand('ping')"` | 10s | 5s | 5 |
| `etl_backend` | HTTP GET `/health` (port 8000) | 30s | 10s | 3 |
| `nutrition_service` | HTTP GET `/health` (port 8001) | 30s | 10s | 3 |
| `exercices_service` | HTTP GET `/health` (port 8002) | 30s | 10s | 3 |
| `minio` | `mc ready local` | 30s | 10s | 5 |

#### Réponses des endpoints `/health`

| Service | Réponse attendue |
|---------|-----------------|
| `api_backend` (port 5000) | `{"status": "OK"}` ou similaire |
| `etl_backend` (port 8000) | `{"status": "OK", "service": "etl_backend"}` |
| `nutrition_service` (port 8001) | `{"status": "ok", "service": "nutrition-recommendation"}` |
| `exercices_service` (port 8002) | `{"status": "ok", "service": "exercices_service"}` |

#### État des conteneurs supervisé

```bash
docker compose ps
```

États possibles : `healthy` / `starting` / `unhealthy` / `exited`

---

### 3.4 Données ETL — Pipeline de données

Le service ETL (`etl_backend`, port 8000) collecte et expose des données sur la qualité du pipeline :

#### Sources de données publiques interrogées

| Source | Données collectées | Statut |
|--------|-------------------|--------|
| **OpenFoodFacts** | Ingrédients alimentaires (valeurs nutritionnelles, allergènes) | Utilisé en MSPR 1 |
| **Wger** | Exercices physiques (nom, description, groupes musculaires) | Utilisé en MSPR 1 |
| **USDA FoodData Central** | Valeurs nutritionnelles de référence (API key gratuite) | Utilisé en MSPR 2 |

#### Données de qualité ETL exposées via API

| Endpoint | Données supervisées |
|----------|-------------------|
| `GET /csv` | Liste des fichiers CSV générés (taille, existence) |
| `GET /csv/ingredient` | Ingrédients **valides** (traités et prêts à charger) + ingrédients **invalides** (rejetés avec raison) |
| `GET /csv/exercise` | Exercices **valides** + exercices **invalides** (avec raison de rejet) |

#### Métriques de qualité des données

| Métrique | Description |
|----------|-------------|
| **Taux de validation** | `nb_valides / (nb_valides + nb_invalides)` × 100 |
| **Raisons de rejet** | Champs manquants ou vides par type de donnée |
| **Volume ingéré** | Nombre d'ingrédients / exercices chargés en base |
| **Taille des CSV** | Taille en KB des fichiers intermédiaires |

#### Règles de validation ETL

**Ingrédients** — champs obligatoires pour être considéré valide :
- `ingredient_energy_100g`
- `ingredient_protein_100g`
- `ingredient_carbohydrate_100g`
- `ingredient_fats_100g`
- `ingredient_fiber_100g`
- `ingredient_sugars_100g`
- `ingredient_salt_100g`
- `ingredient_saturated_fats_100g`

**Exercices** — champs obligatoires :
- `sport_exercise_instruction` (non vide)

#### Logs ETL

Les logs du pipeline ETL sont capturés et retournés dans les réponses API :

```json
{
  "status": "success",
  "message": "Pipeline ETL exécuté avec succès",
  "detailed_logs": ["2026-06-25 [INFO] — Extraction démarrée", "..."],
  "return_code": 0
}
```

---

### 3.5 Données IA & ML

#### Service Nutrition — Analyse des repas

| Donnée collectée | Source | Description |
|-----------------|--------|-------------|
| **Photo de repas** (input) | Utilisateur | Image uploadée pour analyse |
| **Aliment détecté** | Modèle ViT `nateraw/food` (Food-101) | Catégorie d'aliment reconnue (101 classes) |
| **Score de confiance** | Modèle ViT | Probabilité de la prédiction |
| **Macronutriments calculés** | USDA FoodData Central API | Calories, protéines, glucides, lipides, fibres |
| **Type de déséquilibre** | Random Forest (scikit-learn) | `déficit_protéines` / `excès_lipides` / `déficit_glucides` / etc. |
| **Recommandations générées** | ML + règles métier | Texte personnalisé selon profil et objectif |
| **Plan de repas** (output) | Algorithme de planification | JSON structuré sur 1 à 7 jours, filtré allergènes |

**Persistance** : les plans de repas générés sont stockés dans MongoDB (`user_profiles`).

#### Service Exercices — Recommandations sportives

| Donnée collectée | Source | Description |
|-----------------|--------|-------------|
| **Profil utilisateur** (input) | PostgreSQL | Objectif, niveau, groupe musculaire ciblé |
| **Exercices candidats** | PostgreSQL (`sport_exercise`) | Sélection par le modèle ML |
| **Score ML** | Modèle scikit-learn (entraîné sur la base) | Pertinence de chaque exercice pour le profil |
| **Programme sportif** (output) | Gemini 1.5 Flash (LLM) | Programme structuré avec séances, répétitions, temps de repos |

**Données d'entraînement du modèle** :
- Exercices de la base PostgreSQL (nom, objectif, difficulté, groupe musculaire, calories)
- Équipements disponibles

#### Métriques LLM (Gemini 1.5 Flash)

| Métrique | Valeur de référence |
|----------|-------------------|
| Quota gratuit | 15 req/min / 1 500 req/jour / 1 000 000 tokens/min |
| Latence typique | < 2 secondes |
| Coût au-delà | $0.075 / 1M tokens |

---

## 4. Accès aux interfaces de supervision

### Grafana Dashboard

| URL | Identifiants par défaut |
|-----|------------------------|
| `http://localhost:3000` | admin / admin |

**Datasources configurables dans Grafana** :
- PostgreSQL (via PDC Agent pour Grafana Cloud, ou connexion directe en local)
- Loki (logs si configuré)

### Swagger UI — Documentation et test des APIs

| Service | URL |
|---------|-----|
| ETL Backend | `http://localhost:8000/docs` |
| Service Nutrition | `http://localhost:8001/docs` |
| Service Exercices | `http://localhost:8002/docs` |
| API Backend | `http://localhost:5000/api-docs` (Swagger Express) |

### Console MinIO

| URL | Identifiants par défaut |
|-----|------------------------|
| `http://localhost:9001` | admin / Azerty12! |

**Métriques disponibles dans la console MinIO** :
- Volume total stocké par bucket
- Nombre d'objets par bucket
- Métriques de performance I/O
- Audit logs des accès

---

## 5. Healthchecks Docker

### Schéma de dépendances et conditions de démarrage

```
database ──(healthy)──► api_backend
         ──(healthy)──► etl_backend
         ──(healthy)──► frontend
         ──(healthy)──► monitoring
         ──(no cond)──► pdc_agent

mongodb  ──(healthy)──► nutrition_service ◄──(healthy)── database
         ──(healthy)──► exercices_service ◄──(healthy)── database

minio    ──(healthy)──► minio-init
         ──(healthy)──► nginx
```

### Vérification manuelle des healthchecks

```bash
# État global
docker compose ps

# Healthcheck d'un service spécifique
docker inspect --format='{{.State.Health.Status}}' api_backend
docker inspect --format='{{.State.Health.Log}}' nutrition_service
```

---

## 6. Logs applicatifs

### Structure des logs ETL

```
2026-06-25 14:30:00 [INFO] — Démarrage du pipeline ingredient
2026-06-25 14:30:01 [INFO] — 1 247 ingrédients extraits depuis OpenFoodFacts
2026-06-25 14:30:05 [INFO] — 1 189 ingrédients valides / 58 invalides
2026-06-25 14:30:05 [INFO] — CSV ingredient_valid.csv généré (245.3 KB)
2026-06-25 14:30:10 [INFO] — Chargement PostgreSQL : 1 189 lignes insérées
```

### Commandes de supervision des logs

```bash
# Logs en temps réel — tous services
docker compose logs -f

# Logs d'un service précis
docker compose logs -f api_backend
docker compose logs -f etl_backend
docker compose logs -f nutrition_service
docker compose logs -f exercices_service
docker compose logs -f database

# Dernières 100 lignes
docker compose logs --tail=100 etl_backend

# Logs depuis une date précise
docker compose logs --since="2026-06-25T12:00:00" api_backend
```

---

## 7. Alertes et seuils

### Seuils de supervision recommandés

| Métrique | Seuil WARNING | Seuil CRITICAL | Action |
|----------|--------------|----------------|--------|
| Conteneur en état `unhealthy` | — | Immédiat | Vérifier logs + redémarrer |
| Taux de rejet ETL | > 10% | > 30% | Vérifier qualité des sources |
| RAM `nutrition_service` | > 1.5 Go | > 2 Go | Passer en mode performance |
| Quota Gemini API | > 1 000 req/jour | > 1 400 req/jour | Monitorer l'usage |
| Espace disque MinIO | > 80% | > 95% | Nettoyer ou étendre le volume |
| Connexions PostgreSQL actives | > 80 | > 100 | Optimiser les pools |

### Perspectives d'évolution du monitoring

- **Court terme** : Intégration Prometheus (métriques techniques) + alertes Grafana automatiques sur exécution ETL
- **Moyen terme** : Intégration Loki pour centralisation des logs
- **Long terme** : Passage en production avec monitoring complet Prometheus + Grafana + Alertmanager

---

## 8. Modes de supervision

### Mode normal (stack complète)

Supervision complète disponible :
- ✅ Grafana Cloud via PDC Agent
- ✅ Healthchecks Docker (tous services)
- ✅ Logs Docker
- ✅ Swagger UI pour les APIs Python
- ✅ Console MinIO
- ✅ Dashboards Angular (Chart.js)

### Mode offline

Supervision partielle :
- ❌ Grafana Cloud (PDC Agent désactivé)
- ✅ Healthchecks Docker (tous services)
- ✅ Logs Docker
- ✅ Dashboards Angular (Chart.js)
- ⚠️ Services IA en MOCK_MODE (données simulées)

### Mode performance (basse RAM)

Supervision adaptée :
- ❌ Grafana Cloud (PDC Agent désactivé)
- ✅ Healthchecks Docker
- ✅ Logs Docker
- ⚠️ Service Nutrition remplacé par un mock léger
