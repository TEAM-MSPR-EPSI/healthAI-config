# healthAI-config

Guide de déploiement — healthAI

Ce document décrit, pas à pas, comment déployer l'ensemble de la solution healthAI en conteneurs Docker, vérifier l'état des services, initialiser la base de données, sauvegarder et restaurer.

## Structure de déploiement

À la racine du dépôt, vous devez avoir les fichiers utilisés par Docker Compose :

- `docker-compose.yml` : orchestration des services.
- `.env` : variables d'environnement réelles pour l'exécution.

Voici les fichiers complémentaires présents dans le dossier healthAI-config :

- `.env.example` : modèle de variables à copier dans le `.env` à la racine.
- `git_pull_all.py` : script pour mettre à jour tous les dépôts et copier le fichier docker-compose.yml à la racine.

Le dossier `healthAI-config` sert donc de référentiel de configuration, mais le déploiement se lance depuis la racine du projet.

## 1. Prérequis

- Docker
- Docker Compose
- Python (pour `git_pull_all.py` si utilisé localement)
- Accès réseau aux services externes nécessaires à la supervision

Vérifier les versions :

```bash
docker --version
docker compose version
python --version
```

Liens d'installation rapides :

- Docker Desktop (Windows / macOS) : https://www.docker.com/products/docker-desktop
- Docker Engine & Compose (Linux) : https://docs.docker.com/engine/install/
- docker-compose (cli v2) docs : https://docs.docker.com/compose/

## 2. Variables d'environnement

Créez un fichier `.env` à la racine du dépôt à partir de `healthAI-config/.env.example`.

```env
# Postgres
POSTGRES_DB=db_name
POSTGRES_USER=db_user
POSTGRES_PASSWORD=db_password
POSTGRES_HOST=db_host
POSTGRES_PORT=db_port
POSTGRES_URL=postgresql://db_user:db_password@db_host:db_port/db_name

# JWT
JWT_SECRET=java_web_token,

# Options applicatives
NODE_ENV=development
```

Important : le `docker-compose.yml` racine lit le `.env` racine pour `database`.  
Le service `etl_backend` lit son propre fichier `healthAI-backend-ETL/.env`.  
Le service `api_backend` lit son propre fichier `healthAI-backend-API/.env`.

## 3. Récupérer le code

Le dépôt principal contient plusieurs services en sous-dossiers. Depuis la racine du dépôt :

```bash
# si vous n'avez pas encore cloné
git clone repo_url
cd nom_repo

# mettre à jour tous les sous-dépôts (optionnel)
python git_pull_all.py
```

## 4. Construction et démarrage (environnement local / staging)

1. Placer un `.env` valide à la racine du dépôt et exécuter cette commande :

```bash
docker compose build
```

2. Démarrer les services :

```bash
docker compose up -d
```

3. Vérifier le statut :

```bash
docker compose ps
docker compose logs -f api_backend
```

Remarques:
- Si vous utilisez `docker-compose` (ancienne CLI), remplacez `docker compose` par `docker-compose`.
- Les variables de ports sont exposées depuis `docker-compose.yml`.

## 5. Initialisation de la base de données

La base est déjà branchée dans le `docker-compose.yml` racine.  
Le fichier `healthAI-database/init.sql` est monté automatiquement au démarrage du conteneur Postgres.

Il n'y a rien à créer ni à lancer manuellement pour l'initialisation.  
Vérifiez simplement que les variables de la base sont correctes dans le `.env` racine, puis démarrez la stack.

Si la base est déjà en service, laissez les données existantes en place et passez directement à la vérification du fonctionnement.

## 6. Volumes, persistance et sauvegardes

- Les volumes Docker sont déjà définis pour Postgres.
- En fonctionnement normal, vous n'avez rien à modifier.

## 7. Démarrage et vérification

Le déploiement courant se fait avec les fichiers déjà présents à la racine. L'utilisateur n'a pas à créer de dossier, ni à lancer de commande spéciale.

