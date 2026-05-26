import { render, screen, waitFor } from '@testing-library/react';
import { MemoryRouter, Route, Routes } from 'react-router-dom';
import { vi, describe, it, expect, beforeEach } from 'vitest';
import { menuApi } from '../../api';
import MenuCalendar from './MenuCalendar';
import type { Menu } from '../../types';

vi.mock('../../api', () => ({
  menuApi: { getById: vi.fn() },
}));

const mockMenuApi = menuApi as { getById: ReturnType<typeof vi.fn> };

function makeMenu(overrides?: Partial<Menu>): Menu {
  const slots = Array.from({ length: 21 }, (_, i) => {
    const day = Math.floor(i / 3) + 1;
    const slots_ = ['Breakfast', 'Lunch', 'Dinner'] as const;
    const mealSlot = slots_[i % 3];
    return {
      day,
      mealSlot,
      recipe: {
        id: i + 1,
        title: `Recipe ${i + 1}`,
        servings: 1,
        caloriesPerServing: 500,
        proteinG: 20,
        carbsG: 40,
        fatG: 15,
        primaryProtein: null,
        tags: [],
        steps: [],
      },
    };
  });

  return {
    id: 7,
    seed: 42,
    generatedAt: '2026-01-01T00:00:00Z',
    slots,
    ...overrides,
  };
}

function renderCalendar(id = '7') {
  return render(
    <MemoryRouter initialEntries={[`/menus/${id}`]}>
      <Routes>
        <Route path="/menus/:id" element={<MenuCalendar />} />
      </Routes>
    </MemoryRouter>,
  );
}

describe('MenuCalendar', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('renders 7 day columns', async () => {
    // Arrange
    mockMenuApi.getById.mockResolvedValue(makeMenu());

    // Act
    renderCalendar();

    // Assert
    await waitFor(() => {
      for (let day = 1; day <= 7; day++) {
        expect(screen.getByRole('gridcell', { name: `Day ${day}` })).toBeInTheDocument();
      }
    });
  });

  it('renders Breakfast, Lunch, Dinner slots for day 1', async () => {
    // Arrange
    mockMenuApi.getById.mockResolvedValue(makeMenu());

    // Act
    renderCalendar();

    // Assert
    await waitFor(() => {
      expect(screen.getByRole('generic', { name: /breakfast day 1/i })).toBeInTheDocument();
      expect(screen.getByRole('generic', { name: /lunch day 1/i })).toBeInTheDocument();
      expect(screen.getByRole('generic', { name: /dinner day 1/i })).toBeInTheDocument();
    });
  });

  it('renders all 21 recipe links', async () => {
    // Arrange
    mockMenuApi.getById.mockResolvedValue(makeMenu());

    // Act
    renderCalendar();

    // Assert — 21 recipe links + 2 nav links (Grocery List, Generate New)
    await waitFor(() => {
      const links = screen.getAllByRole('link');
      const recipeLinks = links.filter((l) => l.getAttribute('href')?.startsWith('/recipes/'));
      expect(recipeLinks).toHaveLength(21);
    });
  });

  it('shows error on API failure', async () => {
    // Arrange
    mockMenuApi.getById.mockRejectedValue(new Error('Menu not found'));

    // Act
    renderCalendar('9999');

    // Assert
    await waitFor(() => {
      expect(screen.getByRole('alert')).toHaveTextContent(/menu not found/i);
    });
  });

  it('shows seed in the page description', async () => {
    // Arrange
    mockMenuApi.getById.mockResolvedValue(makeMenu({ seed: 99 }));

    // Act
    renderCalendar();

    // Assert
    await waitFor(() => {
      expect(screen.getByText(/seed: 99/i)).toBeInTheDocument();
    });
  });
});
