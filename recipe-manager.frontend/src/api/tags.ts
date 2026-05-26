import { request } from './client';
import type { Tag } from '../types';

export const tagsApi = {
  getAll: () => request<Tag[]>('/api/tags'),
};
