-- Migration 001: Initial Schema
-- ANSI-compliant SQL (SQLite dev / SQL Server production)

CREATE TABLE IF NOT EXISTS Actions (
    Id      INTEGER PRIMARY KEY AUTOINCREMENT,
    Name    TEXT    NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS Recipes (
    Id           INTEGER PRIMARY KEY AUTOINCREMENT,
    Title        TEXT    NOT NULL,
    Instructions TEXT,
    Servings     INTEGER NOT NULL DEFAULT 1,
    CaloriesPerServing INTEGER NOT NULL DEFAULT 0,
    ProteinG     REAL    NOT NULL DEFAULT 0,
    CarbsG       REAL    NOT NULL DEFAULT 0,
    FatG         REAL    NOT NULL DEFAULT 0,
    PrimaryProtein TEXT,
    CreatedAt    TEXT    NOT NULL DEFAULT (datetime('now')),
    UpdatedAt    TEXT    NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS Tags (
    Id   INTEGER PRIMARY KEY AUTOINCREMENT,
    Name TEXT    NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS RecipeTags (
    RecipeId INTEGER NOT NULL REFERENCES Recipes(Id) ON DELETE CASCADE,
    TagId    INTEGER NOT NULL REFERENCES Tags(Id)    ON DELETE CASCADE,
    PRIMARY KEY (RecipeId, TagId)
);

CREATE TABLE IF NOT EXISTS Ingredients (
    Id   INTEGER PRIMARY KEY AUTOINCREMENT,
    Name TEXT    NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS RecipeSteps (
    Id          INTEGER PRIMARY KEY AUTOINCREMENT,
    RecipeId    INTEGER NOT NULL REFERENCES Recipes(Id) ON DELETE CASCADE,
    OrderIndex  INTEGER NOT NULL,
    DurationMinutes INTEGER,
    Notes       TEXT,
    UNIQUE (RecipeId, OrderIndex)
);

CREATE TABLE IF NOT EXISTS RecipeStepActions (
    StepId   INTEGER NOT NULL REFERENCES RecipeSteps(Id) ON DELETE CASCADE,
    ActionId INTEGER NOT NULL REFERENCES Actions(Id),
    PRIMARY KEY (StepId, ActionId)
);

CREATE TABLE IF NOT EXISTS RecipeStepIngredients (
    Id         INTEGER PRIMARY KEY AUTOINCREMENT,
    StepId     INTEGER NOT NULL REFERENCES RecipeSteps(Id) ON DELETE CASCADE,
    IngredientId INTEGER NOT NULL REFERENCES Ingredients(Id),
    Quantity   REAL    NOT NULL,
    Unit       TEXT    NOT NULL
);

CREATE TABLE IF NOT EXISTS Menus (
    Id          INTEGER PRIMARY KEY AUTOINCREMENT,
    Seed        INTEGER NOT NULL,
    GeneratedAt TEXT    NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS MenuSlots (
    Id       INTEGER PRIMARY KEY AUTOINCREMENT,
    MenuId   INTEGER NOT NULL REFERENCES Menus(Id) ON DELETE CASCADE,
    Day      INTEGER NOT NULL CHECK (Day BETWEEN 1 AND 7),
    MealSlot TEXT    NOT NULL CHECK (MealSlot IN ('Breakfast', 'Lunch', 'Dinner')),
    RecipeId INTEGER NOT NULL REFERENCES Recipes(Id),
    UNIQUE (MenuId, Day, MealSlot)
);

-- Seed standard culinary actions
INSERT OR IGNORE INTO Actions (Name) VALUES
    ('Blend'), ('Mix'), ('Whisk'), ('Fry'), ('Boil'),
    ('Chop'), ('Bake'), ('Roast'), ('Simmer'), ('Grill'),
    ('Steam'), ('Marinate'), ('Season'), ('Drain'), ('Preheat');
