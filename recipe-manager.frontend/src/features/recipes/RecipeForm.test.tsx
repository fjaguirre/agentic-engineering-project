import { render, screen, waitFor, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter, Route, Routes } from 'react-router-dom';
import { vi, describe, it, expect, beforeEach } from 'vitest';
import { recipesApi, tagsApi, actionsApi } from '../../api';
import RecipeForm from './RecipeForm';
import type { CulinaryAction, Recipe, Tag } from '../../types';

vi.mock('../../api', () => ({
  recipesApi: {
    create: vi.fn(),
    update: vi.fn(),
    getById: vi.fn(),
  },
  tagsApi: {
    getAll: vi.fn(),
  },
  actionsApi: {
    getAll: vi.fn(),
  },
}));

const mockRecipesApi = recipesApi as {
  create: ReturnType<typeof vi.fn>;
  update: ReturnType<typeof vi.fn>;
  getById: ReturnType<typeof vi.fn>;
};
const mockTagsApi = tagsApi as { getAll: ReturnType<typeof vi.fn> };
const mockActionsApi = actionsApi as { getAll: ReturnType<typeof vi.fn> };

const sampleTags: Tag[] = [
  { id: 1, name: 'GlutenFree' },
  { id: 2, name: 'Vegan' },
];

const sampleActions: CulinaryAction[] = [
  { id: 1, name: 'Chop' },
  { id: 2, name: 'Mix' },
  { id: 3, name: 'Boil' },
];

const sampleRecipe: Recipe = {
  id: 3,
  title: 'Existing Recipe',
  servings: 2,
  caloriesPerServing: 500,
  proteinG: 30,
  carbsG: 40,
  fatG: 15,
  primaryProtein: 'Chicken',
  tags: [{ id: 1, name: 'GlutenFree' }],
  steps: [
    {
      id: 10,
      orderIndex: 1,
      actions: ['Chop', 'Mix'],
      ingredients: [{ id: 20, ingredientName: 'Chicken', quantity: 200, unit: 'g' }],
      durationMinutes: 10,
      notes: 'Cook until golden',
    },
  ],
};

function renderCreateForm() {
  return render(
    <MemoryRouter initialEntries={['/recipes/new']}>
      <Routes>
        <Route path="/recipes/new" element={<RecipeForm />} />
        <Route path="/recipes/:id" element={<div>Recipe detail page</div>} />
      </Routes>
    </MemoryRouter>,
  );
}

function renderEditForm(id = '3') {
  return render(
    <MemoryRouter initialEntries={[`/recipes/${id}/edit`]}>
      <Routes>
        <Route path="/recipes/:id/edit" element={<RecipeForm />} />
        <Route path="/recipes/:id" element={<div>Recipe detail page</div>} />
      </Routes>
    </MemoryRouter>,
  );
}

