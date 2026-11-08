# 🎨 MindHaven Theme & Design System

This document describes the visual theme used in MindHaven: colours, light/dark mode, typography, and the accent colours used across features.

The app uses a **calm, neutral greyscale base** so the interface feels quiet and non-distracting, an important choice for a mental health app. **Accent colours** are used sparingly to show meaning (mood level, categories, warnings).

---

## 1. Where the theme lives

| File | Purpose |
|---|---|
| [`lib/themes/light_mode.dart`](../lib/themes/light_mode.dart) | Light `ThemeData` (`lightMode`) |
| [`lib/themes/dark_mode.dart`](../lib/themes/dark_mode.dart) | Dark `ThemeData` (`darkMode`) |
| [`lib/widgets/widget_support.dart`](../lib/widgets/widget_support.dart) | Reusable text styles (`AppWidget`) and toast style |
| [`lib/features/mood_tracker/utils/mood_utils.dart`](../lib/features/mood_tracker/utils/mood_utils.dart) | Mood-score colour scale |
| [`pubspec.yaml`](../pubspec.yaml) | Custom font registration |

Both themes are registered in [`lib/main.dart`](../lib/main.dart):

```dart
MaterialApp(
  theme: lightMode,
  darkTheme: darkMode,
  ...
)
```

The app is built on Flutter's **Material Design 3** (the default for `ThemeData` in current Flutter versions). Widgets read colours from the theme with `Theme.of(context).colorScheme`, most often `colorScheme.primary`.

---

## 2. Colour scheme

### ☀️ Light mode

```dart
ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.light(
    surface: Colors.grey.shade100,
    primary: Colors.grey.shade800,
    secondary: Colors.grey.shade200,
    tertiary: Colors.white,
    inversePrimary: Colors.grey.shade600,
  ),
  scaffoldBackgroundColor: Colors.white,
  iconTheme: const IconThemeData(color: Colors.black),
);
```

| Role | Flutter colour | Hex | Used for |
|---|---|---|---|
| `scaffoldBackgroundColor` | `Colors.white` | `#FFFFFF` | Page background (white so card shadows stand out) |
| `surface` | `grey.shade100` | `#F5F5F5` | Cards, sheets, surfaces |
| `primary` | `grey.shade800` | `#424242` | Main text/icons, buttons, AppBar icons |
| `secondary` | `grey.shade200` | `#EEEEEE` | Text fields, secondary containers |
| `tertiary` | `Colors.white` | `#FFFFFF` | Inner containers / highlights |
| `inversePrimary` | `grey.shade600` | `#757575` | AppBar background, contrasting elements |
| `iconTheme` | `Colors.black` | `#000000` | Drawer and default icons |

### 🌙 Dark mode

```dart
ThemeData darkMode = ThemeData(
  colorScheme: ColorScheme.dark(
    surface: Colors.grey.shade900,
    primary: Colors.grey.shade300,
    secondary: const Color.fromARGB(255, 39, 39, 39),
    tertiary: const Color.fromARGB(255, 39, 39, 39),
    inversePrimary: Colors.grey.shade300,
  ),
  scaffoldBackgroundColor: Colors.grey.shade900,
  iconTheme: const IconThemeData(color: Colors.white),
);
```

| Role | Flutter colour | Hex | Used for |
|---|---|---|---|
| `scaffoldBackgroundColor` | `grey.shade900` | `#212121` | Page background |
| `surface` | `grey.shade900` | `#212121` | Cards, sheets, surfaces |
| `primary` | `grey.shade300` | `#E0E0E0` | Main text/icons, buttons, AppBar icons |
| `secondary` | `ARGB(255, 39, 39, 39)` | `#272727` | Text fields, secondary containers |
| `tertiary` | `ARGB(255, 39, 39, 39)` | `#272727` | Inner containers |
| `inversePrimary` | `grey.shade300` | `#E0E0E0` | AppBar background, contrasting elements |
| `iconTheme` | `Colors.white` | `#FFFFFF` | Drawer and default icons |

### Palette at a glance

```
Light:  #FFFFFF ░ #F5F5F5 ░ #EEEEEE ░ #757575 ▓ #424242 █
Dark:   #212121 █ #272727 █ #E0E0E0 ░
```

---

## 3. Light / dark mode switching

- `MaterialApp` sets no `themeMode`, so Flutter uses the default **`ThemeMode.system`**. The app **automatically follows the phone's system setting**: light theme when the device is in light mode, dark theme when it's in dark mode.
- Settings has a **Dark Mode** toggle that saves a `darkMode` value (default `false`) to the user's settings.

> ⚠️ **Known limitation:** the Settings *Dark Mode* toggle currently only saves the preference. It isn't connected to `MaterialApp.themeMode`, so it doesn't change the theme yet. To connect it, read the saved setting (e.g. via a `ThemeCubit`) and pass `themeMode: isDark ? ThemeMode.dark : ThemeMode.light` to `MaterialApp`.

---

## 4. Typography

Two custom fonts are bundled in `fonts/` and registered in `pubspec.yaml`:

| Font | File | Character | Used for |
|---|---|---|---|
| **Poppins** (SemiBold) | `fonts/Poppins-SemiBold.ttf` | Clean, modern sans-serif | Headings, body text, labels |
| **Courgette** | `fonts/Courgette-Regular.ttf` | Friendly, handwritten script | Greetings, soft/decorative text |

