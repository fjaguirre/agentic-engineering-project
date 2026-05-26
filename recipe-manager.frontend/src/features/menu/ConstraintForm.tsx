import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { menuApi, tagsApi } from '../../api';
import type { MenuConstraints, Tag } from '../../types';

export default function ConstraintForm() {
  const navigate = useNavigate();

  const [tags, setTags] = useState<Tag[]>([]);
  const [excludedTags, setExcludedTags] = useState<string[]>([]);
  const [dailyCalorieMin, setDailyCalorieMin] = useState('1200');
  const [dailyCalorieMax, setDailyCalorieMax] = useState('2500');
  const [targetServings, setTargetServings] = useState('1');
  const [seed, setSeed] = useState(() => Math.floor(Math.random() * 100000));
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    tagsApi.getAll().then(setTags).catch(() => {});
  }, []);

  const toggleTag = (name: string) =>
    setExcludedTags((prev) =>
      prev.includes(name) ? prev.filter((t) => t !== name) : [...prev, name],
    );

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);

    const min = Number(dailyCalorieMin);
    const max = Number(dailyCalorieMax);
    if (min > max) {
      setError('Minimum calories must be less than or equal to maximum calories.');
      return;
    }

    setSubmitting(true);
    try {
      const constraints: MenuConstraints = {
        excludedTags,
        dailyCalorieMin: min,
        dailyCalorieMax: max,
        seed,
        targetServings: Number(targetServings),
      };
      const menu = await menuApi.generate(constraints);
      navigate(`/menus/${menu.id}`);
    } catch (err) {
      setError((err as Error).message);
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} aria-label="Generate menu">
      <h1>Generate 7-Day Menu</h1>

      {error && <p role="alert">{error}</p>}

      <fieldset>
        <legend>Calorie targets (per day)</legend>
        <label>
          Min calories
          <input
            type="number"
            min={0}
            required
            aria-label="Min calories"
            value={dailyCalorieMin}
            onChange={(e) => setDailyCalorieMin(e.target.value)}
          />
        </label>
        <label>
          Max calories
          <input
            type="number"
            min={0}
            required
            aria-label="Max calories"
            value={dailyCalorieMax}
            onChange={(e) => setDailyCalorieMax(e.target.value)}
          />
        </label>
      </fieldset>

      <fieldset>
        <legend>Serving options</legend>
        <label>
          Target servings per meal
          <input
            type="number"
            min={1}
            required
            aria-label="Target servings"
            value={targetServings}
            onChange={(e) => setTargetServings(e.target.value)}
          />
        </label>

        <label>
          Randomisation seed
          <input
            type="number"
            min={0}
            required
            aria-label="Seed"
            value={seed}
            onChange={(e) => setSeed(Number(e.target.value))}
          />
        </label>
      </fieldset>

      {tags.length > 0 && (
        <fieldset>
          <legend>Exclude dietary tags</legend>
          {tags.map((tag) => (
            <label key={tag.id} style={{ marginRight: '1rem' }}>
              <input
                type="checkbox"
                checked={excludedTags.includes(tag.name)}
                onChange={() => toggleTag(tag.name)}
                aria-label={`Exclude ${tag.name}`}
              />
              {tag.name}
            </label>
          ))}
        </fieldset>
      )}

      <button type="submit" disabled={submitting} style={{ marginTop: '1rem' }}>
        {submitting ? 'Generating…' : 'Generate Menu'}
      </button>
    </form>
  );
}
