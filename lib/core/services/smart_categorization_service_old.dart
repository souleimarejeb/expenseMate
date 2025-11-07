import 'dart:math' as math;
import '../database/databaseHelper.dart';

class SmartCategorizationService {
  static final SmartCategorizationService _instance = SmartCategorizationService._internal();
  factory SmartCategorizationService() => _instance;
  SmartCategorizationService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Keywords for automatic categorization
  static const Map<String, List<String>> _categoryKeywords = {
    'food': [
      'restaurant', 'grocery', 'supermarket', 'food', 'meal', 'lunch', 'dinner', 
      'breakfast', 'cafe', 'coffee', 'pizza', 'burger', 'sushi', 'delivery',
      'mcdonald', 'subway', 'starbucks', 'kfc', 'domino', 'uber eats', 'foodpanda'
    ],
    'transport': [
      'gas', 'fuel', 'taxi', 'uber', 'lyft', 'bus', 'train', 'metro', 'parking',
      'toll', 'car wash', 'auto', 'vehicle', 'transport', 'airline', 'flight'
    ],
    'entertainment': [
      'movie', 'cinema', 'netflix', 'spotify', 'game', 'concert', 'theater',
      'club', 'bar', 'entertainment', 'streaming', 'subscription', 'music'
    ],
    'shopping': [
      'amazon', 'shop', 'store', 'mall', 'clothes', 'clothing', 'fashion',
      'electronics', 'phone', 'computer', 'gadget', 'appliance'
    ],
    'healthcare': [
      'hospital', 'doctor', 'pharmacy', 'medicine', 'medical', 'health',
      'dentist', 'clinic', 'insurance', 'prescription'
    ],
    'utilities': [
      'electricity', 'water', 'gas bill', 'internet', 'phone bill', 'utility',
      'cable', 'wifi', 'mobile', 'telecom'
    ],
    'education': [
      'school', 'university', 'course', 'book', 'education', 'tuition',
      'training', 'workshop', 'seminar', 'online course'
    ],
    'home': [
      'rent', 'mortgage', 'furniture', 'home', 'house', 'apartment',
      'repair', 'maintenance', 'cleaning', 'decoration'
    ]
  };

  // Suggest category based on title and description using ML-like approach
  Future<String?> suggestCategory(String title, String description) async {
    final db = _dbHelper;
    
    // Get all available categories
    final categories = await db.query('expense_categories');
    if (categories.isEmpty) return null;

    String combinedText = '${title.toLowerCase()} ${description.toLowerCase()}';
    
    // 1. Keyword-based scoring
    Map<String, double> keywordScores = {};
    for (var category in categories) {
      String categoryName = category['name'].toString().toLowerCase();
      keywordScores[category['id'].toString()] = _calculateKeywordScore(combinedText, categoryName);
    }

    // 2. Historical pattern matching
    Map<String, double> historyScores = await _calculateHistoryScore(title, description);

    // 3. Amount-based similarity
    Map<String, double> amountScores = await _calculateAmountSimilarity(title, description);

    // 4. Time-based patterns (day of week, time of month)
    Map<String, double> timeScores = await _calculateTimePatterns(title, description);

    // Combine all scores with weights
    Map<String, double> finalScores = {};
    for (var category in categories) {
      String categoryId = category['id'].toString();
      finalScores[categoryId] = 
        (keywordScores[categoryId] ?? 0.0) * 0.4 +  // 40% keyword matching
        (historyScores[categoryId] ?? 0.0) * 0.3 +   // 30% historical patterns
        (amountScores[categoryId] ?? 0.0) * 0.2 +    // 20% amount similarity
        (timeScores[categoryId] ?? 0.0) * 0.1;       // 10% time patterns
    }

    // Find the category with highest score
    if (finalScores.isEmpty) return null;
    
    String bestCategory = finalScores.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    // Only suggest if confidence is above threshold
    double confidence = finalScores[bestCategory]!;
    return confidence > 0.6 ? bestCategory : null;
  }

  // Calculate keyword-based score
  double _calculateKeywordScore(String text, String categoryName) {
    List<String> keywords = _categoryKeywords[categoryName] ?? [];
    if (keywords.isEmpty) return 0.0;

    int matches = 0;
    for (String keyword in keywords) {
      if (text.contains(keyword.toLowerCase())) {
        matches++;
      }
    }

    return matches / keywords.length;
  }

