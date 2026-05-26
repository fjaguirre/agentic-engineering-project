import { useEffect, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { recipesApi, tagsApi, actionsApi } from '../../api';
import type {
  CulinaryAction,
  CreateRecipeRequest,
  CreateStepRequest,
  CreateStepIngredientRequest,
  Tag,
} from '../../types';

// ─── Step draft types ───────────────────────────────────────────────────────

interface IngredientDraft {
  ingredientName: string;
  quantity: string;
  unit: string;
}

type DurationUnit = 'minutes' | 'hours';

interface StepDraft {
  orderIndex: number;
  /** When true the step is stored as plain text in the Notes field with no actions/ingredients */
  isFreeText: boolean;
  freeText: string;
  selectedActions: string[]; // culinary action names
  includeIngredients: boolean;
  ingredients: IngredientDraft[];
  includeDuration: boolean;
  durationValue: string;
  durationUnit: DurationUnit;
  includeNotes: boolean;
  notes: string;
}

// ─── Helpers ────────────────────────────────────────────────────────────────

function emptyIngredient(): IngredientDraft {
  return { ingredientName: '', quantity: '', unit: '' };
}

function emptyStep(orderIndex: number): StepDraft {
  return {
    orderIndex,
    isFreeText: false,
    freeText: '',
    selectedActions: [],
    includeIngredients: false,
    ingredients: [emptyIngredient()],
    includeDuration: false,
    durationValue: '',
    durationUnit: 'minutes',
    includeNotes: false,
    notes: '',
  };
}

function generatePreview(step: StepDraft): string {
  if (step.isFreeText) return step.freeText.trim() || '(enter step text above)';

  const parts: string[] = [];

  const actionText = step.selectedActions.join(' and ');
  if (!actionText) return '(select an action to see preview)';

  parts.push(actionText);

  if (step.includeIngredients) {
    const ings = step.ingredients
      .filter((i) => i.ingredientName.trim())
      .map((i) => {
        const qty = i.quantity ? `${i.quantity} ${i.unit}`.trim() : '';
        return qty ? `${qty} of ${i.ingredientName}` : i.ingredientName;
      });
    if (ings.length > 0) parts.push(ings.join(', '));
  }

  if (step.includeDuration && step.durationValue) {
    parts.push(`during ${step.durationValue} ${step.durationUnit}`);
  }

  let preview = parts.join(' ');

  if (step.includeNotes && step.notes.trim()) {
    preview += `. ${step.notes.trim()}`;
  }

  return preview;
}

function durationToMinutes(value: string, unit: DurationUnit): number | null {
  const n = Number(value);
  if (!value || isNaN(n)) return null;
  return unit === 'hours' ? n * 60 : n;
}

function minutesToDisplay(minutes: number | null): { value: string; unit: DurationUnit } {
  if (minutes === null) return { value: '', unit: 'minutes' };
  if (minutes > 0 && minutes % 60 === 0) return { value: String(minutes / 60), unit: 'hours' };
  return { value: String(minutes), unit: 'minutes' };
}

// ─── Main form state ─────────────────────────────────────────────────────────

interface FormState {
  title: string;
  servings: string;
  caloriesPerServing: string;
  proteinG: string;
  carbsG: string;
  fatG: string;
  primaryProtein: string;
  selectedTags: string[];
  steps: StepDraft[];
}

function emptyForm(): FormState {
  return {
    title: '',
    servings: '1',
    caloriesPerServing: '',
    proteinG: '',
    carbsG: '',
    fatG: '',
    primaryProtein: '',
    selectedTags: [],
    steps: [emptyStep(1)],
  };
}

// ─── Component ───────────────────────────────────────────────────────────────

export default function RecipeForm() {
  const { id } = useParams<{ id?: string }>();
  const isEdit = Boolean(id);
  const navigate = useNavigate();

  const [form, setForm] = useState<FormState>(emptyForm());
  const [availableTags, setAvailableTags] = useState<Tag[]>([]);
  const [availableActions, setAvailableActions] = useState<CulinaryAction[]>([]);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    tagsApi.getAll().then(setAvailableTags).catch(() => {});
    actionsApi.getAll().then(setAvailableActions).catch(() => {});
  }, []);

  useEffect(() => {
    if (!id) return;
    recipesApi.getById(Number(id)).then((recipe) => {
      setForm({
        title: recipe.title,
        servings: String(recipe.servings),
        caloriesPerServing: String(recipe.caloriesPerServing),
        proteinG: String(recipe.proteinG),
        carbsG: String(recipe.carbsG),
        fatG: String(recipe.fatG),
        primaryProtein: recipe.primaryProtein ?? '',
        selectedTags: recipe.tags.map((t) => t.name),
        steps:
          recipe.steps.length > 0
            ? recipe.steps.map((s): StepDraft => {
                // A step stored without actions and with notes is a free-text step
                const meaningfulIngredients = s.ingredients.filter((i) => i.ingredientName.trim());
                const isFreeText =
                  s.actions.length === 0 &&
                  meaningfulIngredients.length === 0 &&
                  s.durationMinutes === null;

                if (isFreeText) {
                  return {
                    ...emptyStep(s.orderIndex),
                    isFreeText: true,
                    freeText: s.notes ?? '',
                  };
                }

                const dur = minutesToDisplay(s.durationMinutes);
                return {
                  orderIndex: s.orderIndex,
                  isFreeText: false,
                  freeText: '',
                  selectedActions: s.actions,
                  includeIngredients: s.ingredients.length > 0,
                  ingredients:
                    s.ingredients.length > 0
                      ? s.ingredients.map((i) => ({
                          ingredientName: i.ingredientName,
                          quantity: String(i.quantity),
                          unit: i.unit,
                        }))
                      : [emptyIngredient()],
                  includeDuration: s.durationMinutes !== null,
                  durationValue: dur.value,
                  durationUnit: dur.unit,
                  includeNotes: Boolean(s.notes),
                  notes: s.notes ?? '',
                };
              })
            : [emptyStep(1)],
      });
    });
  }, [id]);

  // ─── Field updaters ─────────────────────────────────────────────────────

  const setField = <K extends keyof FormState>(key: K, value: FormState[K]) =>
    setForm((prev) => ({ ...prev, [key]: value }));

  const updateStep = (idx: number, patch: Partial<StepDraft>) =>
    setForm((prev) => {
      const steps = [...prev.steps];
      steps[idx] = { ...steps[idx], ...patch };
      return { ...prev, steps };
    });

  const addStep = () =>
    setForm((prev) => ({
      ...prev,
      steps: [...prev.steps, emptyStep(prev.steps.length + 1)],
    }));

  const removeStep = (idx: number) =>
    setForm((prev) => {
      const steps = prev.steps
        .filter((_, i) => i !== idx)
        .map((s, i) => ({ ...s, orderIndex: i + 1 }));
      return { ...prev, steps };
    });

  const moveStep = (idx: number, direction: -1 | 1) =>
    setForm((prev) => {
      const steps = [...prev.steps];
      const target = idx + direction;
      if (target < 0 || target >= steps.length) return prev;
      [steps[idx], steps[target]] = [steps[target], steps[idx]];
      return { ...prev, steps: steps.map((s, i) => ({ ...s, orderIndex: i + 1 })) };
    });

  // ─── Action chip helpers ─────────────────────────────────────────────────

  const addAction = (idx: number, actionName: string) => {
    const step = form.steps[idx];
    if (actionName === '__freetext__') {
      updateStep(idx, { isFreeText: true, selectedActions: [] });
      return;
    }
    if (step.selectedActions.includes(actionName)) return;
    updateStep(idx, {
      isFreeText: false,
      selectedActions: [...step.selectedActions, actionName],
    });
  };

  const removeAction = (stepIdx: number, actionName: string) => {
    updateStep(stepIdx, {
      selectedActions: form.steps[stepIdx].selectedActions.filter((a) => a !== actionName),
    });
  };

  // ─── Ingredient helpers ──────────────────────────────────────────────────

  const addIngredient = (stepIdx: number) =>
    updateStep(stepIdx, {
      ingredients: [...form.steps[stepIdx].ingredients, emptyIngredient()],
    });

  const removeIngredient = (stepIdx: number, ingIdx: number) =>
    updateStep(stepIdx, {
      ingredients: form.steps[stepIdx].ingredients.filter((_, i) => i !== ingIdx),
    });

  const updateIngredient = (stepIdx: number, ingIdx: number, patch: Partial<IngredientDraft>) =>
    updateStep(stepIdx, {
      ingredients: form.steps[stepIdx].ingredients.map((ing, i) =>
        i === ingIdx ? { ...ing, ...patch } : ing,
      ),
    });

  // ─── Tag helpers ─────────────────────────────────────────────────────────

  const toggleTag = (name: string) =>
    setField(
      'selectedTags',
      form.selectedTags.includes(name)
        ? form.selectedTags.filter((t) => t !== name)
        : [...form.selectedTags, name],
    );

  // ─── Build API request ───────────────────────────────────────────────────

  const buildRequest = (): CreateRecipeRequest => ({
    title: form.title,
    servings: Number(form.servings),
    caloriesPerServing: Number(form.caloriesPerServing),
    proteinG: Number(form.proteinG),
    carbsG: Number(form.carbsG),
    fatG: Number(form.fatG),
    primaryProtein: form.primaryProtein || null,
    tags: form.selectedTags,
    steps: form.steps.map((s): CreateStepRequest => {
      if (s.isFreeText) {
        return {
          orderIndex: s.orderIndex,
          actions: [],
          ingredients: [],
          durationMinutes: null,
          notes: s.freeText || null,
        };
      }
      return {
        orderIndex: s.orderIndex,
        actions: s.selectedActions,
        ingredients: s.includeIngredients
          ? s.ingredients
              .filter((i) => i.ingredientName.trim())
              .map((i): CreateStepIngredientRequest => ({
                ingredientName: i.ingredientName.trim(),
                quantity: Number(i.quantity) || 0,
                unit: i.unit.trim(),
              }))
          : [],
        durationMinutes: s.includeDuration ? durationToMinutes(s.durationValue, s.durationUnit) : null,
        notes: s.includeNotes && s.notes.trim() ? s.notes.trim() : null,
      };
    }),
  });

  // ─── Submit ──────────────────────────────────────────────────────────────

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setSubmitting(true);
    try {
      if (isEdit && id) {
        await recipesApi.update(Number(id), buildRequest());
        navigate(`/recipes/${id}`);
      } else {
        const created = await recipesApi.create(buildRequest());
        navigate(`/recipes/${created.id}`);
      }
    } catch (err) {
      setError((err as Error).message);
    } finally {
      setSubmitting(false);
    }
  };

  // ─── Render ──────────────────────────────────────────────────────────────

  return (
    <form onSubmit={handleSubmit} aria-label={isEdit ? 'Edit recipe' : 'Create recipe'}>
      <h1>{isEdit ? 'Edit Recipe' : 'New Recipe'}</h1>
      {error && <p role="alert">{error}</p>}

      {/* ── Basic info ── */}
      <fieldset>
        <legend>Basic info</legend>
        <label>
          Title
          <input required value={form.title} onChange={(e) => setField('title', e.target.value)} />
        </label>
        <label>
          Servings
          <input required type="number" min={1} value={form.servings}
            onChange={(e) => setField('servings', e.target.value)} />
        </label>
        <label>
          Calories per serving (kcal)
          <input required type="number" min={0} value={form.caloriesPerServing}
            onChange={(e) => setField('caloriesPerServing', e.target.value)} />
        </label>
        <label>
          Protein (g)
          <input required type="number" min={0} step="0.1" value={form.proteinG}
            onChange={(e) => setField('proteinG', e.target.value)} />
        </label>
        <label>
          Carbs (g)
          <input required type="number" min={0} step="0.1" value={form.carbsG}
            onChange={(e) => setField('carbsG', e.target.value)} />
        </label>
        <label>
          Fat (g)
          <input required type="number" min={0} step="0.1" value={form.fatG}
            onChange={(e) => setField('fatG', e.target.value)} />
        </label>
        <label>
          Primary protein
          <input value={form.primaryProtein}
            onChange={(e) => setField('primaryProtein', e.target.value)} />
        </label>
      </fieldset>

      {/* ── Tags ── */}
      {availableTags.length > 0 && (
        <fieldset>
          <legend>Tags</legend>
          {availableTags.map((tag) => (
            <label key={tag.id} style={{ marginRight: '1rem' }}>
              <input type="checkbox" checked={form.selectedTags.includes(tag.name)}
                onChange={() => toggleTag(tag.name)} />
              {tag.name}
            </label>
          ))}
        </fieldset>
      )}

      {/* ── Steps ── */}
      <fieldset>
        <legend>Steps</legend>

        {form.steps.map((step, idx) => (
          <StepCard
            key={idx}
            step={step}
            idx={idx}
            totalSteps={form.steps.length}
            availableActions={availableActions}
            onUpdate={(patch) => updateStep(idx, patch)}
            onMove={(dir) => moveStep(idx, dir)}
            onRemove={() => removeStep(idx)}
            onAddAction={(name) => addAction(idx, name)}
            onRemoveAction={(name) => removeAction(idx, name)}
            onAddIngredient={() => addIngredient(idx)}
            onRemoveIngredient={(ingIdx) => removeIngredient(idx, ingIdx)}
            onUpdateIngredient={(ingIdx, patch) => updateIngredient(idx, ingIdx, patch)}
          />
        ))}

        <button type="button" onClick={addStep} style={{ marginTop: '0.5rem' }}>
          + Add Step
        </button>
      </fieldset>

      {/* ── Step Preview ── */}
      <fieldset style={{ marginTop: '1rem' }}>
        <legend>Preview</legend>
        <ol style={{ margin: 0, paddingLeft: '1.5rem', lineHeight: 1.7 }}>
          {form.steps.map((step, idx) => (
            <li key={idx} style={{ color: '#0c4a6e', marginBottom: '0.25rem' }}>
              {generatePreview(step)}
            </li>
          ))}
        </ol>
      </fieldset>

      {/* ── Submit ── */}
      <div style={{ display: 'flex', gap: '1rem', marginTop: '1rem' }}>
        <button type="submit" disabled={submitting}>
          {submitting ? 'Saving…' : isEdit ? 'Save Changes' : 'Create Recipe'}
        </button>
        <button type="button"
          onClick={() => navigate(isEdit && id ? `/recipes/${id}` : '/recipes')}>
          Cancel
        </button>
      </div>
    </form>
  );
}

