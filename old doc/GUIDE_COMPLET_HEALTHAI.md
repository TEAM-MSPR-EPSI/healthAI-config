# Guide complet du code HealthAI

Ce document explique l'architecture réelle du dépôt HealthAI/MSPR, le rôle de chaque grande couche, les composants front, les services, les routes backend, le modèle de données, le pipeline ETL et les principes RGAA appliqués au frontend.

L'objectif n'est pas de recopier le code ligne par ligne, mais d'expliquer comment tout fonctionne, quels concepts sont utilisés et où se trouvent les points importants à connaître pour maintenir le projet.

## 1. Vue d'ensemble

HealthAI est une plateforme de santé, sport et nutrition structurée en plusieurs briques :

- un frontend Angular qui sert l'interface utilisateur et l'interface d'administration
- une API backend Express/Node.js qui expose les données métier
- un backend ETL FastAPI/Python qui importe et transforme des données externes
- une base PostgreSQL qui contient toutes les entités métier
- une couche de configuration et de déploiement Docker
- une documentation d'accessibilité RGAA pour guider le développement frontend

Le système couvre plusieurs domaines fonctionnels :

- authentification et onboarding
- gestion des utilisateurs et de leurs profils
- nutrition et recettes
- sport, programmes, séances et exercices
- biométrie et suivi de santé
- administration et gestion de données
- import de données via ETL
- analytics côté admin

## 2. Architecture globale

Le flux principal est le suivant :

1. Le navigateur charge l'application Angular.
2. Le frontend appelle l'API Express via HttpClient.
3. L'API passe par des contrôleurs puis des services métier.
4. Les services utilisent Sequelize pour lire ou écrire dans PostgreSQL.
5. Le frontend normalise parfois les réponses pour adapter les champs au besoin de l'interface.
6. Le backend ETL récupère, nettoie et charge des données externes dans la base.

Schéma logique simplifié :

```text
Angular frontend -> Express API -> Sequelize models -> PostgreSQL
                    FastAPI ETL  -> CSV / validation -> PostgreSQL
```

## 3. Organisation du dépôt

### Racine

- `README.md` : vue d'ensemble du projet
- `docker-compose.yml` : orchestration des services
- `package.json` : dépendances partagées au niveau racine
- `dataset.sql` : données ou script de jeu de données

### `healthAI-backend-API/`

API REST principale en Node.js / Express.

### `healthAI-backend-ETL/`

API FastAPI et scripts Python pour l'extraction, la transformation et le chargement de données.

### `healthAI-frontend/`

Application Angular standalone avec pages métier et administration.

### `healthAI-database/`

Script SQL d'initialisation PostgreSQL.

### `healthAI-config/`

Fichiers de déploiement, synchronisation et documentation d'exploitation.

### `healthAI-monitoring/`

Documentation de supervision et monitoring.

## 4. Backend API: fonctionnement

### 4.1 Point d'entrée

Le fichier `healthAI-backend-API/app.js` est le bootstrap de l'API.

Ce qu'il fait :

- instancie Express
- active `express.json()` pour lire les corps JSON
- expose Swagger sur `/api-docs`
- monte les routes métier sur les préfixes `/api/...`
- synchronise les modèles Sequelize au démarrage
- écoute sur le port `5000`

Concept important : l'API est organisée en couches, pas en logique monolithique. Les routes appellent des contrôleurs, les contrôleurs appellent des services, les services utilisent les modèles.

### 4.2 Connexion base de données

Le fichier `config/database.js` crée l'instance Sequelize à partir des variables d'environnement :

- `POSTGRES_DB`
- `POSTGRES_USER`
- `POSTGRES_PASSWORD`
- `POSTGRES_HOST`
- `POSTGRES_PORT`

Concepts clés :

- Sequelize est l'ORM
- le dialecte est `postgres`
- le logging SQL est désactivé par défaut

### 4.3 Modèles Sequelize

Le fichier `models/index.js` charge tous les modèles puis exécute leurs méthodes `associate` pour déclarer les relations.

