-- Migration 002: Seed Recipes
-- 20 diverse recipes with realistic nutritional data.
-- All subqueries use MIN(Id) so the script is safe even if the user already
-- created recipes with the same titles before this migration ran.

-- ─── Tags ────────────────────────────────────────────────────────────────────
INSERT OR IGNORE INTO Tags (Name) VALUES
    ('GlutenFree'), ('HighProtein'), ('Vegetarian'),
    ('Vegan'), ('Breakfast'), ('LowCarb'), ('DairyFree');

-- ─── Ingredients (all 74) ────────────────────────────────────────────────────
INSERT OR IGNORE INTO Ingredients (Name) VALUES
    ('Chicken breast'), ('Olive oil'), ('Salt'), ('Black pepper'),
    ('Ground beef'), ('Onion'), ('Carrot'), ('Celery'), ('Garlic'),
    ('Canned tomatoes'), ('Spaghetti'), ('Parmesan cheese'),
    ('Cherry tomatoes'), ('Cucumber'), ('Red onion'), ('Bell pepper'),
    ('Feta cheese'), ('Kalamata olives'), ('Red wine vinegar'),
    ('Banana'), ('Rolled oats'), ('Milk'), ('Honey'), ('Vanilla extract'),
    ('Salmon fillet'), ('Soy sauce'), ('Fresh ginger'), ('Sesame oil'),
    ('Sourdough bread'), ('Avocado'), ('Lemon juice'), ('Red pepper flakes'),
    ('Romaine lettuce'), ('Caesar dressing'), ('Croutons'),
    ('Beef sirloin'), ('Broccoli'), ('Snap peas'),
    ('Curry paste'), ('Coconut milk'), ('Chickpeas'), ('Potato'), ('Cauliflower'),
    ('Chia seeds'), ('Cod fillets'), ('Fresh thyme'),
    ('Ground turkey'), ('Breadcrumbs'), ('Egg'), ('Fresh parsley'),
    ('Red lentils'), ('Vegetable broth'), ('Cumin'), ('Turmeric'),
    ('Quinoa'), ('Sweet potato'), ('Zucchini'), ('Fresh spinach'),
    ('Pork tenderloin'), ('Fresh rosemary'), ('Butter'), ('Apple'), ('Cinnamon'),
    ('Shrimp'), ('Chili powder'), ('Red cabbage'), ('Fresh cilantro'), ('Lime juice'),
    ('Greek yogurt'), ('Heavy cream'), ('Tikka masala spice blend'),
    ('Dijon mustard'), ('Canned tuna'), ('Green beans');

-- ─── Recipes (20) ────────────────────────────────────────────────────────────
INSERT INTO Recipes (Title, Servings, CaloriesPerServing, ProteinG, CarbsG, FatG, PrimaryProtein) VALUES
    ('Grilled Chicken Breast',           2,  230, 43.0,  0.0,  5.0, 'Chicken'),
    ('Spaghetti Bolognese',              4,  540, 27.0, 62.0, 18.0, 'Beef'),
    ('Greek Salad',                      2,  240,  7.0, 13.0, 19.0, NULL),
    ('Banana Oat Smoothie',              1,  380, 13.0, 62.0,  9.0, NULL),
    ('Salmon Teriyaki',                  2,  390, 36.0, 22.0, 16.0, 'Salmon'),
    ('Avocado Toast',                    1,  320,  9.0, 32.0, 18.0, NULL),
    ('Chicken Caesar Salad',             2,  450, 38.0, 14.0, 28.0, 'Chicken'),
    ('Beef Stir Fry',                    2,  420, 32.0, 24.0, 22.0, 'Beef'),
    ('Vegetable Curry',                  4,  340,  9.0, 50.0, 12.0, NULL),
    ('Overnight Oats',                   1,  370, 14.0, 60.0,  9.0, NULL),
    ('Baked Cod with Herbs',             2,  210, 32.0,  4.0,  7.0, 'Fish'),
    ('Turkey Meatballs',                 4,  310, 28.0, 14.0, 14.0, 'Turkey'),
    ('Lentil Soup',                      4,  280, 16.0, 42.0,  5.0, NULL),
    ('Quinoa Roasted Veggie Bowl',       2,  410, 14.0, 58.0, 14.0, NULL),
    ('Egg and Spinach Omelette',         1,  270, 18.0,  4.0, 20.0, 'Egg'),
    ('Pork Tenderloin with Apple Sauce', 2,  340, 31.0, 18.0, 14.0, 'Pork'),
    ('Shrimp Tacos',                     2,  380, 26.0, 36.0, 14.0, 'Shrimp'),
    ('Greek Yogurt Parfait',             1,  290, 20.0, 38.0,  5.0, NULL),
    ('Tuna Nicoise Salad',               2,  380, 34.0, 18.0, 16.0, 'Tuna'),
    ('Chicken Tikka Masala',             4,  480, 38.0, 20.0, 28.0, 'Chicken');

-- ─── Recipe Tags ─────────────────────────────────────────────────────────────
INSERT OR IGNORE INTO RecipeTags (RecipeId, TagId)
SELECT (SELECT MIN(Id) FROM Recipes WHERE Title = 'Grilled Chicken Breast'), t.Id FROM Tags t WHERE t.Name IN ('GlutenFree', 'HighProtein', 'LowCarb');

INSERT OR IGNORE INTO RecipeTags (RecipeId, TagId)
SELECT (SELECT MIN(Id) FROM Recipes WHERE Title = 'Greek Salad'), t.Id FROM Tags t WHERE t.Name IN ('GlutenFree', 'Vegetarian');

INSERT OR IGNORE INTO RecipeTags (RecipeId, TagId)
SELECT (SELECT MIN(Id) FROM Recipes WHERE Title = 'Banana Oat Smoothie'), t.Id FROM Tags t WHERE t.Name IN ('Vegetarian', 'Breakfast');

INSERT OR IGNORE INTO RecipeTags (RecipeId, TagId)
SELECT (SELECT MIN(Id) FROM Recipes WHERE Title = 'Salmon Teriyaki'), t.Id FROM Tags t WHERE t.Name IN ('GlutenFree', 'HighProtein');

INSERT OR IGNORE INTO RecipeTags (RecipeId, TagId)
SELECT (SELECT MIN(Id) FROM Recipes WHERE Title = 'Avocado Toast'), t.Id FROM Tags t WHERE t.Name IN ('Vegetarian', 'Breakfast');

INSERT OR IGNORE INTO RecipeTags (RecipeId, TagId)
SELECT (SELECT MIN(Id) FROM Recipes WHERE Title = 'Chicken Caesar Salad'), t.Id FROM Tags t WHERE t.Name IN ('HighProtein');

INSERT OR IGNORE INTO RecipeTags (RecipeId, TagId)
SELECT (SELECT MIN(Id) FROM Recipes WHERE Title = 'Beef Stir Fry'), t.Id FROM Tags t WHERE t.Name IN ('GlutenFree', 'DairyFree');

