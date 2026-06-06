
# Mindow — Product Requirements Document (PRD)

**Version :** 1.0  
**Date :** Juin 2026  
**Statut :** MVP Definition  
**Produit :** Mindow

---

# 1. Vision

Mindow est une application mobile et web qui aide les utilisateurs à réduire leur charge mentale grâce à une combinaison de :

- Capture ultra-rapide des préoccupations
- Intelligence artificielle
- Gamification positive
- Coaching quotidien personnalisé

L'objectif n'est pas d'aider les utilisateurs à être plus productifs.

L'objectif est de les aider à retrouver de l'espace mental.

---

# 2. Mission

> Dépose tout ce qui encombre ton esprit. Mindow transforme tes préoccupations en actions simples qui te permettent de retrouver de la légèreté mentale.

---

# 3. Problème

Aujourd'hui les utilisateurs :

- Gardent trop d'informations en tête
- Oublient régulièrement des choses importantes
- Se sentent constamment sous pression
- Utilisent des outils de productivité qui deviennent eux-mêmes une source de stress

Les applications existantes sont principalement conçues pour :

- gérer des tâches
- optimiser la productivité
- améliorer l'organisation

Peu d'outils sont conçus pour réduire la charge mentale.

Mindow doit devenir un espace de décharge mentale.

---

# 4. Proposition de Valeur

## Avant

L'utilisateur garde tout dans sa tête.

```text
"Dentiste"
"Impôts"
"Réparer la fuite"
"Réserver les vacances"
```

Résultat :

- Stress
- Oubli
- Charge mentale

## Après

L'utilisateur dépose ses préoccupations dans Mindow.

Mindow :

- les comprend
- les classe
- les priorise
- propose la prochaine meilleure action

Résultat :

- Moins de stress
- Plus de clarté
- Charge mentale réduite

---

# 5. Personas

## Persona 1 — Parent Actif

### Profil

- 35 à 50 ans
- Couple avec enfants

### Problématiques

- Rendez-vous médicaux
- École
- Administratif
- Maison

### Objectif

Réduire la charge mentale familiale.

---

## Persona 2 — Jeune Professionnel

### Profil

- 25 à 40 ans

### Problématiques

- Travail
- Finances
- Projets personnels

### Objectif

Arrêter de tout garder en tête.

---

## Persona 3 — Entrepreneur

### Profil

- 25 à 55 ans

### Problématiques

- Trop d'idées
- Trop de responsabilités

### Objectif

Externaliser sa mémoire.

---

# 6. North Star Metric

## Kilogrammes de charge mentale libérés par utilisateur et par mois

Toutes les fonctionnalités doivent contribuer à augmenter cette métrique.

---

# 7. KPIs

## Activation

Utilisateur ayant :

- créé son compte
- ajouté au moins 3 préoccupations

---

## Daily Active Users

DAU

---

## Monthly Active Users

MAU

---

## DAU / MAU

Objectif :

```text
> 30%
```

---

## Charge mentale libérée

```text
Aujourd'hui : -6 kg

Ce mois : -38 kg
```

---

## Streak

Nombre de jours consécutifs avec au moins une mission réalisée.

---

## Rétention

J1

J7

J30

---

# 8. MVP Scope

---

# 8.1 Onboarding

## Objectif

Comprendre rapidement l'utilisateur.

---

## Écran 1

Bienvenue.

```text
Décharge ton esprit.
On s'occupe du reste.
```

---

## Écran 2

Questions :

- Tranche d'âge
- Situation familiale
- Niveau de stress actuel

---

## Écran 3

```text
Combien de sujets occupent ton esprit actuellement ?
```

Choix :

- 0-10
- 10-20
- 20-50
- 50+

---

## Écran 4

Compte :

- Apple
- Google
- Email

---

# 8.2 Brain Dump

## Objectif

Capturer une préoccupation en moins de 3 secondes.

---

## UX

Un seul champ.

Placeholder :

```text
Qu'est-ce qui occupe ton esprit ?
```

---

## Exemples

```text
Prendre rendez-vous chez le dentiste
```

```text
Préparer les vacances
```

```text
Renouveler mon passeport
```

```text
Je suis inquiet pour mes impôts
```

---

## CTA

```text
Déposer dans mon sac à dos
```

---

# 8.3 Analyse IA

À chaque ajout.

L'IA détermine :

```json
{
  "category": "Administratif",
  "mentalWeight": 7,
  "effort": 2,
  "estimatedDuration": 15
}
```

---

## Catégories

- Administratif
- Famille
- Santé
- Travail
- Finance
- Maison
- Personnel
- Voyage
- Autre

---

# 8.4 Sac à Dos Mental

## Écran principal

Affichage :

```text
Charge mentale actuelle

63 kg
```

---

## Visualisation

Sac à dos animé :

### 0-20 kg

Léger

### 20-50 kg

Modéré

### 50-80 kg

Lourd

### 80+ kg

Très lourd

---

## Informations

- Charge mentale totale
- Nombre de préoccupations ouvertes
- Progression hebdomadaire

---

# 8.5 Mission Quotidienne

## Fonction principale

Chaque jour.

L'application sélectionne :

UNE action.

---

## Exemple

```text
Mission du jour

Prendre rendez-vous chez le dentiste

Temps estimé :
3 minutes

Gain estimé :
-5 kg
```

---

## Actions

- Commencer
- Plus tard
- Déjà fait

---

# 8.6 Validation

Quand la mission est terminée.

Animation :

```text
-5 kg
```

Le sac à dos devient visiblement plus léger.

