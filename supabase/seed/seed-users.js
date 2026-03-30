#!/usr/bin/env node

/**
 * Seed Test Users via Supabase Admin API
 * 
 * Usage: node seed-users.js
 * 
 * Environment Variables:
 *   SUPABASE_URL=https://your-project.supabase.co
 *   SUPABASE_ADMIN_KEY=your-admin-api-key
 */

const https = require('https');
const { createClient } = require('@supabase/supabase-js');

const SUPABASE_URL = process.env.SUPABASE_URL || 'https://utxmazyyufvupeygmhpw.supabase.co';
const SUPABASE_ADMIN_KEY = process.env.SUPABASE_ADMIN_KEY;
const ORG_ID = '550e8400-e29b-41d4-a716-446655440000';

// Test users to seed
const testUsers = [
  {
    email: 'admin@zenops.demo',
    password: 'Test123!',
    firstName: 'Admin',
    lastName: 'User',
    phone: '+1-800-555-0101',
    jobTitle: 'Administrator',
    teamId: '550e8400-e29b-41d4-a716-446655440001', // Sales team
    profileId: '550e8400-e29b-41d4-a716-446655440010',
    roleId: '550e8400-e29b-41d4-a716-446655440020', // Admin role
  },
  {
    email: 'sales@zenops.demo',
    password: 'Test123!',
    firstName: 'Sarah',
    lastName: 'Sales',
    phone: '+1-800-555-0102',
    jobTitle: 'Sales Manager',
    teamId: '550e8400-e29b-41d4-a716-446655440001', // Sales team
    profileId: '550e8400-e29b-41d4-a716-446655440011',
    roleId: '550e8400-e29b-41d4-a716-446655440021', // Sales Manager role
  },
  {
    email: 'john@zenops.demo',
    password: 'Test123!',
    firstName: 'John',
    lastName: 'Doe',
    phone: '+1-800-555-0103',
    jobTitle: 'Sales Rep',
    teamId: '550e8400-e29b-41d4-a716-446655440001', // Sales team
    profileId: '550e8400-e29b-41d4-a716-446655440011',
    roleId: '550e8400-e29b-41d4-a716-446655440022', // Sales Rep role
  },
  {
    email: 'support@zenops.demo',
    password: 'Test123!',
    firstName: 'Jessica',
    lastName: 'Support',
    phone: '+1-800-555-0104',
    jobTitle: 'Support Agent',
    teamId: '550e8400-e29b-41d4-a716-446655440002', // Support team
    profileId: '550e8400-e29b-41d4-a716-446655440012',
    roleId: '550e8400-e29b-41d4-a716-446655440022', // Sales Rep role (reuse for now)
  },
];

async function seedUsers() {
  if (!SUPABASE_ADMIN_KEY) {
    console.error('❌ SUPABASE_ADMIN_KEY environment variable not set');
    console.error('Set it: export SUPABASE_ADMIN_KEY=your_admin_key');
    process.exit(1);
  }

  console.log('🌱 Seeding test users...\n');

  const adminClient = createClient(SUPABASE_URL, SUPABASE_ADMIN_KEY, {
    auth: {
      autoRefreshToken: false,
      persistSession: false,
    },
  });

  const userIds = [];

  for (const user of testUsers) {
    try {
      console.log(`Creating user: ${user.email}`);

      // Create auth user
      const { data, error: authError } = await adminClient.auth.admin.createUser({
        email: user.email,
        password: user.password,
        email_confirm: true,
      });

      if (authError) {
        throw new Error(`Auth error: ${authError.message}`);
      }

      const userId = data.user.id;
      userIds.push({ email: user.email, id: userId });
      console.log(`  ✓ Auth user created: ${userId}`);

      // Insert into public.users table
      const { error: dbError } = await adminClient
        .from('users')
        .insert({
          id: userId,
          organization_id: ORG_ID,
          team_id: user.teamId,
          profile_id: user.profileId,
          role_id: user.roleId,
          email: user.email,
          first_name: user.firstName,
          last_name: user.lastName,
          phone: user.phone,
          job_title: user.jobTitle,
          status: 'active',
        });

      if (dbError) {
        throw new Error(`DB error: ${dbError.message}`);
      }

      console.log(`  ✓ Profile created in public.users\n`);
    } catch (error) {
      console.error(`  ❌ Failed: ${error.message}\n`);
    }
  }

  console.log('\n📋 Test User Summary:');
  console.log('='.repeat(60));
  userIds.forEach((user) => {
    console.log(`Email: ${user.email.padEnd(25)} | ID: ${user.id}`);
  });
  console.log('='.repeat(60));
  console.log('\n✅ Seeding complete!');
  console.log('\nTest Credentials:');
  console.log('  Password: Test123! (for all users)');
  console.log('\nYou can now:');
  console.log('  1. Log in with these credentials in your app');
  console.log('  2. Run API tests with authenticated requests');
  console.log('  3. Test RLS policies across different user roles');
}

seedUsers().catch(console.error);
