import { request } from './client';
import type { GroceryLineItem } from '../types';

export const groceryApi = {
  getForMenu: (menuId: number) =>
    request<GroceryLineItem[]>(`/api/menus/${menuId}/grocery`),
};
