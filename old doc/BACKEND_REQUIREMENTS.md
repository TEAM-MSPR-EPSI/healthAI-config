# 📋 Gestion des Relations - Spécifications Techniques Backend

**Date:** 18 mars 2026  
**Objectif:** Permettre la gestion des liaisons Program ↔ Sessions et Recipe ↔ Ingredients via l'admin  
**Complexité:** Faible | **Temps estimé:** 30-45 min  

---

## 🎯 Contexte

Le frontend admin affiche actuellement les relations en **lecture seule**. Pour permettre l'ajout/suppression/modification des liaisons (séances dans un programme, ingrédients dans une recette), il faut créer **4 services/controllers + 2 routes**.

Les relations utilisent des **tables de jointure**:
- `ProgramSportSession` (liaison Program → Session avec rang)
- `RecipeIngredient` (liaison Recipe → Ingredient avec quantité)

---

## 📦 Fichiers à Créer

### **1. Service Program-Sessions** 
**Fichier:** `healthAI-backend-API/services/programSession.service.js`

```javascript
const SportProgram = require("../models/SportProgram");
const ProgramSportSession = require("../models/ProgramSportSession");
const SportSession = require("../models/SportSession");

class ProgramSessionService {
    // Add a session to a program
    static async addSessionToProgram(programId, sessionId, rank = null) {
        try {
            // Check if program exists
            const program = await SportProgram.findByPk(programId);
            if (!program) throw new Error("Program not found");

            // Check if session exists
            const session = await SportSession.findByPk(sessionId);
            if (!session) throw new Error("Session not found");

            // Check if relation already exists
            const existingRelation = await ProgramSportSession.findOne({
                where: { sport_program_id: programId, sport_session_id: sessionId }
            });
            if (existingRelation) throw new Error("Session already in program");

            // Create relation
            const programSession = await ProgramSportSession.create({
                sport_program_id: programId,
                sport_session_id: sessionId,
                program_sport_session_rank: rank || 1
            });

            return programSession;
        } catch (error) {
            console.error("Error adding session to program:", error);
            throw error;
        }
    }

    // Remove a session from a program
    static async removeSessionFromProgram(programId, sessionId) {
        try {
            const result = await ProgramSportSession.destroy({
                where: {
                    sport_program_id: programId,
                    sport_session_id: sessionId
                }
            });

            if (result === 0) throw new Error("Relation not found");
            return { message: "Session removed from program" };
        } catch (error) {
            console.error("Error removing session from program:", error);
            throw error;
        }
    }

    // Update rank/order of sessions in program
    static async updateSessionRank(programId, sessionId, newRank) {
        try {
            const relation = await ProgramSportSession.findOne({
                where: { sport_program_id: programId, sport_session_id: sessionId }
            });

            if (!relation) throw new Error("Relation not found");

            await relation.update({ program_sport_session_rank: newRank });
            return relation;
        } catch (error) {
            console.error("Error updating session rank:", error);
            throw error;
        }
    }

    // Get all sessions available to add to program (not already in it)
    static async getAvailableSessions(programId) {
        try {
            const program = await SportProgram.findByPk(programId);
            if (!program) throw new Error("Program not found");

            // Get sessions already in program
            const existingRelations = await ProgramSportSession.findAll({
                where: { sport_program_id: programId },
                attributes: ['sport_session_id']
            });

            const existingSessionIds = existingRelations.map(r => r.sport_session_id);

            // Get all sessions not in program
            const sessions = await SportSession.findAll({
                where: existingSessionIds.length > 0 
                    ? { sport_session_id: { [require('sequelize').Op.notIn]: existingSessionIds } }
                    : {}
            });

            return sessions;
        } catch (error) {
            console.error("Error fetching available sessions:", error);
            throw error;
        }
    }
}

module.exports = ProgramSessionService;
```

---

### **2. Service Recipe-Ingredients**
**Fichier:** `healthAI-backend-API/services/recipeIngredient.service.js`

