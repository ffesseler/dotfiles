# Button Component Tour – Cryospace UI Library

## Overview

The Cryospace UI library provides **two button components**:

1. **`Button`** – Text-based button with optional icons
2. **`ButtonIcon`** – Icon-only button for compact UIs

Both are built using:
- **CVA (Class Variance Authority)** – Type-safe variant management
- **Tailwind CSS** – Styling system
- **Radix UI** – Primitive components and accessibility
- **Lucide React** – Icons

---

## Architecture: Class Variance Authority (CVA)

Instead of manually building conditional className strings, we use **CVA** to define semantic variants that automatically resolve to Tailwind classes.

### Why CVA?

- **Type Safety**: TypeScript ensures only valid variant combinations exist
- **Readability**: Variants are explicit and self-documenting
- **Maintainability**: All style logic lives in one place
- **Scalability**: Easy to add new variants without touching component logic

---

## Regular Button Component

### File Location
`packages/ui/src/components/button.tsx`

### Component Props

```typescript
React.ComponentProps<"button"> &
  VariantProps<typeof buttonVariants> & {
    asChild?: boolean;          // Use Slot.Root to accept children as trigger
    loading?: boolean;          // Show spinner, disable button
  }
```

### Variant System

#### **Impact** (Visual Hierarchy)
- **`primary`** – Filled background. Most prominent. Default.
- **`secondary`** – Outline with border. Less prominent.
- **`tertiary`** – Text-only (no background). Lowest prominence.

