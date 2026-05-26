import { useEffect, useState } from 'react';
import { useParams, Link } from 'react-router-dom';
import { groceryApi } from '../../api';
import type { GroceryLineItem } from '../../types';

export default function GroceryList() {
  const { menuId } = useParams<{ menuId: string }>();
  const [items, setItems] = useState<GroceryLineItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!menuId) return;
    groceryApi
      .getForMenu(Number(menuId))
      .then(setItems)
      .catch((err: Error) => setError(err.message))
      .finally(() => setLoading(false));
  }, [menuId]);

  if (loading) return <p>Loading grocery list…</p>;
  if (error) return <p role="alert">Error: {error}</p>;

  return (
    <div>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <h1>Grocery List</h1>
        <Link to={`/menus/${menuId}`}>
          <button type="button">← Back to Menu</button>
        </Link>
      </div>

      {items.length === 0 ? (
        <p>No ingredients found for this menu.</p>
      ) : (
        <table aria-label="Grocery list">
          <thead>
            <tr>
              <th>Ingredient</th>
              <th>Quantity</th>
              <th>Unit</th>
            </tr>
          </thead>
          <tbody>
            {items.map((item, idx) => (
              <tr key={idx}>
                <td>{item.ingredientName}</td>
                <td>{item.quantity}</td>
                <td>{item.unit}</td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </div>
  );
}