Concept important : chaque fichier de modèle décrit une table, ses colonnes, ses contraintes et ses associations.

Exemples de modèles principaux :

- `User`
- `Company`
- `Subscription`
- `Recipe`
- `Ingredient`
- `SportProgram`
- `SportSession`
- `SportExercise`
- `SportEquipment`
- `UserHealthProfile`
- `UserBiometric`
- `SessionProgress`
- `Consume`
- tables de jointure relationnelles comme `ProgramSportSession`, `RecipeIngredient`, `SportSessionExercise`, `SportExerciseEquipment`

### 4.4 Authentification côté backend

L'authentification repose sur :

- `bcryptjs` pour le hachage des mots de passe
- `jsonwebtoken` pour produire un token JWT

Le flux est le suivant :

1. `register` hache le mot de passe puis crée l'utilisateur.
2. `login` recherche l'utilisateur par email.
3. Le mot de passe fourni est comparé au hash stocké.
4. Si la vérification réussit, un JWT est généré avec l'id utilisateur.

Le contrôleur d'authentification se trouve dans `controllers/auth.controller.js` et la logique métier dans `services/auth.service.js`.

### 4.5 Contrôleurs

Les contrôleurs jouent le rôle de couche HTTP.

Le schéma typique est :

- lire les paramètres `req.params`, `req.body` ou `req.query`
- appeler le service métier
- retourner un code HTTP et un JSON
- gérer les erreurs avec un `try/catch`

Exemples de contrôleurs :

- `auth.controller.js`
- `user.controller.js`
- `company.controller.js`
- `recipe.controller.js`
- `ingredient.controller.js`
- `sportProgram.controller.js`
- `sportSession.controller.js`
- `sportExercise.controller.js`
- `sessionProgress.controller.js`
- `consume.controller.js`
- `analytics.controller.js`

### 4.6 Services

Les services concentrent la logique métier et l'accès aux modèles.

Ils servent à :

- créer, lire, mettre à jour, supprimer des données
- gérer les relations entre entités
- encapsuler la logique de validation ou de transformation
- éviter de dupliquer du code dans les contrôleurs

Services principaux observés :

- `auth.service.js`
- `user.service.js`
- `company.service.js`
- `subscription.service.js`
- `recipe.service.js`
- `ingredient.service.js`
- `consume.service.js`
- `sportProgram.service.js`
- `sportSession.service.js`
- `sportExercise.service.js`
- `sportEquipment.service.js`
- `sessionProgress.service.js`
- `sessionExercise.service.js`
- `programSession.service.js`
- `recipeIngredient.service.js`
- `exerciseEquipment.service.js`
- `userBiometric.service.js`
- `userHealthProfile.service.js`
- `userAllergy.service.js`
- `db.service.js`
- `import.service.js`

### 4.7 Routes HTTP backend

Les routes Express définissent les URL publiques de l'API.

Routes montées dans `app.js` :

- `/api/auth`
- `/api/users`
- `/api/companies`
- `/api/subscriptions`
- `/api/recipes`
- `/api/ingredients`
- `/api/sport-programs`
- `/api/sport-sessions`
- `/api/sport-exercises`
- `/api/sport-equipment`
- `/api/user-health-profiles`
- `/api/user-biometrics`
- `/api/user-allergies`
- `/api/session-progress`
- `/api/consumes`
- `/api/program-sessions`
- `/api/session-exercises`
- `/api/recipe-ingredients`
- `/api/exercise-equipment`
- `/api/analytics`
- `/api/import`
- `/` pour le check simple `API OK`

### 4.8 Inventaire métier des routes backend

