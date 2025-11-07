import '../database/databaseHelper.dart';

class SmartCategorizationService {
  static final SmartCategorizationService _instance = SmartCategorizationService._internal();
  factory SmartCategorizationService() => _instance;
  SmartCategorizationService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Predefined keywords for different categories
  static const Map<String, List<String>> _categoryKeywords = {
    'Food & Dining': [
      'restaurant', 'food', 'lunch', 'dinner', 'breakfast', 'coffee', 'pizza', 
      'burger', 'grocery', 'market', 'supermarket', 'cafe', 'bar', 'eat'
    ],
    'Transportation': [
      'gas', 'fuel', 'car', 'taxi', 'uber', 'bus', 'train', 'flight', 
      'parking', 'toll', 'metro', 'subway', 'transport'
    ],
    'Shopping': [
      'shopping', 'store', 'mall', 'shop', 'buy', 'purchase', 'amazon', 
      'online', 'clothes', 'clothing', 'fashion'
    ],
    'Entertainment': [
      'movie', 'cinema', 'game', 'fun', 'entertainment', 'party', 'music', 
      'concert', 'theater', 'book', 'magazine'
    ],
    'Bills & Utilities': [
      'bill', 'electricity', 'water', 'gas', 'internet', 'phone', 'mobile', 
      'insurance', 'rent', 'utility'
    ],
    'Healthcare': [
      'doctor', 'hospital', 'medicine', 'pharmacy', 'health', 'medical', 
      'clinic', 'dentist', 'checkup'
    ]
  };

  // Suggest category based on title and description using simple keyword matching
  Future<String?> suggestCategory(String title, String description) async {
    final db = _dbHelper;
    
    // Get all available categories
    final categories = await db.query('expense_categories');
    if (categories.isEmpty) return null;

    String combinedText = '${title.toLowerCase()} ${description.toLowerCase()}';
    
    // Keyword-based scoring
    Map<String, double> scores = {};
    
    // Initialize scores for all categories
    for (var category in categories) {
      scores[category['id']] = 0.0;
    }
    
    // Score based on predefined keywords
    for (var category in categories) {
      final categoryName = category['name'] as String;
      final keywords = _categoryKeywords[categoryName] ?? [];
      
      for (String keyword in keywords) {
        if (combinedText.contains(keyword)) {
          scores[category['id']] = (scores[category['id']] ?? 0) + 1.0;
        }
      }
    }
    
    // Find the category with the highest score
    String? bestCategoryId;
    double bestScore = 0.0;
    
    scores.forEach((categoryId, score) {
      if (score > bestScore) {
        bestScore = score;
        bestCategoryId = categoryId;
      }
    });
    
    // Only return if we have a decent confidence score
    return bestScore > 0 ? bestCategoryId : null;
  }

  // Get spending pattern analysis (simplified)
  Future<Map<String, dynamic>> getSpendingPatternAnalysis() async {
    final db = _dbHelper;
    final expenses = await db.getAllExpenses();
    
    if (expenses.isEmpty) {
      return {
        'total_expenses': 0,
        'average_amount': 0.0,
        'most_frequent_category': null,
        'spending_trend': 'no_data'
      };
    }
    
    // Calculate basic statistics
    double totalAmount = 0.0;
    Map<String, int> categoryCount = {};
    
    for (var expense in expenses) {
      totalAmount += expense['amount'] ?? 0.0;
      String categoryId = expense['categoryId'] ?? '';
      categoryCount[categoryId] = (categoryCount[categoryId] ?? 0) + 1;
    }
    
    // Find most frequent category
    String? mostFrequentCategory;
    int maxCount = 0;
    categoryCount.forEach((categoryId, count) {
      if (count > maxCount) {
        maxCount = count;
        mostFrequentCategory = categoryId;
      }
    });
    
    return {
      'total_expenses': expenses.length,
      'average_amount': totalAmount / expenses.length,
      'most_frequent_category': mostFrequentCategory,
      'spending_trend': expenses.length > 10 ? 'normal' : 'low_activity'
    };
  }

  // Get category usage statistics (simplified)
  Future<Map<String, dynamic>> getCategoryUsageStats() async {
    final db = _dbHelper;
    final expenses = await db.getAllExpenses();
    final categories = await db.getAllCategories();
    
    Map<String, Map<String, dynamic>> stats = {};
    
    for (var category in categories) {
      stats[category['id']] = {
        'category_name': category['name'],
        'usage_count': 0,
        'total_amount': 0.0,
        'average_amount': 0.0,
        'last_used': null,
      };
    }
    
    // Calculate usage statistics
    for (var expense in expenses) {
      String categoryId = expense['categoryId'] ?? '';
      if (stats.containsKey(categoryId)) {
        stats[categoryId]!['usage_count'] += 1;
        stats[categoryId]!['total_amount'] += expense['amount'] ?? 0.0;
        
        // Update last used date
        DateTime expenseDate = DateTime.parse(expense['date'] ?? DateTime.now().toIso8601String());
        DateTime? lastUsed = stats[categoryId]!['last_used'];
        if (lastUsed == null || expenseDate.isAfter(lastUsed)) {
          stats[categoryId]!['last_used'] = expenseDate;
        }
      }
    }
    
    // Calculate averages
    stats.forEach((categoryId, data) {
      int count = data['usage_count'];
      if (count > 0) {
        data['average_amount'] = data['total_amount'] / count;
      }
    });
    
    return {'category_stats': stats};
  }

  // Learn from user's categorization choices (simplified - just stores learning data)
  Future<void> learnFromUserChoice(String expenseTitle, String expenseDescription, 
                                  String suggestedCategory, String actualCategory) async {
    // In the simplified version, we could store this in a separate preference key
    // For now, we'll just print the learning data
    print('Learning: "$expenseTitle" -> Suggested: $suggestedCategory, Actual: $actualCategory');
  }

  // Initialize learning system (no-op in simplified version)
  Future<void> initializeLearningSystem() async {
    print('Smart categorization learning system initialized (simplified mode)');
  }

  // Update category keywords based on learning (no-op in simplified version) 
  Future<void> updateCategoryKeywords() async {
    print('Category keywords updated (simplified mode)');
  }

  // Get personalized insights (simplified)
  Future<Map<String, dynamic>> getPersonalizedInsights() async {
    final patternAnalysis = await getSpendingPatternAnalysis();
    
    Map<String, dynamic> insights = {
      'insights_available': true,
      'total_expenses': patternAnalysis['total_expenses'],
      'average_spending': patternAnalysis['average_amount'],
      'spending_trend': patternAnalysis['spending_trend'],
      'most_used_category': patternAnalysis['most_frequent_category'],
    };
    
    // Add some simple insights
    int totalExpenses = patternAnalysis['total_expenses'];
    if (totalExpenses == 0) {
      insights['primary_insight'] = 'Start tracking your expenses to get personalized insights!';
    } else if (totalExpenses < 5) {
      insights['primary_insight'] = 'Track more expenses to get better insights about your spending patterns.';
    } else {
      insights['primary_insight'] = 'You have $totalExpenses tracked expenses. Great job staying on top of your spending!';
    }
    
    return insights;
  }

  // Optimize categories (simplified)
  Future<void> optimizeCategories() async {
    print('Category optimization completed (simplified mode)');
  }
}