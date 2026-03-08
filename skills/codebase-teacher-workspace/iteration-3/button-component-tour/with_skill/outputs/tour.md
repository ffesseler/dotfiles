# Button Component Tour

## Overview

The Cryospace UI library contains two button components: **`Button`** (text button with optional icons) and **`ButtonIcon`** (icon-only button). Both are built using **CVA (Class Variance Authority)** for composable variant-driven styling, with **Radix UI's `Slot`** component for composition flexibility.

---

## Architecture

### Where It Lives
- **Regular Button**: `packages/ui/src/components/button.tsx`
- **Icon Button**: `packages/ui/src/components/button-icon.tsx`
- **Stories (Storybook examples)**: `button.stories.tsx` and `button-icon.stories.tsx`
- **Utilities**: `packages/ui/src/lib/utils.ts` (the `cn()` function)

### Technology Stack
1. **CVA (Class Variance Authority)** - Defines variants and their style combinations
2. **Tailwind CSS** - Utility-first styling framework
3. **Radix UI's Slot** - Enables polymorphic composition (the `asChild` pattern)
4. **Lucide React** - Icon library (including the loading spinner)
5. **clsx + tailwind-merge** - CSS class composition utility (via `cn()`)

---

## Button Component Deep Dive

### The Variant System

The `Button` component uses **CVA** to define a set of variant dimensions:

```typescript
const buttonVariants = cva(
  // Base styles (always applied)
  "inline-flex shrink-0 cursor-pointer items-center justify-center gap-2 rounded-lg font-bold text-sm leading-5 whitespace-nowrap transition-colors outline-none focus-visible:ring-[3px] focus-visible:ring-ring/50 disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-5",
  {
    variants: {
      // 3 visual impact levels
      impact: {
        primary: "",      // Solid filled button
        secondary: "bg-white border",  // Outlined button
        tertiary: "",     // Ghost/text button
      },
      // 5 semantic color modes
      mode: {
        brand: "",        // Primary color (blue)
        critical: "",     // Red (destructive actions)
        warning: "",      // Yellow
        success: "",      // Green
        default: "",      // Gray
      },
      // 2 size presets
      size: {
        large: "h-10 px-4",    // 40px height
        regular: "h-9 px-3",   // 36px height
      },
    },
    compoundVariants: [
      // 15 combinations of impact + mode (3 × 5)
      { impact: "primary", mode: "brand", className: "bg-[#519fc8] text-white hover:bg-[#1d7bae]" },
      { impact: "primary", mode: "critical", className: "bg-red-600 text-white hover:bg-red-500" },
      // ... etc
    ],
  },
);
```

### Variant Combinations (3 × 5 × 2 = 30 unique styles)

| Impact    | Visual Style           | Examples                          |
|-----------|------------------------|-----------------------------------|
| primary   | Solid filled           | Brand blue, red, yellow, green    |
| secondary | Outline with background| Outlined buttons with hover tint  |
| tertiary  | Text-only (ghost)      | Minimal, hover shows subtle bg    |

Each **mode** defines semantic meaning:
- **brand** (blue `#519fc8`) - Primary action
- **critical** (red) - Destructive action (delete, cancel)
- **warning** (yellow) - Caution action
- **success** (green) - Positive action
- **default** (gray) - Neutral action

### Key Features

#### 1. **Base Styles** (Always Applied)
```css
inline-flex shrink-0 cursor-pointer items-center justify-center gap-2 rounded-lg
font-bold text-sm leading-5 whitespace-nowrap transition-colors outline-none
focus-visible:ring-[3px] focus-visible:ring-ring/50 
disabled:pointer-events-none disabled:opacity-50
[&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-5
```

**What this does:**
- **`inline-flex`** + flex centering = icon + text alignment
- **`gap-2`** = space between icon and text
- **`font-bold text-sm`** = standard button typography
- **`focus-visible:ring`** = accessible focus state (keyboard navigation)
- **`disabled:opacity-50`** = visual feedback when disabled
- **SVG selector** = ensures icons inside buttons are always 5rem (`size-5`)

#### 2. **Loading State**
The `loading` prop replaces children with a spinner:
```typescript
{loading ? (
  <>
    <LoaderCircle className="size-5 animate-spin" />
    <span className="sr-only">Chargement...</span>  {/* Screen reader text */}
  </>
) : (
  children
)}
```

#### 3. **Polymorphic Composition** (the `asChild` prop)
```typescript
const Comp = asChild ? Slot.Root : "button";
return <Comp ... >
```
This allows using `Button` with custom components (e.g., as a link):
```jsx
<Button asChild>
  <a href="/dashboard">Go to Dashboard</a>
</Button>
```

#### 4. **Smart Class Merging**
```typescript
className={cn(buttonVariants({ impact, mode, size, className }))}
```
The `cn()` function (from `clsx` + `tailwind-merge`) intelligently merges classes, avoiding conflicts.

---

## ButtonIcon Component Deep Dive