| Route | Rôle |
|---|---|
| `auth.routes.js` | Connexion et inscription |
| `user.routes.js` | CRUD des utilisateurs |
| `company.routes.js` | CRUD des entreprises |
| `subscription.route.js` | Gestion des abonnements |
| `recipe.routes.js` | CRUD recettes |
| `ingredient.routes.js` | CRUD ingrédients |
| `sportProgram.routes.js` | CRUD programmes sportifs |
| `sportSession.routes.js` | CRUD séances |
| `sportExercise.routes.js` | CRUD exercices |
| `sportEquipment.routes.js` | CRUD matériel |
| `userHealthProfile.routes.js` | Profils de santé |
| `userBiometric.routes.js` | Biométrie utilisateur |
| `userAllergy.routes.js` | Allergies utilisateur |
| `sessionProgress.routes.js` | Suivi de progression |
| `consume.routes.js` | Consommation alimentaire |
| `programSession.routes.js` | Relations programme -> séances |
| `sessionExercise.routes.js` | Relations séance -> exercices |
| `recipeIngredient.routes.js` | Relations recette -> ingrédients |
| `exerciseEquipment.routes.js` | Relations exercice -> matériel |
| `analytics.routes.js` | Indicateurs admin |
| `import.routes.js` | Import de fichiers ou données |
| `db.route.js` | Santé ou contrôles base |

### 4.9 Relations de données importantes

Le projet repose sur plusieurs relations structurantes :

- un utilisateur peut appartenir à un programme sportif
- un utilisateur peut appartenir à une entreprise
- une recette contient plusieurs ingrédients via `RecipeIngredient`
- un programme sportif contient plusieurs séances via `ProgramSportSession`
- une séance contient plusieurs exercices via `SportSessionExercise`
- un exercice peut avoir plusieurs équipements via `SportExerciseEquipment`
- un ingrédient peut avoir des allergies via `IngredientAllergy`

Concept important : les tables de jointure ne servent pas seulement à relier deux entités, elles portent souvent un attribut métier supplémentaire comme un rang ou une quantité.

## 5. Le modèle de données

### 5.1 Entités principales

- `User` : identité, rôle, coordonnées, poids, taille, email, mot de passe hashé
- `Company` : entreprise ou organisation
- `Subscription` : type d'abonnement
- `Recipe` : recette de nutrition
- `Ingredient` : aliment avec valeurs nutritionnelles
- `SportProgram` : programme sportif global
- `SportSession` : séance d'entraînement
- `SportExercise` : exercice individuel
- `SportEquipment` : matériel nécessaire
- `UserHealthProfile` : profil santé
- `UserBiometric` : poids, sommeil, pas, etc.
- `SessionProgress` : suivi d'une séance
- `Consume` : consommation alimentaire

### 5.2 Tables de liaison

- `ProgramSportSession`
- `RecipeIngredient`
- `SportSessionExercise`
- `SportExerciseEquipment`
- `UserSubscription`
- `SubscriptionAuthorization`
- `UserAllergy`
- `IngredientAllergy`

### 5.3 Exemple de champs importants

Le modèle `User` contient notamment :

- `user_id`
- `user_username`
- `user_lastname`
- `user_firstname`
- `user_birth`
- `user_role`
- `user_gender`
- `user_city`
- `user_country`
- `user_phone`
- `user_size`
- `user_weight`
- `user_hashpwd`
- `user_inscription`
- `sport_program_id`
- `company_id`

Le modèle `Ingredient` contient par exemple :

- nom
- type d'aliment
- énergie pour 100 g
- protéines, glucides, lipides, fibres, sucres, sel, graisses saturées

Le modèle `SportProgram` contient :

- nom
- objectif
- nombre de séances
- durée
- actif ou non

## 6. Frontend Angular: principes généraux

### 6.1 Architecture Angular utilisée

Le frontend utilise Angular moderne avec :

- composants standalone
- routing déclaratif
- `signals` pour l'état local
- `computed` pour dériver l'affichage
- `input()` et `output()` pour les composants réutilisables
- `HttpClient` pour les appels API
- Angular Material pour l'interface
- `Router` et `RouterLink` pour la navigation
- `BreakpointObserver` pour le responsive

Concept important : le frontend ne suit pas une architecture basée sur des modules lourds. Il s'appuie sur les composants standalone et sur des services injectés.

### 6.2 Bootstrap visuel de l'application

Le point d'entrée du frontend est le composant racine `App`.

Ce composant gère :

