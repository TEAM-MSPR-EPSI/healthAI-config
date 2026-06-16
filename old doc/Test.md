# Rapport de Tests - HealthAI

Ce document décrit comment lancer les tests pour les différents modules du projet et fournit une explication de leur fonctionnement et de leur couverture.

---

## Lancer les tests

### Frontend Angular (Tests Unitaires - Karma & Jasmine)
```bash
cd healthAI-frontend
npm run test:coverage
```

### Frontend Angular (Tests E2E - Playwright)
```bash
cd healthAI-frontend
npm run test:e2e
# Ou pour lancer l'interface interactive :
npm run test:e2e:ui
```

### Backend API Node
```bash
cd healthAI-backend-API
npm run test:coverage
```

### Service de recommandation nutritionnelle
Avec un `.venv` actif :
```bash
.venv\Scripts\Activate.ps1
cd healthAI-service-nutrition
pip install -r requirements.txt
python -m pytest
```

---

## Explication et fonctionnement des tests

### 1. Frontend Angular (`healthAI-frontend`)

#### A. Tests Unitaires
* **Framework de test :** **Jasmine** (moteur d'assertions et d'espionnage) exécuté via le lanceur de tests **Karma** (avec le navigateur `ChromeHeadless` pour une exécution sans interface graphique).
* **Commande lancée :** `npm run test:coverage` (exécute `ng test --watch=false --browsers=ChromeHeadless --code-coverage`).
* **Résultats obtenus :** **10 tests passés avec succès (100% de réussite)**. La couverture globale des lignes testées est de **40.42%**.

##### Ce que font les tests (fichiers spécifiés) :
* **[app.spec.ts](healthAI-frontend/src/app/app.spec.ts) (2 tests) :**
  * Vérifie que le composant racine `App` est correctement créé.
  * S'assure que le titre `"HealthAI Coach"` s'affiche bien dans la barre d'outils.
* **[auth.service.spec.ts](healthAI-frontend/src/app/services/auth.service.spec.ts) (3 tests) :**
  * Vérifie la connexion utilisateur : appelle l'API d'authentification, récupère le profil, met à jour le signal `currentUser` et stocke les données chiffrées/JWT dans le `localStorage`.
  * Gère les cas d'erreur : si la récupération du profil échoue, le service retombe sur les métadonnées incluses dans le payload du token JWT.
  * Valide la déconnexion : nettoie le `localStorage` et redirige l'utilisateur vers la page de `/login`.
* **[api.service.spec.ts](healthAI-frontend/src/app/services/api.service.spec.ts) (2 tests) :**
  * Teste le mapping des données reçues de l'API (ex: convertit les clés brutes de la base comme `ingredient_energy_100g` en propriétés d'interface frontend comme `food_calories_per_100g`).
  * Teste la normalisation des relations d'ingrédients de recettes complexes en un format aplati et propre pour les composants.
* **[subscribe.spec.ts](healthAI-frontend/src/app/pages/subscribe/subscribe.spec.ts) (3 tests) :**
  * Vérifie la création de la page d'abonnement.
  * Valide que la sélection d'un plan affiche une notification SnackBar de confirmation (ex: `Abonnement "Premium" sélectionné`).
  * Vérifie la fonction de fallback d'image (ajoute la classe CSS `.hidden` si le chargement d'une image échoue).

#### B. Tests End-to-End (E2E)
* **Framework de test :** **Playwright** exécutant les tests sur 3 navigateurs cibles (Chromium, Firefox et WebKit) de façon isolée.
* **Commande lancée :** `npm run test:e2e` (ou `npm run test:e2e:ui` pour le mode graphique interactif).
* **Résultats obtenus :** **15 tests passés avec succès (3 navigateurs × 5 scénarios, 100% de réussite)**.

##### Ce que font les scénarios E2E ([app.spec.ts](healthAI-frontend/e2e/app.spec.ts)) :
* **Redirection de Splash :** Charge l'application à la racine `/` et s'assure qu'au bout de 2.5 secondes l'utilisateur est automatiquement redirigé vers la page de bienvenue `/welcome`.
* **Navigation de Bienvenue :** Teste le lien public "Qui sommes-nous ?" vers la page d'accueil et le bouton "Continuer →" menant au formulaire de connexion.
* **Validation de la Connexion (Erreur) :** Remplit de mauvaises informations de connexion, valide le formulaire et vérifie l'apparition dynamique du message d'erreur `"Email ou mot de passe incorrect."`.
* **Navigation vers l'Inscription :** Vérifie que le lien de création de compte redirige bien vers le formulaire d'inscription `/register`.
* **Connexion & Dashboard Mockés :** Intercepte les appels API d'authentification et de chargement de profil utilisateur pour renvoyer des fausses données (JWT fictif et utilisateur test), simule la saisie et valide que l'application redirige bien vers `/user/home` et charge le panneau principal ainsi que la barre latérale avec succès.

