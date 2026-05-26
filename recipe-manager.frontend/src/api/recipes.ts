import { request } from './client';
import type { Recipe, CreateRecipeRequest, UpdateRecipeRequest } from '../types';

export const recipesApi = {
  getAll: () => request<Recipe[]>('/api/recipes'),

  getById: (id: number) => request<Recipe>(`/api/recipes/${id}`),

  create: (body: CreateRecipeRequest) =>
    request<{ id: number }>('/api/recipes', { method: 'POST', body: JSON.stringify(body) }),

  update: (id: number, body: UpdateRecipeRequest) =>
    request<void>(`/api/recipes/${id}`, { method: 'PUT', body: JSON.stringify(body) }),

  delete: (id: number) =>
    request<void>(`/api/recipes/${id}`, { method: 'DELETE' }),
};
