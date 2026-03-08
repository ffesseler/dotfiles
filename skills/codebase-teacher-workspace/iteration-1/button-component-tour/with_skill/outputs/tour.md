# Button Component Tour — Cryospace UI Library

Welcome! This guide walks you through the Button component system in the Cryospace codebase. You'll learn how it's built, what variants it supports, and how to use it.

## 📍 Where It Lives

The Button component lives in the **UI package**:

```
packages/ui/src/components/
├── button.tsx              # Regular Button component
├── button.stories.tsx      # Storybook examples
├── button-icon.tsx         # Icon-only Button variant
└── button-icon.stories.tsx # Icon Button examples
```

This is a **shared UI library** used across Cryospace apps (web, future mobile). It's built with modern tools and patterns that enable both visual development (Storybook) and type-safe implementation.

---

## 🏗️ Architecture Overview

The Button system is built on three foundational technologies:

### 1. **Class Variance Authority (CVA)**
CVA is a type-safe CSS class composition library. It lets you define component variants once and get **automatic TypeScript inference**.

```typescript
import { cva, type VariantProps } from "class-variance-authority";

const buttonVariants = cva(
  "base-classes-here",
  {
    variants: { /* define your variants */ },
    compoundVariants: [ /* complex combinations */ ],
    defaultVariants: { /* defaults */ }
  }
);
```

**Why CVA?** Instead of hardcoding classes in every variant branch, you declare the variant structure **once** and it becomes your source of truth. Components are impossible to get wrong—TypeScript enforces valid combinations.

### 2. **Tailwind CSS**
All styling is pure Tailwind utility classes. No custom CSS file needed for the button—everything is composable via utilities like `bg-red-600`, `hover:bg-red-500`, etc.

### 3. **Radix UI Slot**
The `Slot` component from Radix UI provides a "polymorphic button" capability via the `asChild` prop. This lets you render a Button as a Link, a div, or anything else.

---

## 📦 The Button Component

### File: `button.tsx`

Let's break down the component in sections:

#### **Base Styles** (Applied to all buttons)

```typescript
const buttonVariants = cva(
  "inline-flex shrink-0 cursor-pointer items-center justify-center gap-2 rounded-lg font-bold text-sm leading-5 whitespace-nowrap transition-colors outline-none focus-visible:ring-[3px] focus-visible:ring-ring/50 disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-5",
  { /* variants below */ }
);
```

This base string applies to **every** button:
- **Layout**: `inline-flex`, `items-center`, `justify-center`, `gap-2` — flexbox for content alignment
- **Appearance**: `rounded-lg` (rounded corners), `font-bold`, `text-sm` (font size)
- **Interaction**: `cursor-pointer`, `transition-colors` (smooth color transitions on hover)
- **Accessibility**: `focus-visible:ring-[3px]` (keyboard focus ring), `outline-none` (removes browser outline)
- **Disabled state**: `disabled:opacity-50`, `disabled:pointer-events-none` (visual feedback + prevents interaction)
- **SVG handling**: `[&_svg]:...` (any SVG inside gets no pointer events, fixed size if no explicit size class)

#### **Variants: Impact** (Visual prominence)

```typescript
variants: {
  impact: {
    primary: "",        // Filled background (default)
    secondary: "bg-white border",  // Bordered style
    tertiary: "",       // Text-only (underlined by hover)
  },
```

**Impact** controls the "loudness" of the button:
- **Primary** = Solid, filled button (use for primary actions like "Save", "Submit")
- **Secondary** = Bordered outline (use for secondary actions like "Cancel", "More options")
- **Tertiary** = Text-only with subtle hover (use for less important links)

#### **Variants: Mode** (Color/semantic meaning)

```typescript
mode: {
  brand: "",      // Cryospace blue (#519fc8)
  critical: "",   // Red (delete, danger)
  warning: "",    // Yellow (caution)
  success: "",    // Green (confirmation)
  default: "",    // Gray (neutral)
},
```

**Mode** communicates the action's semantic meaning. Think of it like a traffic light:
- 🔵 **Brand** = Primary action (default branding color)
- 🔴 **Critical** = Dangerous action (red = stop/delete)
- 🟡 **Warning** = Caution needed (yellow = be careful)
- 🟢 **Success** = Positive outcome (green = confirmed)
- ⚪ **Default** = Neutral (gray = standard action)

#### **Variants: Size** (Dimensions)