INSERT OR IGNORE INTO RecipeTags (RecipeId, TagId)
SELECT (SELECT MIN(Id) FROM Recipes WHERE Title = 'Vegetable Curry'), t.Id FROM Tags t WHERE t.Name IN ('Vegan', 'GlutenFree', 'DairyFree');

INSERT OR IGNORE INTO RecipeTags (RecipeId, TagId)
SELECT (SELECT MIN(Id) FROM Recipes WHERE Title = 'Overnight Oats'), t.Id FROM Tags t WHERE t.Name IN ('Vegetarian', 'Breakfast');

INSERT OR IGNORE INTO RecipeTags (RecipeId, TagId)
SELECT (SELECT MIN(Id) FROM Recipes WHERE Title = 'Baked Cod with Herbs'), t.Id FROM Tags t WHERE t.Name IN ('GlutenFree', 'HighProtein', 'LowCarb');

INSERT OR IGNORE INTO RecipeTags (RecipeId, TagId)
SELECT (SELECT MIN(Id) FROM Recipes WHERE Title = 'Turkey Meatballs'), t.Id FROM Tags t WHERE t.Name IN ('HighProtein');

INSERT OR IGNORE INTO RecipeTags (RecipeId, TagId)
SELECT (SELECT MIN(Id) FROM Recipes WHERE Title = 'Lentil Soup'), t.Id FROM Tags t WHERE t.Name IN ('Vegan', 'GlutenFree', 'DairyFree');

INSERT OR IGNORE INTO RecipeTags (RecipeId, TagId)
SELECT (SELECT MIN(Id) FROM Recipes WHERE Title = 'Quinoa Roasted Veggie Bowl'), t.Id FROM Tags t WHERE t.Name IN ('Vegan', 'GlutenFree', 'DairyFree');

INSERT OR IGNORE INTO RecipeTags (RecipeId, TagId)
SELECT (SELECT MIN(Id) FROM Recipes WHERE Title = 'Egg and Spinach Omelette'), t.Id FROM Tags t WHERE t.Name IN ('Vegetarian', 'GlutenFree', 'LowCarb', 'Breakfast');

INSERT OR IGNORE INTO RecipeTags (RecipeId, TagId)
SELECT (SELECT MIN(Id) FROM Recipes WHERE Title = 'Pork Tenderloin with Apple Sauce'), t.Id FROM Tags t WHERE t.Name IN ('GlutenFree');

INSERT OR IGNORE INTO RecipeTags (RecipeId, TagId)
SELECT (SELECT MIN(Id) FROM Recipes WHERE Title = 'Greek Yogurt Parfait'), t.Id FROM Tags t WHERE t.Name IN ('Vegetarian', 'Breakfast');

INSERT OR IGNORE INTO RecipeTags (RecipeId, TagId)
SELECT (SELECT MIN(Id) FROM Recipes WHERE Title = 'Tuna Nicoise Salad'), t.Id FROM Tags t WHERE t.Name IN ('GlutenFree', 'HighProtein');

INSERT OR IGNORE INTO RecipeTags (RecipeId, TagId)
SELECT (SELECT MIN(Id) FROM Recipes WHERE Title = 'Chicken Tikka Masala'), t.Id FROM Tags t WHERE t.Name IN ('GlutenFree');

-- ─────────────────────────────────────────────────────────────────────────────
-- RECIPE 1: Grilled Chicken Breast
-- ─────────────────────────────────────────────────────────────────────────────
INSERT OR IGNORE INTO RecipeSteps (RecipeId, OrderIndex, DurationMinutes, Notes) VALUES
    ((SELECT MIN(Id) FROM Recipes WHERE Title = 'Grilled Chicken Breast'), 1, 5,  NULL),
    ((SELECT MIN(Id) FROM Recipes WHERE Title = 'Grilled Chicken Breast'), 2, 12, 'Cook until internal temperature reaches 74°C (165°F); rest 3 minutes before serving');

INSERT OR IGNORE INTO RecipeStepActions (StepId, ActionId)
SELECT rs.Id, a.Id FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Actions a ON a.Name = 'Season'
WHERE r.Title = 'Grilled Chicken Breast' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Grilled Chicken Breast');

INSERT OR IGNORE INTO RecipeStepActions (StepId, ActionId)
SELECT rs.Id, a.Id FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Actions a ON a.Name = 'Grill'
WHERE r.Title = 'Grilled Chicken Breast' AND rs.OrderIndex = 2 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Grilled Chicken Breast');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 300.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Chicken breast'
WHERE r.Title = 'Grilled Chicken Breast' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Grilled Chicken Breast');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 10.0, 'ml' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Olive oil'
WHERE r.Title = 'Grilled Chicken Breast' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Grilled Chicken Breast');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 3.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Salt'
WHERE r.Title = 'Grilled Chicken Breast' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Grilled Chicken Breast');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 2.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Black pepper'
WHERE r.Title = 'Grilled Chicken Breast' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Grilled Chicken Breast');

-- ─────────────────────────────────────────────────────────────────────────────
-- RECIPE 2: Spaghetti Bolognese
-- ─────────────────────────────────────────────────────────────────────────────
INSERT OR IGNORE INTO RecipeSteps (RecipeId, OrderIndex, DurationMinutes, Notes) VALUES
    ((SELECT MIN(Id) FROM Recipes WHERE Title = 'Spaghetti Bolognese'), 1, 8,  NULL),
    ((SELECT MIN(Id) FROM Recipes WHERE Title = 'Spaghetti Bolognese'), 2, 12, NULL),
    ((SELECT MIN(Id) FROM Recipes WHERE Title = 'Spaghetti Bolognese'), 3, 25, 'Add sautéed vegetables; stir in beef and season with salt and black pepper'),
    ((SELECT MIN(Id) FROM Recipes WHERE Title = 'Spaghetti Bolognese'), 4, 10, 'Cook al dente; drain and serve topped with bolognese and grated parmesan');

INSERT OR IGNORE INTO RecipeStepActions (StepId, ActionId)
SELECT rs.Id, a.Id FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Actions a ON a.Name = 'Chop'
WHERE r.Title = 'Spaghetti Bolognese' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Spaghetti Bolognese');

INSERT OR IGNORE INTO RecipeStepActions (StepId, ActionId)
SELECT rs.Id, a.Id FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Actions a ON a.Name = 'Fry'
WHERE r.Title = 'Spaghetti Bolognese' AND rs.OrderIndex = 2 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Spaghetti Bolognese');

INSERT OR IGNORE INTO RecipeStepActions (StepId, ActionId)
SELECT rs.Id, a.Id FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Actions a ON a.Name = 'Simmer'
WHERE r.Title = 'Spaghetti Bolognese' AND rs.OrderIndex = 3 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Spaghetti Bolognese');

