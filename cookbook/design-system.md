# Design System

## Direction

Shot uses a precise espresso-notebook identity: neutral, compact, and instrument-like with one warm coffee accent. The app should feel like a modern mobile tool, not a default Flutter screen or a generic brown dashboard.

## Color Tokens

### Light

- Background: `#FAFAF9`
- Foreground: `#18181B`
- Card: `#FFFFFF`
- Primary: `#27272A`
- Secondary: `#F4F4F5`
- Muted foreground: `#71717A`
- Accent: `#FFF7ED`
- Accent foreground: `#9A3412`
- Ring/accent coffee: `#D97706`
- Success: `#15803D`
- Destructive: `#DC2626`
- Border/input: `#E4E4E7`

### Dark

- Background: `#09090B`
- Foreground: `#FAFAFA`
- Card: `#18181B`
- Primary: `#FAFAFA`
- Secondary: `#27272A`
- Muted foreground: `#A1A1AA`
- Accent: `#431407`
- Accent foreground: `#FED7AA`
- Ring/accent coffee: `#F59E0B`
- Success: `#4ADE80`
- Destructive: `#F87171`
- Border: `#27272A`
- Input: `#3F3F46`

Neutral zinc surfaces must stay dominant. Orange/coffee accent is used for focus rings, selected recipe details, and small emphasis only.

## Typography

- Use Montserrat for Material and Shad typography.
- Hero recipe number: 36sp, weight 800.
- Screen title: 28sp, weight 800.
- Section title: 16sp, weight 800.
- Body: 14sp, weight 500.
- Metadata: 12-13sp, weight 700 for labels and 500 for secondary text.
- Letter spacing: 0.

## Components

### App Shell

- Bottom navigation with four destinations: Home, Beans, New Shot, History.
- `New Shot` may be emphasized with primary color but must remain part of nav.
- Screen padding: 16dp mobile baseline, 20dp on larger widths.

### Cards

- Border radius max 8dp.
- Thin border using design token.
- Subtle shadow only for primary recipe card.
- Cards must not be nested inside decorative cards.

### Buttons

- Primary: filled neutral foreground/background pair, 44dp minimum height.
- Secondary: outlined neutral.
- Destructive: text or outlined red, never dominant unless confirming.
- Icons should be used for common actions where Material icons exist.

### Metric Tiles

- Dose, yield, time, temperature, and ratio use fixed-height tiles.
- Unit label is always visible.
- On 320-359dp width, use two-column grid or stack.

### Forms

- Brewing order is mandatory.
- Numeric fields show unit suffix.
- Ratio field is read-only and recalculates while typing.
- Save action remains reachable when keyboard is open.
- Validation messages are concise and field-local when possible.

### Empty States

- No Beans: direct Add Bean action.
- No Shots: direct New Shot action, disabled or guided if no beans exist.
- History filter no result: clear filter action.

## Accessibility

- Tap targets at least 44dp.
- Text contrast must remain readable in light and dark.
- Do not rely on color alone for status.
- Date, rating, and ratio values need text labels.