```javascript
const Recipe = require("../models/Recipe");
const RecipeIngredient = require("../models/RecipeIngredient");
const Ingredient = require("../models/Ingredient");

class RecipeIngredientService {
    // Add an ingredient to a recipe
    static async addIngredientToRecipe(recipeId, ingredientId, quantity = 1) {
        try {
            // Check if recipe exists
            const recipe = await Recipe.findByPk(recipeId);
            if (!recipe) throw new Error("Recipe not found");

            // Check if ingredient exists
            const ingredient = await Ingredient.findByPk(ingredientId);
            if (!ingredient) throw new Error("Ingredient not found");

            // Check if relation already exists
            const existingRelation = await RecipeIngredient.findOne({
                where: { recipe_id: recipeId, ingredient_id: ingredientId }
            });
            if (existingRelation) throw new Error("Ingredient already in recipe");

            // Create relation
            const recipeIngredient = await RecipeIngredient.create({
                recipe_id: recipeId,
                ingredient_id: ingredientId,
                ingredient_quantity: quantity
            });

            // Fetch with ingredient details
            const result = await RecipeIngredient.findByPk(recipeIngredient.recipe_ingredient_id, {
                include: [{ model: Ingredient, as: "ingredient" }]
            });

            return result;
        } catch (error) {
            console.error("Error adding ingredient to recipe:", error);
            throw error;
        }
    }

    // Remove an ingredient from a recipe
    static async removeIngredientFromRecipe(recipeId, ingredientId) {
        try {
            const result = await RecipeIngredient.destroy({
                where: {
                    recipe_id: recipeId,
                    ingredient_id: ingredientId
                }
            });

            if (result === 0) throw new Error("Relation not found");
            return { message: "Ingredient removed from recipe" };
        } catch (error) {
            console.error("Error removing ingredient from recipe:", error);
            throw error;
        }
    }

    // Update ingredient quantity in recipe
    static async updateIngredientQuantity(recipeId, ingredientId, newQuantity) {
        try {
            const relation = await RecipeIngredient.findOne({
                where: { recipe_id: recipeId, ingredient_id: ingredientId }
            });

            if (!relation) throw new Error("Relation not found");

            await relation.update({ ingredient_quantity: newQuantity });

            // Fetch with ingredient details
            const result = await RecipeIngredient.findByPk(relation.recipe_ingredient_id, {
                include: [{ model: Ingredient, as: "ingredient" }]
            });

            return result;
        } catch (error) {
            console.error("Error updating ingredient quantity:", error);
            throw error;
        }
    }

    // Get all ingredients available to add to recipe (not already in it)
    static async getAvailableIngredients(recipeId) {
        try {
            const recipe = await Recipe.findByPk(recipeId);
            if (!recipe) throw new Error("Recipe not found");

            // Get ingredients already in recipe
            const existingRelations = await RecipeIngredient.findAll({
                where: { recipe_id: recipeId },
                attributes: ['ingredient_id']
            });

            const existingIngredientIds = existingRelations.map(r => r.ingredient_id);

            // Get all ingredients not in recipe
            const ingredients = await Ingredient.findAll({
                where: existingIngredientIds.length > 0 
                    ? { ingredient_id: { [require('sequelize').Op.notIn]: existingIngredientIds } }
                    : {}
            });

            return ingredients;
        } catch (error) {
            console.error("Error fetching available ingredients:", error);
            throw error;
        }
    }
}

module.exports = RecipeIngredientService;
```

---

### **3. Controller Program-Sessions**
**Fichier:** `healthAI-backend-API/controllers/programSession.controller.js`

```javascript
const ProgramSessionService = require("../services/programSession.service");

class ProgramSessionController {

    static async addSession(req, res) {
        try {
            const { programId } = req.params;
            const { sessionId, rank } = req.body;

            const result = await ProgramSessionService.addSessionToProgram(programId, sessionId, rank);
            res.status(201).json(result);
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    }

    static async removeSession(req, res) {
        try {
            const { programId, sessionId } = req.params;

            const result = await ProgramSessionService.removeSessionFromProgram(programId, sessionId);
            res.json(result);
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    }

    static async updateRank(req, res) {
        try {
            const { programId, sessionId } = req.params;
            const { rank } = req.body;

            const result = await ProgramSessionService.updateSessionRank(programId, sessionId, rank);
            res.json(result);
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    }

    static async getAvailableSessions(req, res) {
        try {
            const { programId } = req.params;

            const sessions = await ProgramSessionService.getAvailableSessions(programId);
            res.json(sessions);
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    }
}

module.exports = ProgramSessionController;
```

---

### **4. Controller Recipe-Ingredients**
**Fichier:** `healthAI-backend-API/controllers/recipeIngredient.controller.js`