INSERT OR IGNORE INTO RecipeStepActions (StepId, ActionId)
SELECT rs.Id, a.Id FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Actions a ON a.Name = 'Boil'
WHERE r.Title = 'Spaghetti Bolognese' AND rs.OrderIndex = 4 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Spaghetti Bolognese');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 150.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Onion'
WHERE r.Title = 'Spaghetti Bolognese' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Spaghetti Bolognese');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 100.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Carrot'
WHERE r.Title = 'Spaghetti Bolognese' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Spaghetti Bolognese');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 80.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Celery'
WHERE r.Title = 'Spaghetti Bolognese' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Spaghetti Bolognese');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 15.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Garlic'
WHERE r.Title = 'Spaghetti Bolognese' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Spaghetti Bolognese');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 500.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Ground beef'
WHERE r.Title = 'Spaghetti Bolognese' AND rs.OrderIndex = 2 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Spaghetti Bolognese');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 15.0, 'ml' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Olive oil'
WHERE r.Title = 'Spaghetti Bolognese' AND rs.OrderIndex = 2 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Spaghetti Bolognese');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 800.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Canned tomatoes'
WHERE r.Title = 'Spaghetti Bolognese' AND rs.OrderIndex = 3 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Spaghetti Bolognese');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 400.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Spaghetti'
WHERE r.Title = 'Spaghetti Bolognese' AND rs.OrderIndex = 4 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Spaghetti Bolognese');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 40.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Parmesan cheese'
WHERE r.Title = 'Spaghetti Bolognese' AND rs.OrderIndex = 4 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Spaghetti Bolognese');

-- ─────────────────────────────────────────────────────────────────────────────
-- RECIPE 3: Greek Salad
-- ─────────────────────────────────────────────────────────────────────────────
INSERT OR IGNORE INTO RecipeSteps (RecipeId, OrderIndex, DurationMinutes, Notes) VALUES
    ((SELECT MIN(Id) FROM Recipes WHERE Title = 'Greek Salad'), 1, 8,  NULL),
    ((SELECT MIN(Id) FROM Recipes WHERE Title = 'Greek Salad'), 2, 3,  'Season with dried oregano; serve immediately');

INSERT OR IGNORE INTO RecipeStepActions (StepId, ActionId)
SELECT rs.Id, a.Id FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Actions a ON a.Name = 'Chop'
WHERE r.Title = 'Greek Salad' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Greek Salad');

INSERT OR IGNORE INTO RecipeStepActions (StepId, ActionId)
SELECT rs.Id, a.Id FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Actions a ON a.Name = 'Mix'
WHERE r.Title = 'Greek Salad' AND rs.OrderIndex = 2 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Greek Salad');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 200.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Cherry tomatoes'
WHERE r.Title = 'Greek Salad' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Greek Salad');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 200.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Cucumber'
WHERE r.Title = 'Greek Salad' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Greek Salad');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 60.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Red onion'
WHERE r.Title = 'Greek Salad' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Greek Salad');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 80.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Bell pepper'
WHERE r.Title = 'Greek Salad' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Greek Salad');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 100.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Feta cheese'
WHERE r.Title = 'Greek Salad' AND rs.OrderIndex = 2 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Greek Salad');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 60.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Kalamata olives'
WHERE r.Title = 'Greek Salad' AND rs.OrderIndex = 2 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Greek Salad');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 30.0, 'ml' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Olive oil'
WHERE r.Title = 'Greek Salad' AND rs.OrderIndex = 2 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Greek Salad');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 15.0, 'ml' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Red wine vinegar'
WHERE r.Title = 'Greek Salad' AND rs.OrderIndex = 2 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Greek Salad');

-- ─────────────────────────────────────────────────────────────────────────────
-- RECIPE 4: Banana Oat Smoothie
-- ─────────────────────────────────────────────────────────────────────────────
INSERT OR IGNORE INTO RecipeSteps (RecipeId, OrderIndex, DurationMinutes, Notes) VALUES
    ((SELECT MIN(Id) FROM Recipes WHERE Title = 'Banana Oat Smoothie'), 1, 2, 'Blend until completely smooth; add ice for a colder texture');

INSERT OR IGNORE INTO RecipeStepActions (StepId, ActionId)
SELECT rs.Id, a.Id FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Actions a ON a.Name = 'Blend'
WHERE r.Title = 'Banana Oat Smoothie' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Banana Oat Smoothie');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 120.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Banana'
WHERE r.Title = 'Banana Oat Smoothie' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Banana Oat Smoothie');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 50.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Rolled oats'
WHERE r.Title = 'Banana Oat Smoothie' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Banana Oat Smoothie');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 250.0, 'ml' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Milk'
WHERE r.Title = 'Banana Oat Smoothie' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Banana Oat Smoothie');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 15.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Honey'
WHERE r.Title = 'Banana Oat Smoothie' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Banana Oat Smoothie');

-- ─────────────────────────────────────────────────────────────────────────────
-- RECIPE 5: Salmon Teriyaki
-- ─────────────────────────────────────────────────────────────────────────────
INSERT OR IGNORE INTO RecipeSteps (RecipeId, OrderIndex, DurationMinutes, Notes) VALUES
    ((SELECT MIN(Id) FROM Recipes WHERE Title = 'Salmon Teriyaki'), 1, 30, NULL),
    ((SELECT MIN(Id) FROM Recipes WHERE Title = 'Salmon Teriyaki'), 2, 10, '5 minutes per side; brush with remaining marinade while grilling');

INSERT OR IGNORE INTO RecipeStepActions (StepId, ActionId)
SELECT rs.Id, a.Id FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Actions a ON a.Name = 'Marinate'
WHERE r.Title = 'Salmon Teriyaki' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Salmon Teriyaki');

INSERT OR IGNORE INTO RecipeStepActions (StepId, ActionId)
SELECT rs.Id, a.Id FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Actions a ON a.Name = 'Grill'
WHERE r.Title = 'Salmon Teriyaki' AND rs.OrderIndex = 2 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Salmon Teriyaki');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 300.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Salmon fillet'
WHERE r.Title = 'Salmon Teriyaki' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Salmon Teriyaki');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 40.0, 'ml' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Soy sauce'
WHERE r.Title = 'Salmon Teriyaki' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Salmon Teriyaki');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 20.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Honey'
WHERE r.Title = 'Salmon Teriyaki' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Salmon Teriyaki');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 8.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Fresh ginger'
WHERE r.Title = 'Salmon Teriyaki' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Salmon Teriyaki');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 5.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Garlic'
WHERE r.Title = 'Salmon Teriyaki' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Salmon Teriyaki');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 10.0, 'ml' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Sesame oil'
WHERE r.Title = 'Salmon Teriyaki' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Salmon Teriyaki');