```typescript
size: {
  large: "h-10 px-4",    // 40px tall, more padding (desktop)
  regular: "h-9 px-3",   // 36px tall, less padding (compact)
},
```

Two sizes accommodate different contexts:
- **Large** = Primary CTAs, form submission buttons
- **Regular** = Secondary actions, toolbar buttons, compact spaces

#### **Compound Variants** (Impact × Mode combinations)

This is where the magic happens. Instead of letting you pick any impact + mode combo, the design system enforces **valid combinations** with specific colors:

```typescript
compoundVariants: [
  // Primary
  { impact: "primary", mode: "brand", className: "bg-[#519fc8] text-white hover:bg-[#1d7bae]" },
  { impact: "primary", mode: "critical", className: "bg-red-600 text-white hover:bg-red-500" },
  // ... more combinations
  // Secondary
  { impact: "secondary", mode: "brand", className: "border-[#378dbb] text-[#378dbb] hover:bg-[#378dbb]/10" },
  // ... more combinations
  // Tertiary
  { impact: "tertiary", mode: "brand", className: "text-[#378dbb] hover:bg-[#378dbb]/10" },
  // ... more combinations
]
```

Each combination explicitly defines:
- **Background color** (`bg-*`)
- **Text color** (`text-*`)
- **Hover state** (`hover:*`)

**The benefit?** You can never create an invalid combination like "primary impact + missing color". The system guides you to valid states.

#### **Default Variants**

```typescript
defaultVariants: {
  impact: "primary",
  mode: "brand",
  size: "large",
},
```

When you render `<Button>Click me</Button>`, you automatically get a **primary, brand, large button**. No props needed for the common case.

### The Component Function

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

**Line-by-line breakdown:**

1. **Props destructuring**: Accepts all standard button props + variant props + extras
   - `VariantProps<typeof buttonVariants>` auto-infers valid impact/mode/size combinations from CVA
   - `asChild` enables polymorphism (render as a Link, div, etc.)
   - `loading` adds async state handling

2. **Polymorphic rendering**: 
   ```typescript
   const Comp = asChild ? Slot.Root : "button";
   ```
   - If `asChild=true`, use `Slot.Root` (delegates to a child component)
   - Otherwise, render a native `<button>`

3. **Class composition**:
   ```typescript
   className={cn(buttonVariants({ impact, mode, size, className }))}
   ```
   - `buttonVariants()` generates the CSS classes from variant props
   - `cn()` is a utility that merges Tailwind classes (handles conflicts)
   - Extra `className` prop is merged last (user can override)

4. **Disabled state**:
   ```typescript
   disabled={disabled || loading}
   ```
   - Button auto-disables when loading
   - Prevents double-click accidents during async operations

5. **Loading state**:
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
   - Shows a spinning loader icon when `loading=true`
   - `sr-only` is a screen-reader-only class (hidden visually but readable by assistants)
   - Says "Chargement..." (French for "Loading...")

---

## 🎨 Variant Matrix

Here's a **complete visual reference** of all valid combinations:

| Impact    | Brand | Critical | Warning | Success | Default |
|-----------|-------|----------|---------|---------|---------|
| Primary   | 🔵 Blue | 🔴 Red | 🟡 Yellow | 🟢 Green | ⚪ Gray |
| Secondary | 🔵 Blue outline | 🔴 Red outline | 🟡 Yellow outline | 🟢 Green outline | ⚪ Gray outline |
| Tertiary  | 🔵 Blue text | 🔴 Red text | 🟡 Yellow text | 🟢 Green text | ⚪ Gray text |

**Plus:**
- 2 sizes: `large` (40px), `regular` (36px)
- 2 states: `disabled`, `loading`

That's **15 color combinations × 2 sizes × 2 states = 60 unique states** the system can express.

---

## 🪄 The `cn()` Utility

Before we move on, understand the `cn()` helper from `lib/utils.ts`:

```typescript
import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}
```

**What it does:**
- **clsx**: Merges multiple class strings/objects (conditional classes)
- **twMerge**: Removes conflicting Tailwind classes (e.g., if you pass both `bg-red-600` and `bg-blue-500`, merge keeps the right one)

**Example:**
```typescript
cn("bg-red-600 px-4", "bg-blue-500 text-white")
// Output: "px-4 bg-blue-500 text-white"
// (bg-blue-500 wins because it comes last)
```

This is how Cryospace lets users override button styles in rare cases without breaking the design system.

---