---

# 8.7 Historique

Liste des victoires.

```text
✓ Dentiste

✓ Assurance

✓ Réparation fuite
```

---

## Informations

- Date
- Gain mental
- Temps investi

---

# 8.8 Notifications

## Exemples

```text
Tu peux libérer 4 kg aujourd'hui.
```

```text
Une mission de 3 minutes t'attend.
```

```text
Ton esprit est plus léger qu'il y a 7 jours.
```

---

# 9. Gamification

---

# 9.1 Niveaux

## Progression

```text
Explorateur
```

↓

```text
Allégeur
```

↓

```text
Esprit Clair
```

↓

```text
Esprit Léger
```

↓

```text
Maître du Calme
```

---

# 9.2 Jardin Mental

Chaque mission accomplie fait évoluer un jardin.

---

## Éléments débloqués

- Fleur
- Arbuste
- Arbre
- Rivière
- Animaux
- Paysages

---

## Objectif

Visualiser sa progression mentale.

---

# 9.3 Succès

## Exemples

```text
Première victoire
```

```text
10 kg libérés
```

```text
100 préoccupations déposées
```

```text
30 jours consécutifs
```

---

# 10. Premium V1

---

# 10.1 Décomposition IA

Entrée :

```text
Préparer mon déménagement
```

---

Sortie :

```text
□ Réserver camion

□ Faire cartons cuisine

□ Changer adresse banque

□ Prévenir assurance
```

---

# 10.2 Coaching IA

Exemple :

```text
Tu sembles accumuler plusieurs sujets administratifs.

Commencer par les impôts pourrait réduire significativement ta charge mentale.
```

---

# 10.3 Dashboard Avancé

Statistiques :

- Évolution charge mentale
- Répartition catégories
- Charge mentale moyenne
- Charge mentale supprimée

---

# 10.4 Mode Couple

Visualisation :

```text
Charge mentale du foyer
```

---

Fonctionnalités :

- Partage de préoccupations
- Répartition intelligente
- Missions collaboratives

---

# 11. Architecture Fonctionnelle

## Module Auth

- Connexion
- Inscription
- Profil

---

## Module Brain Dump

- Création
- Édition
- Suppression

---

## Module Mental Load

- Calcul
- Historisation

---

## Module Missions

- Génération
- Validation

---

## Module Gamification

- XP
- Succès
- Jardin

---

## Module AI

- Classification
- Priorisation
- Décomposition
- Coaching

---

# 12. Architecture Technique

## Frontend

### Flutter

Plateformes :

- iOS
- Android
- Web

---

### State Management

Riverpod

---

### Routing

GoRouter

---

### Local Storage

Hive

---

# Backend

## Supabase

Services utilisés :

- Auth
- PostgreSQL
- Storage
- Realtime
- Edge Functions

---

# Database

## users

```sql
id
email
created_at
```

---

## mental_items

```sql
id
user_id
content
category
mental_weight
effort_score
estimated_duration
status
created_at
```

---

## daily_missions

```sql
id
user_id
mental_item_id
mission_date
completed
completed_at
```

---

## achievements

```sql
id
user_id
achievement_type
unlocked_at
```

---

## garden_items

```sql
id
user_id
item_type
unlocked_at
```

---

## subscriptions

```sql
id
user_id
plan
started_at
expires_at
```

---

# 13. Intelligence Artificielle

## Fournisseur

OpenAI

---

## Modèle MVP

GPT-4o Mini

---

## Cas d'usage

### Classification

Identifier :

- catégorie
- poids mental
- difficulté

---

### Décomposition

Transformer un gros sujet en sous-actions.

---

### Coaching

Proposer les prochaines meilleures actions.

---

### Priorisation

Sélectionner la mission quotidienne optimale.

---

# 14. Notifications

## Service

Firebase Cloud Messaging (FCM)

---

## Types

### Mission du jour

### Streak

### Succès

### Charge mentale réduite

---

# 15. Paiements

## RevenueCat

Gestion :

- Apple Store
- Google Play

---

## Plans

### Gratuit

- Brain dump illimité
- Mission quotidienne
- Gamification

---

### Premium

- Coaching IA
- Décomposition IA
- Dashboard avancé
- Mode Couple

---

# 16. Analytics

## PostHog

Suivi :

- Funnels
- Rétention
- Événements
- A/B Testing

---

# 17. Monitoring

## Sentry

Suivi :

- Crashes
- Exceptions
- Performances

---

# 18. Vision Future

## Assistant Vocal

Ajout de préoccupations par la voix.

---

## Widget Mobile

Affichage :

```text
Charge mentale : 41 kg

Mission du jour :
Appeler le dentiste
```

---

## Apple Watch

Ajout rapide.

---

## Wear OS

Ajout rapide.

---

## Agent IA Personnel

Question :

```text
Qu'est-ce qui me soulagerait le plus aujourd'hui ?
```

Réponse :

```text
Prendre rendez-vous chez le dentiste.

Temps :
3 minutes

Gain estimé :
6 kg
```

---

# 19. Objectifs Année 1

## Utilisateurs

50 000

---

## Premium

5 000 abonnés

---

## NPS

> 50

---

## DAU / MAU

> 30 %

---

# Résumé Produit

Mindow n'est pas une application de gestion de tâches.

Mindow est un coach de décharge mentale assisté par IA.

L'utilisateur ne gère pas une todo-list.

Il dépose ce qui encombre son esprit.

L'application l'aide ensuite à retrouver progressivement de la légèreté mentale grâce à des actions simples, personnalisées et gamifiées.
