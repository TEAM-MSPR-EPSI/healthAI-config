# 🏥 HealthAI - Plateforme Intégrée de Gestion de la Santé, Fitness et Nutrition

## 📖 Table des matières

1. [Vue d'ensemble](#vue-densemble)
2. [Architecture technique](#architecture-technique)
3. [Technologies utilisées](#technologies-utilisées)
4. [Structure du projet](#structure-du-projet)
5. [Composants principaux](#composants-principaux)
6. [Guide de démarrage](#guide-de-démarrage)
7. [Flux de données](#flux-de-données)
8. [Architecture de la base de données](#architecture-de-la-base-de-données)
9. [Endpoints API principaux](#endpoints-api-principaux)
10. [Pipeline ETL](#pipeline-etl)
11. [Déploiement Docker](#déploiement-docker)
12. [Monitoring et observabilité](#monitoring-et-observabilité)

---

## 🎯 Vue d'ensemble

**HealthAI** est une plateforme complète pour gérer :

- **🏋️ Fitness & Entraînement** : Programmes d'entraînement personnalisés, sessions d'exercices, suivi de progression
- **🍽️ Nutrition & Alimentation** : Recettes, ingrédients, suivi de consommation alimentaire, allergies
- **❤️ Santé & Biométriques** : Profils de santé, données biométriques (poids, IMC, tension, etc.), allergies
- **👥 Gestion d'utilisateurs** : Authentification, profils utilisateurs, abonnements
- **🏢 Multi-tenant B2B** : Support d'organisations/entreprises avec leurs propres abonnements

La plateforme propose une **API REST complète** pour intégration backend, un **frontend web responsive** avec Angular, et un **pipeline ETL** pour charger des données externes (APIs publiques : Open Food Facts, Wger).

---

## 🏗️ Architecture technique

```
┌─────────────────────────────────────────────────────────────────┐
│                         FRONTEND (Angular)                       │
│  (4200) Interface Web - Bootstrap 5, Angular Material, Charts.js│
└───────────────────────────┬─────────────────────────────────────┘
                            │
                   ┌────────▼────────┐
                   │  Proxy/Gateway  │
                   └────────┬────────┘
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
┌───────▼────────┐ ┌───────▼────────┐ ┌───────▼────────┐
│ API BACKEND    │ │ ETL BACKEND    │ │   MONITORING   │
│  (Express.js)  │ │  (FastAPI)     │ │    (Grafana)   │
│    (5000)      │ │    (8000)      │ │  (PDC Agent)   │
└───────┬────────┘ └───────┬────────┘ └───────┬────────┘
        │                  │                   │
        └──────────────────┼───────────────────┘
                           │
                    ┌──────▼──────┐
                    │ PostgreSQL  │
                    │  Database   │
                    │   (5432)    │
                    └─────────────┘
```

**Architecture par couches :**

```
┌─────────────────────────────────────┐
│     Frontend Web (Angular)          │  ← Présentation
├─────────────────────────────────────┤
│  API REST Backend (Express/Node.js)  │  ← API & Métier
├─────────────────────────────────────┤
│  Modèles ORM (Sequelize)            │  ← Accès données
├─────────────────────────────────────┤
│  Base de données (PostgreSQL)        │  ← Persistance
└─────────────────────────────────────┘
        +
┌─────────────────────────────────────┐
│ Pipeline ETL (Python + FastAPI)     │  ← Ingestion données externes
│ (Open Food Facts, Wger APIs)        │
└─────────────────────────────────────┘
```

---

## 🛠️ Technologies utilisées

### **Frontend**
- **Angular 20** - Framework web moderne avec TypeScript
- **Bootstrap 5** - Framework CSS responsive
- **Angular Material** - Composants d'interface Material Design
- **Chart.js + ng2-charts** - Graphiques et visualisations de données
- **Font Awesome** - Icônes vectorielles
- **RxJS** - Programmation réactive

### **Backend API**
- **Node.js** - Runtime JavaScript côté serveur
- **Express.js** - Framework web et routage
- **Sequelize** - ORM (Object-Relational Mapping) pour PostgreSQL
- **JWT (jsonwebtoken)** - Authentification par token JWT
- **bcryptjs** - Hachage sécurisé des mots de passe
- **Swagger/OpenAPI** - Documentation interactive des APIs
- **Swagger UI Express** - Interface Swagger
- **dotenv** - Gestion des variables d'environnement

### **Backend ETL**
- **Python 3** - Langage de programmation
- **FastAPI** - Framework web asynchrone pour APIs
- **SQLAlchemy** - ORM Python pour PostgreSQL
- **Pandas** - Manipulation et transformation de données
- **Requests** - Requêtes HTTP aux APIs externes
- **Uvicorn** - Serveur ASGI pour FastAPI
- **psycopg2** - Driver PostgreSQL pour Python

### **Base de données**
- **PostgreSQL 15** - Base de données relationnelle
- **Enums** - Types énumérés pour rôles, objectifs, allergies, régimes
- **Séquences & Indexes** - Optimisation des requêtes
- **Contraintes & Foreign Keys** - Intégrité référentielle

### **Infrastructure & DevOps**
- **Docker** - Conteneurisation des services
- **Docker Compose** - Orchestration multi-conteneurs
- **Grafana** - Dashboard de monitoring
- **Grafana PDC Agent** - Collecte de métriques pour Grafana Cloud
- **Nodemon** - Reload automatique pendant le développement

---

## 📁 Structure du projet

```
MSPR/
├── README.md (ce fichier)
├── BACKEND_REQUIREMENTS.md (spécifications techniques)
├── package.json (dépendances root)
├── docker-compose.yml (orchestration services)
│
├── healthAI-backend-API/                    ← API REST Express/Node.js
│   ├── app.js (point d'entrée)
│   ├── swagger.js (configuration OpenAPI)
│   ├── package.json
│   ├── Dockerfile
│   ├── config/
│   │   ├── database.js (config Sequelize)
│   │   └── pool.js (pool de connexions)
│   ├── controllers/                         ← Logique métier pour chaque entité
│   │   ├── user.controller.js
│   │   ├── company.controller.js
│   │   ├── subscription.controller.js
│   │   ├── sportProgram.controller.js
│   │   ├── sportSession.controller.js
│   │   ├── sportExercise.controller.js
│   │   ├── recipe.controller.js
│   │   ├── ingredient.controller.js
│   │   ├── userHealthProfile.controller.js
│   │   ├── userBiometric.controller.js
│   │   ├── sessionProgress.controller.js
│   │   ├── consume.controller.js
│   │   └── analytics.controller.js
│   ├── models/                              ← Modèles Sequelize (ORM)
│   │   ├── User.js
│   │   ├── Company.js
│   │   ├── Subscription.js
│   │   ├── SportProgram.js
│   │   ├── SportSession.js
│   │   ├── SportExercise.js
│   │   ├── SportExerciseEquipment.js
│   │   ├── Recipe.js
│   │   ├── Ingredient.js
│   │   ├── RecipeIngredient.js
│   │   ├── UserHealthProfile.js
│   │   ├── UserBiometric.js
│   │   ├── UserAllergy.js
│   │   ├── Consume.js
│   │   ├── SessionProgress.js
│   │   └── index.js (initialisation modèles)
│   ├── routes/                              ← Routes HTTP
│   │   ├── auth.routes.js
│   │   ├── user.routes.js
│   │   ├── company.routes.js
│   │   ├── subscription.routes.js
│   │   ├── sportProgram.routes.js
│   │   ├── recipe.routes.js
│   │   ├── ingredient.routes.js
│   │   └── ... (autres routes)
│   ├── middleware/
│   │   └── auth.js (authentification JWT)
│   ├── services/                            ← Logique métier réutilisable
│   │   ├── programSession.service.js
│   │   └── recipeIngredient.service.js
│   └── README.md
│
├── healthAI-backend-ETL/                    ← Pipeline ETL Python/FastAPI
│   ├── api.py (API FastAPI)
│   ├── etl.py (orchestration pipeline)
│   ├── etl_ingredient.py (extraction/transformation ingrédients)
│   ├── etl_exercise.py (extraction/transformation exercices)
│   ├── etl_load.py (chargement en base de données)
│   ├── requirements.txt (dépendances Python)
│   ├── Dockerfile
│   ├── ingredient_valid.csv
│   ├── ingredient_invalid.csv
│   ├── exercise_valid.csv
│   ├── exercise_invalid.csv
│   └── README.md
│
├── healthAI-frontend/                       ← Application web Angular
│   ├── package.json
│   ├── angular.json (config Angular CLI)
│   ├── tsconfig.json
│   ├── Dockerfile
│   ├── proxy.conf.json (configuration proxy)
│   ├── src/
│   │   ├── main.ts
│   │   ├── index.html
│   │   ├── styles.css
│   │   ├── color.css
│   │   └── app/ (composants, services, modules)
│   └── README.md
│
├── healthAI-database/                       ← Schéma et données initiales
│   ├── init.sql (script d'initialisation)
│   └── README.md
│
├── healthAI-config/                         ← Configuration centralisée
│   ├── docker-compose.yml (services)
│   ├── git_pull_all.py (sync repos)
│   ├── .env (variables d'environnement)
│   └── README.md
│
└── healthAI-monitoring/                     ← Monitoring (Grafana)
    └── README.md
```

---

## 🔧 Composants principaux

### **1. API Backend (Express.js - Node.js)**

**Rôle** : API REST qui expose tous les endpoints métier

**Fonctionnalités clés** :
- ✅ Authentification JWT
- ✅ CRUD pour toutes les entités
- ✅ Relations complexes (Program ↔ Sessions, Recipe ↔ Ingredients)
- ✅ Suivi de progression (SessionProgress, UserBiometric)
- ✅ Gestion multi-tenant (Entreprises, Abonnements)
- ✅ Allergies et restrictions alimentaires
- ✅ Analytics et suivi de consommation

**Port** : `5000`
**Documentation** : `http://localhost:5000/api-docs` (Swagger)

**Dépendances clés** :
- Express.js (web framework)
- Sequelize (ORM)
- JWT (authentification)
- PostgreSQL driver (pg)

---

### **2. ETL Backend (FastAPI - Python)**

**Rôle** : Orchestrer des pipelines d'extraction, transformation et chargement de données

**Sources de données externes** :
- 🥗 **Open Food Facts API** - Base de données d'ingrédients alimentaires
- 💪 **Wger API** - Base de données d'exercices et équipements

**Flux ETL** :
```
┌─────────────────────────────┐
│ APIs Externes               │
│ (Open Food Facts, Wger)     │
└────────────┬────────────────┘
             │
      ┌──────▼──────┐
      │  EXTRACT    │ (récupère données brutes)
      └──────┬──────┘
             │
      ┌──────▼──────┐
      │ TRANSFORM   │ (nettoie, valide, normalise)
      └──────┬──────┘
             │
    ┌────────▼────────┐
    │ VALIDATE        │ (contrôle qualité)
    └────────┬────────┘
             │
   ┌─────────▼─────────┐
   │ GENERATE CSVs     │
   │ (valid + invalid) │
   └─────────┬─────────┘
             │
    ┌────────▼────────┐
    │  LOAD TO DB     │ (insert en PostgreSQL)
    └─────────────────┘
```

**Port** : `8000`
**Endpoints principaux** :
- `POST /etl/extract-transform` - Lance le pipeline complet
- `POST /etl/load-to-db` - Charge les données CSV en base
- `GET /csv` - Liste les fichiers CSV disponibles

---

### **3. Frontend (Angular)**

**Rôle** : Interface web responsive pour les utilisateurs

**Caractéristiques** :
- 📊 Dashboards avec graphiques (Chart.js)
- 📝 Gestion des programmes d'entraînement
- 🍽️ Gestion des recettes et ingrédients
- 📈 Suivi de progression personnelle
- 👤 Profils utilisateurs et santé
- 🔐 Authentification JWT

**Port** : `4200`
**Stack technologique** :
- Angular 20 (framework web)
- Bootstrap 5 (CSS responsive)
- Angular Material (composants UI)
- RxJS (programmation réactive)

---

### **4. Base de données (PostgreSQL)**

**Rôle** : Stockage centralisé de toutes les données

**Entités principales** (25+ tables) :

#### **Gestion utilisateurs**
- `users_` - Utilisateurs de l'application
- `user_health_profile` - Profils de santé personnalisés
- `user_biometric` - Données biométriques (poids, IMC, etc.)
- `user_allergy` - Allergies individuelles
- `user_subscription` - Lien utilisateurs ↔ Abonnements

#### **Gestion entreprises & abonnements**
- `companies` - Organisations B2B
- `subscriptions` - Plans d'abonnement
- `subscription_authorization` - Autorisations par abonnement

#### **Fitness & entraînement**
- `sport_program` - Programmes d'entraînement
- `sport_session` - Sessions d'entraînement
- `sport_exercise` - Exercices individuels
- `sport_equipment` - Équipements d'entraînement
- `sport_exercise_equipment` - Liaison exercices ↔ équipements
- `program_sport_session` - **Relation** : Programme → Sessions (avec rang/ordre)
- `sport_session_exercise` - Liaison sessions ↔ exercices
- `session_progress` - Suivi de progression par utilisateur et session

#### **Nutrition**
- `recipes` - Recettes de cuisine
- `ingredients` - Ingrédients alimentaires
- `recipe_ingredient` - **Relation** : Recette → Ingrédients (avec quantité)
- `ingredient_allergy` - Allergies par ingrédient
- `consume` - Consommation alimentaire des utilisateurs

#### **Authentification**
- `authorization` - Rôles et autorisations

---

## 🚀 Guide de démarrage

### **Prérequis**
- Docker & Docker Compose
- PostgreSQL 15 (ou via Docker)
- Node.js 14+ (pour développement local)
- Python 3.8+ (pour ETL local)
- Git

### **Option 1 : Démarrage rapide avec Docker Compose**

```bash
# 1. Se placer dans le dossier du projet
cd MSPR

# 2. Configurer les variables d'environnement
cp healthAI-config/.env .env  # À adapter avec vos paramètres

# 3. Lancer tous les services
docker-compose up -d

# 4. Vérifier le statut
docker-compose ps

# Les services seront disponibles sur :
# - Frontend : http://localhost:4200
# - API : http://localhost:5000
# - ETL : http://localhost:8000
# - API Docs : http://localhost:5000/api-docs
# - Base de données : localhost:5432
```

### **Option 2 : Développement local**

#### **Backend API**
```bash
cd healthAI-backend-API

# Installer les dépendances
npm install

# Créer .env
DB_HOST=localhost
DB_PORT=5432
DB_NAME=healthai
DB_USER=postgres
DB_PASSWORD=your_password

# Démarrer (mode développement)
npm run dev

# Accès : http://localhost:5000/api-docs
```

#### **Frontend**
```bash
cd healthAI-frontend

# Installer les dépendances
npm install

# Démarrer le serveur de développement
npm start

# Accès : http://localhost:4200
```

#### **ETL Backend**
```bash
cd healthAI-backend-ETL

# Créer l'environnement Python
python -m venv venv
source venv/bin/activate  # ou venv\Scripts\activate sur Windows

# Installer les dépendances
pip install -r requirements.txt

# Démarrer l'API
uvicorn api:app --reload --host 0.0.0.0 --port 8000

# Accès : http://localhost:8000/docs
```

---

## 📊 Flux de données

### **1. Cycle utilisateur**

```
Utilisateur
    ↓
Frontend (Angular)
    ↓
API Backend (Express)
    ↓
Base de données (PostgreSQL)
    ↓
Réponse JSON → Frontend → Affichage
```

### **2. Cycle ETL**

```
APIs Externes (Open Food Facts, Wger)
    ↓
ETL Backend (Python)
    ├─ Extract (requêtes HTTP)
    ├─ Transform (nettoyage, normalisation)
    ├─ Validate (contrôle qualité)
    └─ Generate CSVs
           ↓
    API Backend (EXPRESS)
    ↓
    PostgreSQL (INSERT)
    ↓
    Disponible dans le Frontend
```

### **3. Authentification JWT**

```
1. POST /api/auth/login → { email, password }
                ↓
2. Backend valide et génère JWT
                ↓
3. Frontend stocke JWT
                ↓
4. Pour chaque requête : Header { Authorization: Bearer JWT }
                ↓
5. Middleware auth.js vérifie le token
                ↓
6. Accès accordé/refusé
```

---

## 🗄️ Architecture de la base de données

### **Types énumérés (ENUMS)**

```sql
-- Rôles utilisateurs
ENUM role: 'admin', 'user', 'company_admin'

-- Objectifs fitness
ENUM objective: 'weight_loss', 'muscle_gain', 'endurance', 'flexibility', 'maintenance'

-- Allergies
ENUM allergy: 'gluten', 'crustaceans', 'eggs', 'fish', 'milk', 'nuts', 'peanuts', 'sesame', 'soy', 'sulfites', 'tree_nuts', 'other'

-- Régimes alimentaires
ENUM diet: 'vegan', 'vegetarian', 'kosher', 'halal', 'pescatarian', 'paleo', 'keto'

-- Niveaux d'entraînement
ENUM level: 'beginner', 'intermediate', 'advanced'
```

### **Schéma relationnel**

```
users_
├─ user_id (PK)
├─ email
├─ password (hashed)
├─ first_name, last_name
├─ role (ENUM)
├─ company_id (FK → companies)
└─ created_at, updated_at

companies
├─ company_id (PK)
├─ name
├─ email
└─ contact_info

subscriptions
├─ subscription_id (PK)
├─ name
├─ description
├─ price
└─ duration

sport_program
├─ sport_program_id (PK)
├─ name, description
├─ objective (ENUM)
├─ level (ENUM)
└─ created_at

sport_session
├─ sport_session_id (PK)
├─ name, description
├─ duration
└─ level (ENUM)

program_sport_session (TABLE DE JOINTURE)
├─ program_sport_session_id (PK)
├─ sport_program_id (FK)
├─ sport_session_id (FK)
└─ program_sport_session_rank (ordre dans le programme)

recipes
├─ recipe_id (PK)
├─ name, description
├─ prep_time, cook_time
└─ servings

ingredients
├─ ingredient_id (PK)
├─ name, description
├─ calories
└─ nutriments (protein, fat, carbs)

recipe_ingredient (TABLE DE JOINTURE)
├─ recipe_ingredient_id (PK)
├─ recipe_id (FK)
├─ ingredient_id (FK)
└─ ingredient_quantity (quantité)

user_health_profile
├─ user_health_profile_id (PK)
├─ user_id (FK)
├─ age, gender, height, weight
└─ health_goals

user_biometric
├─ user_biometric_id (PK)
├─ user_id (FK)
├─ weight, height, bmi
├─ blood_pressure, heart_rate
└─ measurement_date

session_progress
├─ session_progress_id (PK)
├─ user_id (FK)
├─ sport_session_id (FK)
├─ completed_date
├─ duration, calories_burned
└─ notes
```

---

## 🔌 Endpoints API principaux

### **Authentification**
```
POST   /api/auth/register           - Créer un compte
POST   /api/auth/login              - Se connecter
POST   /api/auth/logout             - Se déconnecter
POST   /api/auth/refresh            - Rafraîchir le token JWT
```

### **Utilisateurs**
```
GET    /api/users                   - Lister tous les utilisateurs
POST   /api/users                   - Créer un utilisateur
GET    /api/users/:id               - Obtenir un utilisateur
PUT    /api/users/:id               - Modifier un utilisateur
DELETE /api/users/:id               - Supprimer un utilisateur
```

### **Entreprises**
```
GET    /api/companies               - Lister les entreprises
POST   /api/companies               - Créer une entreprise
GET    /api/companies/:id           - Obtenir une entreprise
PUT    /api/companies/:id           - Modifier une entreprise
DELETE /api/companies/:id           - Supprimer une entreprise
```

### **Abonnements**
```
GET    /api/subscriptions           - Lister les abonnements
POST   /api/subscriptions           - Créer un abonnement
GET    /api/subscriptions/:id       - Obtenir un abonnement
PUT    /api/subscriptions/:id       - Modifier un abonnement
DELETE /api/subscriptions/:id       - Supprimer un abonnement
```

### **Fitness & Entraînement**
```
GET    /api/sport-programs          - Lister les programmes
POST   /api/sport-programs          - Créer un programme
GET    /api/sport-programs/:id      - Obtenir un programme
PUT    /api/sport-programs/:id      - Modifier un programme
DELETE /api/sport-programs/:id      - Supprimer un programme

GET    /api/sport-sessions          - Lister les sessions
POST   /api/sport-sessions          - Créer une session
GET    /api/sport-sessions/:id      - Obtenir une session

GET    /api/sport-exercises         - Lister les exercices
GET    /api/sport-equipment         - Lister les équipements

GET    /api/session-progress        - Lister les progressions
GET    /api/session-progress/user/:userId - Progressions d'un utilisateur
POST   /api/session-progress        - Enregistrer une progression

GET    /api/program-sessions/:programId/available-sessions
POST   /api/program-sessions/:programId/sessions
PUT    /api/program-sessions/:programId/sessions/:sessionId
DELETE /api/program-sessions/:programId/sessions/:sessionId
```

### **Nutrition**
```
GET    /api/recipes                 - Lister les recettes
POST   /api/recipes                 - Créer une recette
GET    /api/recipes/:id             - Obtenir une recette

GET    /api/ingredients             - Lister les ingrédients
POST   /api/ingredients             - Créer un ingrédient

GET    /api/recipe-ingredients/:recipeId/available-ingredients
POST   /api/recipe-ingredients/:recipeId/ingredients
PUT    /api/recipe-ingredients/:recipeId/ingredients/:ingredientId
DELETE /api/recipe-ingredients/:recipeId/ingredients/:ingredientId

GET    /api/consumes                - Lister les consommations
GET    /api/consumes/user/:userId   - Consommations d'un utilisateur
POST   /api/consumes                - Enregistrer une consommation
```

### **Santé & Biométriques**
```
GET    /api/user-health-profiles    - Lister les profils
POST   /api/user-health-profiles    - Créer un profil
GET    /api/user-health-profiles/user/:userId
PUT    /api/user-health-profiles/:id

GET    /api/user-biometrics         - Lister les biométries
POST   /api/user-biometrics         - Ajouter une mesure
GET    /api/user-biometrics/user/:userId
```

### **Allergies**
```
GET    /api/user-allergies          - Lister les allergies
POST   /api/user-allergies          - Ajouter une allergie
DELETE /api/user-allergies/:id      - Supprimer une allergie
```

### **Analytics**
```
GET    /api/analytics/user/:userId  - Statistiques utilisateur
GET    /api/analytics/health-summary - Résumé santé/fitness
```

---

## 🔄 Pipeline ETL

Le pipeline ETL permet de charger des données externes dans la base de données HealthAI.

### **Sources de données**

#### **1. Open Food Facts API** 🥗
- Récupère les données des ingrédients alimentaires
- Inclut : calories, nutriments (protéines, lipides, glucides), allergènes
- Format : JSON → Transformation → CSV → Base de données

#### **2. Wger API** 💪
- Récupère les exercices de fitness
- Inclut : descriptions, niveaux de difficulté, équipements nécessaires
- Format : JSON → Transformation → CSV → Base de données

### **Endpoints ETL**

```
POST   /etl/extract-transform              - Lance l'ETL complet
POST   /etl/extract-transform/ingredient   - ETL ingrédients uniquement
POST   /etl/extract-transform/exercice     - ETL exercices uniquement

POST   /etl/load-to-db                     - Charge en base de données
POST   /etl/load-to-db/ingredient          - Charge ingrédients uniquement
POST   /etl/load-to-db/exercice            - Charge exercices uniquement

GET    /csv                                - Liste les fichiers CSV
GET    /csv/ingredient                     - Fichiers ingrédients
GET    /csv/exercice                       - Fichiers exercices
GET    /csv/{csv_name}                     - Télécharge un CSV

GET    /health                             - Vérifier le statut de l'API
```

### **Fichiers CSV générés**

- `ingredient_valid.csv` - Ingrédients valides (prêts à charger)
- `ingredient_invalid.csv` - Ingrédients rejetés (contrôle qualité échoué)
- `exercise_valid.csv` - Exercices valides (prêts à charger)
- `exercise_invalid.csv` - Exercices rejetés (contrôle qualité échoué)

### **Workflow complet**

```bash
# 1. Lancer l'extraction et transformation
POST /etl/extract-transform

# 2. Vérifier les fichiers générés
GET /csv

# 3. Télécharger et inspecter les fichiers
GET /csv/ingredient_valid
GET /csv/ingredient_invalid

# 4. Charger en base de données
POST /etl/load-to-db

# 5. Vérifier les données en base via l'API
GET /api/ingredients
GET /api/sport-exercises
```

---

## 🐳 Déploiement Docker

### **Architecture Docker Compose**

```yaml
services:
  database
    ├─ PostgreSQL 15
    ├─ Volume : postgres_data
    ├─ Port : 5432
    └─ Health check inclus

  api_backend
    ├─ Node.js + Express
    ├─ Port : 5000
    ├─ Commande : npm run dev
    └─ Dépend de : database

  etl_backend
    ├─ Python + FastAPI
    ├─ Port : 8000
    ├─ Dépend de : database
    └─ Restart : no (exécution manuelle)

  frontend
    ├─ Angular
    ├─ Port : 4200
    ├─ Dépend de : api_backend
    └─ Commande : npm start

  pdc_agent
    ├─ Grafana PDC Agent
    ├─ Envoie données à Grafana Cloud
    └─ Dépend de : database

  monitoring
    ├─ Grafana
    └─ Dashboard de monitoring
```

### **Démarrer l'application**

```bash
# Démarrer tous les services
docker-compose up -d

# Vérifier le statut
docker-compose ps

# Voir les logs
docker-compose logs -f api_backend
docker-compose logs -f frontend
docker-compose logs -f etl_backend

# Arrêter
docker-compose down

# Redémarrer un service spécifique
docker-compose restart api_backend
```

### **Variables d'environnement (.env)**

```env
# PostgreSQL
POSTGRES_DB=healthai
POSTGRES_USER=postgres
POSTGRES_PASSWORD=your_secure_password

# API Backend
NODE_ENV=development
DB_HOST=database
DB_PORT=5432
DB_NAME=healthai
DB_USER=postgres
DB_PASSWORD=your_secure_password

# Grafana
PDC_TOKEN=your_grafana_token
PDC_CLUSTER=your_cluster_id
PDC_GRAFANA_ID=your_grafana_id
```

---

## 📊 Monitoring et observabilité

### **Grafana**
- **Rôle** : Dashboards de monitoring en temps réel
- **Données sources** : PDC Agent collecte les métriques depuis les conteneurs
- **Destination** : Grafana Cloud
- **Accessible sur** : `http://localhost:3000` (si en local)

### **PDC Agent**
- Collecte les métriques des services Docker
- Envoie vers Grafana Cloud pour centralisation
- Configuration via variables d'environnement

### **Logs**
```bash
# Tous les logs
docker-compose logs -f

# Logs d'un service spécifique
docker-compose logs -f api_backend
docker-compose logs -f etl_backend
docker-compose logs -f frontend

# Logs avec filtre
docker-compose logs --tail=50 api_backend
```

### **Healthchecks**
- PostgreSQL : Health check inclus (`pg_isready`)
- API Backend : Vérifie la disponibilité avant de démarrer le frontend
- Gestion des dépendances via `depends_on`

---

## 📝 Scripts utiles

### **Mise à jour des dépôts Git**
```bash
# Synchroniser tous les sous-dépôts
cd healthAI-config
python git_pull_all.py
```

### **Initialiser la base de données**
```bash
# La base de données est initialisée automatiquement au démarrage du conteneur
# Le fichier init.sql est exécuté via le volume Docker
# Pour réinitialiser :

docker-compose down -v  # Supprime les volumes
docker-compose up -d    # Redémarre et réinitialise
```

### **Développement**

```bash
# Mode dev avec hot-reload
npm run dev              # API Backend
ng serve               # Frontend

# Tests
npm test              # Backend & Frontend
```

---

## 🔐 Sécurité

- **Authentification JWT** : Tokens sécurisés pour toutes les requêtes
- **Hachage des mots de passe** : bcryptjs avec salt
- **CORS configuré** : Seulement les domaines autorisés
- **Variables d'environnement** : Secrets en `.env` (non versionné)
- **Base de données** : Contraintes et intégrité référentielle
- **Middleware auth** : Protection des routes sensibles

---

## 🤝 Contribution & Développement

### **Structure de code**

- **Controllers** : Logique métier simple, validations
- **Services** : Logique réutilisable, traitement complexe
- **Models** : Schéma ORM Sequelize
- **Routes** : Définition des endpoints HTTP
- **Middleware** : Authentification, logging, CORS

### **Conventions de nommage**
- Entités : PascalCase (User, SportProgram, RecipeIngredient)
- Fichiers : kebab-case (user.controller.js, sport-program.routes.js)
- Variables : camelCase (userId, sportProgramId)
- Tables SQL : snake_case (users_, sport_program, recipe_ingredient)

---

## 📚 Documentation supplémentaire

- **Backend API** : [healthAI-backend-API/README.md](./healthAI-backend-API/README.md)
- **Backend ETL** : [healthAI-backend-ETL/README.md](./healthAI-backend-ETL/README.md)
- **Frontend** : [healthAI-frontend/README.md](./healthAI-frontend/README.md)
- **Base de données** : [healthAI-database/README.md](./healthAI-database/README.md)
- **Configuration** : [healthAI-config/README.md](./healthAI-config/README.md)
- **Spécifications techniques** : [BACKEND_REQUIREMENTS.md](./BACKEND_REQUIREMENTS.md)

---

## 🐛 Dépannage

### **La base de données n'est pas accessible**
```bash
# Vérifier le statut des conteneurs
docker-compose ps

# Vérifier les logs PostgreSQL
docker-compose logs database

# Réinitialiser le conteneur
docker-compose restart database
```

### **Le frontend ne se connecte pas à l'API**
```bash
# Vérifier la proxy configuration
cat healthAI-frontend/proxy.conf.json

# S'assurer que l'API backend est en cours d'exécution
curl http://localhost:5000/api-docs

# Vérifier les CORS headers
docker-compose logs api_backend
```

### **Les données ETL ne se chargent pas**
```bash
# Vérifier l'API ETL
curl http://localhost:8000/health

# Vérifier les logs ETL
docker-compose logs etl_backend

# S'assurer que les fichiers CSV sont générés
docker-compose exec etl_backend ls -la *.csv
```

---

## 📞 Support

Pour les problèmes ou questions :
1. Consulter les README spécifiques de chaque module
2. Vérifier les logs Docker
3. Vérifier les spécifications dans BACKEND_REQUIREMENTS.md

---

**Version** : 1.0.0  
**Date de mise à jour** : 24 avril 2026  
**Mainteneurs** : Équipe HealthAI Development
