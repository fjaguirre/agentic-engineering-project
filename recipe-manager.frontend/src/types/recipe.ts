export interface Tag {
  id: number;
  name: string;
}

export interface CulinaryAction {
  id: number;
  name: string;
}

export interface RecipeStepIngredient {
  id: number;
  ingredientName: string;
  quantity: number;
  unit: string;
}

export interface RecipeStep {
  id: number;
  orderIndex: number;
  actions: string[];
  ingredients: RecipeStepIngredient[];
  durationMinutes: number | null;
  notes: string | null;
}

export interface Recipe {
  id: number;
  title: string;
  servings: number;
  caloriesPerServing: number;
  proteinG: number;
  carbsG: number;
  fatG: number;
  primaryProtein: string | null;
  tags: Tag[];
  steps: RecipeStep[];
}

export interface CreateStepIngredientRequest {
  ingredientName: string;
  quantity: number;
  unit: string;
}

export interface CreateStepRequest {
  orderIndex: number;
  actions: string[];
  ingredients: CreateStepIngredientRequest[];
  durationMinutes: number | null;
  notes: string | null;
}

export interface CreateRecipeRequest {
  title: string;
  servings: number;
  caloriesPerServing: number;
  proteinG: number;
  carbsG: number;
  fatG: number;
  primaryProtein: string | null;
  tags: string[];
  steps: CreateStepRequest[];
}

export type UpdateRecipeRequest = CreateRecipeRequest;
