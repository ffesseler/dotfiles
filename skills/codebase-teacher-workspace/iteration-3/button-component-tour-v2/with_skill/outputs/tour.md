# Button Component Tour - Cryospace UI Library

## Welcome! Let's understand how the Button component is built

You've just entered the Cryospace UI library, where the Button component is a foundational building block. This tour will walk you through:
1. **What the Button component is** (conceptually)
2. **How it's built** (the actual code)
3. **The design system it uses** (variants, theming)
4. **How it relates to the rest of the codebase**

By the end, you'll understand not just *how* the button works, but *why* it's designed this way.

---

## 🎯 The Quick Picture

The Button component lives in:
```
packages/ui/src/components/
├── button.tsx           # Main regular button component
├── button.stories.tsx   # Storybook stories (visual tests & documentation)
├── button-icon.tsx      # Icon-only button variant
└── button-icon.stories.tsx
```

**Key insight:** There are TWO button components:
- **`Button`** — Text + optional icons (with text content)
- **`ButtonIcon`** — Icons only (for compact toolbars, icon-only actions)

Both use the same design pattern, so we'll focus on understanding the regular `Button` first, then you'll see the `ButtonIcon` follows the same recipe.

---

## 🏗️ Part 1: The Architecture - Class Variance Authority (CVA)

### What is CVA?

Class Variance Authority is a **variant management system** for styling components. Think of it like a "variant factory"—you define slots (impact, mode, size) and CVA generates all the valid combinations for you.

Here's the pattern:

```typescript
const buttonVariants = cva(
  // Base styles (applied to ALL buttons)
  "inline-flex shrink-0 cursor-pointer items-center justify-center ...",
  {
    variants: {
      impact: { primary: "", secondary: "bg-white border", tertiary: "" },
      mode: { brand: "", critical: "", warning: "", success: "", default: "" },
      size: { large: "h-10 px-4", regular: "h-9 px-3" }
    },
    compoundVariants: [
      // Specific combinations like "primary + brand = blue button"
      { impact: "primary", mode: "brand", className: "bg-[#519fc8] text-white hover:bg-[#1d7bae]" },
      // ... more combinations
    ],
    defaultVariants: {
      impact: "primary",
      mode: "brand",
      size: "large"
    }
  }
);
```

**Why use CVA?**
- Prevents style conflicts (no accidental classname collisions)
- Makes variant combinations explicit and exhaustive
- Type-safe (TypeScript knows what variants exist)
- Scales: 3 impact × 5 mode × 2 size = 30 combinations. CVA manages all of them.

---

## 🎨 Part 2: The Design System - Variants Explained

### The Three Dimensions of a Button

#### **Dimension 1: Impact** (Visual weight—how prominent is it?)

| Impact | Purpose | Example |
|--------|---------|---------|
| **primary** | Main action (calls attention, solid background) | "Save", "Submit" |
| **secondary** | Alternative action (outlined, less prominent) | "Cancel", "Preview" |
| **tertiary** | Minimal action (text only, least prominent) | Links, inline actions |

#### **Dimension 2: Mode** (Semantic meaning—what kind of action is this?)

