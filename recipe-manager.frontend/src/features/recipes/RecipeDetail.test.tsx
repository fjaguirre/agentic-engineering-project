import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter, Route, Routes } from 'react-router-dom';
import { vi, describe, it, expect, beforeEach } from 'vitest';
import { recipesApi } from '../../api';
import RecipeDetail from './RecipeDetail';
import type { Recipe } from '../../types';

vi.mock('../../api', () => ({
  recipesApi: {
    getById: vi.fn(),
    delete: vi.fn(),
  },
}));

const mockRecipesApi = recipesApi as { getById: ReturnType<typeof vi.fn>; delete: ReturnType<typeof vi.fn> };

const sampleRecipe: Recipe = {
  id: 5,
  title: 'Salmon Bowl',
  servings: 2,
  caloriesPerServing: 550,
  proteinG: 35,
  carbsG: 40,
  fatG: 18,
  primaryProtein: 'Fish',
  tags: [{ id: 2, name: 'Dairy-Free' }],
  steps: [
    {
      id: 10,
      orderIndex: 1,
      actions: ['Grill'],
      ingredients: [{ id: 20, ingredientName: 'Salmon', quantity: 200, unit: 'g' }],
      durationMinutes: 15,
      notes: 'Until cooked through',
    },
  ],
};

function renderDetail(id = '5') {
  return render(
    <MemoryRouter initialEntries={[`/recipes/${id}`]}>
      <Routes>
        <Route path="/recipes/:id" element={<RecipeDetail />} />
      </Routes>
    </MemoryRouter>,
  );
}

describe('RecipeDetail', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('shows recipe title and macros after load', async () => {
    // Arrange
    mockRecipesApi.getById.mockResolvedValue(sampleRecipe);

    // Act
    renderDetail();

    // Assert
    await waitFor(() => {
      expect(screen.getByText('Salmon Bowl')).toBeInTheDocument();
      expect(screen.getByText(/550 kcal/)).toBeInTheDocument();
      expect(screen.getByText('Dairy-Free')).toBeInTheDocument();
    });
  });

  it('renders step as a preview sentence', async () => {
    // Arrange
    mockRecipesApi.getById.mockResolvedValue(sampleRecipe);

    // Act
    renderDetail();

    // Assert — step displayed as "Grill 200 g of Salmon during 15 minutes. Until cooked through"
    await waitFor(() => {
      expect(screen.getByText(/Grill 200 g of Salmon during 15 minutes/i)).toBeInTheDocument();
      expect(screen.getByText(/Until cooked through/i)).toBeInTheDocument();
    });
  });

  it('shows not-found message for missing recipe', async () => {
    // Arrange
    mockRecipesApi.getById.mockRejectedValue(new Error('not found'));

    // Act
    renderDetail('9999');

    // Assert
    await waitFor(() => {
      expect(screen.getByRole('alert')).toBeInTheDocument();
    });
  });

  it('navigates away after delete is confirmed', async () => {
    // Arrange
    mockRecipesApi.getById.mockResolvedValue(sampleRecipe);
    mockRecipesApi.delete.mockResolvedValue(undefined);
    vi.spyOn(window, 'confirm').mockReturnValue(true);
    const user = userEvent.setup();

    renderDetail();
    await waitFor(() => expect(screen.getByText('Salmon Bowl')).toBeInTheDocument());

    // Act
    await user.click(screen.getByRole('button', { name: /delete/i }));

    // Assert — page should navigate away (detail content disappears)
    await waitFor(() => {
      expect(mockRecipesApi.delete).toHaveBeenCalledWith(5);
    });
  });
});
