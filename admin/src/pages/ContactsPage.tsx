import React, { useEffect, useState } from 'react';
import { useAuth } from '../context/AuthContext';

interface Contact {
  id: string;
  first_name: string;
  last_name: string;
  email: string;
  phone: string;
  lifecycle_status: string;
  created_at: string;
}

const ContactsPage: React.FC = () => {
  const { supabase } = useAuth();
  const [contacts, setContacts] = useState<Contact[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchContacts = async () => {
      try {
        const { data, error } = await supabase
          .from('contacts')
          .select('id, first_name, last_name, email, phone, lifecycle_status, created_at')
          .order('created_at', { ascending: false });

        if (error) throw error;
        setContacts(data || []);
      } catch (error) {
        console.error('Error fetching contacts:', error);
      } finally {
        setLoading(false);
      }
    };

    fetchContacts();
  }, [supabase]);

  return (
    <div>
      <h1 className="text-3xl font-bold text-gray-900 mb-8">Contacts</h1>

      {loading ? (
        <div className="flex justify-center py-12">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500"></div>
        </div>
      ) : (
        <div className="bg-white rounded-lg shadow-md overflow-hidden">
          <table className="w-full">
            <thead className="bg-gray-50 border-b border-gray-200">
              <tr>
                <th className="px-6 py-3 text-left text-sm font-medium text-gray-700">Name</th>
                <th className="px-6 py-3 text-left text-sm font-medium text-gray-700">Email</th>
                <th className="px-6 py-3 text-left text-sm font-medium text-gray-700">Phone</th>
                <th className="px-6 py-3 text-left text-sm font-medium text-gray-700">Status</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200">
              {contacts.map((contact) => (
                <tr key={contact.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 text-sm font-medium text-gray-900">{contact.first_name} {contact.last_name}</td>
                  <td className="px-6 py-4 text-sm text-gray-600">{contact.email}</td>
                  <td className="px-6 py-4 text-sm text-gray-600">{contact.phone}</td>
                  <td className="px-6 py-4 text-sm"><span className="inline-flex items-center px-3 py-1 rounded-full text-xs font-medium bg-green-100 text-green-800">{contact.lifecycle_status}</span></td>
                </tr>
              ))}
            </tbody>
          </table>
          {contacts.length === 0 && (
            <div className="text-center py-12 text-gray-500">No contacts found</div>
          )}
        </div>
      )}
    </div>
  );
};

export default ContactsPage;
