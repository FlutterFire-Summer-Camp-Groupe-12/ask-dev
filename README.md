# ASK-DEV

Application mobile de questions/réponses inspirée de StackOverflow, pensée pour les développeurs. Posez une question technique, obtenez des réponses de la communauté, et retrouvez l'information facilement grâce à la recherche full-text.

## Stack technique

| Couche | Technologie |
|---|---|
| Mobile | Flutter / Dart |
| Backend | Firebase (Firestore, Auth) |
| Stockage fichiers | Supabase  |
| État | flutter_bloc + get_it |
| Navigation | auto_route |
| Éditeur | flutter_markdown + coloration syntaxique (highlight) |

## Architecture

Les fonctionnalités sont organisées par domaine, chacune suivant une structure `data / domain / presentation` :

```
lib/
├── core/                  # thèmes, routes, utilitaires, widgets partagés
├── dependency_injection/  # câblage get_it
└── features/
    ├── auth/              # authentification
    ├── forum/             # questions & réponses
    ├── profile/           # profil utilisateur
    └── settings/          # paramètres
```

## Fonctionnalités

### Comptes utilisateurs
- Création de compte, connexion / déconnexion
- Profil : pseudo, avatar, date d'inscription

### Forum
- Publication d'une question (titre + description)
- Liste des questions récentes et détail d'une question
- Publication, modification et suppression de réponses
- Gestion de ses propres questions et réponses

### Avancé
- **Recherche full-text** : recherche par mot-clé sur titre et contenu
- **Éditeur enrichi** : markdown et coloration syntaxique du code dans les questions/réponses
- **Temps réel** : les nouvelles réponses apparaissent sans rechargement (Streams)

## Installation

```bash
flutter pub get
dart run build_runner build    # génère le routing auto_route
```

La configuration des services se fait dans `.env` :

```
SUPABASE_URL=...
SUPABASE_ANON_KEY=...
BUCKET_ID=askdev_files
```

Copiez `.env.example` vers `.env` et renseignez vos clés, puis lancez l'application :

```bash
flutter run
```

## Équipe

- **Chef d'équipe :** DOMINICK Randriamanantena Grégoire
- **Mentor :** David BONGOUADE
- NCUTI Abdoul
- OUEDRAOGO Maïmounata
- Ouattara Lacina Levi
- Elana Stacy
- Darius Yassi HOUESSOU-KODE
- Diallo Thiernosadou
