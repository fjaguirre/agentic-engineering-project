import { useEffect, useState } from 'react';
import { useParams, Link } from 'react-router-dom';
import { menuApi } from '../../api';
import type { Menu, MealSlot } from '../../types';

const MEAL_SLOTS: MealSlot[] = ['Breakfast', 'Lunch', 'Dinner'];

export default function MenuCalendar() {
  const { id } = useParams<{ id: string }>();
  const [menu, setMenu] = useState<Menu | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!id) return;
    menuApi
      .getById(Number(id))
      .then(setMenu)
      .catch((err: Error) => setError(err.message))
      .finally(() => setLoading(false));
  }, [id]);

  if (loading) return <p>Loading menu…</p>;
  if (error) return <p role="alert">Error: {error}</p>;
  if (!menu) return <p role="alert">Menu not found.</p>;

  const days = Array.from({ length: 7 }, (_, i) => i + 1);

  const slotRecipe = (day: number, slot: MealSlot) =>
    menu.slots.find((s) => s.day === day && s.mealSlot === slot);

  const totalCaloriesForDay = (day: number) =>
    menu.slots
      .filter((s) => s.day === day)
      .reduce((sum, s) => sum + s.recipe.caloriesPerServing, 0);

  return (
    <div>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <h1>7-Day Menu</h1>
        <div style={{ display: 'flex', gap: '0.5rem' }}>
          <Link to={`/menus/${menu.id}/grocery`}>
            <button type="button">Grocery List</button>
          </Link>
          <Link to="/menus/generate">
            <button type="button">Generate New</button>
          </Link>
        </div>
      </div>
      <p style={{ color: '#666' }}>Seed: {menu.seed} · Generated: {new Date(menu.generatedAt).toLocaleDateString()}</p>

      <div
        role="grid"
        aria-label="7-day menu calendar"
        style={{ display: 'grid', gridTemplateColumns: 'repeat(7, 1fr)', gap: '0.5rem', overflowX: 'auto' }}
      >
        {days.map((day) => (
          <div key={day} role="gridcell" aria-label={`Day ${day}`}>
            <h3 style={{ textAlign: 'center', margin: '0 0 0.5rem' }}>Day {day}</h3>
            <p style={{ textAlign: 'center', fontSize: '0.75rem', color: '#888', marginBottom: '0.5rem' }}>
              {totalCaloriesForDay(day)} kcal
            </p>
            {MEAL_SLOTS.map((slot) => {
              const entry = slotRecipe(day, slot);
              return (
                <div
                  key={slot}
                  aria-label={`${slot} day ${day}`}
                  style={{ marginBottom: '0.5rem', padding: '0.5rem', background: '#f5f5f5', borderRadius: '4px' }}
                >
                  <p style={{ fontSize: '0.7rem', fontWeight: 'bold', margin: '0 0 0.25rem', textTransform: 'uppercase', color: '#888' }}>
                    {slot}
                  </p>
                  {entry ? (
                    <Link to={`/recipes/${entry.recipe.id}`} style={{ fontSize: '0.85rem' }}>
                      {entry.recipe.title}
                    </Link>
                  ) : (
                    <span style={{ color: '#ccc', fontSize: '0.85rem' }}>—</span>
                  )}
                </div>
              );
            })}
          </div>
        ))}
      </div>
    </div>
  );
}