- le shell global
- la barre d'outils
- la sidebar
- le menu mobile
- l'affichage ou la suppression du shell sur les pages d'auth/onboarding
- l'état admin ou utilisateur courant

### 6.3 Shell d'application

Le template du shell est dans `app.html`.

Il contient :

- un skip-link vers le contenu principal
- une toolbar principale
- un `mat-sidenav-container`
- une sidebar desktop
- un contenu principal avec `router-outlet`
- une navigation basse pour mobile

Concept important : le shell se masque sur certaines routes comme `login`, `register`, `welcome`, `splash` et les écrans d'onboarding.

### 6.4 Réactivité et état local

Le composant `App` utilise :

- `signal` pour `sidenavOpened`, `isMobile`, `showShell`, `isAdmin`
- `computed` pour le titre de toolbar et le menu courant
- `BreakpointObserver` pour détecter les mobiles
- les événements `NavigationEnd` pour savoir sur quelle route on se trouve

Concept important : les signaux remplacent beaucoup de logique d'état manuel et simplifient l'UI réactive.

### 6.5 Navigation mobile et desktop

Le frontend distingue :

- une navigation latérale pour desktop
- une bottom nav pour mobile utilisateur
- un mode admin qui change la structure du menu

Le menu admin et le menu utilisateur sont deux ensembles différents de `MenuItem`.

## 7. Inventaire des composants frontend

### 7.1 Pages d'authentification et d'onboarding

| Composant | Rôle |
|---|---|
| `SplashComponent` | Écran d'accueil initial |
| `WelcomeComponent` | Présentation ou orientation |
| `LoginComponent` | Connexion par email/mot de passe |
| `RegisterComponent` | Création de compte |
| `LostAccountComponent` | Récupération de compte |
| `OnboardingRoleComponent` | Choix du rôle |
| `OnboardingNameComponent` | Saisie des informations de base |
| `OnboardingPersonalComponent` | Données personnelles |
| `OnboardingMetricsComponent` | Mesures et métriques |
| `OnboardingGoalComponent` | Objectif de santé/sport |
| `OnboardingCompanyContactComponent` | Contact entreprise |

### 7.2 Pages utilisateur

| Composant | Rôle |
|---|---|
| `HomeComponent` | Accueil utilisateur |
| `RecipesComponent` | Liste des recettes |
| `RecipeDetailComponent` | Détail d'une recette |
| `IngredientsComponent` | Liste des ingrédients |
| `ProfileComponent` | Profil de l'utilisateur |
| `ConsultantProfileComponent` | Profil consultant ou professionnel |
| `BiometricsComponent` | Suivi biométrique |
| `SportProgramsComponent` | Liste des programmes sportifs |
| `ProgramDetailComponent` | Détail d'un programme |
| `SportSessionsComponent` | Liste des séances |
| `SessionDetailComponent` | Détail d'une séance |
| `ExercisesComponent` | Liste des exercices |
| `EquipmentComponent` | Liste du matériel |

### 7.3 Administration

| Composant | Rôle |
|---|---|
| `AdminDashboardComponent` | Dashboard principal admin |
| `AdminUsersListComponent` | Liste des utilisateurs |
| `AdminUserDetailComponent` | Détail d'un utilisateur |
| `UserMetricsComponent` | Métriques utilisateurs |
| `NutritionComponent` | Analyses nutritionnelles |
| `FitnessComponent` | Statistiques fitness |
| `KpiComponent` | KPIs business |
| `DataCheckingPageComponent` | Contrôle qualité des données |
| `AdminManageComponent` | CRUD générique des données |
| `EtlNutritionComponent` | Pilotage ETL nutrition |
| `EtlExerciseComponent` | Pilotage ETL exercices |

### 7.4 Composants partagés et réutilisables

| Composant | Rôle |
|---|---|
| `SidebarComponent` | Navigation réutilisable |
| `AdminEntityTableComponent` | Tableau CRUD générique |
| `RelationEditorComponent` | Éditeur de relations métier |
| `RecipesGridComponent` | Grille de recettes |
| `RecipeCategoryCarouselComponent` | Sélection de catégorie recette |

