# Expense Module CRUD Testing Guide

## Overview
This document provides step-by-step instructions to manually test all CRUD (Create, Read, Update, Delete) operations for the expense module in the ExpenseMate app.

## Prerequisites
1. App should be running successfully
2. Database should be initialized
3. User should be logged in and can access the main layout

## Test Scenarios

### 1. CREATE Operation - Adding New Expenses

#### Test Case 1.1: Add Basic Expense
1. Navigate to the Expenses screen (tap the expenses tab in bottom navigation)
2. Tap the "+" floating action button
3. Fill in the form:
   - **Title**: "Grocery Shopping"
   - **Description**: "Weekly groceries from supermarket"
   - **Amount**: 75.50
   - **Category**: Select "Food" (should be available from default categories)
   - **Date**: Keep current date or select a recent date
4. Tap "Save" button
5. **Expected Result**: 
   - Success message should appear
   - User should be redirected back to expenses list
   - New expense should appear in the list
   - Total amount should be updated

#### Test Case 1.2: Add Expense with All Fields
1. Tap "+" button again
2. Fill in all fields:
   - **Title**: "Gas Station Fill-up"
   - **Description**: "Weekly fuel for commuting"
   - **Amount**: 45.00
   - **Category**: Select "Transport"
   - **Date**: Select yesterday's date
   - **Receipt**: (if available) add a photo
3. Save the expense
4. **Expected Result**: Expense appears in list with all details

#### Test Case 1.3: Form Validation
1. Try to save an expense without required fields
2. **Expected Results**:
   - Title field should show error if empty
   - Amount field should show error if empty or invalid
   - Category field should show error if not selected
   - Form should not submit until all required fields are valid

### 2. READ Operation - Viewing Expenses

#### Test Case 2.1: View Expenses List
1. Navigate to Expenses screen
2. **Expected Results**:
   - All previously added expenses should be visible
   - Expenses should be sorted by date (newest first)
   - Each expense should display:
     - Title
     - Category name and icon
     - Amount (formatted as currency)
     - Date
   - Total amount should be calculated correctly

#### Test Case 2.2: View Individual Expense
1. Tap on any expense from the list
2. **Expected Result**: 
   - Should navigate to edit expense screen
   - All fields should be populated with expense data
   - Form should be in "edit" mode

#### Test Case 2.3: Empty State
1. If no expenses exist, the screen should show:
   - "No expenses yet" message
   - Instruction to tap "+" to add first expense
   - Appropriate illustration/icon

### 3. UPDATE Operation - Editing Expenses

#### Test Case 3.1: Edit Expense Details
1. Tap on an existing expense to edit it
2. Modify the following fields:
   - **Title**: Change to "Updated Grocery Shopping"
   - **Amount**: Change to 85.75
   - **Description**: Add more details
3. Tap "Save"
4. **Expected Results**:
   - Success message should appear
   - Updated expense should reflect changes in the list
   - Total amount should be recalculated
   - Updated timestamp should be current

#### Test Case 3.2: Edit Category
1. Edit an expense and change its category
2. Save the changes
3. **Expected Result**: 
   - Expense should show new category icon and name
   - Expense should appear in correct category filters

### 4. DELETE Operation - Removing Expenses

#### Test Case 4.1: Delete Expense
1. Tap on an expense to edit it
2. Look for delete button (trash icon in app bar)
3. Tap the delete button
4. **Expected Results**:
   - Confirmation dialog should appear
   - "Are you sure?" message should be clear

#### Test Case 4.2: Confirm Deletion
1. In the confirmation dialog, tap "Delete" or "Yes"
2. **Expected Results**:
   - Expense should be removed from the list immediately
   - Success message should appear
   - Total amount should be recalculated
   - If this was the last expense, empty state should appear

#### Test Case 4.3: Cancel Deletion
1. Try to delete an expense but tap "Cancel" in confirmation
2. **Expected Result**: 
   - Expense should remain in the list
   - No changes should occur

### 5. ADDITIONAL FUNCTIONALITY TESTS

#### Test Case 5.1: Search and Filter
1. Add multiple expenses with different categories
2. Test search functionality:
   - Search by title
   - Search by description
3. Test category filter:
   - Filter by specific category
   - Verify only matching expenses appear

#### Test Case 5.2: Date Range Filter
1. Add expenses with different dates
2. Apply date range filter
3. **Expected Result**: Only expenses within date range should appear

#### Test Case 5.3: Total Calculation
1. Add multiple expenses with different amounts
2. Apply various filters
3. **Expected Results**:
   - Total should always reflect currently visible expenses
   - Math should be accurate

#### Test Case 5.4: Refresh Data
1. Tap the refresh icon (if available)
2. **Expected Result**: 
   - Loading indicator should appear briefly
   - Data should be refreshed from database
   - All expenses should still be visible

### 6. ERROR HANDLING TESTS

#### Test Case 6.1: Database Connection Issues
1. (This would require simulating database issues)
2. **Expected Result**: 
   - Appropriate error messages should appear
   - User should be able to retry operations

#### Test Case 6.2: Invalid Data Entry
1. Try entering negative amounts
2. Try entering extremely large amounts
3. Try entering special characters in inappropriate fields
4. **Expected Results**: 
   - Validation should prevent invalid data
   - Clear error messages should guide user

### 7. PERFORMANCE TESTS

#### Test Case 7.1: Large Data Sets
1. Add 50+ expenses
2. Test scrolling performance
3. Test search performance
4. **Expected Results**:
   - UI should remain responsive
   - Scrolling should be smooth
   - Search should return results quickly

## Success Criteria

### All CRUD operations work correctly:
✅ **CREATE**: Users can successfully add new expenses with all required fields
✅ **READ**: Expenses are displayed correctly with proper formatting and sorting
✅ **UPDATE**: Users can edit existing expenses and changes are saved properly
✅ **DELETE**: Users can delete expenses with proper confirmation

### Additional Features Work:
✅ **Search and Filter**: Users can find expenses using various criteria
✅ **Calculations**: Total amounts are always accurate
✅ **Validation**: Forms prevent invalid data entry
✅ **Error Handling**: Appropriate messages for various error scenarios
✅ **Performance**: App remains responsive with reasonable amounts of data

## Common Issues and Solutions

### Issue 1: Expenses not appearing after adding
- **Solution**: Check if provider initialization is working
- Verify database tables are created properly
- Check if refresh is needed after add operation

### Issue 2: Total amount incorrect
- **Solution**: Verify filter logic in provider
- Check calculation method in provider
- Ensure UI is using provider's totalAmount getter

### Issue 3: Deletion not working
- **Solution**: Verify delete method in service layer
- Check if proper confirmation dialog is shown
- Ensure UI refreshes after deletion

### Issue 4: Form validation not working
- **Solution**: Check form validation logic
- Verify required field indicators
- Test all input field types

## Automated Test Coverage

The following test files should also pass:
- `test/expense_model_test.dart` ✅ (Verified working)
- `test/expense_crud_test.dart` (Database integration tests)

## Notes for Developers

1. **Provider Integration**: Ensure ExpenseProvider is properly initialized in main.dart
2. **Database Schema**: Verify all required tables exist in DatabaseHelper
3. **Error Handling**: Implement proper try-catch blocks in all CRUD operations
4. **State Management**: Ensure UI updates properly when data changes
5. **Performance**: Consider pagination for large datasets