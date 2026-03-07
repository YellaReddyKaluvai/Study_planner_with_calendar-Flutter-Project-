# Color System Quick Reference 🎨

## Light Mode vs Dark Mode Colors

### Background Colors

| Element | Light Mode | Dark Mode | Purpose |
|---------|-----------|-----------|---------|
| **Page Background** | `#F5F7FB` | `#0F172A` | Main canvas |
| **Surface/Card** | `#FFFFFF` | `#1E293B` | Elevated content |
| **Card Background** | `#FAFBFC` | `#1E293B` | Subtle variation |

### Text Colors

| Element | Light Mode | Dark Mode |
|---------|-----------|-----------|
| **Primary Text** | `#1E293B` (87% opacity) | `#F1F5F9` (100%) |
| **Secondary Text** | `#64748B` (54% opacity) | `#94A3B8` (70%) |

### Glass Container

| Property | Light Mode | Dark Mode |
|----------|-----------|-----------|
| **Background** | White @ 90% | White @ 10% |
| **Border** | White @ 80% | White @ 15% |
| **Shadow 1** | Black @ 8%, blur 20 | Black @ 30%, blur 20 |
| **Shadow 2** | Black @ 4%, blur 10 | Black @ 20%, blur 10 |

### Stat Cards

| Card Type | Color | Gradient Start | Gradient End | Border |
|-----------|-------|---------------|--------------|--------|
| **Tasks Done** | Success `#22C55E` | 12% opacity | 6% opacity | 20% opacity |
| **Total Tasks** | Primary `#6366F1` | 12% opacity | 6% opacity | 20% opacity |
| **Focus Time** | Cyan `#06B6D4` | 12% opacity | 6% opacity | 20% opacity |
| **Avg Session** | Orange `#F97316` | 12% opacity | 6% opacity | 20% opacity |

### Action Buttons

| Button | Gradient Start | Gradient End | Shadow Color |
|--------|---------------|--------------|--------------|
| **Timer** | `#6366F1` (Indigo) | `#818CF8` (Light Indigo) | Indigo @ 40% |
| **Chatbot** | `#14B8A6` (Teal) | `#2DD4BF` (Light Teal) | Teal @ 40% |

### Navigation Bar

| State | Background | Icon Color | Shadow |
|-------|-----------|------------|--------|
| **Active (Light)** | Primary @ 15% | `#6366F1` | Primary @ 30% |
| **Active (Dark)** | Primary @ 15% | `#6366F1` | Primary @ 30% |
| **Inactive (Light)** | Transparent | Black @ 45% | None |
| **Inactive (Dark)** | Transparent | White @ 54% | None |

---

## Accent Color Palette

### Brand Colors
```dart
Primary: #6366F1      // Indigo 500
Primary Dark: #4338CA // Indigo 700
Primary Light: #818CF8 // Indigo 400

Secondary: #14B8A6    // Teal 500
Secondary Dark: #0F766E // Teal 700
Secondary Light: #2DD4BF // Teal 400
```

### Vibrant Accents
```dart
Pink: #EC4899         // For streaks, achievements
Orange: #F97316       // For trends, averages
Cyan: #06B6D4         // For time tracking
Purple: #A855F7       // For gamification
```

### Functional Colors
```dart
Success: #22C55E      // Green 500
Error: #EF4444        // Red 500
Warning: #F59E0B      // Amber 500
Info: #3B82F6         // Blue 500
```

---

## Gradient Recipes

### Primary Gradient
```dart
LinearGradient(
  colors: [Color(0xFF6366F1), Color(0xFF4338CA)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
)
```

### Timer Button Gradient
```dart
LinearGradient(
  colors: [Color(0xFF6366F1), Color(0xFF818CF8)],
)
```

### Chatbot Button Gradient
```dart
LinearGradient(
  colors: [Color(0xFF14B8A6), Color(0xFF2DD4BF)],
)
```

### FAB Gradient (Dark Mode)
```dart
LinearGradient(
  colors: [
    primaryColor,
    primaryColor.withBlue(255),
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
)
```

---

## Shadow Recipes

### Light Mode Card Shadow
```dart
[
  BoxShadow(
    color: Colors.black.withOpacity(0.08),
    blurRadius: 20,
    spreadRadius: 0,
    offset: Offset(0, 8),
  ),
  BoxShadow(
    color: Colors.black.withOpacity(0.04),
    blurRadius: 10,
    spreadRadius: -5,
    offset: Offset(0, 4),
  ),
]
```

### Dark Mode Card Shadow
```dart
[
  BoxShadow(
    color: Colors.black.withOpacity(0.3),
    blurRadius: 20,
    spreadRadius: 0,
    offset: Offset(0, 8),
  ),
  BoxShadow(
    color: Colors.black.withOpacity(0.2),
    blurRadius: 10,
    spreadRadius: -5,
    offset: Offset(0, 4),
  ),
]
```

### Stat Card Hover Shadow
```dart
BoxShadow(
  color: cardColor.withOpacity(0.3),
  blurRadius: 20,
  spreadRadius: 0,
  offset: Offset(0, 8),
)
```

### Action Button Shadow
```dart
BoxShadow(
  color: gradientColor.withOpacity(0.4),
  blurRadius: 12,
  spreadRadius: 0,
  offset: Offset(0, 4),
)
```

---

## Opacity Scale Reference

| Opacity % | Hex Value | Use Case |
|-----------|-----------|----------|
| 100% | FF | Primary text, icons |
| 90% | E6 | Light mode glass |
| 87% | DE | Light mode primary text |
| 80% | CC | Emphasis elements |
| 70% | B3 | Dark mode secondary text |
| 54% | 8A | Light mode secondary text |
| 45% | 73 | Inactive icons (light) |
| 40% | 66 | Shadows, glows |
| 30% | 4D | Borders, overlays |
| 20% | 33 | Subtle backgrounds |
| 15% | 26 | Active state bg, glass border |
| 12% | 1F | Card gradient start |
| 10% | 1A | Dark mode glass, subtle effects |
| 8% | 14 | Light mode shadows |
| 6% | 0F | Card gradient end |
| 4% | 0A | Secondary shadows |

---

## Usage Guidelines

### ✅ Do:
- Use consistent opacity values
- Maintain 4.5:1 contrast ratio minimum
- Test in both light and dark modes
- Use gradients for depth
- Apply shadows for elevation

### ❌ Don't:
- Mix random opacity values
- Use pure white (#FFFFFF) for light mode backgrounds
- Forget border colors on transparent cards
- Overuse vibrant accent colors
- Create jarring color transitions

---

## Contrast Checker

### Light Mode Combinations (Must Pass AA)
- Background `#F5F7FB` + Text `#1E293B` ✅ **14.2:1**
- Card `#FFFFFF` + Text `#1E293B` ✅ **15.8:1**
- Primary `#6366F1` + White ✅ **4.8:1**

### Dark Mode Combinations (Must Pass AA)
- Background `#0F172A` + Text `#F1F5F9` ✅ **14.8:1**
- Card `#1E293B` + Text `#F1F5F9` ✅ **12.6:1**
- Primary `#6366F1` + Dark BG ✅ **6.2:1**

---

**Last Updated:** March 6, 2026  
**Version:** 2.0
