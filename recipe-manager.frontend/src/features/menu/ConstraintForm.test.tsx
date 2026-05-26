import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter, Route, Routes } from 'react-router-dom';
import { vi, describe, it, expect, beforeEach } from 'vitest';
import { menuApi, tagsApi } from '../../api';
import ConstraintForm from './ConstraintForm';
import type { Tag } from '../../types';

vi.mock('../../api', () => ({
  menuApi: { generate: vi.fn() },
  tagsApi: { getAll: vi.fn() },
}));

const mockMenuApi = menuApi as { generate: ReturnType<typeof vi.fn> };
const mockTagsApi = tagsApi as { getAll: ReturnType<typeof vi.fn> };

const sampleTags: Tag[] = [
  { id: 1, name: 'GlutenFree' },
  { id: 2, name: 'Vegan' },
];

function renderForm() {
  return render(
    <MemoryRouter initialEntries={['/menus/generate']}>
      <Routes>
        <Route path="/menus/generate" element={<ConstraintForm />} />
        <Route path="/menus/:id" element={<div>Menu calendar page</div>} />
      </Routes>
    </MemoryRouter>,
  );
}

describe('ConstraintForm', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mockTagsApi.getAll.mockResolvedValue(sampleTags);
  });

  it('renders the form with calorie and seed fields', async () => {
    // Arrange / Act
    renderForm();

    // Assert
    await waitFor(() => {
      expect(screen.getByRole('form', { name: /generate menu/i })).toBeInTheDocument();
      expect(screen.getByRole('spinbutton', { name: /min calories/i })).toBeInTheDocument();
      expect(screen.getByRole('spinbutton', { name: /max calories/i })).toBeInTheDocument();
      expect(screen.getByRole('spinbutton', { name: /seed/i })).toBeInTheDocument();
    });
  });

  it('renders tag exclusion checkboxes after load', async () => {
    // Arrange / Act
    renderForm();

    // Assert
    await waitFor(() => {
      expect(screen.getByRole('checkbox', { name: /exclude glutenfree/i })).toBeInTheDocument();
      expect(screen.getByRole('checkbox', { name: /exclude vegan/i })).toBeInTheDocument();
    });
  });

  it('shows validation error when min > max', async () => {
    // Arrange
    const user = userEvent.setup();
    renderForm();
    await waitFor(() => screen.getByRole('form', { name: /generate menu/i }));

    // Act
    await user.clear(screen.getByRole('spinbutton', { name: /min calories/i }));
    await user.type(screen.getByRole('spinbutton', { name: /min calories/i }), '3000');
    await user.clear(screen.getByRole('spinbutton', { name: /max calories/i }));
    await user.type(screen.getByRole('spinbutton', { name: /max calories/i }), '2000');
    await user.click(screen.getByRole('button', { name: /generate menu/i }));

    // Assert
    await waitFor(() => {
      expect(screen.getByRole('alert')).toHaveTextContent(/minimum calories/i);
    });
    expect(mockMenuApi.generate).not.toHaveBeenCalled();
  });

  it('calls generate API with correct constraints and navigates to calendar', async () => {
    // Arrange
    const user = userEvent.setup();
    mockMenuApi.generate.mockResolvedValue({ id: 42, seed: 1, generatedAt: '', slots: [] });
    renderForm();
    await waitFor(() => screen.getByRole('checkbox', { name: /exclude glutenfree/i }));

    // Act — toggle GlutenFree exclusion, then submit
    await user.click(screen.getByRole('checkbox', { name: /exclude glutenfree/i }));
    await user.click(screen.getByRole('button', { name: /generate menu/i }));

    // Assert
    await waitFor(() => {
      expect(mockMenuApi.generate).toHaveBeenCalledOnce();
      const arg = mockMenuApi.generate.mock.calls[0][0];
      expect(arg.excludedTags).toContain('GlutenFree');
      expect(arg.dailyCalorieMin).toBe(1200);
      expect(arg.dailyCalorieMax).toBe(2500);
    });
    // Should navigate to calendar
    await waitFor(() => {
      expect(screen.getByText('Menu calendar page')).toBeInTheDocument();
    });
  });

  it('shows API error message on generate failure', async () => {
    // Arrange
    const user = userEvent.setup();
    mockMenuApi.generate.mockRejectedValue(new Error('Insufficient recipe pool'));
    renderForm();
    await waitFor(() => screen.getByRole('form', { name: /generate menu/i }));

    // Act
    await user.click(screen.getByRole('button', { name: /generate menu/i }));

    // Assert
    await waitFor(() => {
      expect(screen.getByRole('alert')).toHaveTextContent(/insufficient recipe pool/i);
    });
  });
});
