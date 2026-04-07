# healthAI-config

Configure et orchestre toute l'application healthAI en conteneurs Docker.

## Fichiers du dossier

- **`docker-compose.yml`** : Définition de tous les services (base de données, API, frontend, etc.)
- **`git_pull_all.py`** : Script pour mettre à jour tous les dépôts Git et copier la config à la racine
- **`.env`** : Variables d'environnement

## Services actifs

| Service | Port | URL |
|---------|------|-----|
| Frontend | 4200 | http://localhost:4200 |
| API | 5000 | http://localhost:5000 |
| ETL API | 8000 | http://localhost:8000 |
| Base de données | 5432 | localhost |
| PDC Agent | - | Envoie les données à Grafana Cloud |

## Démarrage rapide

```bash

# Lancer tous les services
docker-compose up -d

# Vérifier le statut
docker-compose ps

# Arrêter
docker-compose down
```

## Mises à jour

Pour synchroniser tous les repositories et appliquer les changements :

```bash
python git_pull_all.py
```

## Logs

```bash
# Voir les logs d'un service
docker-compose logs -f [service_name]

# Tous les logs
docker-compose logs -f
```

## Variables d'environnement (.env)

```env
POSTGRES_DB=healthai_db
POSTGRES_USER=healthai_user
POSTGRES_PASSWORD=secure_password

PDC_TOKEN=your_token
PDC_CLUSTER=your_cluster
PDC_GRAFANA_ID=your_grafana_id

# Note: Grafana est hébergé sur Grafana Cloud
```