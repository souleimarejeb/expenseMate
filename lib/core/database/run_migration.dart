import 'package:flutter/material.dart';
import 'package:expensemate/core/database/data_migration_helper.dart';

/// Test script to migrate data from SharedPreferences to SQLite
/// 
/// Usage:
/// 1. Add this file to your project
/// 2. Call `runMigration()` from your app's initialization
/// 3. Monitor the console output for migration status
Future<void> runMigration() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('=================================');
  print('Starting Data Migration');
  print('=================================\n');
  
  final migrationHelper = DataMigrationHelper.instance;
  
  // Check if migration is needed
  print('Checking if migration is needed...');
  final needsMigration = await migrationHelper.isMigrationNeeded();
  
  if (!needsMigration) {
    print('✅ No migration needed - SharedPreferences is empty or already migrated');
    return;
  }
  
  print('⚠️ Migration needed - found data in SharedPreferences\n');
  
  // Perform migration
  print('Starting migration...');
  final result = await migrationHelper.migrateData(
    clearOldData: false, // Set to true to clear SharedPreferences after migration
  );
  
  print('\n=================================');
  print('Migration Results');
  print('=================================');
  print(result.toString());
  
  if (result.success) {
    print('\n✅ Migration completed successfully!\n');
    
    // Validate migration
    print('Validating migration...');
    final validation = await migrationHelper.validateMigration();
    
    print('\n=================================');
    print('Validation Results');
    print('=================================');
    print(validation.toString());
    
    if (validation.isValid) {
      print('\n✅ Validation passed - data migrated correctly!');
      print('\n⚠️ Note: You can now set clearOldData=true to remove old SharedPreferences data');
    } else {
      print('\n❌ Validation failed - please check the data');
    }
  } else {
    print('\n❌ Migration failed - see errors above');
  }
  
  print('\n=================================');
  print('Migration Process Complete');
  print('=================================\n');
}

void main() async {
  await runMigration();
}