-- ─────────────────────────────────────────────────────────────────────────────
-- RECIPE 6: Avocado Toast
-- ─────────────────────────────────────────────────────────────────────────────
INSERT OR IGNORE INTO RecipeSteps (RecipeId, OrderIndex, DurationMinutes, Notes) VALUES
    ((SELECT MIN(Id) FROM Recipes WHERE Title = 'Avocado Toast'), 1, 3,  NULL),
    ((SELECT MIN(Id) FROM Recipes WHERE Title = 'Avocado Toast'), 2, 3,  NULL),
    ((SELECT MIN(Id) FROM Recipes WHERE Title = 'Avocado Toast'), 3, NULL, 'Spread mashed avocado on toasted bread. Top with cherry tomatoes and a drizzle of olive oil.');

INSERT OR IGNORE INTO RecipeStepActions (StepId, ActionId)
SELECT rs.Id, a.Id FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Actions a ON a.Name = 'Roast'
WHERE r.Title = 'Avocado Toast' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Avocado Toast');

INSERT OR IGNORE INTO RecipeStepActions (StepId, ActionId)
SELECT rs.Id, a.Id FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Actions a ON a.Name = 'Mix'
WHERE r.Title = 'Avocado Toast' AND rs.OrderIndex = 2 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Avocado Toast');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 80.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Sourdough bread'
WHERE r.Title = 'Avocado Toast' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Avocado Toast');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 150.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Avocado'
WHERE r.Title = 'Avocado Toast' AND rs.OrderIndex = 2 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Avocado Toast');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 10.0, 'ml' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Lemon juice'
WHERE r.Title = 'Avocado Toast' AND rs.OrderIndex = 2 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Avocado Toast');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 2.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Salt'
WHERE r.Title = 'Avocado Toast' AND rs.OrderIndex = 2 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Avocado Toast');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 1.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Red pepper flakes'
WHERE r.Title = 'Avocado Toast' AND rs.OrderIndex = 2 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Avocado Toast');

-- ─────────────────────────────────────────────────────────────────────────────
-- RECIPE 7: Chicken Caesar Salad
-- ─────────────────────────────────────────────────────────────────────────────
INSERT OR IGNORE INTO RecipeSteps (RecipeId, OrderIndex, DurationMinutes, Notes) VALUES
    ((SELECT MIN(Id) FROM Recipes WHERE Title = 'Chicken Caesar Salad'), 1, 12, NULL),
    ((SELECT MIN(Id) FROM Recipes WHERE Title = 'Chicken Caesar Salad'), 2, 5,  NULL),
    ((SELECT MIN(Id) FROM Recipes WHERE Title = 'Chicken Caesar Salad'), 3, 2,  'Slice grilled chicken and arrange on top; shave extra parmesan to finish');

INSERT OR IGNORE INTO RecipeStepActions (StepId, ActionId)
SELECT rs.Id, a.Id FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Actions a ON a.Name = 'Grill'
WHERE r.Title = 'Chicken Caesar Salad' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Chicken Caesar Salad');

INSERT OR IGNORE INTO RecipeStepActions (StepId, ActionId)
SELECT rs.Id, a.Id FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Actions a ON a.Name = 'Chop'
WHERE r.Title = 'Chicken Caesar Salad' AND rs.OrderIndex = 2 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Chicken Caesar Salad');

INSERT OR IGNORE INTO RecipeStepActions (StepId, ActionId)
SELECT rs.Id, a.Id FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Actions a ON a.Name = 'Mix'
WHERE r.Title = 'Chicken Caesar Salad' AND rs.OrderIndex = 3 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Chicken Caesar Salad');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 300.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Chicken breast'
WHERE r.Title = 'Chicken Caesar Salad' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Chicken Caesar Salad');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 10.0, 'ml' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Olive oil'
WHERE r.Title = 'Chicken Caesar Salad' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Chicken Caesar Salad');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 250.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Romaine lettuce'
WHERE r.Title = 'Chicken Caesar Salad' AND rs.OrderIndex = 2 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Chicken Caesar Salad');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 60.0, 'ml' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Caesar dressing'
WHERE r.Title = 'Chicken Caesar Salad' AND rs.OrderIndex = 3 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Chicken Caesar Salad');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 30.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Parmesan cheese'
WHERE r.Title = 'Chicken Caesar Salad' AND rs.OrderIndex = 3 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Chicken Caesar Salad');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 40.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Croutons'
WHERE r.Title = 'Chicken Caesar Salad' AND rs.OrderIndex = 3 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Chicken Caesar Salad');

-- ─────────────────────────────────────────────────────────────────────────────
-- RECIPE 8: Beef Stir Fry
-- ─────────────────────────────────────────────────────────────────────────────
INSERT OR IGNORE INTO RecipeSteps (RecipeId, OrderIndex, DurationMinutes, Notes) VALUES
    ((SELECT MIN(Id) FROM Recipes WHERE Title = 'Beef Stir Fry'), 1, 10, NULL),
    ((SELECT MIN(Id) FROM Recipes WHERE Title = 'Beef Stir Fry'), 2, 8,  'Cook on high heat; do not overcrowd the pan'),
    ((SELECT MIN(Id) FROM Recipes WHERE Title = 'Beef Stir Fry'), 3, 2,  'Serve over steamed rice');

INSERT OR IGNORE INTO RecipeStepActions (StepId, ActionId)
SELECT rs.Id, a.Id FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Actions a ON a.Name = 'Chop'
WHERE r.Title = 'Beef Stir Fry' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Beef Stir Fry');

INSERT OR IGNORE INTO RecipeStepActions (StepId, ActionId)
SELECT rs.Id, a.Id FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Actions a ON a.Name = 'Fry'
WHERE r.Title = 'Beef Stir Fry' AND rs.OrderIndex = 2 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Beef Stir Fry');

INSERT OR IGNORE INTO RecipeStepActions (StepId, ActionId)
SELECT rs.Id, a.Id FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Actions a ON a.Name = 'Season'
WHERE r.Title = 'Beef Stir Fry' AND rs.OrderIndex = 3 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Beef Stir Fry');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 300.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Beef sirloin'
WHERE r.Title = 'Beef Stir Fry' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Beef Stir Fry');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 150.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Bell pepper'
WHERE r.Title = 'Beef Stir Fry' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Beef Stir Fry');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 150.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Broccoli'
WHERE r.Title = 'Beef Stir Fry' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Beef Stir Fry');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 100.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Snap peas'
WHERE r.Title = 'Beef Stir Fry' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Beef Stir Fry');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 10.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Garlic'
WHERE r.Title = 'Beef Stir Fry' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Beef Stir Fry');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 15.0, 'ml' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Sesame oil'
WHERE r.Title = 'Beef Stir Fry' AND rs.OrderIndex = 2 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Beef Stir Fry');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 40.0, 'ml' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Soy sauce'
WHERE r.Title = 'Beef Stir Fry' AND rs.OrderIndex = 3 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Beef Stir Fry');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 10.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Honey'
WHERE r.Title = 'Beef Stir Fry' AND rs.OrderIndex = 3 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Beef Stir Fry');

