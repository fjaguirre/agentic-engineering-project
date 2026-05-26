import { render, screen, waitFor } from '@testing-library/react';
import { MemoryRouter, Route, Routes } from 'react-router-dom';
import { vi, describe, it, expect, beforeEach } from 'vitest';
import { groceryApi } from '../../api';
import GroceryList from './GroceryList';
import type { GroceryLineItem } from '../../types';

vi.mock('../../api', () => ({
  groceryApi: { getForMenu: vi.fn() },
}));

const mockGroceryApi = groceryApi as { getForMenu: ReturnType<typeof vi.fn> };

const sampleItems: GroceryLineItem[] = [
  { ingredientName: 'Chicken', quantity: 1.5, unit: 'kg' },
  { ingredientName: 'Rice', quantity: 600, unit: 'g' },
  { ingredientName: 'Olive Oil', quantity: 0.1, unit: 'L' },
];

function renderList(menuId = '7') {
  return render(
    <MemoryRouter initialEntries={[`/menus/${menuId}/grocery`]}>
      <Routes>
        <Route path="/menus/:menuId/grocery" element={<GroceryList />} />
        <Route path="/menus/:id" element={<div>Menu calendar page</div>} />
      </Routes>
    </MemoryRouter>,
  );
}

describe('GroceryList', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('shows loading state initially', () => {
    // Arrange
    mockGroceryApi.getForMenu.mockReturnValue(new Promise(() => {}));

    // Act
    renderList();

    // Assert
    expect(screen.getByText(/loading/i)).toBeInTheDocument();
  });

  it('renders ingredient table with all items', async () => {
    // Arrange
    mockGroceryApi.getForMenu.mockResolvedValue(sampleItems);

    // Act
    renderList();

    // Assert
    await waitFor(() => {
      expect(screen.getByRole('table', { name: /grocery list/i })).toBeInTheDocument();
      expect(screen.getByText('Chicken')).toBeInTheDocument();
      expect(screen.getByText('Rice')).toBeInTheDocument();
      expect(screen.getByText('Olive Oil')).toBeInTheDocument();
    });
  });

  it('renders quantity and unit columns', async () => {
    // Arrange
    mockGroceryApi.getForMenu.mockResolvedValue(sampleItems);

    // Act
    renderList();

    // Assert
    await waitFor(() => {
      expect(screen.getByText('1.5')).toBeInTheDocument();
      expect(screen.getByText('kg')).toBeInTheDocument();
      expect(screen.getByText('600')).toBeInTheDocument();
      expect(screen.getByText('g')).toBeInTheDocument();
    });
  });

  it('shows empty state message when no items returned', async () => {
    // Arrange
    mockGroceryApi.getForMenu.mockResolvedValue([]);

    // Act
    renderList();

    // Assert
    await waitFor(() => {
      expect(screen.getByText(/no ingredients found/i)).toBeInTheDocument();
    });
  });

  it('shows error message on API failure', async () => {
    // Arrange
    mockGroceryApi.getForMenu.mockRejectedValue(new Error('Menu not found'));

    // Act
    renderList();

    // Assert
    await waitFor(() => {
      expect(screen.getByRole('alert')).toHaveTextContent(/menu not found/i);
    });
  });

  it('passes correct menuId to API call', async () => {
    // Arrange
    mockGroceryApi.getForMenu.mockResolvedValue([]);

    // Act
    renderList('42');

    // Assert
    await waitFor(() => {
      expect(mockGroceryApi.getForMenu).toHaveBeenCalledWith(42);
    });
  });
});