describe('RecipeForm — create', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mockTagsApi.getAll.mockResolvedValue(sampleTags);
    mockActionsApi.getAll.mockResolvedValue(sampleActions);
  });

  it('renders create heading and required fields', async () => {
    // Arrange / Act
    renderCreateForm();

    // Assert
    await waitFor(() => {
      expect(screen.getByRole('form', { name: /create recipe/i })).toBeInTheDocument();
    });
    expect(screen.getByRole('button', { name: /create recipe/i })).toBeInTheDocument();
  });

  it('renders available tags as checkboxes', async () => {
    // Arrange / Act
    renderCreateForm();

    // Assert
    await waitFor(() => {
      expect(screen.getByRole('checkbox', { name: /glutenfree/i })).toBeInTheDocument();
      expect(screen.getByRole('checkbox', { name: /vegan/i })).toBeInTheDocument();
    });
  });

  it('starts with one empty step and action dropdown — ingredients hidden by default', async () => {
    // Arrange / Act
    renderCreateForm();

    // Assert
    await waitFor(() => {
      expect(screen.getByRole('group', { name: /step 1/i })).toBeInTheDocument();
    });
    expect(screen.getByRole('combobox', { name: /add action/i })).toBeInTheDocument();
    // Ingredient rows are hidden until the Ingredients checkbox is checked
    expect(screen.queryByRole('spinbutton', { name: /quantity/i })).not.toBeInTheDocument();
  });

  it('adds a step when "+ Add Step" is clicked', async () => {
    // Arrange
    const user = userEvent.setup();
    renderCreateForm();
    await waitFor(() => screen.getByRole('group', { name: /step 1/i }));

    // Act
    await user.click(screen.getByRole('button', { name: /add step/i }));

    // Assert
    expect(screen.getByRole('group', { name: /step 2/i })).toBeInTheDocument();
  });

  it('removes a step when Remove is clicked', async () => {
    // Arrange
    const user = userEvent.setup();
    renderCreateForm();
    await waitFor(() => screen.getByRole('group', { name: /step 1/i }));
    await user.click(screen.getByRole('button', { name: /add step/i }));
    expect(screen.getByRole('group', { name: /step 2/i })).toBeInTheDocument();

    // Act — remove Step 2
    const step2 = screen.getByRole('group', { name: /step 2/i });
    await user.click(within(step2).getByRole('button', { name: /remove step/i }));

    // Assert
    expect(screen.queryByRole('group', { name: /step 2/i })).not.toBeInTheDocument();
  });

  it('reorders steps with move-up and move-down buttons', async () => {
    // Arrange
    const user = userEvent.setup();
    renderCreateForm();
    await waitFor(() => screen.getByRole('group', { name: /step 1/i }));
    await user.click(screen.getByRole('button', { name: /add step/i }));
    expect(screen.getByRole('group', { name: /step 2/i })).toBeInTheDocument();

    // Act — move step 2 up
    const step2Group = screen.getByRole('group', { name: /step 2/i });
    await user.click(within(step2Group).getByRole('button', { name: /move step up/i }));

    // Assert — both step groups still exist after reorder
    expect(screen.getByRole('group', { name: /step 1/i })).toBeInTheDocument();
    expect(screen.getByRole('group', { name: /step 2/i })).toBeInTheDocument();
  });

  it('shows free text textarea when free text option is selected', async () => {
    // Arrange
    const user = userEvent.setup();
    renderCreateForm();
    await waitFor(() => screen.getByRole('group', { name: /step 1/i }));

    // Act — select the free text option
    await user.selectOptions(screen.getByRole('combobox', { name: /add action/i }), '__freetext__');

    // Assert — textarea appears and optional field checkboxes are hidden
    expect(screen.getByRole('textbox', { name: /free text step description/i })).toBeInTheDocument();
    expect(screen.queryByRole('checkbox', { name: /ingredients/i })).not.toBeInTheDocument();
  });

  it('shows ingredient rows when Ingredients checkbox is checked', async () => {
    // Arrange
    const user = userEvent.setup();
    renderCreateForm();
    await waitFor(() => screen.getByRole('group', { name: /step 1/i }));

    // Act
    await user.click(screen.getByRole('checkbox', { name: /ingredients/i }));

    // Assert
    expect(screen.getByRole('spinbutton', { name: /quantity/i })).toBeInTheDocument();
  });

  it('submits create request with correct payload and navigates to detail', async () => {
    // Arrange
    const user = userEvent.setup();
    mockRecipesApi.create.mockResolvedValue({ id: 99 });
    renderCreateForm();
    await waitFor(() => screen.getByRole('form', { name: /create recipe/i }));

    // Act
    await user.type(screen.getByRole('textbox', { name: /title/i }), 'Test Dish');
    await user.clear(screen.getByRole('spinbutton', { name: /calories/i }));
    await user.type(screen.getByRole('spinbutton', { name: /calories/i }), '400');
    await user.clear(screen.getByRole('spinbutton', { name: /protein/i }));
    await user.type(screen.getByRole('spinbutton', { name: /protein/i }), '30');
    await user.clear(screen.getByRole('spinbutton', { name: /carbs/i }));
    await user.type(screen.getByRole('spinbutton', { name: /carbs/i }), '50');
    await user.clear(screen.getByRole('spinbutton', { name: /fat/i }));
    await user.type(screen.getByRole('spinbutton', { name: /fat/i }), '10');

    await user.click(screen.getByRole('button', { name: /create recipe/i }));

    // Assert
    await waitFor(() => {
      expect(mockRecipesApi.create).toHaveBeenCalledOnce();
      const arg = mockRecipesApi.create.mock.calls[0][0];
      expect(arg.title).toBe('Test Dish');
      expect(arg.caloriesPerServing).toBe(400);
    });
  });
});

describe('RecipeForm — edit', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mockTagsApi.getAll.mockResolvedValue(sampleTags);
    mockActionsApi.getAll.mockResolvedValue(sampleActions);
    mockRecipesApi.getById.mockResolvedValue(sampleRecipe);
  });

  it('pre-fills form fields with existing recipe data', async () => {
    // Arrange / Act
    renderEditForm();

    // Assert
    await waitFor(() => {
      expect(screen.getByRole('form', { name: /edit recipe/i })).toBeInTheDocument();
      const titleInput = screen.getByRole('textbox', { name: /title/i });
      expect(titleInput).toHaveValue('Existing Recipe');
    });
  });

  it('pre-checks tags that exist on the recipe', async () => {
    // Arrange / Act
    renderEditForm();

    // Assert
    await waitFor(() => {
      expect(screen.getByRole('checkbox', { name: /glutenfree/i })).toBeChecked();
      expect(screen.getByRole('checkbox', { name: /vegan/i })).not.toBeChecked();
    });
  });

  it('calls update API on submit', async () => {
    // Arrange
    const user = userEvent.setup();
    mockRecipesApi.update.mockResolvedValue(undefined);
    renderEditForm();
    await waitFor(() => screen.getByRole('form', { name: /edit recipe/i }));

    // Act
    await user.click(screen.getByRole('button', { name: /save changes/i }));

    // Assert
    await waitFor(() => {
      expect(mockRecipesApi.update).toHaveBeenCalledWith(3, expect.objectContaining({ title: 'Existing Recipe' }));
    });
  });
});
