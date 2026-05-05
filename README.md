# 🌺 Baoule Learn

Application mobile Flutter pour apprendre le **Baoulé**, langue du peuple Akan de Côte d'Ivoire 🇨🇮

---

## 📁 Structure du projet

```
lib/
├── main.dart                    # Point d'entrée
├── core/
│   ├── theme.dart               # Couleurs, thème global
│   └── constants.dart           # Constantes de l'app
├── data/
│   └── lessons_data.dart        # Contenu des leçons (Baoulé)
├── models/
│   └── lesson_model.dart        # Modèles de données
├── screens/
│   ├── splash_screen.dart       # Écran de démarrage animé
│   ├── onboarding_screen.dart   # Présentation de l'app
│   ├── home_screen.dart         # Accueil + liste des leçons
│   ├── lesson_screen.dart       # Quiz interactif
│   └── result_screen.dart       # Résultats + confettis
├── widgets/
│   ├── xp_bar.dart              # Barre XP et série
│   ├── heart_widget.dart        # Coeurs de vie
│   ├── lesson_card.dart         # Carte de leçon
│   └── answer_tile.dart         # Tuile de réponse animée
└── controllers/
    └── lesson_controller.dart   # Logique du quiz
```

---

## 🚀 Installation

```bash
# 1. Cloner / copier le projet
cd baoule_learn

# 2. Créer le dossier assets
mkdir -p assets/images

# 3. Installer les dépendances
flutter pub get

# 4. Lancer l'app
flutter run
```

---

## 📚 Leçons disponibles

| # | Unité | Contenu |
|---|-------|---------|
| 1 | 👋 Salutations | Akwaba, N'dɛ, Mi si, Mɛ, Yako |
| 2 | 🔢 Chiffres | Ngon (1), Abien (2), Anon (4), Nyo (5), Bla (10) |
| 3 | 👨‍👩‍👧 Famille | Ni (mère), Ba (père), Wa (enfant), Kaka (grand-mère) |
| 4 | 🎨 Couleurs | Fiɛ (rouge), Fitɛ (blanc), Tete (noir), Blɔ (vert) |
| 5 | 🍽️ Nourriture | Nzue (eau), Mlo (igname), Mi di (je mange) |

---

## ✨ Fonctionnalités

- ✅ **Splash Screen** animé avec gradient orange ivoirien
- ✅ **Onboarding** en 3 slides avec navigation fluide
- ✅ **Home Screen** avec header animé, progression XP et série
- ✅ **Leçons déverrouillables** progressivement
- ✅ **Quiz interactif** avec feedback immédiat
- ✅ **Animations** : shake sur erreur, slide, scale, fade
- ✅ **Système de coeurs** (vies)
- ✅ **Écran résultat** avec confettis animés
- ✅ **5 unités** avec contenu Baoulé authentique

---

## 🎨 Design

Couleurs inspirées du **drapeau ivoirien** :
- 🟠 Orange principal : `#FF6B00`
- 🟢 Vert succès : `#2ECC71`
- 🟡 Or XP : `#FFD700`
- 🔴 Rouge erreur : `#E74C3C`

---

## 📦 Dépendances

```yaml
dependencies:
  flutter: sdk
  cupertino_icons: ^1.0.6
  shared_preferences: ^2.2.2   # Pour persister la progression
```

---

## 🔮 Améliorations futures

- [ ] Persistance locale avec `shared_preferences`
- [ ] Audio pour la prononciation
- [ ] Système de niveaux (A1 → B2)
- [ ] Mode sombre
- [ ] Classement / leaderboard
- [ ] Notifications quotidiennes