## 💻 How to Use the Button

### Basic Usage

```typescript
import { Button } from "@cryospace/ui";

// Default: primary, brand, large
<Button>Save Changes</Button>

// Different impact
<Button impact="secondary">Cancel</Button>
<Button impact="tertiary">Learn more</Button>

// Different mode
<Button mode="critical">Delete Account</Button>
<Button mode="warning">Confirm Action</Button>
<Button mode="success">Backup Complete</Button>

// Different size
<Button size="regular">Compact button</Button>

// With loading state
<Button loading={isSubmitting}>
  {isSubmitting ? "" : "Submit"}
</Button>

// With icons
<Button>
  <Plus size={20} />
  Add Item
</Button>

// Disabled
<Button disabled>Can't click me</Button>

// As a link (polymorphic)
<Button asChild>
  <a href="/dashboard">Go to Dashboard</a>
</Button>
```

### Real-world Example: Form Submission

```typescript
const [isSubmitting, setIsSubmitting] = useState(false);

async function handleSubmit() {
  setIsSubmitting(true);
  try {
    await api.submitForm(formData);
    toast.success("Form submitted!");
  } catch (error) {
    toast.error("Failed to submit");
  } finally {
    setIsSubmitting(false);
  }
}

return (
  <form onSubmit={handleSubmit}>
    {/* form fields */}
    <Button loading={isSubmitting} disabled={!isFormValid}>
      Submit
    </Button>
  </form>
);
```

The button automatically:
- ✅ Shows spinner during submission
- ✅ Disables interaction (prevents double-click)
- ✅ Restores normal state when done
- ✅ Respects `isFormValid` prop

---

## 🎭 ButtonIcon Component

There's a companion **ButtonIcon** component for icon-only buttons (no text).

### File: `button-icon.tsx`

It follows the **exact same pattern** as Button but:

1. **Removes** text-specific sizing (no `px` padding needed)
2. **Adds** square sizing: `size-11` (large), `size-9` (regular)
3. **Replaces** some modes: `neutral` instead of `default`, adds `reverse`
4. **Adds** `aria-label` requirement (accessibility for screen readers)

```typescript
<ButtonIcon aria-label="Close dialog" mode="critical">
  <X size={20} />
</ButtonIcon>
```

The `aria-label` is **required** because there's no visible text. Screen readers need it to understand the button's purpose.

---

## 📚 Storybook Stories

The component has **interactive documentation** in Storybook. You can explore all variants visually:

### File: `button.stories.tsx`

```typescript
const meta: Meta<typeof Button> = {
  title: "Actions/ButtonRegular",
  component: Button,
  args: {
    children: "Button",
  },
  argTypes: {
    impact: { control: "select", options: ["primary", "secondary", "tertiary"] },
    mode: { control: "select", options: ["brand", "critical", "warning", "success", "default"] },
    size: { control: "select", options: ["large", "regular"] },
  },
};
```

**What this enables:**
- ✅ Interactive controls in Storybook (change props in real-time)
- ✅ Auto-generated prop documentation
- ✅ Visual regression testing (future: Chromatic)

### Stories Defined

```typescript
export const Default: Story = {};                    // Single primary button

export const AllImpacts: Story = {
  render: () => (
    <div className="flex items-center gap-4">
      <Button impact="primary">Primary</Button>
      <Button impact="secondary">Secondary</Button>
      <Button impact="tertiary">Tertiary</Button>
    </div>
  ),
};

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

export const WithIcons: Story = {
  render: () => (
    <div className="flex items-center gap-4">
      <Button><Plus />Ajouter</Button>
      <Button>Suivant<ChevronRight /></Button>
      <Button><Plus />Avec icones<ChevronRight /></Button>
    </div>
  ),
};

export const Loading: Story = {
  args: { loading: true },
};

export const Disabled: Story = {
  args: { disabled: true },
};
```

Each story is a **living example** you can:
- 🎬 Watch in action
- 🎛️ Tweak props interactively
- 📸 Screenshot for design handoff
- ✅ Test accessibility

---

## 🔑 Key Design Principles

Now that you understand *how* the Button works, here's *why* it's designed this way:

### 1. **Type Safety Over Configuration**
CVA enforces valid combinations at compile time. You can't create a broken button by accident.

```typescript
// ✅ Valid
<Button impact="primary" mode="critical" size="large" />

// ❌ TypeScript error (invalid mode for this context)
<Button impact="primary" mode="invalid_mode" />
```