The `ButtonIcon` is similar but for icon-only buttons (typically in toolbars, headers).

### Key Differences

```typescript
// Size is different: square dimensions
size: {
  large: "size-11 [&_svg:not([class*='size-'])]:size-5",    // 44px square
  regular: "size-9 [&_svg:not([class*='size-'])]:size-4",   // 36px square
},

// Mode includes "reverse" for dark backgrounds
mode: {
  brand: "",
  neutral: "",      // Gray instead of "default"
  critical: "",
  reverse: "",      // Light colors on dark bg
},
```

### Accessibility
Icon buttons **require** an `aria-label`:
```typescript
<ButtonIcon aria-label="Delete" mode="critical">
  <Trash2 />
</ButtonIcon>
```

---

## Variants Guide

### Button (Regular)

**Impacts:**
- **Primary** (solid fill) - Most prominent, use for main actions
- **Secondary** (outline) - Secondary actions, less emphasis
- **Tertiary** (ghost/text) - Minimal visual weight

**Modes:**
- **brand** (blue) - Main application flow
- **critical** (red) - Destructive: delete, cancel
- **warning** (yellow) - Cautious: confirm, risk
- **success** (green) - Positive: confirm, done
- **default** (gray) - Neutral: close, dismiss

**Sizes:**
- **large** (40px) - Primary CTAs
- **regular** (36px) - Secondary CTAs

### ButtonIcon (Icon Only)

**Impacts:** Same as Button (primary, secondary, tertiary)

**Modes:**
- **brand** (blue) - Primary icon actions
- **neutral** (gray) - Neutral icon actions
- **critical** (red) - Dangerous icon actions
- **reverse** (white/light on dark) - Use on dark backgrounds

**Sizes:**
- **large** (44px) - Prominent icon buttons
- **regular** (36px) - Compact icon buttons

---

## Usage Examples

### Regular Button

```jsx
// Primary brand button (default)
<Button>Create Tank</Button>

// Secondary with warning mode (outline)
<Button impact="secondary" mode="warning">
  Cancel Operation
</Button>

// Tertiary with critical mode (ghost/red text)
<Button impact="tertiary" mode="critical">
  Delete
</Button>

// With icons
<Button>
  <Plus /> Add Specimen
</Button>

<Button>
  Next <ChevronRight />
</Button>

// Loading state
<Button loading>
  Processing...  {/* Hidden, replaced with spinner */}
</Button>

// Disabled
<Button disabled>
  Cannot Act
</Button>

// As a link
<Button asChild>
  <a href="/specimens">View Specimens</a>
</Button>
```

### Icon Button

```jsx
// Primary brand icon button (default)
<ButtonIcon aria-label="Add new">
  <Plus />
</ButtonIcon>

// Secondary outline
<ButtonIcon impact="secondary" mode="brand" aria-label="Edit">
  <Pencil />
</ButtonIcon>

// Critical (red, for delete)
<ButtonIcon mode="critical" aria-label="Delete">
  <Trash2 />
</ButtonIcon>

// Reverse (light on dark background)
<div className="bg-gray-800 p-4">
  <ButtonIcon mode="reverse" aria-label="Close">
    <X />
  </ButtonIcon>
</div>

// Loading
<ButtonIcon loading aria-label="Processing">
  {/* Spinner shown */}
</ButtonIcon>
```

---

## How Styling Works

### Step-by-Step (CVA + Tailwind)

1. **Define variants** in CVA:
   ```typescript
   buttonVariants = cva(baseStyles, {
     variants: { impact: {...}, mode: {...}, size: {...} },
     compoundVariants: [ /* impact + mode combos */ ],
   })
   ```

2. **Select variant values** in component:
   ```typescript
   // User calls: <Button impact="primary" mode="critical" size="large">
   // Component extracts: impact, mode, size props
   ```

3. **CVA resolves styles**:
   - Finds matching `compoundVariants` entry
   - Returns a Tailwind class string like: `"bg-red-600 text-white hover:bg-red-500 h-10 px-4 inline-flex ..."`

4. **Merge with custom classes** using `cn()`:
   ```typescript
   cn(
     buttonVariants({ impact, mode, size, className }),
     // If className="rounded-full" is passed, it intelligently overrides "rounded-lg"
   )
   ```

5. **Apply to DOM**:
   ```jsx
   <button className="bg-red-600 text-white hover:bg-red-500 h-10 px-4 ...">
     Delete
   </button>
   ```

### Why `clsx` + `tailwind-merge`?

The `cn()` utility prevents Tailwind class conflicts:
- `clsx(input1, input2)` → joins all truthy values
- `twMerge()` → intelligently merges Tailwind classes, so `rounded-full` overrides `rounded-lg`

---

## Design Decisions

### 1. **CVA over Styled Components or CSS Modules**
- **Pro**: Variant combinations are explicit and type-safe
- **Pro**: Easy to extend or modify (no cascading issues)
- **Con**: Larger CSS surface area (all 30 button variants in the app)

