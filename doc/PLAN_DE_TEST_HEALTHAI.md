# Plan de test — HealthAI Coach

> **Projet** : HealthAI Coach — MSPR TPRE601  
> **Équipe** : Mathis Morales · Arnaud Goldberg · Hugo Lembrez · Mathilde Ageron  
> **Année** : 2025-2026 — EPSI, Certification CDA 3ème année  
> **Date de soutenance** : 02/07/2026

---

## Sommaire

1. [Objectifs et périmètre](#1-objectifs-et-périmètre)
2. [Stratégie de test](#2-stratégie-de-test)
3. [Environnements de test](#3-environnements-de-test)
4. [Couverture par composant](#4-couverture-par-composant)
5. [Tests Frontend Angular](#5-tests-frontend-angular)
6. [Tests Backend API Node.js](#6-tests-backend-api-nodejs)
7. [Tests Backend ETL Python](#7-tests-backend-etl-python)
8. [Tests Service Nutrition Python](#8-tests-service-nutrition-python)
9. [Tests d'intégration et E2E](#9-tests-dintégration-et-e2e)
10. [Pipeline CI/CD et automatisation](#10-pipeline-cicd-et-automatisation)
11. [Indicateurs de qualité](#11-indicateurs-de-qualité)

---

## 1. Objectifs et périmètre

Ce plan de test décrit la stratégie, les cas de test et les outils retenus pour valider la qualité du projet HealthAI Coach dans le cadre de la MSPR 3 (mise en production).

### Objectifs

- Garantir la fiabilité fonctionnelle de chaque composant de la stack
- Assurer la sécurité des mécanismes d'authentification et de stockage des données sensibles
- Valider la robustesse des pipelines ETL face aux données malformées ou manquantes
- Vérifier le bon comportement des services IA en conditions normales et limites
- Maintenir une couverture de code suffisante pour chaque service critique

### Périmètre

| Composant | Type de tests couverts |
|-----------|----------------------|
| Frontend Angular | Unitaires (Jasmine/Karma), E2E (Playwright) |
| Backend API Node.js | Unitaires (node --test) |
| Backend ETL Python | Unitaires (pytest) |
| Service Nutrition Python | Unitaires (pytest) |
| Service Exercices Python | Non couvert (hors périmètre MSPR 3) |
| Infrastructure Docker | Tests de démarrage / healthchecks |

---

## 2. Stratégie de test

La stratégie repose sur une pyramide de tests à trois niveaux :

1. **Tests unitaires** — validation isolée de chaque fonction, méthode ou composant, sans dépendance externe
2. **Tests d'intégration** — validation des interactions entre composants (API + base de données dans le contexte CI/CD)
3. **Tests end-to-end (E2E)** — simulation de parcours utilisateurs complets dans un navigateur réel

Les tests sont exécutés automatiquement à chaque push et pull request via la pipeline GitHub Actions, garantissant qu'aucune régression n'est intégrée sur les branches `dev` et `main`.

---

## 3. Environnements de test

### Environnement local

- Docker Desktop (Windows/macOS) ou Docker Engine + Compose (Linux)
- Commande de démarrage : `python run.py` → option 2 (stack normale)
- Base de données de test initialisée automatiquement par `01-init.sql` et `02-demo-data.sql`

### Environnement CI/CD (GitHub Actions)

- Fichier dédié : `docker-compose.test.yml` à la racine de chaque repository
- Services démarrés avec l'option `--wait` (Docker Compose v2) pour attendre les healthchecks
- Variables d'environnement injectées via le secret GitHub `ETL_ENV_FILE`
- Base de données éphémère (identifiants fixes : `testuser` / `testpassword` / `testdb`)

### Mode mock (hors ligne)

- Stack offline : `docker-compose_offline.yml` avec `MOCK_MODE=true` sur les services ETL, nutrition et exercices
- Permet de valider les interfaces sans dépendance aux APIs externes (Gemini, USDA, OpenFoodFacts, Wger)

---

## 4. Couverture par composant

| Composant | Framework | Nombre de tests | Couverture |
|-----------|-----------|-----------------|------------|
| Frontend Angular — unitaires | Jasmine + Karma | 10 | 40,42 % |
| Frontend Angular — E2E | Playwright | 15 (3 navigateurs × 5) | — |
| Backend API Node.js | node --test | 8 | 97,85 % |
| Backend ETL Python | pytest | 112 | 86 % |
| Service Nutrition Python | pytest | 5 | 56 % |

---

## 5. Tests Frontend Angular

### Exécution

```bash
# Tests unitaires avec couverture
cd healthAI-frontend
npm run test:coverage

# Tests E2E
cd healthAI-frontend
npm run test:e2e
```

### 5.1 Tests unitaires (Jasmine + Karma)

#### TC-FE-001 — Création du composant racine

| Champ | Détail |
|-------|--------|
| **Fichier** | `app.spec.ts` |
| **Description** | Vérifie que le composant racine Angular est instancié sans erreur |
| **Préconditions** | Application compilée et serveur de test Karma démarré |
| **Résultat attendu** | Composant créé, titre affiché correctement |
| **Statut** | ✅ Passant |

#### TC-FE-002 — Connexion utilisateur (AuthService)

| Champ | Détail |
|-------|--------|
| **Fichier** | `auth.service.spec.ts` |
| **Description** | Vérifie que le service d'authentification appelle l'endpoint de login et retourne un token |
| **Préconditions** | HttpClientTestingModule configuré |
| **Résultat attendu** | Requête POST envoyée, token reçu et stocké |
| **Statut** | ✅ Passant |

#### TC-FE-003 — Récupération du profil utilisateur

| Champ | Détail |
|-------|--------|
| **Fichier** | `auth.service.spec.ts` |
| **Description** | Vérifie que le profil utilisateur est récupéré avec un token valide |
| **Préconditions** | Token JWT valide présent |
| **Résultat attendu** | Données profil retournées et mappées correctement |
| **Statut** | ✅ Passant |

#### TC-FE-004 — Gestion des erreurs d'authentification

| Champ | Détail |
|-------|--------|
| **Fichier** | `auth.service.spec.ts` |
| **Description** | Vérifie le comportement lors d'identifiants incorrects |
| **Préconditions** | Serveur mockant une réponse 401 |
| **Résultat attendu** | Erreur propagée, aucun token stocké |
| **Statut** | ✅ Passant |

#### TC-FE-005 — Déconnexion utilisateur

| Champ | Détail |
|-------|--------|
| **Fichier** | `auth.service.spec.ts` |
| **Description** | Vérifie que la déconnexion supprime le token et redirige |
| **Préconditions** | Utilisateur connecté |
| **Résultat attendu** | Token supprimé, redirection vers `/welcome` |
| **Statut** | ✅ Passant |

#### TC-FE-006 — Mapping des données API (ApiService)

| Champ | Détail |
|-------|--------|
| **Fichier** | `api.service.spec.ts` |
| **Description** | Vérifie la transformation des réponses API vers les modèles Angular |
| **Préconditions** | Données de test injectées |
| **Résultat attendu** | Objets Angular correctement construits depuis la réponse HTTP |
| **Statut** | ✅ Passant |

#### TC-FE-007 — Normalisation des ingrédients

| Champ | Détail |
|-------|--------|
| **Fichier** | `api.service.spec.ts` |
| **Description** | Vérifie que les valeurs nutritionnelles sont normalisées à 100g |
| **Préconditions** | Ingrédient avec valeurs brutes |
| **Résultat attendu** | Valeurs recalculées et arrondies correctement |
| **Statut** | ✅ Passant |

#### TC-FE-008 — Page abonnement — affichage SnackBar

| Champ | Détail |
|-------|--------|
| **Fichier** | `subscribe.spec.ts` |
| **Description** | Vérifie qu'un message de confirmation s'affiche après souscription |
| **Préconditions** | Composant `subscribe` instancié |
| **Résultat attendu** | MatSnackBar ouvert avec le bon message |
| **Statut** | ✅ Passant |

#### TC-FE-009 — Page abonnement — fallback image

| Champ | Détail |
|-------|--------|
| **Fichier** | `subscribe.spec.ts` |
| **Description** | Vérifie qu'une image de substitution s'affiche si le chargement échoue |
| **Préconditions** | URL d'image invalide |
| **Résultat attendu** | Image par défaut affichée, aucune erreur console bloquante |
| **Statut** | ✅ Passant |

#### TC-FE-010 — Affichage du titre application

| Champ | Détail |
|-------|--------|
| **Fichier** | `app.spec.ts` |
| **Description** | Vérifie que le titre de l'application est bien rendu dans le DOM |
| **Préconditions** | Composant racine initialisé |
| **Résultat attendu** | Texte "HealthAI Coach" présent dans le DOM |
| **Statut** | ✅ Passant |

---

### 5.2 Tests E2E — Playwright (3 navigateurs : Chromium, Firefox, WebKit)

#### TC-E2E-001 — Redirection splash screen

| Champ | Détail |
|-------|--------|
| **Description** | La splash screen redirige automatiquement vers `/welcome` |
| **Navigateurs** | Chromium, Firefox, WebKit |
| **Résultat attendu** | URL `/welcome` atteinte dans les délais |
| **Statut** | ✅ Passant (×3) |

#### TC-E2E-002 — Navigation publique

| Champ | Détail |
|-------|--------|
| **Description** | Vérification des liens et boutons accessibles sans authentification |
| **Navigateurs** | Chromium, Firefox, WebKit |
| **Résultat attendu** | Tous les liens publics naviguent vers les bonnes pages sans erreur 404 |
| **Statut** | ✅ Passant (×3) |

#### TC-E2E-003 — Validation formulaire de connexion

| Champ | Détail |
|-------|--------|
| **Description** | Soumission du formulaire avec des identifiants invalides affiche un message d'erreur |
| **Navigateurs** | Chromium, Firefox, WebKit |
| **Résultat attendu** | Message d'erreur affiché, utilisateur non redirigé |
| **Statut** | ✅ Passant (×3) |

#### TC-E2E-004 — Navigation vers l'inscription

| Champ | Détail |
|-------|--------|
| **Description** | Le bouton "S'inscrire" depuis `/welcome` navigue vers la page d'inscription |
| **Navigateurs** | Chromium, Firefox, WebKit |
| **Résultat attendu** | URL d'inscription atteinte, formulaire d'inscription affiché |
| **Statut** | ✅ Passant (×3) |

#### TC-E2E-005 — Connexion mockée et accès dashboard

| Champ | Détail |
|-------|--------|
| **Description** | Connexion avec interception des appels API (mock), vérification de l'accès au dashboard |
| **Navigateurs** | Chromium, Firefox, WebKit |
| **Préconditions** | Interception Playwright configurée pour renvoyer un token JWT valide |
| **Résultat attendu** | Utilisateur redirigé vers le dashboard, composants principaux affichés |
| **Statut** | ✅ Passant (×3) |

---

## 6. Tests Backend API Node.js

### Exécution

```bash
cd healthAI-backend-API
npm run test:coverage
```

#### TC-API-001 — Rejet mot de passe faible

| Champ | Détail |
|-------|--------|
| **Description** | L'inscription avec un mot de passe trop court est rejetée |
| **Résultat attendu** | Réponse 400, message d'erreur explicite, aucun utilisateur créé en base |
| **Statut** | ✅ Passant |

#### TC-API-002 — Hachage bcrypt du mot de passe

| Champ | Détail |
|-------|--------|
| **Description** | Le mot de passe n'est jamais stocké en clair |
| **Résultat attendu** | Valeur `user_hashpwd` en base est un hash bcrypt valide |
| **Statut** | ✅ Passant |

#### TC-API-003 — Génération de JWT à la connexion

| Champ | Détail |
|-------|--------|
| **Description** | La connexion avec des identifiants valides retourne un JWT signé |
| **Résultat attendu** | Token JWT contenant `user_id` et `role`, signé avec `JWT_SECRET` |
| **Statut** | ✅ Passant |

#### TC-API-004 — Rejet d'identifiants incorrects

| Champ | Détail |
|-------|--------|
| **Description** | La connexion avec un mauvais mot de passe est refusée |
| **Résultat attendu** | Réponse 401, aucun token retourné |
| **Statut** | ✅ Passant |

#### TC-API-005 — Parseur SQL — découpe sur `;`

| Champ | Détail |
|-------|--------|
| **Description** | Le parseur SQL découpe correctement les instructions sur les points-virgules |
| **Résultat attendu** | Tableau d'instructions SQL correctement délimité |
| **Statut** | ✅ Passant |

#### TC-API-006 — Parseur SQL — préservation des blocs `$$`

| Champ | Détail |
|-------|--------|
| **Description** | Les blocs PL/pgSQL délimités par `$$` ne sont pas découpés incorrectement |
| **Résultat attendu** | Bloc `$$...$$` conservé comme une seule instruction |
| **Statut** | ✅ Passant |

#### TC-API-007 — Blocage des instructions `DROP TABLE`

| Champ | Détail |
|-------|--------|
| **Description** | Les imports SQL contenant des `DROP TABLE` sont bloqués par sécurité |
| **Résultat attendu** | Erreur levée, aucune instruction exécutée |
| **Statut** | ✅ Passant |

#### TC-API-008 — Import SQL avec `ON CONFLICT DO NOTHING`

| Champ | Détail |
|-------|--------|
| **Description** | L'import SQL standard insère les données sans doublon dans une transaction |
| **Résultat attendu** | Données insérées, conflits ignorés, transaction commitée |
| **Statut** | ✅ Passant |

---

## 7. Tests Backend ETL Python

### Exécution

```bash
cd healthAI-backend-ETL
pytest tests.py -v --cov
```

Les 112 tests couvrent l'ensemble des couches du service ETL et sont exécutés automatiquement dans la pipeline CI/CD via `docker exec etl_backend pytest tests.py`.

### Catégories de tests

#### 7.1 Transformations et nettoyage (ETL)

| ID | Description | Résultat attendu |
|----|-------------|------------------|
| TC-ETL-001 | Fonction `_sanitize` — suppression des caractères spéciaux | Chaîne nettoyée conforme |
| TC-ETL-002 | Fonction `_strip_html` — suppression des balises HTML | Texte brut sans balises |
| TC-ETL-003 | Déduplication — doublons sur même nom d'ingrédient | Un seul enregistrement conservé |
| TC-ETL-004 | Validation métier — ingrédient avec valeurs nutritionnelles négatives | Entrée rejetée dans CSV invalide |
| TC-ETL-005 | Validation métier — exercice sans groupe musculaire | Entrée rejetée dans CSV invalide |
| TC-ETL-006 | Validation métier — ingrédient valide complet | Entrée acceptée dans CSV valide |
| TC-ETL-007 | Validation métier — exercice valide complet | Entrée acceptée dans CSV valide |

#### 7.2 Appels HTTP et gestion des erreurs

| ID | Description | Résultat attendu |
|----|-------------|------------------|
| TC-ETL-010 | Timeout réseau | Retry déclenché, erreur propagée après N tentatives |
| TC-ETL-011 | Réponse HTTP 404 | Entrée ignorée, pipeline continue |
| TC-ETL-012 | JSON invalide dans la réponse | Erreur loggée, entrée ignorée |
| TC-ETL-013 | Pagination — plusieurs pages de résultats | Toutes les pages collectées |

#### 7.3 Routes FastAPI

| ID | Description | Résultat attendu |
|----|-------------|------------------|
| TC-ETL-020 | `GET /csv/ingredient` — fichier valide existant | Code 200, contenu CSV retourné |
| TC-ETL-021 | `PUT /csv/ingredient` — mise à jour du CSV valide | Code 200, fichier mis à jour |
| TC-ETL-022 | `POST /etl/run` — déclenchement du pipeline | Code 200, pipeline lancé |
| TC-ETL-023 | Données invalides (validation Pydantic) | Code 422, message d'erreur descriptif |
| TC-ETL-024 | Erreur interne serveur | Code 500, message d'erreur générique |
| TC-ETL-025 | Timeout base de données | Code 504, message de délai dépassé |

#### 7.4 Écriture CSV et insertion base de données

| ID | Description | Résultat attendu |
|----|-------------|------------------|
| TC-ETL-030 | Écriture CSV — cas nominal | Fichier créé avec le bon contenu |
| TC-ETL-031 | Écriture CSV — fichier vide (0 enregistrement) | Fichier vide créé sans erreur |
| TC-ETL-032 | Écriture CSV — fichier inexistant (chemin invalide) | Erreur levée et loggée |
| TC-ETL-033 | Insertion PostgreSQL — cas nominal | Données insérées correctement |
| TC-ETL-034 | Insertion PostgreSQL — erreur SQLAlchemy | Transaction rollback, erreur propagée |

---

## 8. Tests Service Nutrition Python

### Exécution

```bash
cd healthAI-service-nutrition
python -m pytest -v
```

#### TC-NUT-001 — Endpoint `/health`

| Champ | Détail |
|-------|--------|
| **Description** | Vérifie que l'endpoint de santé retourne le statut attendu |
| **Résultat attendu** | HTTP 200 — `{"status": "ok", "service": "nutrition-recommendation"}` |
| **Statut** | ✅ Passant |

#### TC-NUT-002 — Endpoint racine `/`

| Champ | Détail |
|-------|--------|
| **Description** | Vérifie que la racine retourne les liens vers la documentation OpenAPI |
| **Résultat attendu** | HTTP 200 — Liens vers `/docs` et `/redoc` présents |
| **Statut** | ✅ Passant |

#### TC-NUT-003 — Génération plan de repas hebdomadaire

| Champ | Détail |
|-------|--------|
| **Description** | Génère un plan de repas pour 2 jours avec profil végétalien |
| **Préconditions** | Profil utilisateur végétalien, objectif perte de poids |
| **Résultat attendu** | Plan JSON avec 4 repas/jour respectant les contraintes alimentaires |
| **Statut** | ✅ Passant |

#### TC-NUT-004 — Division par zéro sur apport calorique nul

| Champ | Détail |
|-------|--------|
| **Description** | Comportement quand l'apport calorique calculé est 0 |
| **Préconditions** | Profil utilisateur avec métabolisme de base nul (données aberrantes) |
| **Résultat attendu** | Valeur de fallback 1800 kcal/jour retournée sans erreur |
| **Statut** | ✅ Passant |

#### TC-NUT-005 — Détection de déséquilibres nutritionnels

| Champ | Détail |
|-------|--------|
| **Description** | Le modèle Random Forest détecte correctement trois types de déséquilibres |
| **Cas testés** | Déficit protéines, déficit glucides, excès lipides |
| **Résultat attendu** | Type de déséquilibre correctement identifié pour chaque cas |
| **Statut** | ✅ Passant |

---

## 9. Tests d'intégration et E2E

### 9.1 Healthchecks Docker

Au démarrage de la stack, chaque conteneur doit atteindre l'état `healthy` avant que les services dépendants ne démarrent. La commande de vérification est :

```bash
docker compose ps
curl http://localhost:5000/health
```

| Conteneur | Endpoint de santé | Résultat attendu |
|-----------|-------------------|------------------|
| `api_backend` | `GET http://localhost:5000/health` | HTTP 200 |
| `etl_backend` | `GET http://localhost:8000/health` | HTTP 200 |
| `nutrition_service` | `GET http://localhost:8001/health` | HTTP 200 `{"status": "ok"}` |
| `exercices_service` | `GET http://localhost:8002/health` | HTTP 200 |

### 9.2 Tests de démarrage multi-environnement

| Configuration | Commande | Critère de réussite |
|--------------|----------|---------------------|
| Stack normale | `python run.py` → option 2 | Tous les healthchecks verts en < 10 min |
| Stack offline | `python run.py` → option 3 | Services démarrés sans erreur, mocks actifs |
| Stack performance | `python run.py` → option 4 | Stack démarrée avec limites RAM respectées |

---

## 10. Pipeline CI/CD et automatisation

La pipeline GitHub Actions du projet `healthAI-backend-ETL` s'articule autour de trois jobs :

```
push / pull_request (branches : dev, main)
          │
          ▼
       [build]
    pip install -r requirements.txt
          │
    ┌─────┴─────┐
    ▼           ▼
 [linter]    [test]
  flake8    docker-compose.test.yml
  PEP8      → pytest 112 tests
```

### Déclencheurs

- Tout push sur n'importe quelle branche
- Toute pull request ciblant `dev` ou `main`

### Critères de blocage

- Échec de `pip install` → intégration bloquée
- Non-conformité PEP8 détectée par `flake8` → intégration bloquée
- Au moins 1 test pytest échoue parmi les 112 → intégration bloquée

---

## 11. Indicateurs de qualité

| Indicateur | Valeur actuelle | Objectif |
|------------|-----------------|----------|
| Couverture Backend API Node.js | 97,85 % | ≥ 90 % |
| Couverture ETL Python | 86 % | ≥ 80 % |
| Couverture Service Nutrition | 56 % | ≥ 60 % (évolution) |
| Couverture Frontend Angular | 40,42 % | ≥ 70 % (évolution) |
| Tests ETL passants en CI | 112/112 | 100 % |
| Conformité PEP8 | ✅ | 0 erreur flake8 |
| Navigateurs E2E validés | 3/3 | Chromium, Firefox, WebKit |

---