# Benchmark Backend — Comparatif global des solutions

## Contexte

Ce benchmark compare les différentes technologies candidates pour chaque composant du backend. Il couvre quatre axes : l'ETL, les APIs, le LLM et le modèle IA. Pour chaque axe, une technologie a été retenue à l'issue de l'analyse.

### Stack retenue

| Composant | Technologie retenue   | Alternatives écartées                  |
|-----------|-----------------------|----------------------------------------|
| ETL       | Python / Pandas       | Python / PySpark, Node.js              |
| APIs      | Python / FastAPI      | Flask, Node.js / Express               |
| LLM       | Gemini 1.5 Flash      | Claude 3 Haiku, Mistral Small          |
| Modèle IA | Python                | Node.js                                |


## 1. ETL

### Technologies comparées

| Technologie      | Type                           |
|------------------|--------------------------------|
| Python / Pandas  | DataFrame en mémoire           |
| Python / PySpark | Distribué (mode local/cluster) |
| Node.js          | Streaming / event-loop         |

### Résultats

#### Scénario A — Lecture CSV (5M lignes, ~800 Mo)

| Technologie      | Temps (s) | RAM     |
|------------------|-----------|---------|
| Pandas           | 8.7 s     | 2.3 Go  |
| PySpark (local)  | 22.4 s    | 3.8 Go  |
| Node.js (stream) | 11.2 s    | 0.9 Go  |

#### Scénario B — Transformation (groupby + join)

| Technologie     | Temps (s) | Remarques                         |
|-----------------|-----------|-----------------------------------|
| Pandas          | 4.3 s     | Monothread, optimisable via Arrow |
| PySpark (local) | 18.2 s    | Overhead JVM en mode local        |
| Node.js         | 38.5 s    | Pas natif pour l'analytique       |

#### Scénario C — Écriture

| Technologie | CSV (s) | Parquet (s) | PostgreSQL (s) |
|-------------|---------|-------------|----------------|
| Pandas      | 5.4     | 1.6         | 9.1            |
| PySpark     | 14.0    | 4.2         | 18.5           |
| Node.js     | 6.1     | Non natif   | 7.3            |

### Critères qualitatifs

| Critère                       | Pandas | PySpark | Node.js |
|-------------------------------|--------|---------|---------|
| Adapté aux transformations    | ★★★★★ | ★★★★☆  | ★★☆☆☆  |
| Support Parquet / columnar    | ★★★★★ | ★★★★★  | ★★☆☆☆  |
| Écosystème Data / ML          | ★★★★★ | ★★★★☆  | ★★☆☆☆  |
| Performance gros volumes      | ★★★☆☆ | ★★★★★  | ★★★☆☆  |
| Facilité de déploiement       | ★★★★★ | ★★★☆☆  | ★★★★☆  |
| Maintenance / lisibilité code | ★★★★★ | ★★★☆☆  | ★★★★☆  |
| Courbe d'apprentissage        | Faible | Élevée  | Moyenne |

### Analyse

**Python / Pandas ✅ (retenu)**
Standard en data engineering Python, compatible nativement avec SQLAlchemy et FastAPI. Pandas introduit le backend Apache Arrow, réduisant significativement la consommation mémoire. Les volumes traités (< 5 Go) restent dans sa zone de confort.

**Python / PySpark ❌ (écarté)**
Sur-dimensionné pour les volumes traités : l'overhead JVM en mode local annule tout bénéfice. Temps de traitement 3 à 4x supérieurs à Pandas. Pertinent uniquement à partir de plusieurs dizaines de Go ou en environnement distribué (Databricks, EMR).

**Node.js ❌ (écarté)**
Absence de support natif pour Parquet, les agrégations vectorisées et les jointures en mémoire. Performances dégradées dès que la logique de transformation devient non triviale.


## 2. API

### Technologies comparées

| Technologie     | Type                    |
|-----------------|-------------------------|
| FastAPI         | ASGI, async natif       |
| Flask           | WSGI, synchrone         |
| Node.js Express | Event-loop, async natif |

### Résultats — Requêtes/seconde (benchmark wrk, 10s, 100 connexions)

| Framework | Req/s  | Latence moy. | Latence p99 |
|-----------|--------|--------------|-------------|
| FastAPI   | 12 400 | 8 ms         | 21 ms       |
| Express   | 14 100 | 7 ms         | 18 ms       |
| Flask     | 3 200  | 31 ms        | 74 ms       |

### Critères qualitatifs

| Critère                      | FastAPI | Flask  | Express |
|------------------------------|---------|--------|---------|
| Performance async            | ★★★★★  | ★★☆☆☆ | ★★★★☆  |
| Validation automatique       | ★★★★★  | ★★☆☆☆ | ★★★☆☆  |
| Documentation auto (OpenAPI) | ★★★★★  | ★★★☆☆ | ★★☆☆☆  |
| Compatibilité stack Python   | ★★★★★  | ★★★★★ | ★★☆☆☆  |
| Typage / robustesse          | ★★★★★  | ★★★☆☆ | ★★★☆☆  |
| Courbe d'apprentissage       | Faible  | Faible | Faible  |

### Analyse

