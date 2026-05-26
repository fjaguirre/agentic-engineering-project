import type { Recipe } from './recipe';

export type MealSlot = 'Breakfast' | 'Lunch' | 'Dinner';

export interface MenuSlot {
  day: number;
  mealSlot: MealSlot;
  recipe: Recipe;
}

export interface Menu {
  id: number;
  seed: number;
  generatedAt: string;
  slots: MenuSlot[];
}
