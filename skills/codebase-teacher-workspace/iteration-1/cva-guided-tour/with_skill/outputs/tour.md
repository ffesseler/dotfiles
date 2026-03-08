# CVA (Class-Variance-Authority) — A Guided Tour

## What is CVA? (Concept intro)

**CVA** stands for "Class-Variance-Authority." It's a small library that solves a specific problem: **how do you manage CSS classes for components that have multiple visual options (variants) without creating a tangled mess of conditional logic?**

Think of it this way: a button in your UI isn't just one thing. It can be *primary* or *secondary* in impact, it can convey *danger* (red), *success* (green), *warning* (yellow), or be *neutral* (gray), and it can be *small*, *regular*, or *large* in size. With 3 impact types, 4 color modes, and 3 sizes, you potentially have 36 different visual combinations.

Without CVA, you'd write something like:
```javascript
if (impact === 'primary' && mode === 'critical' && size === 'large') {
  className = 'bg-red-600 text-white px-4 h-10 ...';
} else if (impact === 'secondary' && mode === 'critical' && size === 'large') {
  className = 'border border-red-600 text-red-700 px-4 h-10 ...';
}
// ... 34 more conditions
```

**CVA lets you declaratively define these combinations in a data structure instead**, then call a function to generate the right classes. It also ensures that prop combinations are type-safe — your TypeScript compiler catches mistakes before they reach users.

---

## Section 1: The simplest CVA usage — Badge component

Let's look at the **Badge** component, which is the simplest example in the codebase:

```tsx
const badgeVariants = cva(
  "inline-flex w-fit shrink-0 items-center justify-center gap-1 overflow-hidden rounded-full border border-transparent px-2 py-0.5 text-xs font-medium whitespace-nowrap transition-[color,box-shadow] focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 aria-invalid:border-destructive aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 [&>svg]:pointer-events-none [&>svg]:size-3",
  {
    variants: {
      variant: {
        default: "bg-primary text-primary-foreground [a&]:hover:bg-primary/90",
        secondary: "bg-secondary text-secondary-foreground [a&]:hover:bg-secondary/90",
        destructive: "bg-destructive text-white focus-visible:ring-destructive/20 dark:bg-destructive/60 dark:focus-visible:ring-destructive/40 [a&]:hover:bg-destructive/90",
        outline: "border-border text-foreground [a&]:hover:bg-accent [a&]:hover:text-accent-foreground",
        ghost: "[a&]:hover:bg-accent [a&]:hover:text-accent-foreground",
        link: "text-primary underline-offset-4 [a&]:hover:underline",
      },
    },
    defaultVariants: {
      variant: "default",
    },
  },
);

function Badge({
  className,
  variant = "default",
  asChild = false,
  ...props
}: React.ComponentProps<"span"> & VariantProps<typeof badgeVariants> & { asChild?: boolean }) {
  const Comp = asChild ? Slot.Root : "span";

  return (
    <Comp
      data-slot="badge"
      data-variant={variant}
      className={cn(badgeVariants({ variant }), className)}
      {...props}
    />
  );
}
```

**Here's what's happening:**

1. **`cva("base-classes", {...})`** — The first argument is a string of CSS classes that apply to *all* badges, no matter their variant. This is the "base" look: rounded, properly spaced, with focus rings and accessibility features.

2. **`variants` object** — The second argument's `variants` key lists all the props that can change the look. Here, badge has only one: `variant`. Each variant option (`default`, `secondary`, `destructive`, etc.) gets its own set of CSS classes.

3. **`defaultVariants`** — If you don't specify a `variant` prop when using the Badge, it defaults to `"default"`.

4. **`VariantProps<typeof badgeVariants>`** — This type is imported from CVA and tells TypeScript: "The Badge component accepts all the variant options defined in `badgeVariants`." So if someone tries `<Badge variant="nonexistent" />`, TypeScript catches the error immediately.

5. **`badgeVariants({ variant })`** — Inside the component, you *call* the CVA function with the props you want. It returns a single string of CSS classes, exactly right for that combination.

6. **`cn()`** — This is a utility that merges the CVA-generated classes with any custom `className` the user passes in. It uses `clsx` and `tailwind-merge` to intelligently combine Tailwind classes without conflicts.

