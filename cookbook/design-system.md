# Design System

## Direction

Shot uses a craft espresso identity: warm, precise, and compact. The app should look like a modern brewing notebook with clear numbers and calm surfaces. It must not look like the default Flutter counter app or a generic brown dashboard.

## Color Tokens

### Light

- Background: `#F8F4EE`
- Surface: `#FFFDF8`
- Elevated surface: `#FFFFFF`
- Primary espresso: `#5A3825`
- Primary pressed: `#3B2418`
- Caramel accent: `#C47A3A`
- Mint success: `#5E8C6A`
- Ink: `#201A16`
- Muted text: `#766A60`
- Border: `#E5D8C9`

### Dark

- Background: `#161412`
- Surface: `#211D19`
- Elevated surface: `#2C251F`
- Primary espresso: `#D5A16A`
- Primary pressed: `#F0C28E`
- Caramel accent: `#C98243`
- Mint success: `#83B28C`
- Ink: `#F8EEE3`
- Muted text: `#BBAEA2`
- Border: `#463A31`

Neutral surfaces must stay dominant. Brown/caramel is used for emphasis, not every container.

## Typography

- Use system font stack for reliability and offline tests.
- Hero recipe number: 28-36sp, semi-bold.
- Screen title: 24-28sp, semi-bold.
- Section title: 16-18sp, semi-bold.
- Body: 14-16sp.
- Metadata: 12-13sp.
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

- Primary: filled espresso/caramel, 44dp minimum height.
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