```javascript
const RecipeIngredientService = require("../services/recipeIngredient.service");

class RecipeIngredientController {

    static async addIngredient(req, res) {
        try {
            const { recipeId } = req.params;
            const { ingredientId, quantity } = req.body;

            const result = await RecipeIngredientService.addIngredientToRecipe(recipeId, ingredientId, quantity);
            res.status(201).json(result);
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    }

    static async removeIngredient(req, res) {
        try {
            const { recipeId, ingredientId } = req.params;

            const result = await RecipeIngredientService.removeIngredientFromRecipe(recipeId, ingredientId);
            res.json(result);
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    }

    static async updateQuantity(req, res) {
        try {
            const { recipeId, ingredientId } = req.params;
            const { quantity } = req.body;

            const result = await RecipeIngredientService.updateIngredientQuantity(recipeId, ingredientId, quantity);
            res.json(result);
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    }

    static async getAvailableIngredients(req, res) {
        try {
            const { recipeId } = req.params;

            const ingredients = await RecipeIngredientService.getAvailableIngredients(recipeId);
            res.json(ingredients);
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    }
}

module.exports = RecipeIngredientController;
```

---

### **5. Routes Program-Sessions**
**Fichier:** `healthAI-backend-API/routes/programSession.routes.js`

```javascript
const express = require("express");
const router = express.Router();
const ProgramSessionController = require("../controllers/programSession.controller");

// GET available sessions for a program
router.get("/:programId/available-sessions", ProgramSessionController.getAvailableSessions);

// POST add session to program
router.post("/:programId/sessions", ProgramSessionController.addSession);

// PUT update session rank
router.put("/:programId/sessions/:sessionId", ProgramSessionController.updateRank);

// DELETE remove session from program
router.delete("/:programId/sessions/:sessionId", ProgramSessionController.removeSession);

module.exports = router;
```

---

### **6. Routes Recipe-Ingredients**
**Fichier:** `healthAI-backend-API/routes/recipeIngredient.routes.js`

```javascript
const express = require("express");
const router = express.Router();
const RecipeIngredientController = require("../controllers/recipeIngredient.controller");

// GET available ingredients for a recipe
router.get("/:recipeId/available-ingredients", RecipeIngredientController.getAvailableIngredients);

// POST add ingredient to recipe
router.post("/:recipeId/ingredients", RecipeIngredientController.addIngredient);

// PUT update ingredient quantity
router.put("/:recipeId/ingredients/:ingredientId", RecipeIngredientController.updateQuantity);

// DELETE remove ingredient from recipe
router.delete("/:recipeId/ingredients/:ingredientId", RecipeIngredientController.removeIngredient);

module.exports = router;
```

---

## 🔧 Modification Requise: app.js

**Localisation:** `healthAI-backend-API/app.js`

**Ajouter les imports** (cerca ligne 19):
```javascript
const programSessionRoutes = require('./routes/programSession.routes');
const recipeIngredientRoutes = require('./routes/recipeIngredient.routes');
```

**Ajouter les routes** (cerca ligne 36-37, après `/api/recipes`):
```javascript
app.use('/api/recipe-ingredients', recipeIngredientRoutes);
app.use('/api/program-sessions', programSessionRoutes);
```

---

## 📊 Endpoints Finaux

| Méthode | Endpoint | Body | Description |
|---------|----------|------|-------------|
| `GET` | `/api/program-sessions/:programId/available-sessions` | - | List sessions not in program |
| `POST` | `/api/program-sessions/:programId/sessions` | `{sessionId, rank?}` | Add session to program |
| `PUT` | `/api/program-sessions/:programId/sessions/:sessionId` | `{rank}` | Update session rank |
| `DELETE` | `/api/program-sessions/:programId/sessions/:sessionId` | - | Remove session from program |
| `GET` | `/api/recipe-ingredients/:recipeId/available-ingredients` | - | List ingredients not in recipe |
| `POST` | `/api/recipe-ingredients/:recipeId/ingredients` | `{ingredientId, quantity?}` | Add ingredient to recipe |
| `PUT` | `/api/recipe-ingredients/:recipeId/ingredients/:ingredientId` | `{quantity}` | Update ingredient quantity |
| `DELETE` | `/api/recipe-ingredients/:recipeId/ingredients/:ingredientId` | - | Remove ingredient from recipe |

---

## ✅ Checklist d'Intégration

- [ ] Créer les 4 fichiers services & controllers
- [ ] Créer les 2 fichiers routes
- [ ] Modifier `app.js` (ajouter imports + app.use)
- [ ] Tester avec Postman/cURL:
  ```
  GET http://localhost:5000/api/program-sessions/1/available-sessions
  ```
- [ ] Redémarrer le container API
- [ ] Tester depuis l'interface admin (bouton "Gérer")

---

**Questions?** Contacte l'équipe frontend.
