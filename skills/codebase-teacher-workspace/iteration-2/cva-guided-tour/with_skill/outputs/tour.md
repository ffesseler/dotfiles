# CVA (Class-Variance-Authority) Guided Tour — Cryospace UI Components

## What is CVA and why do we use it?

Imagine you're building a button that can look different based on how you use it. It can be big or small. It can be a "normal" button or a "danger" button. It can be filled in or outlined. Without a good system, you'd end up with messy code full of if/else chains or complicated className conditions. You'd easily create invalid combinations (like a "danger button" that's somehow also "success green").

**CVA** (Class-Variance-Authority) is a tiny library that solves this: it lets you declare all the valid visual states of a component *up front*, in a structured way, and then generates the right CSS classes based on the props you pass in. It's like a style machine—you tell it the rules, and it handles the rest. It also gives you TypeScript safety for free: you can't accidentally pass an invalid prop value.

In Cryospace, we use CVA for all our interactive components (buttons, badges, icon buttons). This keeps the styling consistent, prevents invalid states, and makes it easy to add new variants as the design system grows.

---

## Section 1: The simplest case — Badge

Let's start with the simplest component in the codebase:

```tsx
// packages/ui/src/components/badge.tsx

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
```

Here's what's happening:

- **First argument** (the long string): These are the *base classes* applied to every badge, no matter what. Things like padding, gap, border-radius, transitions. These are the common ground.
- **`variants` object**: This lists every prop that *changes the look*. Here, we have one: `variant`. It has six possible values: `default`, `secondary`, `destructive`, `outline`, `ghost`, `link`. Each gets its own set of Tailwind classes.
- **`defaultVariants`**: If someone renders `<Badge />` without passing a `variant` prop, it uses `"default"` by default.

The magic: CVA combines the base classes with the variant-specific classes. So `<Badge variant="secondary" />` gets both the base padding/border/transition AND the secondary color classes.

**Check your understanding:**

Look at the `badge.tsx` code above. If you wanted to add a new variant called `"success"` with a green background (`bg-green-600 text-white`), which part of the `cva()` call would you edit, and what would you add?

