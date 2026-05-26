import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { recipesApi } from '../../api';
import type { Recipe } from '../../types';

export default function RecipeList() {
  const [recipes, setRecipes] = useState<Recipe[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    recipesApi
      .getAll()
      .then(setRecipes)
      .catch((err: Error) => setError(err.message))
      .finally(() => setLoading(false));
  }, []);

  const handleDelete = async (id: number) => {
    if (!confirm('Delete this recipe?')) return;
    await recipesApi.delete(id);
    setRecipes((prev) => prev.filter((r) => r.id !== id));
  };

  if (loading) return <p>Loading recipes…</p>;
  if (error) return <p role="alert">Error: {error}</p>;

  return (
    <div>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <h1>Recipes</h1>
        <Link to="/recipes/new">
          <button type="button">New Recipe</button>
        </Link>
      </div>

      {recipes.length === 0 ? (
        <p>No recipes yet. Add one to get started.</p>
      ) : (
        <ul style={{ listStyle: 'none', padding: 0 }}>
          {recipes.map((recipe) => (
            <li key={recipe.id} style={{ marginBottom: '1rem', padding: '1rem', border: '1px solid #ccc', borderRadius: '4px' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
                <div>
                  <Link to={`/recipes/${recipe.id}`}>
                    <strong>{recipe.title}</strong>
                  </Link>
                  <p style={{ margin: '0.25rem 0', color: '#666' }}>
                    {recipe.caloriesPerServing} kcal · {recipe.servings} serving{recipe.servings !== 1 ? 's' : ''}
                    {recipe.primaryProtein ? ` · ${recipe.primaryProtein}` : ''}
                  </p>
                  {recipe.tags.length > 0 && (
                    <p style={{ margin: 0 }}>
                      {recipe.tags.map((t) => (
                        <span key={t.id} style={{ marginRight: '0.4rem', background: '#eee', padding: '2px 6px', borderRadius: '4px', fontSize: '0.8rem' }}>
                          {t.name}
                        </span>
                      ))}
                    </p>
                  )}
                </div>
                <div style={{ display: 'flex', gap: '0.5rem' }}>
                  <Link to={`/recipes/${recipe.id}/edit`}>
                    <button type="button">Edit</button>
                  </Link>
                  <button type="button" onClick={() => handleDelete(recipe.id)}>
                    Delete
                  </button>
                </div>
              </div>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