### Text styles (`AppWidget` in `widget_support.dart`)

| Style | Font | Size | Weight | Colour |
|---|---|---|---|---|
| `HeadlineTextFieldStyle()` | Poppins | 24 | Bold | Black |
| `boldTextFieldStyle()` | Poppins | 20 | Bold | Black |
| `WhiteBoldTextFieldStyle()` | Poppins | 20 | Bold | White |
| `WhiteHeadlineTextFieldStyle()` | Poppins | 18 | Bold | White |
| `semiTextFieldStyle()` | Poppins | 18 | w500 | Black |
| `bodyTextFieldStyle()` | Poppins | 18 | w500 | Black |
| `semiCourgetteTextFieldStyle()` | Courgette | 40 | w500 | Black |
| `LightTextFieldStyle()` | Courgette | 16 | w500 | Black 38% (`Colors.black38`) |
| `WhiteLightTextFieldStyle()` | Courgette | 18 | w500 | White |
| `EmoticonCourgetteTextFieldStyle()` | Poppins | 12 | Regular | White |

**Toasts** (`AppWidget.showToast`): centred, `Colors.black54` background, white 16px text.

---

## 5. Accent & semantic colours

Accent colours sit on top of the greyscale base. Each one carries meaning.

### Mood score scale (`MoodUtils.getMoodColor`)

| Score | Colour | Hex | Meaning |
|---|---|---|---|
| 1 – 3 | 🔴 `Colors.red` | `#F44336` | Low mood |
| 4 – 5 | 🟠 `Colors.orange` | `#FF9800` | Below average |
| 6 – 7 | 🟡 `Colors.amber` | `#FFC107` | Okay |
| 8 – 10 | 🟢 `Colors.green` | `#4CAF50` | Good mood |

### Home screen

| Element | Colour |
|---|---|
| Quick action – Start a Conversation | Theme `primary` |
| Quick action – Write in Journal | 🔵 Blue `#2196F3` |
| Quick action – View Mood Insights | 🟦 Teal `#009688` |
| Quick action – View Achievements | 🟡 Amber `#FFC107` |
| Stat – Journal Entries | 🔵 Blue |
| Stat – Chat Sessions | 🟣 Purple `#9C27B0` |
| Stat – Total Messages | 🟦 Teal |
| Stat – Mood Entries | 🟠 Orange |
| Resource cards / helpline icons | 🔴 Red 700 `#D32F2F` (on 10% red tint) |
| Phone numbers / links | 🔵 Blue 700 `#1976D2` |

### Gamification

| Element | Colour |
|---|---|
| Daily challenges | 🟠 Orange |
| Weekly challenges | 🟣 Purple |
| Points star / level progress bar | 🟡 Amber |
| Category – Mood Tracking | 🔵 Blue |
| Category – Journaling | 🟣 Purple |
| Category – Chat Engagement | 🟢 Green |
| Category – Wellness | 🟦 Teal |
| Category – Streaks | 🟠 Orange |
| Category – Special | 🩷 Pink `#E91E63` |

**Achievement tiers**

| Tier | Colour | Hex |
|---|---|---|
| 🥉 Bronze | `Colors.brown` | `#795548` |
| 🥈 Silver | `Colors.grey` | `#9E9E9E` |
| 🥇 Gold | `Colors.amber` | `#FFC107` |
| 💠 Platinum | `Colors.cyan` | `#00BCD4` |
| 💎 Diamond | `Colors.blue` | `#2196F3` |

### Chatbot status colours

| State | Colour |
|---|---|
| Moderated / filtered message | 🟠 Orange tints (`orange[50]`, `orange[100]`, shield icon `orange[700]`) |
| Warning banner | 🟠 Orange 800 `#EF6C00` |
| Crisis alert | 🔴 Red on `red[50]` `#FFEBEE` background |
| Success / confirm actions | 🟢 Green |
| Destructive actions | 🔴 Red |

### Settings / dialogs

- **Delete account** and **Clear data** dialogs use 🔴 red for destructive actions.

---

## 6. Design principles

1. **Neutral first.** A greyscale base keeps the app calm and accessible for users who may be feeling anxious or overwhelmed.
2. **Colour has meaning.** Accent colours always mean something (mood level, category, warning), never just decoration.
3. **Warm & approachable type.** Poppins for clarity, with Courgette adding a friendly, personal touch.
4. **High contrast.** Dark `primary` on light backgrounds (and the reverse in dark mode) keeps text and icons readable in both themes.
5. **Red is reserved** for crisis support, warnings and destructive actions, so it always stands out.

---

## 7. Using the theme in code

```dart
final colors = Theme.of(context).colorScheme;

Container(
  color: colors.secondary,               // themed background
  child: Text(
    'Hello',
    style: TextStyle(color: colors.primary, fontFamily: 'Poppins'),
  ),
);

// Predefined text style
Text(AppWidget.getGreeting(), style: AppWidget.semiCourgetteTextFieldStyle());

// Mood colour
Icon(Icons.circle, color: MoodUtils.getMoodColor(entry.score));
```

> 💡 **Tip:** prefer `Theme.of(context).colorScheme` over hard-coded `Colors.black`/`Colors.white` so widgets adapt correctly to dark mode. Some `AppWidget` styles use fixed black or white text and won't switch automatically.