## 8. Services frontend

### 8.1 `ApiService`

`ApiService` centralise la communication HTTP avec le backend.

Il joue plusieurs rôles :

- exposer les appels auth
- exposer les appels CRUD utilisateur
- exposer les listes métier
- exposer les endpoints de détails
- exposer les endpoints de relations entre entités
- exposer les analytics admin
- exposer l'import de fichiers SQL

Concepts importants :

- il utilise `Observable` et `HttpClient`
- il normalise certains objets reçus du backend pour le besoin de l'UI
- il contient une table de correspondance entre noms métier et routes backend

Exemples de normalisation côté front :

- les ingrédients sont transformés en `food_*`
- les exercices sont transformés en champs lisibles par les vues
- les programmes, séances et recettes sont enrichis avec leurs relations pour le détail

### 8.2 `AuthService`

`AuthService` gère l'état d'authentification courant.

Il fournit :

- `login`
- `register`
- `logout`
- `isLoggedIn`
- mise à jour du profil courant
- mise à jour du prénom et du rôle

Concepts importants :

- il stocke l'utilisateur courant dans `localStorage`
- il expose l'utilisateur courant via un `signal`
- il extrait l'id utilisateur à partir du JWT
- il tente de récupérer le profil complet après login

### 8.3 Services ETL côté front

Les pages admin ETL utilisent :

- `EtlNutritionService`
- `EtlExerciseService`

Ils appellent le backend FastAPI sur `http://localhost:8000`.

Fonctionnement :

- extraction / transformation des données
- lecture des CSV générés
- sauvegarde des CSV traités
- chargement en base

### 8.4 Guard d'administration

`adminOnlyGuard` protège les routes admin.

Logique :

- si aucun utilisateur n'est connecté, redirection vers `/login`
- si le rôle est `admin`, accès autorisé
- sinon redirection vers `/recipes`

Concept important : c'est un garde de navigation côté client, pas une sécurité serveur. Il améliore l'UX, mais le backend doit rester la vraie barrière de sécurité.

## 9. Fonctionnement des pages majeures du frontend

### 9.1 Authentification

`LoginComponent` et `RegisterComponent` suivent une logique simple :

- récupération des champs saisis
- validation minimale côté interface
- appel à `AuthService`
- navigation après succès
- message d'erreur en cas d'échec

Concepts utilisés :

- `FormsModule`
- `MatFormFieldModule`
- `MatInputModule`
- `MatButtonModule`
- `MatIconModule`

### 9.2 Administration dynamique

`AdminManageComponent` est un des composants les plus importants du projet.

Il sert de CRUD générique pour plusieurs entités :

- recettes
- ingrédients
- programmes
- séances
- exercices
- matériel

Il repose sur une configuration centralisée dans `admin-manage.config.ts`.

Concepts clés :

- onglets configurables
- colonnes dynamiques
- édition inline
- suppression
- snackbars pour les retours utilisateur
- rechargement global des données
- gestion des relations via un éditeur dédié

### 9.3 Table CRUD générique

`AdminEntityTableComponent` reçoit :

- les colonnes
- les lignes
- la clé d'identité
- l'état d'édition

Il décide :

- quelles colonnes sont modifiables
- comment afficher les booléens
- comment rendre les champs de saisie
- quand lancer les événements parent

### 9.4 Éditeur de relations

`RelationEditorComponent` gère les relations métier entre entités.

Cas supportés :

- programme -> séances
- recette -> ingrédients
- séance -> exercices
- exercice -> matériel

Concepts importants :

- les relations peuvent porter un rang
- les ingrédients portent une quantité
- certaines relations sont strictement ordonnées
- l'éditeur charge les éléments disponibles selon le contexte
- les relations déjà existantes sont affichées et éditables

## 10. Routeur frontend

Le routing central est défini dans `app.routes.ts`.

### 10.1 Routes d'accès public et onboarding

