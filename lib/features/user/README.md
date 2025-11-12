# User Module

Complete user management system with full CRUD operations and SQLite integration for the ExpenseMate application.

## Features

- ✅ Create, Read, Update, Delete (CRUD) operations
- ✅ SQLite database integration
- ✅ User search functionality
- ✅ Email validation and uniqueness check
- ✅ Profile image support
- ✅ User preferences management
- ✅ Provider pattern for state management
- ✅ Comprehensive test suite

## Structure

```
lib/
├── core/
│   ├── models/
│   │   └── user.dart                  # User model
│   ├── services/
│   │   └── user_service.dart          # User CRUD service
│   └── database/
│       └── sqlite_database_helper.dart # Updated with users table
└── features/
    └── user/
        ├── providers/
        │   └── user_provider.dart      # State management
        └── screens/
            ├── user_list_screen.dart   # List all users
            ├── user_form_screen.dart   # Create/Edit user
            └── user_detail_screen.dart # View user details

test/
└── user_crud_test.dart                 # Comprehensive test suite
```

## User Model

The `User` model includes:

- `id`: Unique identifier (auto-generated)
- `name`: User's full name (required)
- `email`: User's email address (required, unique)
- `phoneNumber`: Phone number (optional)
- `profileImagePath`: Path to profile image (optional)
- `bio`: User biography (optional)
- `preferences`: JSON preferences object (optional)
- `createdAt`: Creation timestamp
- `updatedAt`: Last update timestamp

## Database Schema

```sql
CREATE TABLE users (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  phone_number TEXT,
  profile_image_path TEXT,
  bio TEXT,
  preferences TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
)
```

## Usage

### 1. Add UserProvider to your app

```dart
import 'package:provider/provider.dart';
import 'package:expensemate/features/user/providers/user_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        // ... other providers
      ],
      child: MyApp(),
    ),
  );
}
```

### 2. Navigate to User List Screen

```dart
import 'package:expensemate/features/user/screens/user_list_screen.dart';

// In your navigation
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const UserListScreen()),
);
```

### 3. Using UserService directly

```dart
import 'package:expensemate/core/services/user_service.dart';
import 'package:expensemate/core/models/user.dart';

final userService = UserService();

// Create a user
final user = User(
  name: 'John Doe',
  email: 'john@example.com',
  phoneNumber: '+1234567890',
  bio: 'Software Developer',
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

final userId = await userService.createUser(user);

// Get all users
final users = await userService.getAllUsers();

// Get user by ID
final user = await userService.getUserById(userId);

// Update user
final updatedUser = user.copyWith(name: 'Jane Doe');
await userService.updateUser(updatedUser);

// Delete user
await userService.deleteUser(userId);

// Search users
final results = await userService.searchUsers('John');

// Check if email exists
final exists = await userService.emailExists('john@example.com');
```

### 4. Using UserProvider with UI

```dart
import 'package:provider/provider.dart';
import 'package:expensemate/features/user/providers/user_provider.dart';

// In your widget
Consumer<UserProvider>(
  builder: (context, userProvider, child) {
    if (userProvider.isLoading) {
      return CircularProgressIndicator();
    }
    
    return ListView.builder(
      itemCount: userProvider.users.length,
      itemBuilder: (context, index) {
        final user = userProvider.users[index];
        return ListTile(
          title: Text(user.name),
          subtitle: Text(user.email),
        );
      },
    );
  },
);

// Load users
Provider.of<UserProvider>(context, listen: false).loadUsers();

// Create user
await Provider.of<UserProvider>(context, listen: false).createUser(user);
```

## API Reference

### UserService Methods

| Method | Description | Parameters | Returns |
|--------|-------------|------------|---------|
| `createUser` | Create a new user | `User user` | `Future<String>` (userId) |
| `getAllUsers` | Get all users | - | `Future<List<User>>` |
| `getUserById` | Get user by ID | `String id` | `Future<User?>` |
| `getUserByEmail` | Get user by email | `String email` | `Future<User?>` |
| `updateUser` | Update existing user | `User user` | `Future<bool>` |
| `deleteUser` | Delete a user | `String id` | `Future<bool>` |
| `searchUsers` | Search users by name/email | `String query` | `Future<List<User>>` |
| `emailExists` | Check if email exists | `String email` | `Future<bool>` |
| `getUserCount` | Get total user count | - | `Future<int>` |
| `updateProfileImage` | Update user's profile image | `String userId, String imagePath` | `Future<bool>` |
| `updateUserPreferences` | Update user preferences | `String userId, Map<String, dynamic> preferences` | `Future<bool>` |
| `getUsersWithPagination` | Get paginated users | `int limit, int offset` | `Future<List<User>>` |

### UserProvider Methods

| Method | Description | Parameters | Returns |
|--------|-------------|------------|---------|
| `loadUsers` | Load all users into state | - | `Future<void>` |
| `createUser` | Create a new user | `User user` | `Future<String?>` |
| `updateUser` | Update existing user | `User user` | `Future<bool>` |
| `deleteUser` | Delete a user | `String userId` | `Future<bool>` |
| `searchUsers` | Search users | `String query` | `Future<List<User>>` |
| `getUserById` | Get user by ID | `String userId` | `Future<User?>` |
| `setCurrentUser` | Set the current active user | `User user` | `void` |
| `clearCurrentUser` | Clear current user | - | `void` |
| `updateProfileImage` | Update profile image | `String userId, String imagePath` | `Future<bool>` |
| `updateUserPreferences` | Update preferences | `String userId, Map<String, dynamic> preferences` | `Future<bool>` |
| `getUserCount` | Get user count | - | `Future<int>` |
| `clearError` | Clear error state | - | `void` |

## Testing

Run the test suite:

```bash
flutter test test/user_crud_test.dart
```

The test suite includes:
- Create user test
- Get all users test
- Get user by ID test
- Get user by email test
- Update user test
- Delete user test
- Search users test
- Email existence check test
- User count test
- Profile image update test
- User preferences update test

## Database Migration

The user table is automatically created when the app first runs. The database version has been updated from 3 to 4.

If you're upgrading from an existing database, the migration will:
1. Create the `users` table
2. Add an index on the `email` column for faster lookups

## Notes

- Email addresses must be unique
- Email validation is performed using regex pattern
- Profile images are stored as file paths
- User preferences are stored as JSON strings in the database
- All timestamps are stored in ISO 8601 format
- The module follows the same patterns as the existing expense management system

## Future Enhancements

Potential features to add:
- User authentication
- Password management
- User roles and permissions
- Multi-user expense sharing
- User activity logs
- Social features (friends, groups)
- Avatar/profile picture upload to cloud storage
- Email verification
- Two-factor authentication
