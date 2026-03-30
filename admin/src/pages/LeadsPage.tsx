import React, { useEffect, useState } from 'react';
import { useAuth } from '../context/AuthContext';

interface Lead {
  id: string;
  name?: string;
  email?: string;
  status: string;
  qualification_status: string;
  urgency_score: number;
  created_at: string;
}

const LeadsPage: React.FC = () => {
  const { supabase } = useAuth();
  const [leads, setLeads] = useState<Lead[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchLeads = async () => {
      try {
        const { data, error } = await supabase
          .from('leads')
          .select('id, status, qualification_status, urgency_score, created_at')
          .order('created_at', { ascending: false });

        if (error) throw error;
        setLeads(data || []);
      } catch (error) {
        console.error('Error fetching leads:', error);
      } finally {
        setLoading(false);
      }
    };

    fetchLeads();
  }, [supabase]);

  return (
    <div>
      <h1 className="text-3xl font-bold text-gray-900 mb-8">Leads</h1>

      {loading ? (
        <div className="flex justify-center py-12">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500"></div>
        </div>
      ) : (
        <div className="bg-white rounded-lg shadow-md overflow-hidden">
          <table className="w-full">
            <thead className="bg-gray-50 border-b border-gray-200">
              <tr>
                <th className="px-6 py-3 text-left text-sm font-medium text-gray-700">ID</th>
                <th className="px-6 py-3 text-left text-sm font-medium text-gray-700">Status</th>
                <th className="px-6 py-3 text-left text-sm font-medium text-gray-700">Qualification</th>
                <th className="px-6 py-3 text-left text-sm font-medium text-gray-700">Urgency</th>
                <th className="px-6 py-3 text-left text-sm font-medium text-gray-700">Created</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200">
              {leads.map((lead) => (
                <tr key={lead.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 text-sm text-gray-600">{lead.id.substring(0, 8)}</td>
                  <td className="px-6 py-4 text-sm"><span className="inline-flex items-center px-3 py-1 rounded-full text-xs font-medium bg-blue-100 text-blue-800">{lead.status}</span></td>
                  <td className="px-6 py-4 text-sm text-gray-600">{lead.qualification_status}</td>
                  <td className="px-6 py-4 text-sm text-gray-600">{lead.urgency_score}</td>
                  <td className="px-6 py-4 text-sm text-gray-600">{new Date(lead.created_at).toLocaleDateString()}</td>
                </tr>
              ))}
            </tbody>
          </table>
          {leads.length === 0 && (
            <div className="text-center py-12 text-gray-500">No leads found</div>
          )}
        </div>
      )}
    </div>
  );
};

export default LeadsPage;