-- ─────────────────────────────────────────────────────────────────────────────
-- RECIPE 9: Vegetable Curry
-- ─────────────────────────────────────────────────────────────────────────────
INSERT OR IGNORE INTO RecipeSteps (RecipeId, OrderIndex, DurationMinutes, Notes) VALUES
    ((SELECT MIN(Id) FROM Recipes WHERE Title = 'Vegetable Curry'), 1, 10, NULL),
    ((SELECT MIN(Id) FROM Recipes WHERE Title = 'Vegetable Curry'), 2, 5,  NULL),
    ((SELECT MIN(Id) FROM Recipes WHERE Title = 'Vegetable Curry'), 3, 20, 'Season with salt; serve with basmati rice or naan');

INSERT OR IGNORE INTO RecipeStepActions (StepId, ActionId)
SELECT rs.Id, a.Id FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Actions a ON a.Name = 'Chop'
WHERE r.Title = 'Vegetable Curry' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Vegetable Curry');

INSERT OR IGNORE INTO RecipeStepActions (StepId, ActionId)
SELECT rs.Id, a.Id FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Actions a ON a.Name = 'Fry'
WHERE r.Title = 'Vegetable Curry' AND rs.OrderIndex = 2 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Vegetable Curry');

INSERT OR IGNORE INTO RecipeStepActions (StepId, ActionId)
SELECT rs.Id, a.Id FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Actions a ON a.Name = 'Simmer'
WHERE r.Title = 'Vegetable Curry' AND rs.OrderIndex = 3 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Vegetable Curry');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 200.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Onion'
WHERE r.Title = 'Vegetable Curry' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Vegetable Curry');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 15.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Garlic'
WHERE r.Title = 'Vegetable Curry' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Vegetable Curry');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 300.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Potato'
WHERE r.Title = 'Vegetable Curry' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Vegetable Curry');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 300.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Cauliflower'
WHERE r.Title = 'Vegetable Curry' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Vegetable Curry');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 20.0, 'ml' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Olive oil'
WHERE r.Title = 'Vegetable Curry' AND rs.OrderIndex = 2 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Vegetable Curry');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 40.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Curry paste'
WHERE r.Title = 'Vegetable Curry' AND rs.OrderIndex = 2 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Vegetable Curry');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 400.0, 'ml' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Coconut milk'
WHERE r.Title = 'Vegetable Curry' AND rs.OrderIndex = 3 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Vegetable Curry');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 240.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Chickpeas'
WHERE r.Title = 'Vegetable Curry' AND rs.OrderIndex = 3 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Vegetable Curry');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 400.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Canned tomatoes'
WHERE r.Title = 'Vegetable Curry' AND rs.OrderIndex = 3 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Vegetable Curry');

-- ─────────────────────────────────────────────────────────────────────────────
-- RECIPE 10: Overnight Oats
-- ─────────────────────────────────────────────────────────────────────────────
INSERT OR IGNORE INTO RecipeSteps (RecipeId, OrderIndex, DurationMinutes, Notes) VALUES
    ((SELECT MIN(Id) FROM Recipes WHERE Title = 'Overnight Oats'), 1, 3,    NULL),
    ((SELECT MIN(Id) FROM Recipes WHERE Title = 'Overnight Oats'), 2, NULL, 'Cover and refrigerate overnight (minimum 8 hours). Top with fresh berries and banana slices before serving.');

INSERT OR IGNORE INTO RecipeStepActions (StepId, ActionId)
SELECT rs.Id, a.Id FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Actions a ON a.Name = 'Mix'
WHERE r.Title = 'Overnight Oats' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Overnight Oats');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 80.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Rolled oats'
WHERE r.Title = 'Overnight Oats' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Overnight Oats');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 15.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Chia seeds'
WHERE r.Title = 'Overnight Oats' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Overnight Oats');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 200.0, 'ml' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Milk'
WHERE r.Title = 'Overnight Oats' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Overnight Oats');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 15.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Honey'
WHERE r.Title = 'Overnight Oats' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Overnight Oats');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 3.0, 'ml' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Vanilla extract'
WHERE r.Title = 'Overnight Oats' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Overnight Oats');

-- ─────────────────────────────────────────────────────────────────────────────
-- RECIPE 11: Baked Cod with Herbs
-- ─────────────────────────────────────────────────────────────────────────────
INSERT OR IGNORE INTO RecipeSteps (RecipeId, OrderIndex, DurationMinutes, Notes) VALUES
    ((SELECT MIN(Id) FROM Recipes WHERE Title = 'Baked Cod with Herbs'), 1, 5,  NULL),
    ((SELECT MIN(Id) FROM Recipes WHERE Title = 'Baked Cod with Herbs'), 2, 18, 'Bake at 200°C (400°F) until fish flakes easily with a fork');

INSERT OR IGNORE INTO RecipeStepActions (StepId, ActionId)
SELECT rs.Id, a.Id FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Actions a ON a.Name = 'Season'
WHERE r.Title = 'Baked Cod with Herbs' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Baked Cod with Herbs');

INSERT OR IGNORE INTO RecipeStepActions (StepId, ActionId)
SELECT rs.Id, a.Id FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Actions a ON a.Name = 'Bake'
WHERE r.Title = 'Baked Cod with Herbs' AND rs.OrderIndex = 2 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Baked Cod with Herbs');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 400.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Cod fillets'
WHERE r.Title = 'Baked Cod with Herbs' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Baked Cod with Herbs');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 15.0, 'ml' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Olive oil'
WHERE r.Title = 'Baked Cod with Herbs' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Baked Cod with Herbs');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 20.0, 'ml' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Lemon juice'
WHERE r.Title = 'Baked Cod with Herbs' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Baked Cod with Herbs');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 4.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Fresh thyme'
WHERE r.Title = 'Baked Cod with Herbs' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Baked Cod with Herbs');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 3.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Salt'
WHERE r.Title = 'Baked Cod with Herbs' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Baked Cod with Herbs');

-- ─────────────────────────────────────────────────────────────────────────────
-- RECIPE 12: Turkey Meatballs
-- ─────────────────────────────────────────────────────────────────────────────
INSERT OR IGNORE INTO RecipeSteps (RecipeId, OrderIndex, DurationMinutes, Notes) VALUES
    ((SELECT MIN(Id) FROM Recipes WHERE Title = 'Turkey Meatballs'), 1, 5,  'Roll into balls about 3 cm in diameter'),
    ((SELECT MIN(Id) FROM Recipes WHERE Title = 'Turkey Meatballs'), 2, 22, 'Bake at 200°C (400°F); serve with tomato sauce and pasta or zucchini noodles');

INSERT OR IGNORE INTO RecipeStepActions (StepId, ActionId)
SELECT rs.Id, a.Id FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Actions a ON a.Name = 'Mix'
WHERE r.Title = 'Turkey Meatballs' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Turkey Meatballs');

