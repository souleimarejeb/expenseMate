import 'package:flutter/material.dart';
import 'package:expensemate/core/models/Categories/category.dart';

class CategoriesPage extends StatefulWidget {
  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  // Dummy data - replace with your actual data source
  List<Category> categories = [
    Category(
      id: '1',
      name: 'Food & Dining',
      icon: Icons.restaurant,
      color: Colors.orange,
      budget: 500.0,
      spent: 320.75,
      transactions: 12,
    ),
    Category(
      id: '2',
      name: 'Transportation',
      icon: Icons.directions_car,
      color: Colors.blue,
      budget: 200.0,
      spent: 180.50,
      transactions: 8,
    ),
    Category(
      id: '3',
      name: 'Entertainment',
      icon: Icons.movie,
      color: Colors.purple,
      budget: 150.0,
      spent: 85.25,
      transactions: 5,
    ),
    Category(
      id: '4',
      name: 'Shopping',
      icon: Icons.shopping_bag,
      color: Colors.pink,
      budget: 300.0,
      spent: 275.80,
      transactions: 9,
    ),
    Category(
      id: '5',
      name: 'Bills & Utilities',
      icon: Icons.receipt,
      color: Colors.green,
      budget: 400.0,
      spent: 385.00,
      transactions: 6,
    ),
    Category(
      id: '6',
      name: 'Healthcare',
      icon: Icons.local_hospital,
      color: Colors.red,
      budget: 100.0,
      spent: 45.00,
      transactions: 3,
    ),
  ];

  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredCategories = categories.where((category) {
      return category.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.category, color: Colors.white),
            ),
            SizedBox(width: 12),
            Text(
              'Categories',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.add, color: Colors.black),
              onPressed: _addNewCategory,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search categories...',
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
            ),

            // Summary Cards
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      'Total Budget',
                      '\$${_calculateTotalBudget().toStringAsFixed(2)}',
                      Colors.black,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      'Total Spent',
                      '\$${_calculateTotalSpent().toStringAsFixed(2)}',
                      Colors.red,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Categories List
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: filteredCategories.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        physics: BouncingScrollPhysics(),
                        itemCount: filteredCategories.length,
                        itemBuilder: (context, index) {
                          final category = filteredCategories[index];
                          return _buildCategoryCard(category);
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewCategory,
        backgroundColor: Colors.black,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String amount, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(Category category) {
    final progress = category.spent / category.budget;
    final progressColor = progress >= 1.0 ? Colors.red : Colors.green;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _viewCategoryDetails(category),
          onLongPress: () => _showCategoryOptions(category),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    // Category Icon
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: category.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        category.icon,
                        color: category.color,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 16),
                    
                    // Category Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '${category.transactions} transactions',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Amount
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${category.spent.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'of \$${category.budget.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                SizedBox(height: 12),
                
                // Progress Bar
                LinearProgressIndicator(
                  value: progress > 1.0 ? 1.0 : progress,
                  backgroundColor: Colors.grey[200],
                  color: progressColor,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
                
                SizedBox(height: 8),
                
                // Progress Text
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${(progress * 100).toStringAsFixed(1)}% of budget',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '\$${(category.budget - category.spent).toStringAsFixed(2)} left',
                      style: TextStyle(
                        color: progressColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.category_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No categories found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Try a different search or add a new category',
            style: TextStyle(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _addNewCategory,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Add Category'),
          ),
        ],
      ),
    );
  }

  // Helper methods
  double _calculateTotalBudget() {
    return categories.fold(0, (sum, category) => sum + category.budget);
  }

  double _calculateTotalSpent() {
    return categories.fold(0, (sum, category) => sum + category.spent);
  }

  // Functionality methods
  void _addNewCategory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildCategoryForm(),
    );
  }

  void _viewCategoryDetails(Category category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryDetailsPage(category: category),
      ),
    );
  }

  void _showCategoryOptions(Category category) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.edit, color: Colors.blue),
                title: Text('Edit Category'),
                onTap: () {
                  Navigator.pop(context);
                  _editCategory(category);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Delete Category'),
                onTap: () {
                  Navigator.pop(context);
                  _deleteCategory(category);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _editCategory(Category category) {
    // Implement edit functionality
    print('Edit category: ${category.name}');
  }

  void _deleteCategory(Category category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Category'),
        content: Text('Are you sure you want to delete ${category.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                categories.removeWhere((c) => c.id == category.id);
              });
              Navigator.pop(context);
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryForm({Category? existingCategory}) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            existingCategory == null ? 'Add New Category' : 'Edit Category',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 24),
          // Add form fields here for category name, budget, icon, color, etc.
          Text('Category form implementation would go here'),
          SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Save category logic
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),
                  child: Text('Save'),
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
}

// Category Details Page
class CategoryDetailsPage extends StatelessWidget {
  final Category category;

  const CategoryDetailsPage({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          category.name,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              // Category Overview Card
              Container(
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Add detailed category information here
                    Text('Category details implementation'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}