### 2. **Slot for Polymorphism**
- Allows `<Button asChild><a href="...">Link</a></Button>` to render as an `<a>` tag with button styles
- Useful for accessibility and semantic HTML

### 3. **Compound Variants vs. Separate Classes**
- Using `compoundVariants` keeps the variant matrix readable in one place
- Alternative: compute styles dynamically (slower, less IDE support)

### 4. **SVG Auto-Sizing**
```css
[&_svg:not([class*='size-'])]:size-5
```
- If an icon **doesn't have its own size class**, it defaults to `size-5` (20px)
- Allows custom icon sizes when explicitly set: `<Plus className="size-7" />`

---

## Integration in Cryospace

The Button component is part of the **`@cryospace/ui`** package and is reused across:
- **Web app** (`apps/web`) - UI controls in forms, modals, toolbars
- **Storybook** - Component library documentation (`packages/ui/src/components/*.stories.tsx`)
- **Future mobile** - Once a React Native version is created

---

## Extending the Button

### Add a New Mode
1. Add to `buttonVariants` variants object:
   ```typescript
   mode: {
     // ... existing
     info: "",  // New mode
   }
   ```
2. Add `compoundVariants` for each impact + mode combo:
   ```typescript
   { impact: "primary", mode: "info", className: "bg-blue-500 text-white hover:bg-blue-600" },
   { impact: "secondary", mode: "info", className: "border-blue-500 text-blue-600 hover:bg-blue-50" },
   { impact: "tertiary", mode: "info", className: "text-blue-600 hover:bg-blue-50" },
   ```

### Add a New Impact
1. Add to variants:
   ```typescript
   impact: {
     // ... existing
     "high-contrast": "",
   }
   ```
2. Add `compoundVariants` for each impact + mode combo (5 new combinations)

### Pass Custom Classes
```jsx
<Button className="rounded-full">
  Custom Button
</Button>
```
The `cn()` utility merges these intelligently with variant classes.

---

## Storybook Stories

### Button Stories (`button.stories.tsx`)
- **Default** - Basic button
- **AllImpacts** - Shows primary, secondary, tertiary side-by-side
- **AllModes** - Grid of all 5 × 3 = 15 combinations
- **WithIcons** - Demonstrates icon placement and alignment
- **Loading** - Loading spinner state
- **Disabled** - Disabled state styling

### ButtonIcon Stories (`button-icon.stories.tsx`)
- **Default** - Basic icon button with Plus icon
- **AllVariants** - Shows all 3 impacts × 3 modes + reverse dark mode demo
- **Sizes** - Large vs. regular
- **Loading** - Spinning icon
- **Disabled** - Disabled state
- **Critical** - Red delete button example

**View in Storybook**: Run `pnpm storybook` and navigate to "Actions/ButtonRegular" or "Actions/ButtonIcon"

---

## Performance & Accessibility

### Performance
- **No runtime computation**: All styles pre-computed by CVA at build time
- **CSS-in-JS free**: Pure Tailwind, no CSS-in-JS overhead
- **Icon auto-sizing**: SVG size constraint prevents layout shifts

### Accessibility
- **Focus state**: `focus-visible:ring` provides clear keyboard navigation feedback
- **Loading screen reader**: `<span className="sr-only">Chargement...</span>`
- **Icon button labels**: `aria-label` required for screen readers
- **Disabled state**: Built-in `disabled` attribute support
- **Semantic HTML**: Can render as `<button>`, `<a>`, or custom component via `asChild`

---

## Quick Reference

### Defaults
| Prop      | Default Value |
|-----------|---------------|
| `impact`  | `"primary"`   |
| `mode`    | `"brand"`     |
| `size`    | `"large"`     |
| `loading` | `false`       |
| `disabled`| Inherited     |
| `asChild` | `false`       |

### Common Patterns
```jsx
// Successful action
<Button mode="success">Confirm</Button>

// Destructive action
<Button impact="secondary" mode="critical">Delete</Button>

// Loading submission
<Button loading>Processing...</Button>

// Disabled (e.g., form invalid)
<Button disabled>Submit</Button>

// Icon + text
<Button><Save /> Save Changes</Button>

// Icon only
<ButtonIcon aria-label="Save"><Save /></ButtonIcon>

// As a link
<Button asChild><Link to="/dashboard">Dashboard</Link></Button>
```

---

## Summary

The Button components are **production-ready, accessible, and composable**. They use:
- **CVA** for variant-driven styling (30 Button combinations, 20 ButtonIcon combinations)
- **Tailwind CSS** for utility styling
- **Radix UI's Slot** for polymorphic rendering
- **Accessible patterns** (focus states, ARIA labels, semantic HTML)
- **Loading states** with spinner icons
- **Class merging** via `clsx` + `tailwind-merge` to handle custom classes

Use the **Stories** in Storybook to explore all variants, and refer to the **Usage Examples** section for common patterns in your code.
