import React, { useEffect, useState } from 'react';
import { useAuth } from '../context/AuthContext';

interface Opportunity {
  id: string;
  name: string;
  amount_estimated: number;
  status: string;
  service_type: string;
  expected_close_date: string;
  created_at: string;
}

const OpportunitiesPage: React.FC = () => {
  const { supabase } = useAuth();
  const [opportunities, setOpportunities] = useState<Opportunity[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchOpportunities = async () => {
      try {
        const { data, error } = await supabase
          .from('opportunities')
          .select('id, name, amount_estimated, status, service_type, expected_close_date, created_at')
          .order('created_at', { ascending: false });

        if (error) throw error;
        setOpportunities(data || []);
      } catch (error) {
        console.error('Error fetching opportunities:', error);
      } finally {
        setLoading(false);
      }
    };

    fetchOpportunities();
  }, [supabase]);

  return (
    <div>
      <h1 className="text-3xl font-bold text-gray-900 mb-8">Opportunities</h1>

      {loading ? (
        <div className="flex justify-center py-12">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500"></div>
        </div>
      ) : (
        <div className="bg-white rounded-lg shadow-md overflow-hidden">
          <table className="w-full">
            <thead className="bg-gray-50 border-b border-gray-200">
              <tr>
                <th className="px-6 py-3 text-left text-sm font-medium text-gray-700">Deal Name</th>
                <th className="px-6 py-3 text-left text-sm font-medium text-gray-700">Amount</th>
                <th className="px-6 py-3 text-left text-sm font-medium text-gray-700">Type</th>
                <th className="px-6 py-3 text-left text-sm font-medium text-gray-700">Status</th>
                <th className="px-6 py-3 text-left text-sm font-medium text-gray-700">Close Date</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200">
              {opportunities.map((opp) => (
                <tr key={opp.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 text-sm font-medium text-gray-900">{opp.name}</td>
                  <td className="px-6 py-4 text-sm font-medium text-gray-900">${opp.amount_estimated?.toLocaleString()}</td>
                  <td className="px-6 py-4 text-sm text-gray-600">{opp.service_type}</td>
                  <td className="px-6 py-4 text-sm"><span className="inline-flex items-center px-3 py-1 rounded-full text-xs font-medium bg-yellow-100 text-yellow-800">{opp.status}</span></td>
                  <td className="px-6 py-4 text-sm text-gray-600">{new Date(opp.expected_close_date).toLocaleDateString()}</td>
                </tr>
              ))}
            </tbody>
          </table>
          {opportunities.length === 0 && (
            <div className="text-center py-12 text-gray-500">No opportunities found</div>
          )}
        </div>
      )}
    </div>
  );
};

export default OpportunitiesPage;