#### **Mode** (Semantic Meaning)
- **`brand`** – Primary action, Cryospace blue (#519fc8)
- **`critical`** – Destructive action (red)
- **`warning`** – Caution action (yellow)
- **`success`** – Positive/confirmatory action (green)
- **`default`** – Neutral gray

#### **Size**
- **`large`** – Height 40px (h-10), padding 0 16px
- **`regular`** – Height 36px (h-9), padding 0 12px

### Default Variants

```typescript
defaultVariants: {
  impact: "primary",
  mode: "brand",
  size: "large",
}
```

A button renders as a **large, filled, brand-colored button** if no props are passed.

### CVA Definition (Simplified)

```typescript
const buttonVariants = cva(
  // Base styles (applied to all buttons)
  "inline-flex shrink-0 cursor-pointer items-center justify-center gap-2 rounded-lg font-bold text-sm leading-5 whitespace-nowrap transition-colors outline-none focus-visible:ring-[3px] focus-visible:ring-ring/50 disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-5",
  {
    variants: { /* impact, mode, size definitions */ },
    compoundVariants: [
      // Combinations: e.g., impact=primary + mode=brand → bg-[#519fc8] text-white hover:bg-[#1d7bae]
    ],
    defaultVariants: { /* defaults */ }
  },
);
```

### Key Features

#### 1. **Icon Support**
SVGs inside buttons automatically get:
- `pointer-events-none` – Don't intercept clicks
- `shrink-0` – Don't squeeze when space is tight
- `size-5` – Standard 20px (unless custom size class exists)

```jsx
<Button>
  <Plus />
  Add Item
</Button>
```

#### 2. **Loading State**
When `loading={true}`:
- Button becomes disabled
- Content replaced with spinning `LoaderCircle` icon
- Screen reader text: "Chargement..." (French for "Loading...")

```jsx
<Button loading>Submit</Button>
```

#### 3. **polymorphic** (`asChild`)
Use `asChild={true}` to render the button as a different component (e.g., `<a>`, form trigger).

Powered by Radix UI's `Slot.Root`:

```jsx
<Button asChild>
  <a href="/settings">Go to Settings</a>
</Button>
```

#### 4. **Color Combinations**
Compound variants ensure every impact + mode combination is defined:

| Impact    | Brand                  | Critical          | Warning          | Success          | Default          |
|-----------|------------------------|-------------------|------------------|------------------|------------------|
| Primary   | Blue (#519fc8)         | Red               | Yellow           | Green            | Gray             |
| Secondary | Blue outline           | Red outline       | Yellow outline   | Green outline    | Gray outline     |
| Tertiary  | Blue text              | Red text          | Yellow text      | Green text       | Gray text        |

---

## Icon Button Component

### File Location
`packages/ui/src/components/button-icon.tsx`

### Why a Separate Component?

Icon buttons have different requirements:
- **No padding** – Just a square or circle
- **Fixed size** – Typically 44px (large) or 36px (regular)
- **Different modes** – Includes "reverse" (white icon on dark bg)
- **No gap** – No space between icon and anything (there's nothing else!)
- **Mandatory aria-label** – No visible text, so accessibility label is critical

### Variant System

#### **Impact**
Same as regular button: `primary`, `secondary`, `tertiary`

#### **Mode**
- **`brand`** – Cryospace blue
- **`neutral`** – Gray
- **`critical`** – Red (delete actions)
- **`reverse`** – White/light on dark backgrounds

#### **Size**
- **`large`** – 44px (size-11), icon 20px
- **`regular`** – 36px (size-9), icon 16px

### Component Props

```typescript
React.ComponentProps<"button"> &
  VariantProps<typeof buttonIconVariants> & {
    loading?: boolean;
    "aria-label": string;  // Mandatory for accessibility
  }
```

### Examples from Storybook

```jsx
// Primary brand icon button
<ButtonIcon impact="primary" mode="brand" aria-label="Add">
  <Plus />
</ButtonIcon>

// Secondary critical (delete)
<ButtonIcon impact="secondary" mode="critical" aria-label="Delete">
  <Trash2 />
</ButtonIcon>

// Tertiary on dark background (reverse mode)
<ButtonIcon impact="tertiary" mode="reverse" aria-label="Close">
  <X />
</ButtonIcon>
```

---

## Shared Styling Patterns

### Utility Function: `cn()`
Located in `packages/ui/src/lib/utils.ts`:

```typescript
import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}
```

**What it does:**
1. **`clsx()`** – Merges multiple classname sources (strings, objects, arrays)
2. **`twMerge()`** – Intelligently merges Tailwind classes (resolves conflicts)

**Why needed:**
Tailwind doesn't merge conflicting utilities. If CVA generates `bg-blue-600` and you pass `className="bg-red-500"`, both would apply, causing issues. `twMerge()` intelligently resolves this.

Example:
```jsx
<Button className="px-6">Submit</Button>
// Tailwind classes: ...px-3... from variants, but px-6 wins (merged correctly)
```

---

## Accessibility Features

1. **Focus Ring**
   ```css
   focus-visible:ring-[3px] focus-visible:ring-ring/50
   ```
   Visible outline on keyboard focus (3px ring at 50% opacity)

2. **Disabled State**
   ```css
   disabled:pointer-events-none disabled:opacity-50
   ```
   Can't be clicked or interacted with

3. **Icon Button Labels**
   ```jsx
   <ButtonIcon aria-label="Delete item">
     <Trash2 />
   </ButtonIcon>
   ```
   Screen readers announce "Delete item" button

4. **Loading State**
   ```jsx
   <span className="sr-only">Chargement...</span>
   ```
   Screen reader only text during loading

5. **SVG Optimization**
   ```css
   [&_svg]:pointer-events-none
   ```
   Prevents SVG from stealing click events

---

## How to Use: Examples

### Basic Button
```jsx
import { Button } from "@cryospace/ui";

export function MyComponent() {
  return <Button onClick={() => alert("Clicked!")}>Click me</Button>;
}
```
Renders: **Large, filled, brand-blue button** with "Click me" text.

### Destructive Action
```jsx
<Button impact="primary" mode="critical">
  Delete Tank
</Button>
```
Renders: **Red button** for delete actions.

### Icon Button with Loading
```jsx
const [saving, setSaving] = useState(false);

return (
  <Button loading={saving} onClick={async () => {
    setSaving(true);
    await saveTank();
    setSaving(false);
  }}>
    Save
  </Button>
);
```

### Icon + Text
```jsx
<Button>
  <Plus />
  Add Specimen
</Button>
```
Renders: **Icon (20px) + text**, horizontally centered with 8px gap between them.

### Icon-Only (with Tooltip)
```jsx
<ButtonIcon
  impact="secondary"
  mode="critical"
  aria-label="Delete this specimen"
  onClick={() => deleteSpecimen()}
>
  <Trash2 />
</ButtonIcon>
```

### As a Link
```jsx
<Button asChild>
  <a href="/settings">Open Settings</a>
</Button>
```
Renders: **`<a>` tag** with button styling and behavior.

---

## Design Decisions

### Why CVA Over Styled-Components?
- **No runtime overhead** – Classes resolved at build time
- **Tree-shakeable** – Unused styles can be purged by Tailwind
- **Integrates with Tailwind** – No new CSS syntax to learn
- **Type-safe by default** – TypeScript prevents invalid combinations

### Why `cn()` Over Direct classname?
- **Solves Tailwind conflicts** – `twMerge()` intelligently handles overlapping utilities
- **Cleaner syntax** – No need to manually manage class ordering
- **Composable** – Easy to extend with custom classnames

### Impact vs. Mode System
- **Impact** – Visual hierarchy (how prominent is this button?)
- **Mode** – Semantic meaning (what does this button do?)

Separating them allows independent variation. A "Delete" button can be primary (most prominent) AND critical (red).

---

## Storybook

View all variants interactively:

```bash
pnpm --filter @cryospace/ui run storybook
```

Opens: `http://localhost:6006`

Stories available:
- **Actions/ButtonRegular** – All Button variants
- **Actions/ButtonIcon** – All ButtonIcon variants

---

## File Structure

```
packages/ui/src/components/
├── button.tsx                    # Regular button component
├── button.stories.tsx            # Button stories for Storybook
├── button-icon.tsx               # Icon-only button component
├── button-icon.stories.tsx       # Icon button stories
└── ... (other components)

packages/ui/src/lib/
└── utils.ts                      # cn() utility function
```

---

## Key Takeaways

1. **CVA handles all styling** – No manual className logic in components
2. **Variants are type-safe** – Invalid combinations won't compile
3. **Base styles are shared** – Reduces duplication (focus, disabled, layout)
4. **Compound variants solve complexity** – Every color combo is explicit
5. **Accessibility is built-in** – Focus rings, disabled states, aria-labels
6. **`cn()` is essential** – Merges classnames intelligently
7. **Two components for two jobs** – Button (text + icon) vs. ButtonIcon (icon only)
8. **Storybook is the reference** – Explore all variants there first

---

## Next Steps to Explore

1. **View in Storybook** – Run `pnpm storybook` to see all variants
2. **Check usage** – Search codebase for `<Button` or `<ButtonIcon` imports
3. **Understand Tailwind** – The base styles use Tailwind utilities
4. **Learn CVA syntax** – [class-variance-authority docs](https://cva.style/)
