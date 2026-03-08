# CVA Deep Dive: Guided Tour

## Concept Introduction: What is CVA?

**CVA** stands for **Class Variance Authority**. It's a tiny TypeScript library (less than 2KB) that solves one concrete problem: **How do you build component variants in a type-safe way?**

Imagine you're building a button component. That button can be big or small (size), primary or secondary (style), and enabled or disabled (state). Without CVA, you'd be writing manual if-else logic or string concatenation to apply the right CSS classes based on all these combinations. With CVA, you declare **what classes apply when** in a data structure, and it handles the rest—plus gives you full TypeScript inference so you can't accidentally pass invalid prop combinations.

In the Cryospace codebase, CVA is used everywhere in the UI package (`packages/ui/src/components/`) to define reusable, type-safe component variants for buttons, badges, icons, and other UI elements. It keeps the styling logic declarative and separate from the React component logic.

---

## Section 1: The simplest example — badge.tsx

Let me show you the Badge component, which is the clearest introduction to CVA's pattern:

```typescript
const badgeVariants = cva(
  "inline-flex w-fit shrink-0 items-center justify-center gap-1 overflow-hidden rounded-full border border-transparent px-2 py-0.5 text-xs font-medium whitespace-nowrap transition-[color,box-shadow] focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 aria-invalid:border-destructive aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 [&>svg]:pointer-events-none [&>svg]:size-3",
  {
    variants: {
      variant: {
        default: "bg-primary text-primary-foreground [a&]:hover:bg-primary/90",
        secondary: "bg-secondary text-secondary-foreground [a&]:hover:bg-secondary/90",
        destructive:
          "bg-destructive text-white focus-visible:ring-destructive/20 dark:bg-destructive/60 dark:focus-visible:ring-destructive/40 [a&]:hover:bg-destructive/90",
        outline:
          "border-border text-foreground [a&]:hover:bg-accent [a&]:hover:text-accent-foreground",
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
      className={cn(badgeVariants({ variant }), className)}
      {...props}
    />
  );
}
```

Here's what's happening:

1. **First argument to `cva()`** — that long string of Tailwind classes — is the **base styles**. These classes apply to *every* badge, no matter what variant you pick. They define the shared layout, padding, transitions, and focus states.

2. **The `variants` object** is where the flexibility comes in. The `variant` key defines a prop name. Its value is an object mapping each variant name (`default`, `secondary`, `destructive`, etc.) to a set of Tailwind classes that override or extend the base. When you use `<Badge variant="destructive" />`, CVA applies both the base classes *and* the `destructive` classes together.

3. **`defaultVariants`** sets what you get if the user doesn't pass a `variant` prop. Here, it defaults to `default`.

4. **`VariantProps<typeof badgeVariants>`** is TypeScript magic. It extracts the prop types from your variant definition, so TypeScript knows that `variant` must be one of those six values. If you try `<Badge variant="invalid" />`, TypeScript will yell at you before the code even runs.

5. **`badgeVariants({ variant })`** is how you apply the computed classes. You pass it the props, and it returns a string of all the classes (base + the variant's classes) merged together.

**Check your understanding:**

Looking at the Badge component above: if you wanted to add a `success` variant with a green background and white text (similar to how `destructive` is styled), where in the `badgeVariants` definition would you add it, and what would that new entry look like?
