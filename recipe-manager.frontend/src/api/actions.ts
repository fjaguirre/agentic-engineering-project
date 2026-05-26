import { request } from './client';
import type { CulinaryAction } from '../types';

export const actionsApi = {
  getAll: () => request<CulinaryAction[]>('/api/actions'),
};
