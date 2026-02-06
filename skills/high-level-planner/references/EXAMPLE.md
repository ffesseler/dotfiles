# Example High-Level Plan: Base Supplies Screen

This example demonstrates a complete high-level plan following the recommended format.

---

## Overview

Create a "Base Supplies" screen in the mobile app that allows users to view, search, create, and edit their saved supply items. The screen integrates into an existing "Base" tab with two sub-tabs (Services and Supplies).

---

## User Flow

```
┌─────────────────────────────────┐
│ User taps "Base" tab             │
└────────────┬────────────────────┘
             │
             ▼
┌─────────────────────────────────┐
│ Screen shows "Services" tab      │
│ (existing functionality)         │
└────────────┬────────────────────┘
             │
             ▼
┌─────────────────────────────────┐
│ User taps "Supplies" sub-tab     │
└────────────┬────────────────────┘
             │
             ▼
┌─────────────────────────────────┐
│ List of saved supplies displays  │
│ Search bar + "+" button visible  │
└────────────┬────────────────────┘
             │
             ├─── User clicks item ───────┐
             │                            ▼
             │                  ┌──────────────────┐
             │                  │ Edit modal opens │
             │                  └──────────────────┘
             │
             └─── User clicks "+" ────────┐
                                          ▼
                                ┌──────────────────┐
                                │ Create modal     │
                                └──────────────────┘
```

---

## Component Structure

```
Base Screen (new)
├── Header
│   ├── Title "Base"
│   ├── Search Bar (shared)
│   └── "+" Button (contextual)
├── Sub-Tabs
│   ├── Services Tab (existing)
│   └── Supplies Tab (new)
└── Content (conditional)
    ├── BaseServicesScreen (existing)
    └── BaseSuppliesScreen (new)
        ├── SupplyList
        │   └── SupplyListItem (repeated)
        └── SupplyFormModal
```

---

## Functional Increments

### Step 1: Restructure Base Tab

**Objective**: Transform existing Services screen into a tabbed Base screen

**Actions**:
- Rename tab route from "services" to "base"
- Create Base screen with search bar and sub-tabs
- Move Services screen into first sub-tab
- Pass search query from parent to Services screen

**Result**: User can switch between Services and empty Supplies tab

---

### Step 2: Display Supply List

**Objective**: Show user's saved supplies with search functionality

**Actions**:
- Create hook to fetch supplies from API
- Build supply list item component
- Implement search filtering
- Add empty state with icon and message

**Result**: User sees list of supplies, can search, and create button appears

---

### Step 3: Edit Supply Modal

**Objective**: Enable users to modify existing supply details

**Actions**:
- Create modal with form fields
- Load supply data when modal opens
- Auto-calculate usage unit price
- Save changes via API

**Result**: User can tap supply, edit fields, and save changes

---

### Step 4: Create Supply Modal

**Objective**: Allow users to add new supplies

**Actions**:
- Reuse form modal from Step 3
- Handle "new" mode with empty fields
- Set default values for hidden fields
- Create new supply via API

**Result**: User can tap "+" button to create new supply

---

## Key Decisions

### Form Simplification
**Decision**: Hide quantity/reference fields from UI
**Reason**: Quantity always defaults to 1; reference auto-generated
**Impact**: Simpler form, faster data entry

### Search Placement
**Decision**: Single search bar above tabs (shared)
**Reason**: One search filters whichever tab is active
**Alternative considered**: Separate search per tab (more UI complexity)

### Auto-Calculated Fields
**Decision**: Margin comes from artisan profile default
**Reason**: Reduces user input, maintains consistency
**Impact**: One less field to fill, but less flexibility

---

## Checklist

- [ ] Step 1: Restructure Base tab with sub-tabs
- [ ] Step 2: Display supply list with search
- [ ] Step 3: Implement edit modal
- [ ] Step 4: Implement create modal