// ─── StepCard sub-component ──────────────────────────────────────────────────

interface StepCardProps {
  step: StepDraft;
  idx: number;
  totalSteps: number;
  availableActions: CulinaryAction[];
  onUpdate: (patch: Partial<StepDraft>) => void;
  onMove: (dir: -1 | 1) => void;
  onRemove: () => void;
  onAddAction: (name: string) => void;
  onRemoveAction: (name: string) => void;
  onAddIngredient: () => void;
  onRemoveIngredient: (ingIdx: number) => void;
  onUpdateIngredient: (ingIdx: number, patch: Partial<IngredientDraft>) => void;
}

function StepCard({
  step,
  idx,
  totalSteps,
  availableActions,
  onUpdate,
  onMove,
  onRemove,
  onAddAction,
  onRemoveAction,
  onAddIngredient,
  onRemoveIngredient,
  onUpdateIngredient,
}: StepCardProps) {
  const unselectedActions = availableActions.filter(
    (a) => !step.selectedActions.includes(a.name),
  );

  return (
    <div
      role="group"
      aria-label={`Step ${step.orderIndex}`}
      style={{ border: '1px solid #ccc', borderRadius: '6px', padding: '1rem', marginBottom: '1rem', background: '#fafafa' }}
    >
      {/* Header */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '0.75rem' }}>
        <strong>Step {step.orderIndex}</strong>
        <div style={{ display: 'flex', gap: '0.25rem' }}>
          <button type="button" aria-label="Move step up" onClick={() => onMove(-1)} disabled={idx === 0}>↑</button>
          <button type="button" aria-label="Move step down" onClick={() => onMove(1)} disabled={idx === totalSteps - 1}>↓</button>
          <button type="button" aria-label="Remove step" onClick={onRemove} disabled={totalSteps === 1}>Remove</button>
        </div>
      </div>

      {/* Action selector */}
      <div style={{ marginBottom: '0.75rem' }}>
        <label style={{ display: 'block', marginBottom: '0.25rem', fontWeight: 500 }}>Action</label>
        <div style={{ display: 'flex', gap: '0.5rem', alignItems: 'center', flexWrap: 'wrap' }}>
          <select
            aria-label="Add action"
            value=""
            onChange={(e) => { if (e.target.value) onAddAction(e.target.value); }}
            disabled={step.isFreeText}
            style={{ minWidth: '140px' }}
          >
            <option value="">— pick an action —</option>
            <option value="__freetext__">📝 Free text step</option>
            <optgroup label="Culinary actions">
              {unselectedActions.map((a) => (
                <option key={a.id} value={a.name}>{a.name}</option>
              ))}
            </optgroup>
          </select>

          {/* Selected action chips */}
          {step.selectedActions.map((name) => (
            <span
              key={name}
              style={{ display: 'inline-flex', alignItems: 'center', gap: '4px', background: '#dbeafe', borderRadius: '4px', padding: '2px 8px', fontSize: '0.875rem' }}
            >
              {name}
              <button
                type="button"
                aria-label={`Remove action ${name}`}
                onClick={() => onRemoveAction(name)}
                style={{ background: 'none', border: 'none', cursor: 'pointer', padding: 0, lineHeight: 1, color: '#555' }}
              >×</button>
            </span>
          ))}

          {step.isFreeText && (
            <span style={{ display: 'inline-flex', alignItems: 'center', gap: '4px', background: '#fef9c3', borderRadius: '4px', padding: '2px 8px', fontSize: '0.875rem' }}>
              📝 Free text
              <button
                type="button"
                aria-label="Remove free text mode"
                onClick={() => onUpdate({ isFreeText: false, freeText: '' })}
                style={{ background: 'none', border: 'none', cursor: 'pointer', padding: 0, lineHeight: 1 }}
              >×</button>
            </span>
          )}
        </div>
      </div>

      {/* Free text textarea — only when isFreeText */}
      {step.isFreeText && (
        <div style={{ marginBottom: '0.75rem' }}>
          <label style={{ display: 'block', marginBottom: '0.25rem' }}>Step description</label>
          <textarea
            aria-label="Free text step description"
            rows={3}
            style={{ width: '100%', boxSizing: 'border-box' }}
            value={step.freeText}
            onChange={(e) => onUpdate({ freeText: e.target.value })}
            placeholder="e.g. Preheat the oven to 180°C for 10 minutes"
          />
        </div>
      )}

      {/* Optional fields — only when not free text */}
      {!step.isFreeText && (
        <>
          {/* Ingredients toggle */}
          <div style={{ marginBottom: '0.5rem' }}>
            <label style={{ fontWeight: 500, cursor: 'pointer' }}>
              <input
                type="checkbox"
                checked={step.includeIngredients}
                onChange={(e) => onUpdate({ includeIngredients: e.target.checked })}
              />{' '}
              Ingredients
            </label>

            {step.includeIngredients && (
              <div style={{ marginTop: '0.5rem', paddingLeft: '1rem' }}>
                {step.ingredients.map((ing, ingIdx) => (
                  <div key={ingIdx} style={{ display: 'flex', gap: '0.4rem', marginBottom: '0.4rem', flexWrap: 'wrap' }}>
                    <input
                      aria-label="Ingredient name"
                      placeholder="Ingredient"
                      value={ing.ingredientName}
                      onChange={(e) => onUpdateIngredient(ingIdx, { ingredientName: e.target.value })}
                      style={{ flex: '2 1 120px' }}
                    />
                    <input
                      aria-label="Quantity"
                      placeholder="Qty"
                      type="number"
                      min={0}
                      step="0.01"
                      value={ing.quantity}
                      onChange={(e) => onUpdateIngredient(ingIdx, { quantity: e.target.value })}
                      style={{ flex: '1 1 60px', maxWidth: '80px' }}
                    />
                    <input
                      aria-label="Unit"
                      placeholder="unit"
                      value={ing.unit}
                      onChange={(e) => onUpdateIngredient(ingIdx, { unit: e.target.value })}
                      style={{ flex: '1 1 60px', maxWidth: '80px' }}
                    />
                    <button
                      type="button"
                      aria-label="Remove ingredient"
                      onClick={() => onRemoveIngredient(ingIdx)}
                      disabled={step.ingredients.length === 1}
                    >×</button>
                  </div>
                ))}
                <button type="button" onClick={onAddIngredient} style={{ fontSize: '0.85rem' }}>
                  + Ingredient
                </button>
              </div>
            )}
          </div>

          {/* Duration toggle */}
          <div style={{ marginBottom: '0.5rem' }}>
            <label style={{ fontWeight: 500, cursor: 'pointer' }}>
              <input
                type="checkbox"
                checked={step.includeDuration}
                onChange={(e) => onUpdate({ includeDuration: e.target.checked })}
              />{' '}
              Duration
            </label>

            {step.includeDuration && (
              <div style={{ display: 'flex', gap: '0.4rem', marginTop: '0.4rem', paddingLeft: '1rem', alignItems: 'center' }}>
                <input
                  aria-label="Duration value"
                  type="number"
                  min={1}
                  step={1}
                  placeholder="5"
                  value={step.durationValue}
                  onChange={(e) => onUpdate({ durationValue: e.target.value })}
                  style={{ width: '70px' }}
                />
                <select
                  aria-label="Duration unit"
                  value={step.durationUnit}
                  onChange={(e) => onUpdate({ durationUnit: e.target.value as DurationUnit })}
                >
                  <option value="minutes">minutes</option>
                  <option value="hours">hours</option>
                </select>
              </div>
            )}
          </div>

          {/* Notes toggle */}
          <div style={{ marginBottom: '0.75rem' }}>
            <label style={{ fontWeight: 500, cursor: 'pointer' }}>
              <input
                type="checkbox"
                checked={step.includeNotes}
                onChange={(e) => onUpdate({ includeNotes: e.target.checked })}
              />{' '}
              Notes
            </label>

            {step.includeNotes && (
              <div style={{ marginTop: '0.4rem', paddingLeft: '1rem' }}>
                <input
                  aria-label="Step notes"
                  placeholder="e.g. Dice into 2 cm cubes"
                  value={step.notes}
                  onChange={(e) => onUpdate({ notes: e.target.value })}
                  style={{ width: '100%', boxSizing: 'border-box' }}
                />
              </div>
            )}
          </div>
        </>
      )}

    </div>
  );
}