  // Calculate score based on historical spending patterns
  Future<Map<String, double>> _calculateHistoryScore(String title, String description) async {
    final db = await _dbHelper.database;
    
    // Find similar expenses in the past
    final result = await db.rawQuery('''
      SELECT 
        categoryId,
        COUNT(*) as frequency,
        AVG(
          -- Calculate text similarity using word overlap
          CASE 
            WHEN (LENGTH(title) + LENGTH(?)) > 0 THEN
              (2.0 * LENGTH(title || ? || '') - LENGTH(title) - LENGTH(?)) / 
              (LENGTH(title) + LENGTH(?))
            ELSE 0
          END
        ) as similarity_score
      FROM expenses
      WHERE date >= date('now', '-6 months')
        AND (
          title LIKE '%' || ? || '%' OR
          description LIKE '%' || ? || '%' OR
          ? LIKE '%' || SUBSTR(title, 1, 5) || '%'
        )
      GROUP BY categoryId
      HAVING similarity_score > 0.3
      ORDER BY frequency DESC, similarity_score DESC
    ''', [title, title, title, title, title, description, title]);

    Map<String, double> scores = {};
    double maxFrequency = result.isNotEmpty 
        ? (result.first['frequency'] as int).toDouble() 
        : 1.0;

    for (var row in result) {
      String categoryId = row['categoryId'].toString();
      double frequency = (row['frequency'] as int).toDouble();
      double similarity = (row['similarity_score'] as double? ?? 0.0);
      
      // Normalize and combine frequency and similarity
      scores[categoryId] = (frequency / maxFrequency) * 0.7 + similarity * 0.3;
    }

    return scores;
  }

  // Calculate amount-based similarity
  Future<Map<String, double>> _calculateAmountSimilarity(String title, String description) async {
    final db = await _dbHelper.database;
    
    // Extract potential amount from text (simple regex approach)
    double? extractedAmount = _extractAmountFromText('$title $description');
    if (extractedAmount == null) return {};

    final result = await db.rawQuery('''
      SELECT 
        categoryId,
        AVG(amount) as avg_amount,
        COUNT(*) as count
      FROM expenses
      WHERE date >= date('now', '-3 months')
      GROUP BY categoryId
      HAVING count >= 3
    ''');

    Map<String, double> scores = {};
    for (var row in result) {
      String categoryId = row['categoryId'].toString();
      double avgAmount = (row['avg_amount'] as double? ?? 0.0);
      
      if (avgAmount > 0) {
        // Calculate similarity based on amount difference
        double difference = (extractedAmount - avgAmount).abs();
        double similarity = math.max(0, 1 - (difference / math.max(extractedAmount, avgAmount)));
        scores[categoryId] = similarity;
      }
    }

    return scores;
  }

  // Calculate time-based patterns
  Future<Map<String, double>> _calculateTimePatterns(String title, String description) async {
    final db = await _dbHelper.database;
    
    DateTime now = DateTime.now();
    int dayOfWeek = now.weekday;
    int dayOfMonth = now.day;
    int hour = now.hour;

    final result = await db.rawQuery('''
      SELECT 
        categoryId,
        COUNT(*) as total_count,
        COUNT(CASE WHEN strftime('%w', date) = ? THEN 1 END) as same_weekday_count,
        COUNT(CASE WHEN strftime('%d', date) = ? THEN 1 END) as same_day_count,
        COUNT(CASE WHEN strftime('%H', datetime(date, 'localtime')) = ? THEN 1 END) as same_hour_count
      FROM expenses
      WHERE date >= date('now', '-2 months')
      GROUP BY categoryId
      HAVING total_count >= 5
    ''', [dayOfWeek.toString(), dayOfMonth.toString().padLeft(2, '0'), hour.toString().padLeft(2, '0')]);

    Map<String, double> scores = {};
    for (var row in result) {
      String categoryId = row['categoryId'].toString();
      int totalCount = row['total_count'] as int;
      int sameWeekdayCount = row['same_weekday_count'] as int;
      int sameDayCount = row['same_day_count'] as int;
      int sameHourCount = row['same_hour_count'] as int;
      
      if (totalCount > 0) {
        double weekdayScore = sameWeekdayCount / totalCount;
        double dayScore = sameDayCount / totalCount;
        double hourScore = sameHourCount / totalCount;
        
        // Weight different time patterns
        scores[categoryId] = weekdayScore * 0.5 + dayScore * 0.3 + hourScore * 0.2;
      }
    }

    return scores;
  }

  // Extract amount from text using regex
  double? _extractAmountFromText(String text) {
    RegExp amountRegex = RegExp(r'[\$€£¥]?(\d+\.?\d*)');
    Match? match = amountRegex.firstMatch(text);
    if (match != null) {
      return double.tryParse(match.group(1) ?? '');
    }
    return null;
  }

  // Learn from user's categorization decisions
  Future<void> learnFromUserChoice({
    required String title,
    required String description,
    required String selectedCategoryId,
    required String suggestedCategoryId,
  }) async {
    final db = await _dbHelper.database;

    // Store learning data for future improvements
    await db.insert('expense_learning', {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'description': description,
      'suggested_category': suggestedCategoryId,
      'actual_category': selectedCategoryId,
      'was_correct': selectedCategoryId == suggestedCategoryId ? 1 : 0,
      'created_at': DateTime.now().toIso8601String(),
    });

    // Update category keywords based on user choices
    if (selectedCategoryId != suggestedCategoryId) {
      await _updateCategoryKeywords(title, description, selectedCategoryId);
    }
  }

