# Glossaire — HealthAI Coach

> **Projet** : HealthAI Coach — MSPR TPRE601  
> **Équipe** : Mathis Morales · Arnaud Goldberg · Hugo Lembrez · Mathilde Ageron  
> **Année** : 2025-2026 — EPSI, Certification CDA 3ème année

---

## A

**API (Application Programming Interface)**  
Interface permettant à deux applications de communiquer entre elles via des requêtes HTTP. Dans HealthAI Coach, plusieurs APIs sont exposées : l'API principale Node.js/Express (port 5000), l'API ETL (port 8000), le service nutrition (port 8001) et le service exercices (port 8002).

**API REST**  
Style d'architecture d'API reposant sur le protocole HTTP et les méthodes standard (GET, POST, PUT, DELETE). L'ensemble des services backend de HealthAI Coach exposent des API REST documentées via Swagger/OpenAPI.

**ARIA (Accessible Rich Internet Applications)**  
Ensemble d'attributs HTML permettant d'améliorer l'accessibilité des interfaces web pour les utilisateurs de technologies d'assistance (lecteurs d'écran). Utilisés dans le frontend Angular pour la conformité RGAA AA (`aria-label`, `aria-current`, `aria-live`, etc.).

**asyncpg**  
Bibliothèque Python asynchrone haute performance pour la connexion à PostgreSQL. Utilisée par le service exercices pour interroger la base de données relationnelle.

---

## B

**Backend**  
Partie serveur d'une application web, invisible pour l'utilisateur final. Gère la logique métier, les accès aux bases de données et l'exposition des APIs. HealthAI Coach dispose de quatre services backend : API principale, ETL, service nutrition et service exercices.

**bcrypt**  
Algorithme de hachage cryptographique utilisé pour stocker les mots de passe de façon sécurisée. Dans HealthAI Coach, les mots de passe utilisateurs sont hachés via bcrypt avant stockage dans le champ `user_hashpwd` de PostgreSQL.

**Bucket (MinIO)**  
Espace de stockage logique au sein de MinIO, équivalent à un dossier racine. HealthAI Coach utilise trois buckets : `avatars`, `photos` et `videos`.

---

## C

**cAdvisor (Container Advisor)**  
Outil Google qui collecte les métriques propres aux conteneurs Docker : disponibilité, nombre de restarts et état des services. Les données sont scrappées par Prometheus dans le monitoring HealthAI Coach.

**CDA (Concepteur Développeur d'Applications)**  
Titre professionnel de niveau 6 (Bac+3/4) délivré par le Ministère du Travail. HealthAI Coach est le projet fil rouge de la 3ème année de cette certification à l'EPSI.

**CI/CD (Continuous Integration / Continuous Deployment)**  
Pratique DevOps consistant à automatiser les phases de build, test et déploiement du code source. Dans HealthAI Coach, la CI/CD est implémentée via GitHub Actions avec trois jobs : `build`, `linter` et `test`.

**conteneur (Docker)**  
Unité d'exécution légère et isolée encapsulant une application et toutes ses dépendances. La stack HealthAI Coach orchestre 10 conteneurs distincts via Docker Compose.

---

## D

**Docker**  
Plateforme de conteneurisation permettant d'empaqueter une application avec son environnement d'exécution. Toute l'infrastructure HealthAI Coach est conteneurisée via Docker.

**Docker Compose**  
Outil permettant de définir et d'orchestrer plusieurs conteneurs Docker via un fichier YAML (`docker-compose.yml`). HealthAI Coach propose trois configurations : normale, offline et performance.

**Docker Hub**  
Registre public d'images Docker. Les images HealthAI Coach sont publiées sous le namespace `hugol34`.

---

## E

**ENUM (PostgreSQL)**  
Type de données PostgreSQL permettant de définir une liste de valeurs autorisées. La base HealthAI Coach définit 12 types ENUM (`user_role_enum`, `gender_enum`, `objective_enum`, `difficulty_enum`, etc.).

**ETL (Extract, Transform, Load)**  
Pipeline de traitement de données en trois étapes : extraction depuis les sources, transformation/nettoyage, puis chargement en base. Le service ETL de HealthAI Coach collecte les données depuis OpenFoodFacts, Wger et USDA FoodData Central.

**Express**  
Framework web minimaliste pour Node.js. Utilisé pour l'API REST principale de HealthAI Coach (port 5000), retenu pour sa légèreté et son modèle asynchrone non bloquant (14 100 req/s en benchmark).

---

## F

**FastAPI**  
Framework web Python moderne et asynchrone. Utilisé pour les services ETL (port 8000), nutrition (port 8001) et exercices (port 8002). Retenu pour sa validation Pydantic native, sa documentation Swagger automatique et ses performances (12 400 req/s en benchmark).

**flake8**  
Outil d'analyse statique Python vérifiant la conformité du code aux règles PEP8. Intégré dans la pipeline CI/CD de HealthAI Coach, avec une tolérance de longueur de ligne fixée à 200 caractères.

**Flutter**  
Framework Google de développement d'applications mobiles cross-platform (iOS/Android) basé sur le langage Dart. Utilisé pour l'application mobile HealthAI Coach permettant le partage de publications sociales.

**Food-101**  
Jeu de données de reconnaissance d'aliments contenant 101 classes de plats cuisinés. Le modèle Vision Transformer `nateraw/food` utilisé par le service nutrition est entraîné sur ce dataset.

**Frontend**  
Partie client d'une application web, visible et interactable par l'utilisateur. HealthAI Coach dispose d'une interface Angular (port 4200) avec dashboards administrateur et espace utilisateur.

---

## G

**Gemini 1.5 Flash**  
Grand modèle de langage (LLM) de Google AI. Utilisé dans le service exercices pour générer des programmes sportifs personnalisés structurés (JSON). Retenu pour son tier gratuit généreux (1 500 req/jour, 1M tokens/min) et son SDK Python officiel.

**GitHub Actions**  
Service d'intégration et déploiement continus intégré à GitHub. Utilisé dans HealthAI Coach pour automatiser les jobs de build, lint et test à chaque push ou pull request sur les branches `dev` et `main`.

**Grafana**  
Plateforme open-source de visualisation et de monitoring. Dans HealthAI Coach, Grafana Cloud (SaaS) centralise les métriques Prometheus et les logs Loki, exposant des dashboards d'observabilité.

**Grafana Alloy**  
Agent de collecte installé en binaire système (systemd) sur l'hôte. Il scrape les métriques Prometheus et les transmet vers Grafana Cloud. Remplace le précédent agent PDC dans la MSPR 3.

**Grafana Cloud**  
Offre SaaS de Grafana hébergeant le stockage des métriques, les dashboards et le moteur d'alerting. Utilisée dans HealthAI Coach pour éviter l'hébergement d'une infrastructure de monitoring dédiée.

---

## H

**Healthcheck (Docker)**  
Mécanisme Docker permettant de vérifier qu'un conteneur est opérationnel avant d'en démarrer les dépendants. Utilisé dans HealthAI Coach pour orchestrer le démarrage ordonné des services.

**Hugging Face**  
Plateforme communautaire hébergeant des modèles de machine learning. Le modèle `nateraw/food` (Vision Transformer) est téléchargé depuis Hugging Face et mis en cache dans le volume Docker `huggingface_cache`.

---

## I

**IaC (Infrastructure as Code)**  
Pratique consistant à définir l'infrastructure (conteneurs, réseaux, volumes) via des fichiers de configuration versionnés. Les fichiers `docker-compose.yml` de HealthAI Coach représentent l'IaC du projet.

---

## J

**Jasmine**  
Framework de tests unitaires JavaScript. Utilisé avec Karma pour les tests unitaires du frontend Angular HealthAI Coach (10 tests, 40,42% de couverture).

**JIRA**  
Outil de gestion de projet agile. Utilisé par l'équipe HealthAI Coach pour le suivi du backlog, l'organisation des sprints et le suivi des tickets via un tableau Kanban.

**JSON (JavaScript Object Notation)**  
Format d'échange de données léger et lisible par l'humain. Utilisé pour les réponses API REST et le stockage des plans de repas/programmes sportifs dans MongoDB.

**JWT (JSON Web Token)**  
Standard ouvert (RFC 7519) permettant de transmettre des informations de façon sécurisée entre parties sous forme de token signé. Utilisé dans HealthAI Coach pour l'authentification et l'autorisation des utilisateurs (contient `user_id` et `role`).

---

## K

**Karma**  
Environnement d'exécution de tests pour navigateurs. Utilisé conjointement avec Jasmine pour les tests unitaires du frontend Angular.

---

## L

**LLM (Large Language Model)**  
Grand modèle de langage entraîné sur d'importantes quantités de texte, capable de comprendre et générer du langage naturel. Dans HealthAI Coach, Gemini 1.5 Flash est le LLM retenu pour la génération de programmes sportifs.

**LogQL**  
Langage de requête de Loki pour filtrer et analyser les logs centralisés. Permet dans HealthAI Coach de rechercher les logs par labels Docker (`container_name`, `image`, `host`).

**Loki**  
Système de centralisation et d'indexation de logs développé par Grafana. Utilisé dans HealthAI Coach via le Loki Docker Driver Plugin pour agréger les logs de tous les conteneurs.

---

## M

**Machine Learning (ML)**  
Sous-domaine de l'intelligence artificielle permettant à un système d'apprendre à partir de données. HealthAI Coach utilise des modèles ML (Random Forest, scikit-learn) pour les recommandations nutritionnelles et sportives.

**MinIO**  
Serveur de stockage objet open-source compatible avec l'API Amazon S3. Utilisé dans HealthAI Coach pour stocker les médias utilisateurs (avatars, photos de repas, vidéos) via un reverse proxy Nginx.

**Mock / MOCK_MODE**  
Substitut simulant le comportement d'un composant réel (API externe, service IA) à des fins de tests ou de démo hors ligne. En mode `docker-compose_offline.yml`, les services exercices, nutrition et ETL passent en `MOCK_MODE=true`.

**MongoDB**  
Base de données NoSQL orientée documents. Utilisée dans HealthAI Coach pour stocker les plans de repas générés et les programmes sportifs personnalisés (structure flexible, collection `user_profiles`), ainsi que les publications sociales (`social_posts`).

**Mongoose**  
ODM (Object Document Mapper) Node.js pour MongoDB. Utilisé par l'API backend Express pour les interactions avec MongoDB.

**Motor**  
Client MongoDB asynchrone pour Python. Utilisé par les services nutrition et exercices pour les interactions avec MongoDB.

**MSPR (Mise en Situation Professionnelle Reconstituée)**  
Épreuve du titre CDA consistant en un projet fil rouge simulant des conditions professionnelles réelles. HealthAI Coach est développé sur trois MSPR successives.

**Multer S3**  
Middleware Node.js pour l'upload de fichiers directement vers un stockage S3 (MinIO dans HealthAI Coach). Intégré dans l'API backend Express.

---

## N

**Nginx**  
Serveur web et reverse proxy haute performance. Utilisé dans HealthAI Coach comme proxy et cache devant MinIO (ports 80/443) et comme serveur du frontend Angular (port 4200).

**node-exporter**  
Exporteur Prometheus exposant les métriques système d'un hôte Linux (CPU, mémoire, disque, réseau). Intégré dans le monitoring HealthAI Coach.

**Node.js**  
Environnement d'exécution JavaScript côté serveur basé sur le moteur V8 de Chrome. Utilisé pour l'API backend principale de HealthAI Coach (version 22).

**NoSQL**  
Catégorie de systèmes de gestion de bases de données n'utilisant pas le modèle relationnel. MongoDB est la base NoSQL de HealthAI Coach.

---

## O

**OpenAPI / Swagger**  
Standard de description des APIs REST. FastAPI génère automatiquement une documentation Swagger interactive pour chaque service Python de HealthAI Coach.

**OpenFoodFacts**  
Base de données collaborative et open-source sur les produits alimentaires. Source de données pour le pipeline ETL de HealthAI Coach (ingrédients).

---

## P

**Pandas**  
Bibliothèque Python de manipulation et d'analyse de données. Utilisée dans le service ETL pour le nettoyage et la transformation des données nutritionnelles et sportives. Retenue pour ses performances sur les volumes < 5 Go (8,7 s pour lire un CSV de 5M lignes).

**PDC Agent (Private Data Connect)**  
Agent Grafana permettant de connecter un environnement local à Grafana Cloud. Présent dans les configurations Docker de HealthAI Coach (remplacé par Grafana Alloy dans la MSPR 3).

**PEP8**  
Guide de style de la communauté Python définissant des conventions d'écriture du code. La pipeline CI/CD HealthAI Coach vérifie la conformité PEP8 via flake8.

**Playwright**  
Framework de tests end-to-end multi-navigateurs (Chromium, Firefox, WebKit). Utilisé pour les 15 tests E2E du frontend Angular HealthAI Coach (5 scénarios × 3 navigateurs).

**PostgreSQL**  
Système de gestion de bases de données relationnelles open-source. Base de données principale de HealthAI Coach (version 15-alpine, port 5432), composée de 15 tables et 12 types ENUM, normalisée en 3NF.

**Prometheus**  
Système de monitoring et d'alerte open-source collectant des métriques au format time-series. Utilisé dans HealthAI Coach pour scraper les métriques des conteneurs et de l'hôte.

**Pydantic**  
Bibliothèque Python de validation de données basée sur les annotations de types. Intégrée nativement dans FastAPI pour valider les requêtes et réponses des APIs des services ETL, nutrition et exercices.

**PyTorch**  
Framework de machine learning Python développé par Meta. Utilisé par le service nutrition pour l'inférence du modèle Vision Transformer `nateraw/food` (~2 Go de RAM).

**pytest**  
Framework de tests Python. Utilisé dans HealthAI Coach pour les tests du service ETL (112 tests, 86% de couverture) et du service nutrition (5 tests, 56% de couverture).

---

## R

**Random Forest**  
Algorithme d'ensemble learning basé sur de multiples arbres de décision. Utilisé dans le service nutrition pour prédire le type de déséquilibre nutritionnel d'un repas selon sa composition et l'objectif utilisateur.

**React Native / Expo**  
Framework de développement d'applications mobiles cross-platform basé sur React. *Initialement considéré, remplacé par Flutter* pour l'application mobile HealthAI Coach.

**RGAA (Référentiel Général d'Amélioration de l'Accessibilité)**  
Standard français d'accessibilité numérique basé sur les WCAG. Le frontend Angular de HealthAI Coach vise la conformité RGAA niveau AA avec Angular Material.

**RPS (Requests Per Second)**  
Nombre de requêtes traitées par seconde, indicateur clé de performance d'une API.

---

## S

**S3 (Simple Storage Service)**  
Protocole de stockage objet d'Amazon. MinIO est un serveur compatible S3 utilisé dans HealthAI Coach pour stocker les médias sans dépendance à AWS.

**scikit-learn**  
Bibliothèque Python de machine learning fournissant des outils simples et efficaces pour l'analyse de données. Utilisée dans les services nutrition (Random Forest) et exercices (modèle de scoring).

**Scrum**  
Méthodologie agile de gestion de projet basée sur des itérations courtes (sprints). L'équipe HealthAI Coach a structuré ses trois MSPR selon cette méthodologie, avec JIRA comme outil de suivi.

**Sequelize**  
ORM (Object-Relational Mapper) Node.js pour les bases de données SQL. Utilisé par l'API backend Express pour les interactions avec PostgreSQL.

**SQLAlchemy**  
ORM Python pour les bases de données SQL. Utilisé par les services ETL et nutrition pour les interactions avec PostgreSQL.

---

## T

**3NF (Troisième Forme Normale)**  
Niveau de normalisation d'une base de données relationnelle éliminant les redondances et les dépendances transitives. La base PostgreSQL de HealthAI Coach est normalisée en 3NF avec 15 tables.

**TypeScript**  
Sur-ensemble typé de JavaScript compilé en JavaScript standard. Langage principal du frontend Angular et de l'API backend Node.js/Express de HealthAI Coach.

---

## U

**USDA FoodData Central**  
Base de données nutritionnelles officielle du Département de l'Agriculture américain. Source des valeurs nutritionnelles utilisées par le service nutrition HealthAI Coach (via API avec clé gratuite).

**Uvicorn**  
Serveur ASGI (Asynchronous Server Gateway Interface) Python haute performance. Utilisé pour exécuter les services FastAPI de HealthAI Coach.

---

## V

**ViT (Vision Transformer)**  
Architecture de modèle de deep learning basée sur le mécanisme d'attention, adaptée à la vision par ordinateur. Le modèle `nateraw/food` utilisé dans le service nutrition est un ViT entraîné sur Food-101 (101 classes d'aliments).

**Volume Docker**  
Mécanisme de persistance des données pour les conteneurs Docker. HealthAI Coach utilise 6 volumes persistants : `postgres_data`, `grafana_data`, `mongodb_data`, `huggingface_cache`, `minio_data`, `nginx_cache`.

---

## W

**Wger**  
API open-source fournissant une base de données d'exercices physiques. Source de données pour le pipeline ETL HealthAI Coach (exercices sportifs).

---

*Glossaire établi sur la base de la documentation technique du projet HealthAI Coach (MSPR 1, 2 & 3).*
