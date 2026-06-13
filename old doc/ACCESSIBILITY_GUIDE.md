# Guide d'Accessibilité RGAA AA pour Développeurs HealthAI

## Introduction

Ce guide résume les règles d'accessibilité à respecter dans le frontend HealthAI. L'idée est simple: privilégier le HTML sémantique, garder une navigation clavier fluide, limiter l'ARIA au strict nécessaire et vérifier les contrastes, les labels et les messages d'erreur.

## Principes clés

### 1. Préférer le HTML sémantique

Utilise les vrais éléments HTML avant d'ajouter du `role`.

```html
<button type="button">Envoyer</button>
```

Évite les `div` cliquables si un bouton ou un lien suffit.

### 2. Tout doit être accessible au clavier

Chaque action doit fonctionner avec Tab, Maj+Tab, Entrée et Espace si pertinent.

```html
<button type="button" (click)="openMenu()">Menu</button>
<a routerLink="/recipes">Recettes</a>
```

### 3. Toujours associer un label aux formulaires

```html
<mat-form-field>
  <mat-label>Email</mat-label>
  <input matInput type="email" required aria-required="true" />
</mat-form-field>
```

### 4. Décrire les images

```html
<img src="logo.png" alt="Logo HealthAI Coach" />
<img src="decor.png" alt="" aria-hidden="true" />
```

### 5. Les icônes doivent être lisibles via le bouton

```html
<button aria-label="Se déconnecter">
  <mat-icon aria-hidden="true">logout</mat-icon>
</button>
```

## Checklist pour chaque composant

- Structure HTML sémantique: `nav`, `main`, `section`, `button`, `a`
- Titres hiérarchisés: pas de saut de niveau
- Focus visible sur les éléments interactifs
- Labels explicites sur tous les champs
- `aria-required="true"` sur les champs obligatoires
- Messages d'erreur reliés au champ avec `aria-describedby`
- Erreurs annoncées avec `role="alert"`
- Images décoratives cachées avec `aria-hidden="true"`
- Cibles tactiles d'au moins 44x44 px
- Zoom 200 % sans casse ni scroll horizontal forcé

## Patterns courants

### Bouton avec icône et texte

```html
<button mat-flat-button (click)="submitForm()" [disabled]="loading">
  <mat-icon aria-hidden="true">send</mat-icon>
  <span>{{ loading ? 'Envoi...' : 'Envoyer' }}</span>
</button>
```

### Navigation active

```html
<nav aria-label="Navigation principale">
  <a routerLink="/recipes" [attr.aria-current]="isRouteActive ? 'page' : null">Recettes</a>
</nav>
```

### Formulaire avec erreur

```html
<form [attr.aria-busy]="loading">
  <mat-form-field>
    <mat-label>Email <span aria-label="requis">*</span></mat-label>
    <input matInput type="email" aria-required="true" aria-describedby="email-error" />
    <p id="email-error" role="alert" aria-live="assertive">Adresse email invalide.</p>
  </mat-form-field>
</form>
```

## Contrastes recommandés

Utilise des couleurs qui respectent au minimum:

- 4.5:1 pour le texte normal
- 3:1 pour le gros texte

Évite de transmettre une information uniquement par la couleur.

## Tests recommandés

- Lighthouse Accessibility
- Axe DevTools
- Navigation clavier complète
- Test zoom à 200 %
- Vérification avec NVDA, VoiceOver ou TalkBack

## Ressources

- RGAA 4.1: https://www.numerique.gouv.fr/publications/rgaa-accessibilite/
- WCAG 2.1 AA: https://www.w3.org/WAI/WCAG21/quickref/
- MDN Accessibility: https://developer.mozilla.org/en-US/docs/Web/Accessibility

## Rappel important

L'ARIA ne remplace jamais le HTML sémantique. Il faut d'abord construire une interface compréhensible sans ajout artificiel, puis ajouter seulement les attributs nécessaires.