# Product Requirement Document - MVP

## 1. Product Overview & Goal

The goal of this MVP is to build a **Recipe Manager and Weekly Menu Planner** that creates a deterministic, reproducible 7-day meal plan based on specific dietary constraints, and automatically compiles a consolidated grocery list.

---

## 2. Core Functional Requirements (MVP Scope)

### 2.1 Recipe & Ingredient Management (CRUD)

- **Recipes:** Create, Read, Update, and Delete recipes. Each recipe contains a title, instructions, servings, ingredients, and tags.
- **Ingredients:** Each ingredient must support metadata tagging for identification (e.g., Name, Quantity, Unit).
- **Dietary Constraints:** Association of specific recipes or ingredients with restriction tags (e.g., Gluten-Free, Vegan).

### 2.1.1 Advanced Step-by-Step Recipe Structure (UI & Backend)

To support granular tracking, recipe creation and editing must be structured around sequential steps rather than a single text block.

#### 1. Step Properties & Schema:

Each step in a recipe must explicitly capture:

- **Order Index:** Integer tracking the exact sequence of the step (e.g., Step 1, Step 2).
- **Core Actions:** A dropdown selection of standardized culinary actions (e.g., `Blend`, `Mix`, `Whisk`, `Fry`, `Boil`, `Chop`, `Bake`).
  - _Data Strategy:_ Implement a lookup table for **Actions** to maintain system uniformity. A single step can have one or multiple actions.
- **Contextual Step Ingredients:** Ability to bind specific ingredients, exact quantities, and measurement units _directly_ to that specific step (e.g., Whisk + `2` + `pieces` + `eggs`).
- **Optional Step Duration:** An optional time field capturing preparation or cooking duration (e.g., Boil 1 cup of milk + `duration: 10 minutes`).
- **Additional Instruction Text:** A text field for descriptive nuances or notes for that specific step.

#### 2. UI/UX Requirements (React Frontend):

- **Dynamic Form Arrays:** The recipe creation form must allow users to dynamically add, remove, and reorder steps.
- **Scoped Ingredients:** Ingredients added to a step must automatically populate the recipe's master ingredient list behind the scenes for grocery consolidation.

### 2.2 Constraint-Based Menu Generator

The core engine must generate a 7-day menu (Breakfast, Lunch, Dinner per day = 21 meal slots total) that strictly satisfies user-defined constraints.

#### Valid Constraint Types:

1. **Exclusion Constraints (Allergens & Dietary):**
   - _Behavior:_ Strictly binary filter. If a recipe or any of its ingredients contains an excluded tag (e.g., `Gluten`, `Peanuts`, `Dairy`), it **must never** be selected for the menu.
2. **Target Windows (Calories / Macros):**
   - _Behavior:_ The cumulative daily total must fall within a strict min/max range (e.g., Target: 2000 kcal/day $\pm$ 100 kcal variance allowed).
3. **Ingredient Variety (Avoid Repetition):**
   - _Behavior:_ Prevent the same recipe from appearing more than once every 3 days. Prevent the same primary protein ingredient from dominating consecutive days.

---

## 3. Algorithm & Architectural Logic

### 3.1 Custom Agent Skill: `constraint-menu-generator`

The agent environment must be provisioned with a specialized skill descriptor (e.g., in `skills/constraint-menu-generator/SKILL.md`) that teaches the LLM how to orchestrate the generation loop:

1. **Context Registration:** Teach the agent how to ingest the Recipe Pool schema, user constraints, and seeds.
2. **Deterministic Code Generation:** The skill empowers the agent to write and execute a 100% deterministic, seed-based selection loop in the C# service layer.
3. **Automated Testing Scaffold:** The skill must automatically generate its own target verification suites to assert constraint compliance.

### 3.2 Algorithmic Determinism & Reproducibility

- **Rule:** For any identical combination of input recipes, constraints, and integer `Seed` value, the generated 7-day menu **must be 100% identical**.
- No unseeded `Random`, `Guid.NewGuid()`, or system clock dependencies are allowed inside the selection loop.

### 3.3 Grocery List Consolidation Logic

Once a 7-day menu is successfully assembled, the system must parse all selected recipes and aggregate their ingredients into a unified shopping list using these strict rules:

1. **Unit Standardization:** Ingredients sharing the exact same unit must be mathematically summed (e.g., `200g Rice` + `300g Rice` = `500g Rice`).
2. **Distinct Item Collision:** Ingredients with the same name but incompatible measurement units (e.g., `2 Cloves Garlic` vs `10g Garlic`) must not be summed blindly; they must be listed as separate line items under the same ingredient head to prevent corrupting grocery metrics.
3. **Scale Factor:** Adjust ingredient quantities dynamically based on the target menu servings vs. the original recipe base servings.

---

## 4. Test Specifications & Acceptance Criteria

### 4.1 Agent & Environment Testing Strategy

- **Agent Skill Testing (Validation Matrix):** We are testing the _agent's ability_ to respect constraints. The execution framework must pass mock recipe pools to the agent-generated algorithm and assert that the agent logs zero constraint leaks.
- **Deterministic Assertions:** Verify that the agent's code outputs identical 7-day meal matrices when evaluated against identical seeds.
- **Integration Test Pipeline:** An automated pipeline that validates the full execution flow from the agent's code creation to the compilation of the final grocery list.

### 4.2 Acceptance Criteria

- **Constraint Enforcement:** 100% compliance in test cases generated by the agent.
- **Agent Accountability (`agent_log.md`):** The agent must record the exact prompt iterations, tuning adjustments, and system rules used to achieve deterministic menu results.
- **CI Pipelines:** The code, agent logs, and test matrix validation must pass cleanly on the CI runner.

---

## 5. Required Deliverables & Artifacts

- **Repositories:** Isolated Backend and Frontend codebases with verified cross-origin orchestration.
- **CI Configuration:** Operational build pipelines accompanied by a repository status indicator/badge.
- **Tuning Logs (`agent_log.md`):** Chronological log of agent prompts used to fine-tune the algorithm loop boundaries and performance constraints.
