import { NavLink } from 'react-router-dom';

export default function NavBar() {
  const linkStyle = ({ isActive }: { isActive: boolean }) => ({
    fontWeight: isActive ? 'bold' : 'normal',
    marginRight: '1.5rem',
    textDecoration: 'none',
    color: isActive ? '#000' : '#555',
  });

  return (
    <nav aria-label="Main navigation" style={{ borderBottom: '1px solid #ddd', padding: '0.75rem 1.5rem', marginBottom: '1.5rem' }}>
      <NavLink to="/recipes" style={linkStyle}>Recipes</NavLink>
      <NavLink to="/menus/generate" style={linkStyle}>Generate Menu</NavLink>
    </nav>
  );
}