### 2. **Semantic Colors**
Colors mean something:
- 🔴 Red = Danger (delete, remove)
- 🟢 Green = Success (confirm, save)
- 🟡 Yellow = Warning (be careful)
- 🔵 Blue = Brand (primary action)

This is **universal** across web/mobile/future interfaces.

### 3. **Accessibility First**
- Focus indicators: `focus-visible:ring-[3px]` (visible keyboard navigation)
- Disabled states: Prevents interaction + clear visual feedback
- Loading state: Shows progress (prevents perceived freezing)
- `aria-label`: Required for icon buttons (screen reader support)

### 4. **Composability**
Buttons work with **Tailwind utilities**:
```typescript
<Button className="w-full">Full-width button</Button>
<Button className="text-lg">Bigger text</Button>
```

And with **other components**:
```typescript
<Button asChild>
  <Link to="/home">Navigate</Link>
</Button>

<Button asChild>
  <Tooltip title="Click to save">
    <span>Save</span>
  </Tooltip>
</Button>
```

### 5. **Dark Mode Ready**
The color scheme (blue #519fc8, red, yellow, green) works in light AND dark themes (via next-themes).

---

## 🚀 When to Use Each Variant

**Decision tree:**

```
Need to take an action?
├─ Is it the MOST important action on the page?
│  └─ YES → Use Primary (impact="primary")
│     └─ Is it dangerous? → mode="critical" (red)
│     └─ Is it positive? → mode="success" (green)
│     └─ Otherwise → mode="brand" (blue)
│
├─ Is it a secondary action?
│  └─ YES → Use Secondary (impact="secondary")
│     └─ Repeat color logic above
│
└─ Is it just a link/less important?
   └─ YES → Use Tertiary (impact="tertiary")
      └─ Repeat color logic above
```

**Examples:**

| Action | Variant | Reason |
|--------|---------|--------|
| "Save Specimen" | primary/brand | Main workflow action |
| "Delete Rack" | primary/critical | Dangerous, needs prominence |
| "Download Report" | secondary/brand | Important but not critical |
| "Help" | tertiary/brand | Nice-to-have, de-emphasized |
| "Confirm MTI Storage?" | primary/success | Positive affirmation |

---

## 🔗 Related Components in the Codebase

The Button is part of a **larger component system**. Here's how it relates:

- **ButtonIcon** (`button-icon.tsx`) — Icon-only variant of Button
- **Dialog** (`dialog.tsx`) — Often contains buttons for confirmation
- **ActionList** (`action-list.tsx`) — Groups of action buttons
- **Badge** (`badge.tsx`) — Small labels (similar coloring system)

All use the **same color modes** (brand, critical, warning, success, default) for consistency.

---

## 📖 Storybook for Visual Exploration

To see all Button variants in action:

```bash
cd packages/ui
pnpm storybook
# Opens http://localhost:6006
# Navigate to "Actions/ButtonRegular" to see all stories
```

---

## 🎓 Key Takeaways

✅ **Button is built with CVA** — Type-safe variant system  
✅ **Three dimensions of variation** — Impact (primary/secondary/tertiary), Mode (brand/critical/warning/success/default), Size (large/regular)  
✅ **Compound variants enforce design rules** — Can't create invalid combinations  
✅ **Supports loading and disabled states** — Built-in async UX patterns  
✅ **Polymorphic via asChild** — Can render as links, divs, or custom components  
✅ **Icon support** — Works with lucide-react icons  
✅ **Accessible by default** — Keyboard focus, ARIA labels, semantic colors  
✅ **Tailwind-based** — No custom CSS, fully composable  

---

## 🤔 Next Questions You Might Have

**Q: How do I add a new variant?**  
A: Edit `buttonVariants` in `button.tsx`, add to the `variants` object, then define `compoundVariants` for valid combinations. Update Storybook stories in `button.stories.tsx`.

**Q: Can I override the button's colors?**  
A: Yes, use the `className` prop: `<Button className="bg-purple-600">Custom</Button>`. The design system encourages using the built-in modes instead.

**Q: What if my button needs custom behavior?**  
A: Use the `asChild` pattern to compose with other components. The Button handles styling; composition handles behavior.

**Q: How does this scale with the design system?**  
A: Every component (Badge, Dialog, etc.) follows the same CVA pattern + compound variants. This keeps the entire system consistent.

---

**Happy building! 🚀**