| Mode | Color | Semantics |
|------|-------|-----------|
| **brand** | Blue (#519fc8) | Primary product actions |
| **critical** | Red | Destructive (delete, remove) |
| **warning** | Yellow | Caution or alert |
| **success** | Green | Confirmation or positive outcome |
| **default** | Gray | Neutral/secondary actions |

#### **Dimension 3: Size** (Dimensions—how much space does it take?)

| Size | Height | Padding | Use Case |
|------|--------|---------|----------|
| **large** | 40px (h-10) | 16px (px-4) | Primary actions, hero buttons |
| **regular** | 36px (h-9) | 12px (px-3) | Standard form buttons, toolbars |

### Why This Design?

These three dimensions let you express **every button scenario** in the app:

- "Delete this specimen" → `impact="primary" mode="critical"` (screams danger, can't miss it)
- "Optional secondary action" → `impact="secondary" mode="brand"` (styled but not in your face)
- "Discard changes?" → `impact="tertiary" mode="warning"` (minimal, just a fallback)

---

## 💻 Part 3: The Implementation

### The Button Component Code

```typescript
function Button({
  className,
  impact,
  mode,
  size,
  loading = false,
  asChild = false,
  children,
  disabled,
  ...props
}: React.ComponentProps<"button"> &
  VariantProps<typeof buttonVariants> & {
    asChild?: boolean;
    loading?: boolean;
  }) {
  
  const Comp = asChild ? Slot.Root : "button";

  return (
    <Comp
      data-slot="button"
      className={cn(buttonVariants({ impact, mode, size, className }))}
      disabled={disabled || loading}
      {...props}
    >
      {loading ? (
        <>
          <LoaderCircle className="size-5 animate-spin" />
          <span className="sr-only">Chargement...</span>
        </>
      ) : (
        children
      )}
    </Comp>
  );
}
```

### Breaking It Down

**1. Props Merging:**
```typescript
React.ComponentProps<"button">  // All native button props (onClick, disabled, etc.)
& VariantProps<typeof buttonVariants>  // impact, mode, size
& { asChild?: boolean; loading?: boolean }  // Custom props
```

This tells TypeScript: "This component accepts everything a native button accepts, PLUS our custom variant and feature props."

**2. Polymorphism with `asChild`:**
```typescript
const Comp = asChild ? Slot.Root : "button";
```

The `asChild` prop (from Radix UI) lets you use a Button as a different element:
```tsx
// Renders as a link with button styling
<Button asChild>
  <a href="/dashboard">Go to dashboard</a>
</Button>

// Renders as a native button (default)
<Button>Click me</Button>
```

This is powerful for **composition**—you can style any element like a button without duplicating styles.

**3. Combining Classes with `cn()`:**
```typescript
className={cn(buttonVariants({ impact, mode, size, className }))}
```

The `cn()` utility (from `utils.ts`) uses two libraries:
- **clsx** — merges conditional classes
- **tailwind-merge** — smartly overrides Tailwind classes

So if a parent passes `className="px-6"`, it won't conflict with button's `px-4`—`tailwind-merge` resolves the conflict.

**4. Loading State:**
```typescript
{loading ? (
  <>
    <LoaderCircle className="size-5 animate-spin" />
    <span className="sr-only">Chargement...</span>
  </>
) : (
  children
)}
```

When `loading={true}`:
- Shows a spinning loader icon
- Hides text content (replaced with loader)
- Sets `disabled={disabled || loading}` so button can't be clicked
- `sr-only` = "screen reader only" — visually hidden but announced to accessibility tools

---

## 🎭 Part 4: Real-World Examples

### Example 1: A Primary "Save" Button
```tsx
<Button impact="primary" mode="brand" size="large">
  Save Changes
</Button>
```
Produces: Solid blue, large button. Screams "click me, this is important!"

### Example 2: A Tertiary Danger Link
```tsx
<Button impact="tertiary" mode="critical" asChild>
  <a href="#" onClick={handleDelete}>
    Remove this specimen
  </a>
</Button>
```
Produces: Red text, no background. Links but with button styling.

### Example 3: A Loading Secondary Button
```tsx
<Button impact="secondary" mode="brand" loading={loading}>
  {loading ? "Saving..." : "Save"}
</Button>
```
Produces: While `loading={true}`, shows spinner and is disabled. Consumer can still pass text (it'll be hidden).

### Example 4: Button with Icon
```tsx
<Button impact="primary" mode="success">
  <Plus />
  Add Sample
</Button>
```
Produces: Blue button with Plus icon on the left (Tailwind gap-2 spaces them).

---

## 🔗 Part 5: Integration Points

### Where Does Button Get Used?

The Button component is published from **`@cryospace/ui`** package:

```typescript
// In apps/web or anywhere else in the monorepo:
import { Button } from "@cryospace/ui";

<Button>Click me</Button>
```

This is possible because:
1. `packages/ui/package.json` exports `"."` pointing to `src/index.ts`
2. `src/index.ts` re-exports `Button` and `ButtonIcon`
3. The UI package is in a pnpm workspace, so other apps can depend on it

### Styling Engine: Tailwind

All colors and spacing use **Tailwind CSS**:
- `h-10` = height 40px
- `px-4` = padding-left & padding-right 16px
- `bg-[#519fc8]` = inline hex color (overrides default Tailwind palette)
- `hover:bg-[#1d7bae]` = on hover, change background

This means buttons automatically follow the Tailwind config of whatever app imports them.

---

## 📖 Part 6: The Storybook Stories

Stories serve **three purposes:**
1. **Visual regression testing** (Chromatic catches visual changes)
2. **Documentation** (developers see all variants in one place)
3. **Interactive development** (Storybook's knobs let you tweak variants)

Example story:
```typescript
export const AllModes: Story = {
  render: () => (
    <div className="flex flex-col gap-4">
      {(["brand", "critical", "warning", "success", "default"] as const).map((mode) => (
        <div key={mode} className="flex items-center gap-4">
          <span className="w-16 text-xs text-gray-500">{mode}</span>
          <Button impact="primary" mode={mode}>Primary</Button>
          <Button impact="secondary" mode={mode}>Secondary</Button>
          <Button impact="tertiary" mode={mode}>Tertiary</Button>
        </div>
      ))}
    </div>
  ),
};
```

This renders a **3×5 grid** showing every combination of impact × mode. It's your component's "spec sheet."

---

## 🎯 Part 7: Two Components, One Pattern

### `ButtonIcon` — The Icon-Only Variant

```typescript
const buttonIconVariants = cva(
  "inline-flex shrink-0 cursor-pointer items-center justify-center rounded-lg ...",
  {
    variants: {
      impact: { primary: "", secondary: "bg-white border", tertiary: "" },
      mode: { brand: "", neutral: "", critical: "", reverse: "" },  // Different modes!
      size: { large: "size-11 [&_svg:not([class*='size-'])]:size-5", regular: "size-9 [&_svg:not([class*='size-'])]:size-4" }
    },
    // ... compoundVariants
  }
);
```

**Differences from Button:**
- **Mode** includes `neutral` and `reverse` (for dark backgrounds) instead of `warning` and `success`
- **Size** is `size-11` (square, 44px) instead of `h-10` (width auto)
- **SVG sizing**: `[&_svg:not([class*='size-'])]:size-5` — automatically scales icons to 20px if they don't have a size class

Example use:
```tsx
<ButtonIcon mode="brand" aria-label="Delete">
  <Trash2 />
</ButtonIcon>
```

**Why separate?** Icon-only buttons need different semantics:
- They're square (not rectangular like text buttons)
- They need `aria-label` for accessibility
- Their variant meanings differ (no "success" mode—that doesn't make sense for a toolbar button)

---

## 🌍 Accessibility Features Built In

The Button components include:

1. **Focus indicators:** `focus-visible:ring-[3px] focus-visible:ring-ring/50` — keyboard users see where focus is
2. **Disabled state:** `disabled:pointer-events-none disabled:opacity-50` — visually and functionally disabled
3. **Loading announcement:** `<span className="sr-only">Chargement...</span>` — screen readers announce "Loading"
4. **Icon safety:** `[&_svg]:pointer-events-none` — prevents accidental clicks on the icon element
5. **Required `aria-label` on ButtonIcon** — so screen readers know what the button does

---

## 🎓 Summary: What You've Learned

| Concept | Key Takeaway |
|---------|--------------|
| **CVA** | A variant system that manages styling combinations safely and scales |
| **Variants** | Three dimensions (impact, mode, size) = 30 button styles from one component |
| **Polymorphism** | `asChild` lets buttons wrap other elements while keeping button styling |
| **Composition** | Base + compound variants = expressive, simple API |
| **Accessibility** | Built-in ARIA labels, focus indicators, disabled states, screen reader support |
| **Reusability** | Exported from `@cryospace/ui`, can be used across all apps in the monorepo |

---

## 🤔 Quick Check-In: Do You Follow?

Before we move on, let me ask you a few questions to make sure this all makes sense:

**Q1: Variant Dimensions**
> If you wanted a button for "Cancel this action" (not destructive, just a secondary action), what would you pick?
> - `impact="primary" mode="brand"`
> - `impact="secondary" mode="default"`
> - `impact="tertiary" mode="critical"`
> - Something else?

**Q2: Polymorphism**
> Why would someone use `<Button asChild><a href="/page">Go to page</a></Button>` instead of just a styled link?

**Q3: Loading State**
> What happens to a button when you set `loading={true}`? (Three things!)

**Q4: Which component would you use?**
> A toolbar with only icons (plus, edit, delete) — `Button` or `ButtonIcon`? Why?

---

## 📚 Next Steps (When You're Ready)

Once you feel comfortable with this tour, you could:
1. **Explore the stories** — Open Storybook: `pnpm storybook`
2. **See it in action** — Find where `Button` is used in `apps/web`
3. **Understand CVA deeply** — Read the CVA docs: https://cva.style
4. **Learn Radix UI `Slot`** — Used for the `asChild` prop: https://radix-ui.com/docs/primitives/utilities/slot

---

**Ready to test your understanding? Scroll down to the questions above (Q1-Q4) and let me know your answers!** 🚀