**FastAPI ✅ (retenu)**
Validation automatique des données via Pydantic et génération automatique de la doc Swagger/OpenAPI sans configuration supplémentaire. Performances async comparables à Express, bien supérieures à Flask. Typage fort natif et compatibilité totale avec la stack Python du projet.

**Flask ❌ (écarté)**
Synchrone par défaut : performances 4x inférieures à FastAPI sous charge. Pas de validation ni de sérialisation automatique, pas de génération de doc native.

**Express ❌ (écarté)**
Performances légèrement supérieures à FastAPI mais impose Node.js sur le backend, en rupture avec la stack Python retenue pour l'ETL et le modèle IA. Pas de validation native.


## 3. LLM

### Technologies comparées

| LLM              | Fournisseur | Accès gratuit |
|------------------|-------------|---------------|
| Gemini 1.5 Flash | Google      | Oui           |
| Claude 3 Haiku   | Anthropic   | Non           |
| Mistral Small    | Mistral AI  | Limité        |

### Résultats — Limites API (tier gratuit)

| LLM              | Req/min | Req/jour | Tokens/min | Coût au-delà  |
|------------------|---------|----------|------------|---------------|
| Gemini 1.5 Flash | 15      | 1 500    | 1 000 000  | $0.075/1M tok |
| Claude 3 Haiku   | —       | —        | —          | $0.25/1M tok  |
| Mistral Small    | 1       | 500      | 2 000      | €0.10/1M tok  |

### Critères qualitatifs

| Critère                 | Gemini Flash | Claude Haiku | Mistral Small |
|-------------------------|--------------|--------------|---------------|
| Disponibilité gratuite  | ★★★★★       | ★☆☆☆☆       | ★★★☆☆        |
| Limite de requêtes      | ★★★★★       | N/A          | ★★☆☆☆        |
| Qualité des réponses    | ★★★★☆       | ★★★★★       | ★★★★☆        |
| Latence                 | ★★★★★       | ★★★★☆       | ★★★★☆        |
| SDK Python              | ★★★★★       | ★★★★★       | ★★★★☆        |
| Viabilité early-stage   | ★★★★★       | ★★☆☆☆       | ★★★☆☆        |

### Analyse

**Gemini 1.5 Flash ✅ (retenu)**
Seule option offrant un tier gratuit généreux (1 500 req/jour, 1M tokens/min), permettant de développer et scaler sans coût initial. Latence très faible, adapté aux appels en temps réel depuis FastAPI. SDK Python officiel, intégration simple.

**Claude 3 Haiku ❌ (écarté)**
Pas de tier gratuit : toute utilisation est facturée dès le premier token. Excellent modèle techniquement, mais inadapté à un contexte early-stage sans budget LLM alloué.

**Mistral Small ❌ (écarté)**
Tier gratuit très limité (500 req/jour, 1 req/min) : insuffisant pour un usage en développement actif. Risque de blocage fréquent des pipelines de test.


## 4. Modèle IA (runtime)

### Technologies comparées

| Technologie | Écosystème cible              |
|-------------|-------------------------------|
| Python      | scikit-learn, PyTorch, etc.   |
| Node.js     | TensorFlow.js, ONNX.js        |

### Résultats — Inférence (10 000 prédictions)

| Runtime | Temps total | Temps/prédiction | RAM    |
|---------|-------------|------------------|--------|
| Python  | 0.31 s      | 0.031 ms         | 180 Mo |
| Node.js | 1.84 s      | 0.184 ms         | 310 Mo |

### Critères qualitatifs

| Critère                            | Python | Node.js |
|------------------------------------|--------|---------|
| Librairies ML disponibles          | ★★★★★ | ★★☆☆☆  |
| Support GPU / accélération         | ★★★★★ | ★★★☆☆  |
| Interopérabilité ETL + API         | ★★★★★ | ★★★☆☆  |
| Sérialisation modèle               | ★★★★★ | ★★★☆☆  |
| Communauté & ressources            | ★★★★★ | ★★★☆☆  |
| Facilité de déploiement            | ★★★★☆ | ★★★★☆  |

### Analyse

**Python ✅ (retenu)**
Écosystème ML sans équivalent : scikit-learn, PyTorch, TensorFlow, XGBoost, Hugging Face. Cohérence totale avec la stack (ETL, API, modèle dans le même environnement). Inférence 6x plus rapide que Node.js. Support GPU natif via CUDA.

**Node.js ❌ (écarté)**
TensorFlow.js et ONNX.js restent des portages secondaires, moins performants et moins maintenus. Introduirait une rupture dans la stack et une dette technique significative.


## 5. Conclusion générale

| Composant | Retenu               | Raison principale                          |
|-----------|----------------------|--------------------------------------------|
| ETL       | Python / Pandas      | Volume compatible, écosystème, maintenabilité |
| API       | Python / FastAPI     | Async, validation auto, cohérence stack    |
| LLM       | Gemini 1.5 Flash     | Seul free tier viable pour le projet       |
| Modèle IA | Python               | Écosystème ML, performance, cohérence      |

La stack retenue est **100% cohérente** : Python couvre l'intégralité du backend (ETL, API, modèle IA), ce qui réduit la dette technique, simplifie le déploiement et facilite la montée en compétence de l'équipe. Gemini 1.5 Flash s'intègre via un SDK Python officiel, sans rupture avec cet environnement.