- `/` -> `SplashComponent`
- `/welcome` -> `WelcomeComponent`
- `/login` -> `LoginComponent`
- `/register` -> `RegisterComponent`
- `/onboarding/role`
- `/onboarding/name`
- `/onboarding/personal`
- `/onboarding/metrics`
- `/onboarding/goal`
- `/onboarding/company-contact`
- `/lost-account`

### 10.2 Routes métier utilisateur

- `/home`
- `/recipes`
- `/recipes/:id`
- `/ingredients`
- `/profile`
- `/consultant`
- `/biometrics`
- `/sport-programs`
- `/sport-programs/:id`
- `/sport-sessions`
- `/sport-sessions/:id`
- `/exercises`
- `/equipment`

### 10.3 Routes admin

- `/admin`
- `/admin/user-list`
- `/admin/users/:id`
- `/admin/user-metrics`
- `/admin/nutrition`
- `/admin/fitness`
- `/admin/kpi`
- `/admin/data-check`
- `/admin/etl/nutrition`
- `/admin/etl/exercise`
- `/admin/manage`

Concept important : les routes admin sont protégées par `adminOnlyGuard`.

## 11. RGAA et accessibilité

Le projet possède une vraie documentation d'accessibilité dans :

- `ACCESSIBILITY_GUIDE.md`
- `ACCESSIBILITY_IMPROVEMENTS.md`
- `ACCESSIBILITY_CHECKLIST.md`

### 11.1 Principes appliqués

- privilégier le HTML sémantique avant ARIA
- garder un focus visible
- permettre l'utilisation au clavier
- associer un label à chaque champ de formulaire
- fournir des textes alternatifs aux images
- ne pas transmettre l'information uniquement par la couleur
- garantir un bon contraste des textes et états
- rendre les cibles tactiles suffisamment grandes
- tester le zoom jusqu'à 200 %

### 11.2 Éléments RGAA visibles dans le code

Dans le shell Angular :

- skip-link vers le contenu principal
- `role="banner"` sur la toolbar
- `role="main"` sur le conteneur principal
- navigation explicite avec `aria-label`

Dans la sidebar :

- `nav` sémantique
- `aria-current="page"` sur l'entrée active
- icônes marquées `aria-hidden="true"`
- logo avec `alt` descriptif

Dans les formulaires de login et registration :

- `mat-label`
- indication des champs requis
- `aria-required="true"`
- messages d'erreur annoncés via `role="alert"`
- association visuelle et sémantique entre champ et erreur

### 11.3 Concepts RGAA importants à retenir

- le RGAA n'est pas seulement du CSS, c'est une conception complète de la navigation et des interactions
- l'ARIA doit rester ponctuelle et justifiée
- les utilisateurs clavier doivent pouvoir tout faire sans souris
- les lecteurs d'écran doivent lire un contenu logique et compréhensible
- le contraste et le focus sont des critères critiques, pas des détails visuels

## 12. ETL: extraction, transformation, chargement

Le backend ETL se trouve dans `healthAI-backend-ETL/`.

### 12.1 Rôle du backend ETL

Il sert à :

- récupérer des données externes
- les nettoyer et les transformer
- produire des CSV valides et invalides
- charger les données validées en base PostgreSQL

### 12.2 Fichiers clés

- `api.py` : API FastAPI
- `etl.py` : orchestrateur principal
- `etl_ingredient.py` : traitement des ingrédients
- `etl_exercise.py` : traitement des exercices
- `etl_load.py` : chargement en base
- `requirements.txt` : dépendances Python
- fichiers CSV de test et de validation

### 12.3 Endpoints ETL

- `POST /etl/extract-transform`
- `POST /etl/extract-transform/ingredient`
- `POST /etl/extract-transform/exercise`
- `POST /etl/load-to-db`
- `POST /etl/load-to-db/ingredient`
- `POST /etl/load-to-db/exercise`
- `GET /csv`
- `GET /csv/ingredient`
- `GET /csv/exercise`
- `GET /health`

Concepts importants :

- extraction et transformation peuvent être lancées globalement ou par domaine
- les CSV servent de zone intermédiaire entre l'external API et la base
- les fichiers invalides permettent l'audit des rejets

