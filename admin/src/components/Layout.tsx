import React from 'react';
import { Outlet, Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

const Layout: React.FC = () => {
  const navigate = useNavigate();
  const { user, signOut } = useAuth();

  const handleLogout = async () => {
    await signOut();
    navigate('/login');
  };

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow">
        <div className="max-w-7xl mx-auto px-4 py-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center">
            <h1 className="text-2xl font-bold text-gray-900">ZenOps Admin</h1>
            <div className="flex items-center space-x-4">
              <span className="text-sm text-gray-600">{user?.email}</span>
              <button
                onClick={handleLogout}
                className="text-sm bg-red-600 hover:bg-red-700 text-white px-4 py-2 rounded"
              >
                Logout
              </button>
            </div>
          </div>
        </div>
      </header>

      {/* Navigation */}
      <div className="bg-white border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <nav className="flex space-x-8" aria-label="navigation">
            <Link to="/" className="py-4 px-1 border-b-2 border-blue-500 font-medium text-sm text-blue-600">
              Dashboard
            </Link>
            <Link to="/leads" className="py-4 px-1 border-b-2 border-transparent hover:border-gray-300 font-medium text-sm text-gray-600">
              Leads
            </Link>
            <Link to="/contacts" className="py-4 px-1 border-b-2 border-transparent hover:border-gray-300 font-medium text-sm text-gray-600">
              Contacts
            </Link>
            <Link to="/opportunities" className="py-4 px-1 border-b-2 border-transparent hover:border-gray-300 font-medium text-sm text-gray-600">
              Opportunities
            </Link>
          </nav>
        </div>
      </div>

      {/* Main content */}
      <main className="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
        <Outlet />
      </main>
    </div>
  );
};

export default Layout;
