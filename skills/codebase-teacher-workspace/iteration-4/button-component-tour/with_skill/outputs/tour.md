# Button Component Tour — Section 1

## The Button Component

The Button component in this codebase is built using **CVA** (class-variance-authority) combined with **Tailwind CSS**, and it's wrapped with **Radix UI's Slot** primitive. The key insight is that Button isn't just a styled HTML button — it's designed to handle multiple visual states (primary, secondary, tertiary), semantic modes (brand, critical, warning, success), and sizes all through a single, type-safe component. You'll see this same pattern used throughout the UI package.

The design follows the philosophy: *declare all your visual variations upfront using CVA*, then the component layer stays thin and focused on behavior (loading states, asChild composition, disabled logic).

---

### Section 1: The base styles and variant structure — buttonVariants

```tsx
const buttonVariants = cva(
  "inline-flex shrink-0 cursor-pointer items-center justify-center gap-2 rounded-lg font-bold text-sm leading-5 whitespace-nowrap transition-colors outline-none focus-visible:ring-[3px] focus-visible:ring-ring/50 disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-5",
  {
    variants: {
      impact: {
        primary: "",
        secondary: "bg-white border",
        tertiary: "",
      },
      mode: {
        brand: "",
        critical: "",
        warning: "",
        success: "",
        default: "",
      },
      size: {
        large: "h-10 px-4",
        regular: "h-9 px-3",
      },
    },
    compoundVariants: [
      { impact: "primary", mode: "brand", className: "bg-[#519fc8] text-white hover:bg-[#1d7bae]" },
      { impact: "primary", mode: "critical", className: "bg-red-600 text-white hover:bg-red-500" },
      // ... more compound variants
    ],
    defaultVariants: {
      impact: "primary",
      mode: "brand",
      size: "large",
    },
  },
);
```

Here's what CVA is doing:
- **First argument** — the base classes that apply to *every* button, no matter what props you pass. These are the layout and accessibility fundamentals.
- **`variants` object** — three separate axes: `impact` (how prominent), `mode` (semantic color), and `size` (dimensions). Notice most impact/mode combos have empty strings — that's because their styles come from `compoundVariants` instead.
- **`compoundVariants`** — this is where the magic happens. Instead of writing "if impact is primary AND mode is brand, apply X", you declare it once in a table. Each row is one specific combination.
- **`defaultVariants`** — what you get if someone renders `<Button />` with no props.

**Check your understanding:**

Look at the compound variant for `{ impact: "primary", mode: "critical" }`. If a user renders `<Button impact="primary" mode="critical" size="regular" />`, which classes get applied to that button? (Hint: think about which parts contribute — base styles, variant entries with actual classes, compound matches, and size.)