INSERT OR IGNORE INTO RecipeStepActions (StepId, ActionId)
SELECT rs.Id, a.Id FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Actions a ON a.Name = 'Bake'
WHERE r.Title = 'Turkey Meatballs' AND rs.OrderIndex = 2 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Turkey Meatballs');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 500.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Ground turkey'
WHERE r.Title = 'Turkey Meatballs' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Turkey Meatballs');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 60.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Breadcrumbs'
WHERE r.Title = 'Turkey Meatballs' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Turkey Meatballs');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 50.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Egg'
WHERE r.Title = 'Turkey Meatballs' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Turkey Meatballs');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 10.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Garlic'
WHERE r.Title = 'Turkey Meatballs' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Turkey Meatballs');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 15.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Fresh parsley'
WHERE r.Title = 'Turkey Meatballs' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Turkey Meatballs');

-- ─────────────────────────────────────────────────────────────────────────────
-- RECIPE 13: Lentil Soup
-- ─────────────────────────────────────────────────────────────────────────────
INSERT OR IGNORE INTO RecipeSteps (RecipeId, OrderIndex, DurationMinutes, Notes) VALUES
    ((SELECT MIN(Id) FROM Recipes WHERE Title = 'Lentil Soup'), 1, 8,  NULL),
    ((SELECT MIN(Id) FROM Recipes WHERE Title = 'Lentil Soup'), 2, 30, 'Add sautéed vegetables; stir occasionally'),
    ((SELECT MIN(Id) FROM Recipes WHERE Title = 'Lentil Soup'), 3, 2,  'Adjust seasoning; finish with a squeeze of lemon juice');

INSERT OR IGNORE INTO RecipeStepActions (StepId, ActionId)
SELECT rs.Id, a.Id FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Actions a ON a.Name = 'Chop'
WHERE r.Title = 'Lentil Soup' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Lentil Soup');

INSERT OR IGNORE INTO RecipeStepActions (StepId, ActionId)
SELECT rs.Id, a.Id FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Actions a ON a.Name = 'Boil'
WHERE r.Title = 'Lentil Soup' AND rs.OrderIndex = 2 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Lentil Soup');

INSERT OR IGNORE INTO RecipeStepActions (StepId, ActionId)
SELECT rs.Id, a.Id FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Actions a ON a.Name = 'Season'
WHERE r.Title = 'Lentil Soup' AND rs.OrderIndex = 3 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Lentil Soup');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 150.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Onion'
WHERE r.Title = 'Lentil Soup' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Lentil Soup');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 150.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Carrot'
WHERE r.Title = 'Lentil Soup' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Lentil Soup');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 100.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Celery'
WHERE r.Title = 'Lentil Soup' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Lentil Soup');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 15.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Garlic'
WHERE r.Title = 'Lentil Soup' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Lentil Soup');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 300.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Red lentils'
WHERE r.Title = 'Lentil Soup' AND rs.OrderIndex = 2 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Lentil Soup');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 1200.0, 'ml' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Vegetable broth'
WHERE r.Title = 'Lentil Soup' AND rs.OrderIndex = 2 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Lentil Soup');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 400.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Canned tomatoes'
WHERE r.Title = 'Lentil Soup' AND rs.OrderIndex = 2 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Lentil Soup');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 4.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Cumin'
WHERE r.Title = 'Lentil Soup' AND rs.OrderIndex = 3 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Lentil Soup');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 3.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Turmeric'
WHERE r.Title = 'Lentil Soup' AND rs.OrderIndex = 3 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Lentil Soup');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 20.0, 'ml' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Lemon juice'
WHERE r.Title = 'Lentil Soup' AND rs.OrderIndex = 3 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Lentil Soup');

-- ─────────────────────────────────────────────────────────────────────────────
-- RECIPE 14: Quinoa Roasted Veggie Bowl
-- ─────────────────────────────────────────────────────────────────────────────
INSERT OR IGNORE INTO RecipeSteps (RecipeId, OrderIndex, DurationMinutes, Notes) VALUES
    ((SELECT MIN(Id) FROM Recipes WHERE Title = 'Quinoa Roasted Veggie Bowl'), 1, 20, 'Use 2:1 water to quinoa ratio; rest 5 minutes then fluff with a fork'),
    ((SELECT MIN(Id) FROM Recipes WHERE Title = 'Quinoa Roasted Veggie Bowl'), 2, 25, 'Roast at 200°C (400°F); spread in a single layer for even caramelisation');

INSERT OR IGNORE INTO RecipeStepActions (StepId, ActionId)
SELECT rs.Id, a.Id FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Actions a ON a.Name = 'Boil'
WHERE r.Title = 'Quinoa Roasted Veggie Bowl' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Quinoa Roasted Veggie Bowl');

INSERT OR IGNORE INTO RecipeStepActions (StepId, ActionId)
SELECT rs.Id, a.Id FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Actions a ON a.Name = 'Roast'
WHERE r.Title = 'Quinoa Roasted Veggie Bowl' AND rs.OrderIndex = 2 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Quinoa Roasted Veggie Bowl');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 200.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Quinoa'
WHERE r.Title = 'Quinoa Roasted Veggie Bowl' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Quinoa Roasted Veggie Bowl');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 200.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Sweet potato'
WHERE r.Title = 'Quinoa Roasted Veggie Bowl' AND rs.OrderIndex = 2 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Quinoa Roasted Veggie Bowl');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 150.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Zucchini'
WHERE r.Title = 'Quinoa Roasted Veggie Bowl' AND rs.OrderIndex = 2 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Quinoa Roasted Veggie Bowl');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 150.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Cherry tomatoes'
WHERE r.Title = 'Quinoa Roasted Veggie Bowl' AND rs.OrderIndex = 2 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Quinoa Roasted Veggie Bowl');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 25.0, 'ml' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Olive oil'
WHERE r.Title = 'Quinoa Roasted Veggie Bowl' AND rs.OrderIndex = 2 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Quinoa Roasted Veggie Bowl');

-- ─────────────────────────────────────────────────────────────────────────────
-- RECIPE 15: Egg and Spinach Omelette
-- ─────────────────────────────────────────────────────────────────────────────
INSERT OR IGNORE INTO RecipeSteps (RecipeId, OrderIndex, DurationMinutes, Notes) VALUES
    ((SELECT MIN(Id) FROM Recipes WHERE Title = 'Egg and Spinach Omelette'), 1, 2, NULL),
    ((SELECT MIN(Id) FROM Recipes WHERE Title = 'Egg and Spinach Omelette'), 2, 4, 'Fold omelette in half once edges are set; feta should be slightly melted');

INSERT OR IGNORE INTO RecipeStepActions (StepId, ActionId)
SELECT rs.Id, a.Id FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Actions a ON a.Name = 'Whisk'
WHERE r.Title = 'Egg and Spinach Omelette' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Egg and Spinach Omelette');