  // Update category keywords based on user patterns
  Future<void> _updateCategoryKeywords(String title, String description, String categoryId) async {
    final db = await _dbHelper.database;

    // Extract meaningful words from title and description
    List<String> words = _extractKeywords('$title $description');
    
    for (String word in words) {
      if (word.length >= 3) { // Only consider words with 3+ characters
        await db.execute('''
          INSERT OR REPLACE INTO category_keywords (category_id, keyword, frequency)
          VALUES (?, ?, COALESCE((
            SELECT frequency + 1 FROM category_keywords 
            WHERE category_id = ? AND keyword = ?
          ), 1))
        ''', [categoryId, word, categoryId, word]);
      }
    }
  }

  // Extract meaningful keywords from text
  List<String> _extractKeywords(String text) {
    // Common stop words to ignore
    Set<String> stopWords = {
      'the', 'a', 'an', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for', 
      'of', 'with', 'by', 'is', 'are', 'was', 'were', 'be', 'been', 'have',
      'has', 'had', 'do', 'does', 'did', 'will', 'would', 'could', 'should'
    };

    List<String> words = text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty && !stopWords.contains(word))
        .toList();

    return words;
  }

  // Get category confidence score for an expense
  Future<double> getCategoryConfidence(String title, String description, String categoryId) async {
    String? suggestedCategory = await suggestCategory(title, description);
    
    if (suggestedCategory == categoryId) {
      return 1.0; // Perfect match
    } else if (suggestedCategory == null) {
      return 0.5; // No suggestion, neutral confidence
    } else {
      return 0.2; // Different suggestion, low confidence
    }
  }

  // Analyze categorization accuracy over time
  Future<Map<String, dynamic>> getCategorizationAccuracy() async {
    final db = await _dbHelper.database;

    final result = await db.rawQuery('''
      SELECT 
        COUNT(*) as total_suggestions,
        SUM(was_correct) as correct_suggestions,
        AVG(was_correct) as accuracy_rate,
        COUNT(DISTINCT actual_category) as categories_learned,
        MAX(created_at) as last_learning
      FROM expense_learning
      WHERE created_at >= date('now', '-30 days')
    ''');

    if (result.isNotEmpty) {
      return result.first;
    }

    return {
      'total_suggestions': 0,
      'correct_suggestions': 0,
      'accuracy_rate': 0.0,
      'categories_learned': 0,
      'last_learning': null,
    };
  }

  // Get trending categories based on recent patterns
  Future<List<Map<String, dynamic>>> getTrendingCategories({int daysBack = 30}) async {
    final db = await _dbHelper.database;

    final result = await db.rawQuery('''
      WITH recent_expenses AS (
        SELECT 
          categoryId,
          COUNT(*) as recent_count,
          SUM(amount) as recent_total
        FROM expenses
        WHERE date >= date('now', '-$daysBack days')
        GROUP BY categoryId
      ),
      previous_expenses AS (
        SELECT 
          categoryId,
          COUNT(*) as previous_count,
          SUM(amount) as previous_total
        FROM expenses
        WHERE date >= date('now', '-${daysBack * 2} days')
          AND date < date('now', '-$daysBack days')
        GROUP BY categoryId
      )
      SELECT 
        c.id,
        c.name,
        c.colorValue,
        COALESCE(re.recent_count, 0) as recent_transactions,
        COALESCE(re.recent_total, 0) as recent_amount,
        COALESCE(pe.previous_count, 0) as previous_transactions,
        COALESCE(pe.previous_total, 0) as previous_amount,
        CASE 
          WHEN COALESCE(pe.previous_count, 0) > 0 THEN
            ((COALESCE(re.recent_count, 0) - COALESCE(pe.previous_count, 0)) * 100.0) / pe.previous_count
          ELSE 100.0
        END as transaction_growth,
        CASE 
          WHEN COALESCE(pe.previous_total, 0) > 0 THEN
            ((COALESCE(re.recent_total, 0) - COALESCE(pe.previous_total, 0)) * 100.0) / pe.previous_total
          ELSE 100.0
        END as amount_growth
      FROM expense_categories c
      LEFT JOIN recent_expenses re ON c.id = re.categoryId
      LEFT JOIN previous_expenses pe ON c.id = pe.categoryId
      WHERE COALESCE(re.recent_count, 0) > 0
      ORDER BY transaction_growth DESC, amount_growth DESC
    ''');

    return result;
  }
}

// Create the learning and keywords tables if they don't exist
extension SmartCategorizationTables on DatabaseHelper {
  Future<void> createSmartCategorizationTables() async {
    final db = await database;
    
    // Table to store learning data
    await db.execute('''
      CREATE TABLE IF NOT EXISTS expense_learning(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        suggested_category TEXT,
        actual_category TEXT NOT NULL,
        was_correct INTEGER NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Table to store dynamic category keywords
    await db.execute('''
      CREATE TABLE IF NOT EXISTS category_keywords(
        category_id TEXT NOT NULL,
        keyword TEXT NOT NULL,
        frequency INTEGER DEFAULT 1,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (category_id, keyword),
        FOREIGN KEY (category_id) REFERENCES expense_categories(id)
      )
    ''');

    // Indexes for better performance
    await db.execute('CREATE INDEX IF NOT EXISTS idx_learning_category ON expense_learning(actual_category)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_learning_date ON expense_learning(created_at)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_keywords_frequency ON category_keywords(frequency DESC)');
  }
}