```bash
docker compose up -d
docker compose ps
docker compose logs -f
```

Vérification rapide :

```bash
curl http://localhost:5000/health
```

## 8. Réseau et accès

- Les services principaux exposent leurs ports habituels.
- L'accès se fait via l'URL de l'environnement fourni par l'équipe.
- L'utilisateur ne doit rien modifier dans l'infrastructure réseau.

## 9. Logs

- Pour consulter les logs :

```bash
docker compose logs -f
```

- Pour un service précis :

```bash
docker compose logs -f api_backend
docker compose logs -f frontend
docker compose logs -f etl_backend
```

## 10. Vérifications post-déploiement

- Endpoint santé API :

```bash
curl -fsS http://localhost:5000/health
```

- Frontend : ouvrez l'URL fournie par l'environnement.
- Si tout répond, le déploiement est terminé.

## 11. Mise à jour et rollback

- Pour mettre à jour la solution, l'équipe n'a qu'à récupérer les dernières images ou le dernier code selon le mode de livraison choisi, puis relancer la stack.

```bash
docker compose pull
docker compose up -d
```

- En cas de rollback, revenir à la version précédente des images et relancer `docker compose up -d`.

## 12. Production

- L'environnement actuel est prévu pour être migré en production.
- L'utilisateur n'a rien à créer ni à modifier en dehors des fichiers `.env` fournis.
- Les paramètres réseau, volumes et services sont déjà définis.

## 13. Dépannage (erreurs courantes)

- Si un service ne démarre pas, vérifiez d'abord le contenu du `.env`.
- Si l'API répond mal, regardez les logs avec `docker compose logs -f api_backend`.
- Si la stack ne répond pas, relancez `docker compose up -d`.

## 15. Liens utiles

- `healthAI-backend-API/` : code de l'API
- `healthAI-backend-API/.env` : variables d'environnement dédiées à l'API.
- `healthAI-backend-ETL/` : code de  l'ETL.
- `healthAI-backend-ETL/.env` : variables d'environnement dédiées à l'ETL.
- `healthAI-database/init.sql` : script d'initialisation de la base de données.
- `git_pull_all.py` : script de mise à jour des dépôts.

---

## 16. Variables d'environnement (liste complète)

Voici la liste consolidée des variables d'environnement utilisées par les différents composants.  
Le fichier racine `.env` sert pour la BDD.  
L'ETL lit `healthAI-backend-ETL/.env`.  
L'API lit `healthAI-backend-API/.env`.

- **POSTGRES_DB** : nom de la base de données (ex: `healthai_db`)
- **POSTGRES_USER** : utilisateur Postgres (ex: `healthai_user`)
- **POSTGRES_PASSWORD** : mot de passe Postgres (ex: `password`)
- **POSTGRES_HOST** : host Postgres (ex: `database` ou `localhost`)
- **POSTGRES_PORT** : port Postgres (ex: `5432`)
- **POSTGRES_URL** : URL de connexion complète utilisée par le pool PostgreSQL, ex: `postgresql://db_user:db_password@db_host:db_port/db_name
`
- **JWT_SECRET** : Java Web Token pour signer/valider les tokens (doit être long et secret)
- **NODE_ENV** : `development` ou `production` (détermine le comportement du Dockerfile / démarrage)

ETL (healthAI-backend-ETL) :
- **DB_USER** : utilisateur BDD pour l'ETL
- **DB_PASSWORD** : mot de passe BDD pour l'ETL
- **DB_HOST** : host BDD pour l'ETL
- **DB_PORT** : port BDD pour l'ETL
- **DB_NAME** : nom de la base utilisée par l'ETL

## 17. Utilisateurs par défaut dans la BDD

Par défaut, deux utilisateurs sont présents dans la BDD.  
Ils permettent de se connecter une première fois à l'application sans avoir à créer de compte.

Compte utilisateur par défaut :

Email : user@user.fr
Mot de passe : 123456789

Compte administrateur par défaut :

Email : admin@admin.fr
Mot de passe : 123456789