---

### 2. Backend API Node (`healthAI-backend-API`)

* **Framework de test :** Testeur natif de Node.js (`node --test`) couplé à l'outil expérimental de couverture de code (`--experimental-test-coverage`).
* **Commande lancée :** `npm run test:coverage` (exécute `node --test --experimental-test-coverage`).
* **Résultats obtenus :** **8 tests passés avec succès (100% de réussite)**. La couverture de code globale est excellente avec **97.85%** des lignes couvertes.

#### Ce que font les tests (fichiers spécifiés) :
* **[auth.service.test.js](healthAI-backend-API/tests/services/auth.service.test.js) (4 tests) :**
  * **Inscription :** Rejette les mots de passe trop faibles (ex: inférieurs à la complexité requise) avec un message d'erreur.
  * **Hachage :** Vérifie que le mot de passe est correctement haché avec `bcrypt` avant l'enregistrement en base de données (jamais stocké en clair).
  * **Connexion (succès) :** Vérifie que la connexion avec de bons identifiants génère un jeton JWT valide contenant le rôle et l'identifiant de l'utilisateur.
  * **Connexion (échec) :** Vérifie le rejet d'une tentative de connexion avec un mot de passe incorrect.
* **[import.service.test.js](healthAI-backend-API/tests/services/import.service.test.js) (4 tests) :**
  * **Parseur SQL :** Valide que l'analyseur découpe correctement les instructions SQL sur les points-virgules, tout en préservant l'intégrité des blocs SQL dollar-quoted (`$$`).
  * **Sécurité :** Vérifie le blocage et le rejet immédiat des requêtes contenant des instructions destructrices comme `DROP TABLE`.
  * **Import SQL standard :** Valide que les insertions (`INSERT`) sont enveloppées avec des clauses de gestion de conflits (`ON CONFLICT DO NOTHING`) et exécutées dans une transaction sécurisée (`BEGIN` / `COMMIT`).
  * **Import SQL forcé :** Vérifie que si le mode `force` est activé, le service tronque les tables (`TRUNCATE ... CASCADE`) avant de relancer l'insertion.

---

### 3. Service de recommandation nutritionnelle (`healthAI-service-nutrition`)

* **Framework de test :** **Pytest** (Python) avec le plugin `pytest-cov` pour la couverture de code.
* **Commande lancée :** `python -m pytest` (exécutée en local via le dossier virtuel `.venv`).
* **Résultats obtenus :** **5 tests passés avec succès (100% de réussite)**. Couverture globale du code : **56%**.

#### Ce que font les tests (fichiers spécifiés) :
* **[test_main.py](healthAI-service-nutrition/tests/test_main.py) (2 tests) :**
  * Utilise `TestClient` (FastAPI) pour requêter l'API de manière isolée.
  * Valide que le endpoint d'état de santé `/health` renvoie bien `{"status": "ok", "service": "nutrition-recommendation"}` avec un code `200`.
  * Vérifie que la racine `/` retourne les liens vers la documentation OpenAPI (`/docs`) et l'état de santé.
* **[test_meal_plan.py](healthAI-service-nutrition/tests/test_meal_plan.py) (1 test) :**
  * Teste la génération d'un plan de repas hebdomadaire personnalisé de manière asynchrone (`asyncio.run`).
  * Utilise `monkeypatch` pour mocker l'enregistrement en base MongoDB, permettant de tester la logique pure de génération de repas (ex: 2 jours de repas avec 4 repas/jour pour un profil végétalien visant la prise de muscle).
  * Vérifie la présence de recommandations spécifiques (ex: "protéines végétales") et l'exactitude des structures de repas générées (ex: "Porridge protéiné" au petit-déjeuner).
* **[test_recommender.py](healthAI-service-nutrition/tests/test_recommender.py) (2 tests) :**
  * **Calculs extrêmes :** S'assure que si l'apport calorique enregistré est de `0`, la fonction d'analyse de balance nutritionnelle ne lève pas d'erreur de division par zéro, retourne un besoin par défaut de 1800 kcal et affiche une notification appropriée.
  * **Analyse de déséquilibre :** Valide que l'algorithme d'analyse nutritionnelle détecte correctement et remonte des anomalies nutritionnelles spécifiques (ex: "Déficit en protéines", "Déficit en glucides", "Excès de lipides") et génère les conseils diététiques correspondants.