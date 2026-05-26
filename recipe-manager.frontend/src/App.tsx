import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import NavBar from './components/NavBar';
import RecipeList from './features/recipes/RecipeList';
import RecipeDetail from './features/recipes/RecipeDetail';
import RecipeForm from './features/recipes/RecipeForm';
import ConstraintForm from './features/menu/ConstraintForm';
import MenuCalendar from './features/menu/MenuCalendar';
import GroceryList from './features/grocery/GroceryList';

export default function App() {
  return (
    <BrowserRouter>
      <NavBar />
      <main style={{ padding: '0 1.5rem' }}>
        <Routes>
          <Route path="/" element={<Navigate to="/recipes" replace />} />
          <Route path="/recipes" element={<RecipeList />} />
          <Route path="/recipes/new" element={<RecipeForm />} />
          <Route path="/recipes/:id" element={<RecipeDetail />} />
          <Route path="/recipes/:id/edit" element={<RecipeForm />} />
          <Route path="/menus/generate" element={<ConstraintForm />} />
          <Route path="/menus/:id" element={<MenuCalendar />} />
          <Route path="/menus/:menuId/grocery" element={<GroceryList />} />
        </Routes>
      </main>
    </BrowserRouter>
  );
}
