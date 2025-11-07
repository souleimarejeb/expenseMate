import '../database/databaseHelper.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';

class AdvancedAnalyticsService {
  static final AdvancedAnalyticsService _instance = AdvancedAnalyticsService._internal();
  factory AdvancedAnalyticsService() => _instance;
  AdvancedAnalyticsService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Get spending trends with moving averages
  Future<List<Map<String, dynamic>>> getSpendingTrends({
    required DateTime startDate,
    required DateTime endDate,
    String? categoryId,
  }) async {
    final db = await _dbHelper.database;
    
    String whereClause = 'WHERE e.date >= ? AND e.date <= ?';
    List<dynamic> whereArgs = [startDate.toIso8601String(), endDate.toIso8601String()];
    
    if (categoryId != null) {
      whereClause += ' AND e.categoryId = ?';
      whereArgs.add(categoryId);
    }

    final result = await db.rawQuery('''
      SELECT 
        DATE(e.date) as date,
        SUM(e.amount) as dailyTotal,
        COUNT(e.id) as transactionCount,
        AVG(e.amount) as avgTransaction,
        MAX(e.amount) as maxTransaction,
        MIN(e.amount) as minTransaction,
        -- 7-day moving average
        AVG(SUM(e.amount)) OVER (
          ORDER BY DATE(e.date) 
          ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ) as movingAverage7Day,
        -- Cumulative sum
        SUM(SUM(e.amount)) OVER (
          ORDER BY DATE(e.date) 
          ROWS UNBOUNDED PRECEDING
        ) as cumulativeTotal
      FROM expenses e
      $whereClause
      GROUP BY DATE(e.date)
      ORDER BY DATE(e.date)
    ''', whereArgs);
    
    return result;
  }

