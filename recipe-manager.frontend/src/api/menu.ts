import { request } from './client';
import type { Menu, MenuConstraints } from '../types';

export const menuApi = {
  generate: (constraints: MenuConstraints) =>
    request<Menu>('/api/menus/generate', { method: 'POST', body: JSON.stringify(constraints) }),

  getById: (id: number) => request<Menu>(`/api/menus/${id}`),

  getAll: () => request<Menu[]>('/api/menus'),
};