INSERT OR IGNORE INTO RecipeStepActions (StepId, ActionId)
SELECT rs.Id, a.Id FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Actions a ON a.Name = 'Fry'
WHERE r.Title = 'Egg and Spinach Omelette' AND rs.OrderIndex = 2 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Egg and Spinach Omelette');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 150.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Egg'
WHERE r.Title = 'Egg and Spinach Omelette' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Egg and Spinach Omelette');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 2.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Salt'
WHERE r.Title = 'Egg and Spinach Omelette' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Egg and Spinach Omelette');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 8.0, 'ml' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Olive oil'
WHERE r.Title = 'Egg and Spinach Omelette' AND rs.OrderIndex = 2 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Egg and Spinach Omelette');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 80.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Fresh spinach'
WHERE r.Title = 'Egg and Spinach Omelette' AND rs.OrderIndex = 2 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Egg and Spinach Omelette');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 40.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Feta cheese'
WHERE r.Title = 'Egg and Spinach Omelette' AND rs.OrderIndex = 2 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Egg and Spinach Omelette');

-- ─────────────────────────────────────────────────────────────────────────────
-- RECIPE 16: Pork Tenderloin with Apple Sauce
-- ─────────────────────────────────────────────────────────────────────────────
INSERT OR IGNORE INTO RecipeSteps (RecipeId, OrderIndex, DurationMinutes, Notes) VALUES
    ((SELECT MIN(Id) FROM Recipes WHERE Title = 'Pork Tenderloin with Apple Sauce'), 1, 5,  NULL),
    ((SELECT MIN(Id) FROM Recipes WHERE Title = 'Pork Tenderloin with Apple Sauce'), 2, 25, 'Roast at 200°C until internal temperature reaches 63°C; rest 5 minutes before slicing'),
    ((SELECT MIN(Id) FROM Recipes WHERE Title = 'Pork Tenderloin with Apple Sauce'), 3, 10, 'Dice apple; simmer on medium heat until soft; mash and serve alongside pork');

INSERT OR IGNORE INTO RecipeStepActions (StepId, ActionId)
SELECT rs.Id, a.Id FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Actions a ON a.Name = 'Season'
WHERE r.Title = 'Pork Tenderloin with Apple Sauce' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Pork Tenderloin with Apple Sauce');

INSERT OR IGNORE INTO RecipeStepActions (StepId, ActionId)
SELECT rs.Id, a.Id FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Actions a ON a.Name = 'Roast'
WHERE r.Title = 'Pork Tenderloin with Apple Sauce' AND rs.OrderIndex = 2 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Pork Tenderloin with Apple Sauce');

INSERT OR IGNORE INTO RecipeStepActions (StepId, ActionId)
SELECT rs.Id, a.Id FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Actions a ON a.Name = 'Simmer'
WHERE r.Title = 'Pork Tenderloin with Apple Sauce' AND rs.OrderIndex = 3 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Pork Tenderloin with Apple Sauce');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 500.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Pork tenderloin'
WHERE r.Title = 'Pork Tenderloin with Apple Sauce' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Pork Tenderloin with Apple Sauce');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 15.0, 'ml' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Olive oil'
WHERE r.Title = 'Pork Tenderloin with Apple Sauce' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Pork Tenderloin with Apple Sauce');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 4.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Fresh rosemary'
WHERE r.Title = 'Pork Tenderloin with Apple Sauce' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Pork Tenderloin with Apple Sauce');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 10.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Garlic'
WHERE r.Title = 'Pork Tenderloin with Apple Sauce' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Pork Tenderloin with Apple Sauce');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 200.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Apple'
WHERE r.Title = 'Pork Tenderloin with Apple Sauce' AND rs.OrderIndex = 3 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Pork Tenderloin with Apple Sauce');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 15.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Butter'
WHERE r.Title = 'Pork Tenderloin with Apple Sauce' AND rs.OrderIndex = 3 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Pork Tenderloin with Apple Sauce');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 2.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Cinnamon'
WHERE r.Title = 'Pork Tenderloin with Apple Sauce' AND rs.OrderIndex = 3 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Pork Tenderloin with Apple Sauce');

-- ─────────────────────────────────────────────────────────────────────────────
-- RECIPE 17: Shrimp Tacos
-- ─────────────────────────────────────────────────────────────────────────────
INSERT OR IGNORE INTO RecipeSteps (RecipeId, OrderIndex, DurationMinutes, Notes) VALUES
    ((SELECT MIN(Id) FROM Recipes WHERE Title = 'Shrimp Tacos'), 1, 10, NULL),
    ((SELECT MIN(Id) FROM Recipes WHERE Title = 'Shrimp Tacos'), 2, 5,  '2–3 minutes per side until pink and lightly charred'),
    ((SELECT MIN(Id) FROM Recipes WHERE Title = 'Shrimp Tacos'), 3, 5,  'Serve shrimp in warm corn tortillas topped with slaw and avocado');

INSERT OR IGNORE INTO RecipeStepActions (StepId, ActionId)
SELECT rs.Id, a.Id FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Actions a ON a.Name = 'Marinate'
WHERE r.Title = 'Shrimp Tacos' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Shrimp Tacos');

INSERT OR IGNORE INTO RecipeStepActions (StepId, ActionId)
SELECT rs.Id, a.Id FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Actions a ON a.Name = 'Grill'
WHERE r.Title = 'Shrimp Tacos' AND rs.OrderIndex = 2 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Shrimp Tacos');

INSERT OR IGNORE INTO RecipeStepActions (StepId, ActionId)
SELECT rs.Id, a.Id FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Actions a ON a.Name = 'Chop'
WHERE r.Title = 'Shrimp Tacos' AND rs.OrderIndex = 3 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Shrimp Tacos');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 300.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Shrimp'
WHERE r.Title = 'Shrimp Tacos' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Shrimp Tacos');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 20.0, 'ml' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Lime juice'
WHERE r.Title = 'Shrimp Tacos' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Shrimp Tacos');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 4.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Chili powder'
WHERE r.Title = 'Shrimp Tacos' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Shrimp Tacos');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 2.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Cumin'
WHERE r.Title = 'Shrimp Tacos' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Shrimp Tacos');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 5.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Garlic'
WHERE r.Title = 'Shrimp Tacos' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Shrimp Tacos');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 100.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Red cabbage'
WHERE r.Title = 'Shrimp Tacos' AND rs.OrderIndex = 3 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Shrimp Tacos');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 100.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Avocado'
WHERE r.Title = 'Shrimp Tacos' AND rs.OrderIndex = 3 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Shrimp Tacos');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 10.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Fresh cilantro'
WHERE r.Title = 'Shrimp Tacos' AND rs.OrderIndex = 3 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Shrimp Tacos');

-- ─────────────────────────────────────────────────────────────────────────────
-- RECIPE 18: Greek Yogurt Parfait
-- ─────────────────────────────────────────────────────────────────────────────
INSERT OR IGNORE INTO RecipeSteps (RecipeId, OrderIndex, DurationMinutes, Notes) VALUES
    ((SELECT MIN(Id) FROM Recipes WHERE Title = 'Greek Yogurt Parfait'), 1, 2,    NULL),
    ((SELECT MIN(Id) FROM Recipes WHERE Title = 'Greek Yogurt Parfait'), 2, NULL, 'Layer in a glass: yogurt mixture, granola (40 g), fresh mixed berries (100 g). Repeat layers and serve immediately.');