  // Get category insights with spending patterns
  Future<List<Map<String, dynamic>>> getCategoryInsights({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final db = await _dbHelper.database;
    
    final result = await db.rawQuery('''
      WITH category_stats AS (
        SELECT 
          c.id,
          c.name,
          c.colorValue,
          COUNT(e.id) as transactionCount,
          SUM(e.amount) as totalAmount,
          AVG(e.amount) as avgAmount,
          MAX(e.amount) as maxAmount,
          MIN(e.amount) as minAmount,
          STDDEV(e.amount) as stdDeviation,
          -- Calculate trend (positive/negative slope)
          CASE 
            WHEN COUNT(e.id) > 1 THEN
              (COUNT(e.id) * SUM(julianday(e.date) * e.amount) - SUM(julianday(e.date)) * SUM(e.amount)) /
              (COUNT(e.id) * SUM(julianday(e.date) * julianday(e.date)) - SUM(julianday(e.date)) * SUM(julianday(e.date)))
            ELSE 0
          END as trend
        FROM expense_categories c
        LEFT JOIN expenses e ON c.id = e.categoryId 
          AND e.date >= ? AND e.date <= ?
        GROUP BY c.id, c.name, c.colorValue
      ),
      total_spending AS (
        SELECT SUM(totalAmount) as grandTotal
        FROM category_stats
      )
      SELECT 
        cs.*,
        ROUND((cs.totalAmount / ts.grandTotal) * 100, 2) as percentage,
        CASE 
          WHEN cs.trend > 0 THEN 'increasing'
          WHEN cs.trend < 0 THEN 'decreasing'
          ELSE 'stable'
        END as trendDirection,
        -- Spending frequency score (1-10)
        CASE 
          WHEN cs.transactionCount = 0 THEN 0
          WHEN cs.transactionCount <= 5 THEN 1
          WHEN cs.transactionCount <= 10 THEN 3
          WHEN cs.transactionCount <= 20 THEN 5
          WHEN cs.transactionCount <= 50 THEN 7
          ELSE 10
        END as frequencyScore
      FROM category_stats cs
      CROSS JOIN total_spending ts
      WHERE cs.totalAmount > 0
      ORDER BY cs.totalAmount DESC
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);
    
    return result;
  }

  // Predict next month's expenses using linear regression
  Future<Map<String, dynamic>> predictNextMonthExpenses() async {
    final db = await _dbHelper.database;
    
    final result = await db.rawQuery('''
      WITH monthly_totals AS (
        SELECT 
          strftime('%Y-%m', date) as month,
          SUM(amount) as total,
          COUNT(id) as transactions,
          ROW_NUMBER() OVER (ORDER BY strftime('%Y-%m', date)) as month_number
        FROM expenses
        WHERE date >= date('now', '-12 months')
        GROUP BY strftime('%Y-%m', date)
        ORDER BY month
      ),
      regression_calc AS (
        SELECT 
          COUNT(*) as n,
          SUM(month_number) as sum_x,
          SUM(total) as sum_y,
          SUM(month_number * total) as sum_xy,
          SUM(month_number * month_number) as sum_x2,
          AVG(total) as avg_total
        FROM monthly_totals
      )
      SELECT 
        -- Linear regression: y = mx + b
        CASE 
          WHEN rc.n * rc.sum_x2 - rc.sum_x * rc.sum_x != 0 THEN
            (rc.n * rc.sum_xy - rc.sum_x * rc.sum_y) / 
            (rc.n * rc.sum_x2 - rc.sum_x * rc.sum_x)
          ELSE 0
        END as slope,
        CASE 
          WHEN rc.n != 0 THEN
            (rc.sum_y - ((rc.n * rc.sum_xy - rc.sum_x * rc.sum_y) / 
            (rc.n * rc.sum_x2 - rc.sum_x * rc.sum_x)) * rc.sum_x) / rc.n
          ELSE 0
        END as intercept,
        rc.avg_total,
        -- Predict next month (month_number = n + 1)
        CASE 
          WHEN rc.n * rc.sum_x2 - rc.sum_x * rc.sum_x != 0 THEN
            ((rc.n * rc.sum_xy - rc.sum_x * rc.sum_y) / 
            (rc.n * rc.sum_x2 - rc.sum_x * rc.sum_x)) * (rc.n + 1) +
            (rc.sum_y - ((rc.n * rc.sum_xy - rc.sum_x * rc.sum_y) / 
            (rc.n * rc.sum_x2 - rc.sum_x * rc.sum_x)) * rc.sum_x) / rc.n
          ELSE rc.avg_total
        END as predicted_amount,
        rc.n as months_of_data
      FROM regression_calc rc
    ''');
    
    return result.isNotEmpty ? result.first : {};
  }

  // Find unusual spending patterns (outliers)
  Future<List<Map<String, dynamic>>> detectSpendingAnomalies({
    int daysBack = 90,
  }) async {
    final db = await _dbHelper.database;
    
    final result = await db.rawQuery('''
      WITH expense_stats AS (
        SELECT 
          e.*,
          c.name as categoryName,
          -- Calculate Z-score for amount within category
          (e.amount - AVG(e.amount) OVER (PARTITION BY e.categoryId)) / 
          NULLIF(STDDEV(e.amount) OVER (PARTITION BY e.categoryId), 0) as amount_zscore,
          -- Calculate percentile
          PERCENT_RANK() OVER (PARTITION BY e.categoryId ORDER BY e.amount) as amount_percentile,
          AVG(e.amount) OVER (PARTITION BY e.categoryId) as category_avg_amount,
          STDDEV(e.amount) OVER (PARTITION BY e.categoryId) as category_std_amount
        FROM expenses e
        JOIN expense_categories c ON e.categoryId = c.id
        WHERE e.date >= date('now', '-$daysBack days')
      )
      SELECT 
        *,
        CASE 
          WHEN ABS(amount_zscore) > 2 THEN 'high_outlier'
          WHEN ABS(amount_zscore) > 1.5 THEN 'moderate_outlier'
          WHEN amount_percentile > 0.95 THEN 'top_5_percent'
          WHEN amount_percentile < 0.05 THEN 'bottom_5_percent'
          ELSE 'normal'
        END as anomaly_type,
        CASE 
          WHEN amount > category_avg_amount + 2 * category_std_amount THEN 'unusually_high'
          WHEN amount < category_avg_amount - 2 * category_std_amount THEN 'unusually_low'
          ELSE 'normal_range'
        END as spending_level
      FROM expense_stats
      WHERE ABS(amount_zscore) > 1.5 OR amount_percentile > 0.95 OR amount_percentile < 0.05
      ORDER BY ABS(amount_zscore) DESC
    ''');
    
    return result;
  }

  // Get spending velocity (rate of change)
  Future<List<Map<String, dynamic>>> getSpendingVelocity({
    String period = 'weekly', // daily, weekly, monthly
  }) async {
    final db = await _dbHelper.database;
    
    String dateFormat;
    switch (period) {
      case 'daily':
        dateFormat = '%Y-%m-%d';
        break;
      case 'weekly':
        dateFormat = '%Y-%W';
        break;
      case 'monthly':
        dateFormat = '%Y-%m';
        break;
      default:
        dateFormat = '%Y-%W';
    }
    
    final result = await db.rawQuery('''
      WITH period_totals AS (
        SELECT 
          strftime('$dateFormat', date) as period,
          SUM(amount) as total,
          COUNT(id) as transactions,
          AVG(amount) as avg_amount
        FROM expenses
        WHERE date >= date('now', '-3 months')
        GROUP BY strftime('$dateFormat', date)
        ORDER BY period
      ),
      velocity_calc AS (
        SELECT 
          *,
          LAG(total) OVER (ORDER BY period) as prev_total,
          LAG(transactions) OVER (ORDER BY period) as prev_transactions,
          total - LAG(total) OVER (ORDER BY period) as amount_change,
          transactions - LAG(transactions) OVER (ORDER BY period) as transaction_change
        FROM period_totals
      )
      SELECT 
        *,
        CASE 
          WHEN prev_total IS NOT NULL AND prev_total != 0 THEN
            ROUND(((total - prev_total) / prev_total) * 100, 2)
          ELSE 0
        END as percent_change,
        CASE 
          WHEN amount_change > 0 THEN 'increasing'
          WHEN amount_change < 0 THEN 'decreasing'
          ELSE 'stable'
        END as velocity_direction,
        ABS(amount_change) as velocity_magnitude
      FROM velocity_calc
      WHERE prev_total IS NOT NULL
      ORDER BY period DESC
    ''');
    
    return result;
  }

  // Get smart spending recommendations
  Future<List<Map<String, dynamic>>> getSpendingRecommendations() async {
    final db = await _dbHelper.database;
    
    final result = await db.rawQuery('''
      WITH current_month AS (
        SELECT 
          categoryId,
          c.name as categoryName,
          SUM(amount) as current_spending,
          COUNT(id) as current_transactions,
          AVG(amount) as current_avg
        FROM expenses e
        JOIN expense_categories c ON e.categoryId = c.id
        WHERE strftime('%Y-%m', date) = strftime('%Y-%m', 'now')
        GROUP BY categoryId, c.name
      ),
      historical_avg AS (
        SELECT 
          categoryId,
          AVG(monthly_total) as historical_avg,
          STDDEV(monthly_total) as historical_std,
          COUNT(*) as months_count
        FROM (
          SELECT 
            categoryId,
            strftime('%Y-%m', date) as month,
            SUM(amount) as monthly_total
          FROM expenses
          WHERE date >= date('now', '-6 months')
            AND strftime('%Y-%m', date) != strftime('%Y-%m', 'now')
          GROUP BY categoryId, strftime('%Y-%m', date)
        ) monthly_expenses
        GROUP BY categoryId
      )
      SELECT 
        cm.categoryId,
        cm.categoryName,
        cm.current_spending,
        ROUND(ha.historical_avg, 2) as historical_average,
        ROUND(cm.current_spending - ha.historical_avg, 2) as variance,
        ROUND(((cm.current_spending - ha.historical_avg) / ha.historical_avg) * 100, 2) as variance_percent,
        CASE 
          WHEN cm.current_spending > ha.historical_avg + ha.historical_std THEN 'reduce_spending'
          WHEN cm.current_spending < ha.historical_avg - ha.historical_std THEN 'low_spending'
          WHEN cm.current_spending > ha.historical_avg * 1.2 THEN 'monitor_closely'
          ELSE 'on_track'
        END as recommendation_type,
        CASE 
          WHEN cm.current_spending > ha.historical_avg + ha.historical_std THEN 
            'Consider reducing spending in ' || cm.categoryName || '. You are ' || 
            ROUND(((cm.current_spending - ha.historical_avg) / ha.historical_avg) * 100, 1) || 
            '% above your historical average.'
          WHEN cm.current_spending < ha.historical_avg - ha.historical_std THEN 
            'Great job managing ' || cm.categoryName || ' expenses! You are ' || 
            ROUND(((ha.historical_avg - cm.current_spending) / ha.historical_avg) * 100, 1) || 
            '% below your usual spending.'
          WHEN cm.current_spending > ha.historical_avg * 1.2 THEN 
            'Monitor your ' || cm.categoryName || ' spending. It\'s trending higher than usual.'
          ELSE 'Your ' || cm.categoryName || ' spending is on track with your historical patterns.'
        END as recommendation_text,
        ha.months_count
      FROM current_month cm
      JOIN historical_avg ha ON cm.categoryId = ha.categoryId
      WHERE ha.months_count >= 3  -- Only show recommendations if we have enough data
      ORDER BY ABS(variance_percent) DESC
    ''');
    
    return result;
  }

  // Advanced search with ranking and relevance
  Future<List<Map<String, dynamic>>> searchExpensesAdvanced({
    required String query,
    String? categoryId,
    DateTime? startDate,
    DateTime? endDate,
    double? minAmount,
    double? maxAmount,
    int limit = 50,
  }) async {
    final db = await _dbHelper.database;
    
    List<String> whereClauses = [];
    List<dynamic> whereArgs = [];
    
    // Full-text search
    whereClauses.add('expenses_fts MATCH ?');
    whereArgs.add('$query*');
    
    String additionalWhere = '';
    if (categoryId != null) {
      additionalWhere += ' AND e.categoryId = ?';
      whereArgs.add(categoryId);
    }
    
    if (startDate != null) {
      additionalWhere += ' AND e.date >= ?';
      whereArgs.add(startDate.toIso8601String());
    }
    
    if (endDate != null) {
      additionalWhere += ' AND e.date <= ?';
      whereArgs.add(endDate.toIso8601String());
    }
    
    if (minAmount != null) {
      additionalWhere += ' AND e.amount >= ?';
      whereArgs.add(minAmount);
    }
    
    if (maxAmount != null) {
      additionalWhere += ' AND e.amount <= ?';
      whereArgs.add(maxAmount);
    }
    
    whereArgs.add(limit);
    
    final result = await db.rawQuery('''
      SELECT 
        e.*,
        c.name as categoryName,
        c.colorValue as categoryColor,
        -- Calculate relevance score
        (
          -- FTS rank (higher is better, so we invert it)
          (1.0 / (expenses_fts.rank + 1)) * 10 +
          -- Recency boost (more recent = higher score)
          (1.0 / (julianday('now') - julianday(e.date) + 1)) * 5 +
          -- Amount relevance (normalize by category average)
          CASE 
            WHEN AVG(e2.amount) OVER (PARTITION BY e.categoryId) > 0 THEN
              (e.amount / AVG(e2.amount) OVER (PARTITION BY e.categoryId)) * 2
            ELSE 1
          END
        ) as relevance_score,
        -- Highlight matching terms
        highlight(expenses_fts, 0, '<mark>', '</mark>') as highlighted_title,
        highlight(expenses_fts, 1, '<mark>', '</mark>') as highlighted_description
      FROM expenses_fts
      JOIN expenses e ON expenses_fts.rowid = e.rowid
      JOIN expense_categories c ON e.categoryId = c.id
      LEFT JOIN expenses e2 ON e.categoryId = e2.categoryId
      WHERE ${whereClauses.join(' AND ')} $additionalWhere
      ORDER BY relevance_score DESC, e.date DESC
      LIMIT ?
    ''', whereArgs);
    
    return result;
  }

  // Generate spending analytics report
  Future<void> generateAnalyticsReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final db = await _dbHelper.database;
    
    // Clear old analytics data
    await db.delete(
      'spending_analytics',
      where: 'periodDate >= ? AND periodDate <= ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
    );
    
    // Generate daily analytics
    await db.execute('''
      INSERT INTO spending_analytics (
        id, period, periodDate, categoryId, 
        totalAmount, transactionCount, averageAmount, maxAmount, minAmount, createdAt
      )
      SELECT 
        'daily_' || DATE(e.date) || '_' || COALESCE(e.categoryId, 'all') as id,
        'daily' as period,
        DATE(e.date) as periodDate,
        e.categoryId,
        SUM(e.amount) as totalAmount,
        COUNT(e.id) as transactionCount,
        AVG(e.amount) as averageAmount,
        MAX(e.amount) as maxAmount,
        MIN(e.amount) as minAmount,
        datetime('now') as createdAt
      FROM expenses e
      WHERE e.date >= ? AND e.date <= ?
      GROUP BY DATE(e.date), e.categoryId
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);
    
    // Generate weekly analytics
    await db.execute('''
      INSERT INTO spending_analytics (
        id, period, periodDate, categoryId, 
        totalAmount, transactionCount, averageAmount, maxAmount, minAmount, createdAt
      )
      SELECT 
        'weekly_' || strftime('%Y-%W', e.date) || '_' || COALESCE(e.categoryId, 'all') as id,
        'weekly' as period,
        strftime('%Y-%W', e.date) as periodDate,
        e.categoryId,
        SUM(e.amount) as totalAmount,
        COUNT(e.id) as transactionCount,
        AVG(e.amount) as averageAmount,
        MAX(e.amount) as maxAmount,
        MIN(e.amount) as minAmount,
        datetime('now') as createdAt
      FROM expenses e
      WHERE e.date >= ? AND e.date <= ?
      GROUP BY strftime('%Y-%W', e.date), e.categoryId
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);
  }
}