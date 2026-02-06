# Detailed Planning Patterns

Guide for creating detailed implementation plans from high-level plan steps.

## Purpose

High-level plans describe WHAT the user can do after each step. Detailed plans describe HOW to implement that capability, broken down into concrete actions.

## Structure of a Detailed Plan

Each detailed plan should include:

1. **Objective** - Restate the step goal (from high-level plan)
2. **Files to Modify/Create** - Specific file paths and operations
3. **Implementation Actions** - Ordered list of concrete changes
4. **Validation** - How to verify the step works (automated + user checks)

Detailed plans are created for top-level steps. If substeps are created during implementation, execute them directly from the approved parent-step detailed plan without generating additional detailed plans.

## Example Transformation

**High-level plan step:**
```markdown
### Step 1: User Can Switch Between Prestations and Fournitures

**Objective**: Enable navigation between two sub-tabs within the Base screen

**Actions**:
- Rename tab route from "prestations" to "base"
- Create base.tsx with shared header and tab switcher
- Adapt BasePrestationsScreen to receive searchQuery prop
- Create empty BaseFournituresScreen

**Result**: User can tap tabs and see content switch

**Validation**: Tapping each tab shows the correct screen
```

**Detailed plan:**
```markdown
## Detailed Plan: Step 1 - Tab Navigation

### Objective
Enable navigation between two sub-tabs (Prestations / Fournitures) within the Base screen.

### Files to Modify
1. `(tabs)/_layout.tsx` - Rename tab route
2. `screens/base-prestations/base-prestations-screen.tsx` - Add searchQuery prop

### Files to Create
1. `(tabs)/base.tsx` - Main screen with tabs
2. `screens/base-fournitures/base-fournitures-screen.tsx` - Empty placeholder

### Implementation Actions

#### 1. Rename Tab Route
**File**: `(tabs)/_layout.tsx`
**Change**: Line ~150
```tsx
// Before
<Tabs.Screen name="prestations" ... />

// After
<Tabs.Screen name="base" ... />
```

#### 2. Create Base Screen
**File**: `(tabs)/base.tsx` (new)
**Content**:
- Import BasePrestationsScreen and BaseFournituresScreen
- State: `activeTab` ('prestations' | 'fournitures')
- State: `searchQuery` (string)
- UI: Header with "Base" title
- UI: Search bar + "+" button
- UI: Two clickable tabs with underline indicator
- UI: Conditional render based on activeTab
- Pass searchQuery prop to child screens

#### 3. Adapt Prestations Screen
**File**: `screens/base-prestations/base-prestations-screen.tsx`
**Changes**:
- Add interface: `BasePrestationsScreenProps { searchQuery?: string }`
- Remove title "Base prestations" (now in parent)
- Replace `usePrestationsSearchStore()` with searchQuery prop
- Update filter logic to use searchQuery

#### 4. Create Fournitures Placeholder
**File**: `screens/base-fournitures/base-fournitures-screen.tsx` (new)
**Content**:
- Accept searchQuery prop
- Show ActivityIndicator + "Loading..." text
- Return basic View with loading state

#### 5. Delete Old File
**File**: `(tabs)/prestations.tsx`
**Action**: Delete (replaced by base.tsx)

### Validation Steps

1. Run app and navigate to "Base" tab
2. Verify "Prestations" and "Fournitures" tabs are visible
3. Tap "Prestations" - should show existing prestations list
4. Tap "Fournitures" - should show loading indicator
5. Type in search bar - should filter active tab content
6. Switch tabs - search bar should remain visible
```

## Pattern: Breaking Down Actions

Each high-level action should expand into:

1. **File operations** - Create, modify, delete
2. **Specific locations** - Line numbers or section markers
3. **Code changes** - Before/after or description
4. **Dependencies** - Order of operations if relevant

## Pattern: Import Analysis

Before creating a detailed plan:

1. **Read related files** - Understand existing patterns
2. **Check dependencies** - What components/hooks are available
3. **Identify patterns** - Follow existing code style
4. **Note conventions** - File naming, import paths, etc.

Example:
```typescript
// Before detailing Step 2, read:
Read('screens/base-prestations/base-prestations-screen.tsx')
  // To understand screen structure, props pattern, list rendering

Read('hooks/useSavedServices.ts')
  // To follow similar hook pattern for useSavedSupplies
```

## Pattern: Validation Criteria

Each detailed plan should end with clear validation steps:

- **Automated checks** - Targeted tests, lint, typecheck, or build when available
- **User actions** - What to click/tap/type
- **Expected outcomes** - What should happen
- **Visual confirmations** - UI elements to verify
- **Functional tests** - Edge cases to check

## Anti-Patterns

### Too Vague
❌ "Update the component to handle search"
✅ "Add searchQuery prop, filter supplies using .filter(), pass filtered data to FlatList"

### Missing File Paths
❌ "Create the hook"
✅ "Create `hooks/useSavedSupplies.ts`"

### No Validation
❌ "Implement the feature"
✅ "Implement the feature, then verify by tapping items and checking modal opens"

### Skipping Dependencies
❌ "Add the modal" (but modal component doesn't exist yet)
✅ "First create SavedSupplyFormModal.tsx, then integrate into screen"

## Checklist for Detailed Plans

Before presenting a detailed plan to the user:

- [ ] All file paths are specific and workspace-relative
- [ ] Actions are ordered correctly (no missing dependencies)
- [ ] Code changes are clear (before/after or description)
- [ ] Validation steps include automated checks when available and user-observable results
- [ ] Related files have been read for context
- [ ] Existing patterns are followed
