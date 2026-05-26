import { useEffect, useState } from 'react';
import { useParams, Link, useNavigate } from 'react-router-dom';
import { recipesApi } from '../../api';
import type { Recipe, RecipeStep } from '../../types';

function stepToSentence(step: RecipeStep): string {
  const meaningfulIngredients = step.ingredients.filter((i) => i.ingredientName.trim());

  // Free-text step: stored with no actions, no real ingredients, no duration
  if (step.actions.length === 0 && meaningfulIngredients.length === 0 && step.durationMinutes === null) {
    return step.notes ?? '';
  }

  const parts: string[] = [];

  if (step.actions.length > 0) {
    parts.push(step.actions.join(' and '));
  }

  const ingSentences = meaningfulIngredients.map((i) => {
    const qty = i.quantity ? `${i.quantity} ${i.unit}`.trim() : '';
    return qty ? `${qty} of ${i.ingredientName}` : i.ingredientName;
  });
  if (ingSentences.length > 0) parts.push(ingSentences.join(', '));

  if (step.durationMinutes !== null) {
    const h = step.durationMinutes / 60;
    const durationText =
      step.durationMinutes % 60 === 0
        ? `${h} ${h === 1 ? 'hour' : 'hours'}`
        : `${step.durationMinutes} ${step.durationMinutes === 1 ? 'minute' : 'minutes'}`;
    parts.push(`during ${durationText}`);
  }

  let sentence = parts.join(' ');
  if (step.notes?.trim()) sentence += `. ${step.notes.trim()}`;

  return sentence;
}

export default function RecipeDetail() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const [recipe, setRecipe] = useState<Recipe | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!id) return;
    recipesApi
      .getById(Number(id))
      .then(setRecipe)
      .catch((err: Error) => setError(err.message))
      .finally(() => setLoading(false));
  }, [id]);

  const handleDelete = async () => {
    if (!recipe || !confirm(`Delete "${recipe.title}"?`)) return;
    await recipesApi.delete(recipe.id);
    navigate('/recipes');
  };

  if (loading) return <p>Loading…</p>;
  if (error) return <p role="alert">Error: {error}</p>;
  if (!recipe) return <p role="alert">Recipe not found.</p>;

  return (
    <div>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <h1>{recipe.title}</h1>
        <div style={{ display: 'flex', gap: '0.5rem' }}>
          <Link to={`/recipes/${recipe.id}/edit`}>
            <button type="button">Edit</button>
          </Link>
          <button type="button" onClick={handleDelete}>Delete</button>
          <Link to="/recipes">
            <button type="button">Back</button>
          </Link>
        </div>
      </div>

      <section aria-label="Nutrition">
        <h2>Nutrition (per serving)</h2>
        <dl>
          <dt>Servings</dt><dd>{recipe.servings}</dd>
          <dt>Calories</dt><dd>{recipe.caloriesPerServing} kcal</dd>
          <dt>Protein</dt><dd>{recipe.proteinG} g</dd>
          <dt>Carbs</dt><dd>{recipe.carbsG} g</dd>
          <dt>Fat</dt><dd>{recipe.fatG} g</dd>
          {recipe.primaryProtein && <><dt>Primary protein</dt><dd>{recipe.primaryProtein}</dd></>}
        </dl>
      </section>

      {recipe.tags.length > 0 && (
        <section aria-label="Tags">
          <h2>Tags</h2>
          <ul style={{ listStyle: 'none', padding: 0, display: 'flex', gap: '0.5rem', flexWrap: 'wrap' }}>
            {recipe.tags.map((t) => (
              <li key={t.id} style={{ background: '#eee', padding: '4px 8px', borderRadius: '4px' }}>
                {t.name}
              </li>
            ))}
          </ul>
        </section>
      )}

      {recipe.steps.length > 0 && (
        <section aria-label="Steps">
          <h2>Steps</h2>
          <ol>
            {recipe.steps.map((step) => (
              <li key={step.id} style={{ marginBottom: '0.5rem' }}>
                {stepToSentence(step)}
              </li>
            ))}
          </ol>
        </section>
      )}
    </div>
  );
}
