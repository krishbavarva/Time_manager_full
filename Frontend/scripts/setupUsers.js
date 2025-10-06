import { usersApi } from '../src/api/users';

// Sample users with different roles
const sampleUsers = [
  {
    username: 'admin',
    first_name: 'Admin',
    last_name: 'User',
    email: 'admin@example.com',
    password: 'admin123',
    role: 'admin'
  },
  {
    username: 'manager1',
    first_name: 'Manager',
    last_name: 'One',
    email: 'manager@example.com',
    password: 'manager123',
    role: 'manager'
  },
  {
    username: 'employee1',
    first_name: 'Employee',
    last_name: 'One',
    email: 'employee@example.com',
    password: 'employee123',
    role: 'employee'
  }
];

async function setupUsers() {
  try {
    // First, get all existing users
    const existingUsers = await usersApi.list();
    
    // Delete all existing users (except the current user if needed)
    for (const user of existingUsers) {
      console.log(`Deleting user: ${user.username}`);
      await usersApi.remove(user.id);
    }
    
    // Create new users
    for (const user of sampleUsers) {
      console.log(`Creating user: ${user.username}`);
      await usersApi.create(user);
    }
    
    console.log('Successfully set up users:');
    console.table(sampleUsers.map(u => ({
      Username: u.username,
      Password: u.password,
      Role: u.role,
      Email: u.email
    })));
    
  } catch (error) {
    console.error('Error setting up users:', error);
    process.exit(1);
  }
}

// Run the setup
setupUsers();
