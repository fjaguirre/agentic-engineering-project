import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter } from 'react-router-dom';
import { vi, describe, it, expect, beforeEach } from 'vitest';
import { recipesApi } from '../../api';
import RecipeList from './RecipeList';
import type { Recipe } from '../../types';

vi.mock('../../api', () => ({
  recipesApi: {
    getAll: vi.fn(),
    delete: vi.fn(),
  },
}));

const mockRecipesApi = recipesApi as { getAll: ReturnType<typeof vi.fn>; delete: ReturnType<typeof vi.fn> };

const sampleRecipes: Recipe[] = [
  {
    id: 1,
    title: 'Chicken Salad',
    servings: 2,
    caloriesPerServing: 400,
    proteinG: 30,
    carbsG: 10,
    fatG: 15,
    primaryProtein: 'Chicken',
    tags: [{ id: 1, name: 'GlutenFree' }],
    steps: [],
  },
  {
    id: 2,
    title: 'Beef Stew',
    servings: 4,
    caloriesPerServing: 600,
    proteinG: 40,
    carbsG: 30,
    fatG: 20,
    primaryProtein: 'Beef',
    tags: [],
    steps: [],
  },
];

function renderList() {
  return render(
    <MemoryRouter>
      <RecipeList />
    </MemoryRouter>,
  );
}

describe('RecipeList', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  // Arrange / Act / Assert

  it('shows loading state initially', () => {
    // Arrange
    mockRecipesApi.getAll.mockReturnValue(new Promise(() => {}));

    // Act
    renderList();

    // Assert
    expect(screen.getByText(/loading/i)).toBeInTheDocument();
  });

  it('renders recipe titles and tags after load', async () => {
    // Arrange
    mockRecipesApi.getAll.mockResolvedValue(sampleRecipes);

    // Act
    renderList();

    // Assert
    await waitFor(() => {
      expect(screen.getByText('Chicken Salad')).toBeInTheDocument();
      expect(screen.getByText('Beef Stew')).toBeInTheDocument();
      expect(screen.getByText('GlutenFree')).toBeInTheDocument();
    });
  });

  it('shows empty message when no recipes exist', async () => {
    // Arrange
    mockRecipesApi.getAll.mockResolvedValue([]);

    // Act
    renderList();

    // Assert
    await waitFor(() => {
      expect(screen.getByText(/no recipes yet/i)).toBeInTheDocument();
    });
  });

  it('shows error message on API failure', async () => {
    // Arrange
    mockRecipesApi.getAll.mockRejectedValue(new Error('Network error'));

    // Act
    renderList();

    // Assert
    await waitFor(() => {
      expect(screen.getByRole('alert')).toHaveTextContent(/network error/i);
    });
  });

  it('removes recipe from list after delete is confirmed', async () => {
    // Arrange
    mockRecipesApi.getAll.mockResolvedValue(sampleRecipes);
    mockRecipesApi.delete.mockResolvedValue(undefined);
    vi.spyOn(window, 'confirm').mockReturnValue(true);
    const user = userEvent.setup();

    renderList();
    await waitFor(() => expect(screen.getByText('Chicken Salad')).toBeInTheDocument());

    // Act — click Delete on the first recipe's button
    const deleteButtons = screen.getAllByRole('button', { name: /delete/i });
    await user.click(deleteButtons[0]);

    // Assert
    await waitFor(() => {
      expect(screen.queryByText('Chicken Salad')).not.toBeInTheDocument();
      expect(screen.getByText('Beef Stew')).toBeInTheDocument();
    });
  });
});