INSERT OR IGNORE INTO RecipeStepActions (StepId, ActionId)
SELECT rs.Id, a.Id FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Actions a ON a.Name = 'Mix'
WHERE r.Title = 'Greek Yogurt Parfait' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Greek Yogurt Parfait');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 250.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Greek yogurt'
WHERE r.Title = 'Greek Yogurt Parfait' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Greek Yogurt Parfait');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 20.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Honey'
WHERE r.Title = 'Greek Yogurt Parfait' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Greek Yogurt Parfait');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 2.0, 'ml' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Vanilla extract'
WHERE r.Title = 'Greek Yogurt Parfait' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Greek Yogurt Parfait');

-- ─────────────────────────────────────────────────────────────────────────────
-- RECIPE 19: Tuna Nicoise Salad
-- ─────────────────────────────────────────────────────────────────────────────
INSERT OR IGNORE INTO RecipeSteps (RecipeId, OrderIndex, DurationMinutes, Notes) VALUES
    ((SELECT MIN(Id) FROM Recipes WHERE Title = 'Tuna Nicoise Salad'), 1, 12, 'Hard-boil eggs 10 minutes; blanch green beans 2 minutes in the same pot; cool both in ice water'),
    ((SELECT MIN(Id) FROM Recipes WHERE Title = 'Tuna Nicoise Salad'), 2, 2,  NULL),
    ((SELECT MIN(Id) FROM Recipes WHERE Title = 'Tuna Nicoise Salad'), 3, 2,  'Whisk dressing; toss with tuna, halved eggs, green beans, and cherry tomatoes (150 g)');

INSERT OR IGNORE INTO RecipeStepActions (StepId, ActionId)
SELECT rs.Id, a.Id FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Actions a ON a.Name = 'Boil'
WHERE r.Title = 'Tuna Nicoise Salad' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Tuna Nicoise Salad');

INSERT OR IGNORE INTO RecipeStepActions (StepId, ActionId)
SELECT rs.Id, a.Id FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Actions a ON a.Name = 'Drain'
WHERE r.Title = 'Tuna Nicoise Salad' AND rs.OrderIndex = 2 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Tuna Nicoise Salad');

INSERT OR IGNORE INTO RecipeStepActions (StepId, ActionId)
SELECT rs.Id, a.Id FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Actions a ON a.Name = 'Mix'
WHERE r.Title = 'Tuna Nicoise Salad' AND rs.OrderIndex = 3 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Tuna Nicoise Salad');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 100.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Egg'
WHERE r.Title = 'Tuna Nicoise Salad' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Tuna Nicoise Salad');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 200.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Green beans'
WHERE r.Title = 'Tuna Nicoise Salad' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Tuna Nicoise Salad');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 160.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Canned tuna'
WHERE r.Title = 'Tuna Nicoise Salad' AND rs.OrderIndex = 2 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Tuna Nicoise Salad');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 40.0, 'ml' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Olive oil'
WHERE r.Title = 'Tuna Nicoise Salad' AND rs.OrderIndex = 3 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Tuna Nicoise Salad');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 12.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Dijon mustard'
WHERE r.Title = 'Tuna Nicoise Salad' AND rs.OrderIndex = 3 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Tuna Nicoise Salad');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 20.0, 'ml' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Lemon juice'
WHERE r.Title = 'Tuna Nicoise Salad' AND rs.OrderIndex = 3 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Tuna Nicoise Salad');

-- ─────────────────────────────────────────────────────────────────────────────
-- RECIPE 20: Chicken Tikka Masala
-- ─────────────────────────────────────────────────────────────────────────────
INSERT OR IGNORE INTO RecipeSteps (RecipeId, OrderIndex, DurationMinutes, Notes) VALUES
    ((SELECT MIN(Id) FROM Recipes WHERE Title = 'Chicken Tikka Masala'), 1, 120, 'Minimum 2 hours; overnight gives deeper flavour'),
    ((SELECT MIN(Id) FROM Recipes WHERE Title = 'Chicken Tikka Masala'), 2, 12,  'Grill until lightly charred; cut into 3 cm chunks'),
    ((SELECT MIN(Id) FROM Recipes WHERE Title = 'Chicken Tikka Masala'), 3, 20,  'Add grilled chicken; simmer until sauce coats the back of a spoon; serve with basmati rice');

INSERT OR IGNORE INTO RecipeStepActions (StepId, ActionId)
SELECT rs.Id, a.Id FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Actions a ON a.Name = 'Marinate'
WHERE r.Title = 'Chicken Tikka Masala' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Chicken Tikka Masala');

INSERT OR IGNORE INTO RecipeStepActions (StepId, ActionId)
SELECT rs.Id, a.Id FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Actions a ON a.Name = 'Grill'
WHERE r.Title = 'Chicken Tikka Masala' AND rs.OrderIndex = 2 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Chicken Tikka Masala');

INSERT OR IGNORE INTO RecipeStepActions (StepId, ActionId)
SELECT rs.Id, a.Id FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Actions a ON a.Name = 'Simmer'
WHERE r.Title = 'Chicken Tikka Masala' AND rs.OrderIndex = 3 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Chicken Tikka Masala');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 600.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Chicken breast'
WHERE r.Title = 'Chicken Tikka Masala' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Chicken Tikka Masala');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 150.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Greek yogurt'
WHERE r.Title = 'Chicken Tikka Masala' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Chicken Tikka Masala');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 25.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Tikka masala spice blend'
WHERE r.Title = 'Chicken Tikka Masala' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Chicken Tikka Masala');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 20.0, 'ml' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Lemon juice'
WHERE r.Title = 'Chicken Tikka Masala' AND rs.OrderIndex = 1 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Chicken Tikka Masala');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 400.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Canned tomatoes'
WHERE r.Title = 'Chicken Tikka Masala' AND rs.OrderIndex = 3 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Chicken Tikka Masala');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 150.0, 'ml' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Heavy cream'
WHERE r.Title = 'Chicken Tikka Masala' AND rs.OrderIndex = 3 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Chicken Tikka Masala');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 200.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Onion'
WHERE r.Title = 'Chicken Tikka Masala' AND rs.OrderIndex = 3 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Chicken Tikka Masala');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 20.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Garlic'
WHERE r.Title = 'Chicken Tikka Masala' AND rs.OrderIndex = 3 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Chicken Tikka Masala');

INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
SELECT rs.Id, i.Id, 15.0, 'g' FROM RecipeSteps rs JOIN Recipes r ON r.Id = rs.RecipeId JOIN Ingredients i ON i.Name = 'Tikka masala spice blend'
WHERE r.Title = 'Chicken Tikka Masala' AND rs.OrderIndex = 3 AND r.Id = (SELECT MIN(Id) FROM Recipes WHERE Title = 'Chicken Tikka Masala');
