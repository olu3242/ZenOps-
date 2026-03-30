import React, { useEffect, useState } from 'react';
import { useAuth } from '../context/AuthContext';

const Dashboard: React.FC = () => {
  const { supabase, user } = useAuth();
  const [stats, setStats] = useState({
    leadsCount: 0,
    contactsCount: 0,
    opportunitiesCount: 0,
    tasksCount: 0,
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchStats = async () => {
      try {
        const [leads, contacts, opportunities, tasks] = await Promise.all([
          supabase.from('leads').select('id', { count: 'exact' }),
          supabase.from('contacts').select('id', { count: 'exact' }),
          supabase.from('opportunities').select('id', { count: 'exact' }),
          supabase.from('tasks').select('id', { count: 'exact' }),
        ]);

        setStats({
          leadsCount: leads.count || 0,
          contactsCount: contacts.count || 0,
          opportunitiesCount: opportunities.count || 0,
          tasksCount: tasks.count || 0,
        });
      } catch (error) {
        console.error('Error fetching stats:', error);
      } finally {
        setLoading(false);
      }
    };

    fetchStats();
  }, [supabase]);

  return (
    <div>
      <h1 className="text-3xl font-bold text-gray-900 mb-8">Dashboard</h1>

      {loading ? (
        <div className="flex justify-center py-12">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500"></div>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          <div className="bg-white rounded-lg shadow-md p-6">
            <h3 className="text-gray-500 text-sm font-medium">Leads</h3>
            <p className="text-3xl font-bold text-gray-900 mt-2">{stats.leadsCount}</p>
          </div>
          <div className="bg-white rounded-lg shadow-md p-6">
            <h3 className="text-gray-500 text-sm font-medium">Contacts</h3>
            <p className="text-3xl font-bold text-gray-900 mt-2">{stats.contactsCount}</p>
          </div>
          <div className="bg-white rounded-lg shadow-md p-6">
            <h3 className="text-gray-500 text-sm font-medium">Opportunities</h3>
            <p className="text-3xl font-bold text-gray-900 mt-2">{stats.opportunitiesCount}</p>
          </div>
          <div className="bg-white rounded-lg shadow-md p-6">
            <h3 className="text-gray-500 text-sm font-medium">Tasks</h3>
            <p className="text-3xl font-bold text-gray-900 mt-2">{stats.tasksCount}</p>
          </div>
        </div>
      )}

      <div className="mt-8 bg-white rounded-lg shadow-md p-6">
        <h2 className="text-xl font-bold text-gray-900 mb-4">Quick Links</h2>
        <ul className="space-y-2">
          <li><a href="#" className="text-blue-600 hover:underline">View all leads</a></li>
          <li><a href="#" className="text-blue-600 hover:underline">View all opportunities</a></li>
          <li><a href="#" className="text-blue-600 hover:underline">View pending tasks</a></li>
        </ul>
      </div>
    </div>
  );
};

export default Dashboard;