## 13. Base PostgreSQL

La base initiale est définie dans `healthAI-database/init.sql`.

### 13.1 Ce qu'elle contient

- les tables métier
- les enums métiers
- les clés étrangères
- des données de démonstration

### 13.2 Enums métier

Les enums structurent les domaines suivants :

- rôles utilisateur
- genres
- objectifs sport/santé
- niveaux de difficulté
- types de recettes
- niveaux d'activité
- régimes alimentaires

Concept important : ces enums stabilisent le modèle de données et évitent les valeurs libres incohérentes.

## 14. Configuration, Docker et déploiement

### 14.1 Configuration centrale

`healthAI-config/` documente le déploiement de la stack.

Il y a notamment :

- la description des variables d'environnement
- les instructions Docker Compose
- le script de synchronisation `git_pull_all.py`

### 14.2 Ports usuels

- frontend Angular : `4200`
- API Express : `5000`
- backend ETL FastAPI : `8000`
- PostgreSQL : `5432`
- Grafana / monitoring : `3000` selon la stack décrite

### 14.3 Variables d'environnement importantes

- `POSTGRES_DB`
- `POSTGRES_USER`
- `POSTGRES_PASSWORD`
- `POSTGRES_HOST`
- `POSTGRES_PORT`
- `POSTGRES_URL`
- `JWT_SECRET`
- `NODE_ENV`

## 15. Monitoring

Le dossier `healthAI-monitoring/` contient la documentation de supervision.

Le README est encore minimal, donc il faut le lire comme un espace prévu pour la stack d'observabilité plutôt qu'un module déjà détaillé.

## 16. Concepts techniques essentiels à connaître

### 16.1 Angular et TypeScript

- composants standalone
- modules Angular Material
- routes et route guards
- signals et computed
- `input()` / `output()`
- `Observable` pour l'HTTP
- gestion responsive via BreakpointObserver

### 16.2 Backend Node.js

- Express pour les routes HTTP
- séparation contrôleur / service / modèle
- Sequelize comme ORM
- JWT pour l'auth
- bcrypt pour le hash des mots de passe

### 16.3 Architecture métier

- entités de référence et tables de liaison
- cardinalités un-à-plusieurs et plusieurs-à-plusieurs
- enrichissement des réponses pour l'UI
- conservation de l'ordre via des rangs dans certaines relations

### 16.4 Qualité et accessibilité

- RGAA AA
- contraste suffisant
- navigation clavier
- compatibilité lecteur d'écran
- responsive mobile

### 16.5 ETL et data quality

- ingestion externe
- validation
- séparation des fichiers valides et invalides
- chargement contrôlé en base

## 17. Points de vigilance et dette technique

- plusieurs composants sont très proches les uns des autres et suivent des patterns répétitifs ; cela simplifie la maintenance, mais demande de garder une cohérence de nommage et de mapping
- le frontend dépend fortement de la forme des objets renvoyés par l'API, d'où l'importance des fonctions de normalisation dans `ApiService`
- certaines pages admin reposent sur de la configuration dynamique ; une erreur dans les clés de colonnes ou d'identifiants casse vite l'édition
- le backend ETL est appelé directement sur `localhost:8000` depuis le frontend admin, ce qui suppose un environnement local ou un proxy correctement configuré
- la qualité du projet dépend beaucoup de la cohérence entre les modèles Sequelize, les routes et le schéma SQL d'initialisation

## 18. Résumé ultra court

En pratique, HealthAI fonctionne comme ceci :

- Angular affiche les pages, gère l'UX, la navigation, le responsive et l'accessibilité
- Express fournit les endpoints métier
- Sequelize mappe les tables PostgreSQL
- FastAPI alimente la base via ETL
- RGAA garantit que le frontend reste utilisable par tous

Si tu veux continuer, la meilleure suite est de transformer ce guide en documentation plus vivante avec des schémas par écran, ou en une version encore plus détaillée qui explique chaque composant une fois avec son fichier source précis.