**Check your understanding:**

If you wanted to add a new `success` variant to the Badge (with a green background), where exactly would you add it in the `badgeVariants()` call, and what would it look like?

---

## Section 2: Multiple variants and compound variants — Button component

Badges are simple because they have only one variant axis. **Buttons are more interesting** — they have *three* independent variant axes: `impact` (primary, secondary, tertiary), `mode` (brand, critical, warning, success, default), and `size` (large, regular).

Here's the Button definition:

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
      // Primary
      { impact: "primary", mode: "brand", className: "bg-[#519fc8] text-white hover:bg-[#1d7bae]" },
      { impact: "primary", mode: "critical", className: "bg-red-600 text-white hover:bg-red-500" },
      { impact: "primary", mode: "warning", className: "bg-yellow-600 text-white hover:bg-yellow-500" },
      { impact: "primary", mode: "success", className: "bg-green-600 text-white hover:bg-green-500" },
      { impact: "primary", mode: "default", className: "bg-gray-600 text-white hover:bg-gray-500" },
      // Secondary
      { impact: "secondary", mode: "brand", className: "border-[#378dbb] text-[#378dbb] hover:bg-[#378dbb]/10" },
      { impact: "secondary", mode: "critical", className: "border-red-600 text-red-700 hover:bg-red-100" },
      { impact: "secondary", mode: "warning", className: "border-yellow-600 text-yellow-700 hover:bg-yellow-100" },
      { impact: "secondary", mode: "success", className: "border-green-600 text-green-700 hover:bg-green-100" },
      { impact: "secondary", mode: "default", className: "border-gray-500 text-gray-600 hover:bg-gray-50" },
      // Tertiary
      { impact: "tertiary", mode: "brand", className: "text-[#378dbb] hover:bg-[#378dbb]/10" },
      { impact: "tertiary", mode: "critical", className: "text-red-700 hover:bg-red-100" },
      { impact: "tertiary", mode: "warning", className: "text-yellow-700 hover:bg-yellow-100" },
      { impact: "tertiary", mode: "success", className: "text-green-700 hover:bg-green-100" },
      { impact: "tertiary", mode: "default", className: "text-gray-600 hover:bg-gray-50" },
    ],
    defaultVariants: {
      impact: "primary",
      mode: "brand",
      size: "large",
    },
  },
);
```

**Notice the difference:**

- **`variants`** still defines each axis independently. But notice: `impact: { primary: "" }` — the value is *empty*. Why? Because `primary` impact needs different colors depending on the `mode`, so we can't define it in isolation.

- **`compoundVariants`** — This is the magic. A compound variant is a rule that says: "When *this specific combination* of variant props occurs, apply *these* classes." Look at the first one: when `impact: "primary"` AND `mode: "brand"`, apply `"bg-[#519fc8] text-white hover:bg-[#1d7bae]"` (the Cryospace brand blue).

This solves a key problem: **you can't define a button's color just by knowing the `impact` — you need to know both the `impact` AND the `mode`**. Compound variants let you express these dependent combinations explicitly.

The Button component itself uses this exactly like Badge:

```tsx
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
}: React.ComponentProps<"button"> & VariantProps<typeof buttonVariants> & { asChild?: boolean }) {
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

It just passes all three variant props to the `buttonVariants()` function, which applies:
1. Base classes
2. Any non-empty classes from `variants[impact]`, `variants[mode]`, `variants[size]`
3. The matching `compoundVariant` rule (if any)

**Check your understanding:**

Looking at the Button's compound variants: what classes would be applied if you created a `<Button impact="secondary" mode="critical" size="regular" />`? Walk me through the order: base classes first, then variants, then which compound variant matches?

---

## Section 3: Why this pattern matters — ButtonIcon and the class merging utility

Let's look at **ButtonIcon**, which is very similar to Button but adds one more detail: understanding how classes actually get combined:

```tsx
const buttonIconVariants = cva(
  "inline-flex shrink-0 cursor-pointer items-center justify-center rounded-lg transition-colors outline-none focus-visible:ring-[3px] focus-visible:ring-ring/50 disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg]:shrink-0",
  {
    variants: {
      impact: { primary: "", secondary: "bg-white border", tertiary: "" },
      mode: { brand: "", neutral: "", critical: "", reverse: "" },
      size: {
        large: "size-11 [&_svg:not([class*='size-'])]:size-5",
        regular: "size-9 [&_svg:not([class*='size-'])]:size-4",
      },
    },
    compoundVariants: [
      { impact: "primary", mode: "brand", className: "bg-[#519fc8] text-white hover:bg-[#1d7bae]" },
      { impact: "primary", mode: "neutral", className: "bg-gray-600 text-white hover:bg-gray-500" },
      // ... more compound variants
    ],
    defaultVariants: { impact: "primary", mode: "brand", size: "large" },
  },
);

function ButtonIcon({
  className,
  impact,
  mode,
  size,
  loading = false,
  children,
  disabled,
  "aria-label": ariaLabel,
  ...props
}: React.ComponentProps<"button"> &
  VariantProps<typeof buttonIconVariants> & {
    loading?: boolean;
  }) {
  return (
    <button
      data-slot="button-icon"
      className={cn(buttonIconVariants({ impact, mode, size, className }))}
      disabled={disabled || loading}
      aria-label={ariaLabel}
      {...props}
    >
      {loading ? <LoaderCircle className="animate-spin" /> : children}
    </button>
  );
}
```

Now, notice the **`cn()` function** at the end. It's defined in `lib/utils.ts`:

```tsx
import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}
```

**Why is this important?**

Imagine a user does:
```tsx
<Button impact="secondary" mode="critical" className="px-8" />
```

They're passing a custom `className="px-8"` to override the padding. Here's what happens:

1. `buttonVariants({ impact: "secondary", mode: "critical" })` generates: `"inline-flex cursor-pointer ... border-red-600 text-red-700 hover:bg-red-100 h-9 px-3"`
2. The user's `className` is also `"px-8"`
3. **Without smart merging**, you'd get: `"... px-3 px-8"` — both padding classes! Tailwind would just apply the last one, which works but is sloppy.
4. **With `cn()`**, the `twMerge` part is smart about Tailwind conflicts. It sees that `px-3` and `px-8` are incompatible, removes `px-3`, and keeps `px-8`. The final string is clean.

This is why CVA pairs naturally with `tailwind-merge` in this codebase: **CVA generates the base classes, but you need `tailwind-merge` to handle custom overrides without duplication**.

---

## Why CVA instead of inline styles or CSS-in-JS?

You might ask: "Why not just use inline styles? Or CSS modules? Or styled-components?"

- **Inline styles** can't express hover states, focus states, or responsive media queries
- **CSS modules** require separate `.module.css` files and lose the type-safety of props
- **styled-components** add runtime overhead and make it hard to read the actual CSS in your component
- **CVA** keeps the class definitions *in* your component file (easy to read), generates plain CSS classes (zero runtime cost, works perfectly with Tailwind), and gives you full type-safety on the props

In a critical domain like Cryospace (where mistakes cost lives), **type safety is not optional**. CVA ensures that a developer can't accidentally pass an invalid combination of props.

---

## Key takeaways

1. **CVA is a data structure + function generator**: You declare variants declaratively, and CVA compiles them into a function that returns CSS classes.

2. **Base classes apply to everything**: The first string in `cva()` is your "reset" — common styles that all variants inherit.

3. **Single variants are independent**: Each axis (impact, mode, size) can have its own rules.

4. **Compound variants handle dependencies**: When one variant prop depends on another (like button color depending on both impact *and* mode), use `compoundVariants`.

5. **Type safety is built in**: `VariantProps<typeof buttonVariants>` means TypeScript knows exactly which prop combinations are valid.

6. **Pair with `tailwind-merge`**: The `cn()` utility ensures that custom `className` overrides don't clash with generated classes.

7. **Why this pattern**: In Cryospace's domain (biobank operations, critical manipulations, zero errors), every component's visual contract matters. CVA lets you enforce that contract with types, not just documentation.

---

## What's next?

- Want to explore how these components are *used* in the actual routes?
- Curious about how to add a new variant to an existing component?
- Want to understand the broader component library structure?
