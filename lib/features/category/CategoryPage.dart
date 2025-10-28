import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // For the pie chart

class CategoryPage extends StatefulWidget {
  const CategoryPage({Key? key}) : super(key: key);

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List<Map<String, dynamic>> categories = [
    {'name': 'Food', 'amount': 300, 'color': Colors.orange, 'icon': Icons.fastfood},
    {'name': 'Transport', 'amount': 120, 'color': Colors.blue, 'icon': Icons.directions_car},
    {'name': 'Entertainment', 'amount': 80, 'color': Colors.purple, 'icon': Icons.movie},
    {'name': 'Bills', 'amount': 250, 'color': Colors.redAccent, 'icon': Icons.receipt_long},
    {'name': 'Shopping', 'amount': 150, 'color': Colors.green, 'icon': Icons.shopping_bag},
  ];

  double get totalSpending =>
      categories.fold(0, (sum, item) => sum + item['amount']);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            Icon(Icons.category, color: Colors.black, size: 26),
            SizedBox(width: 8),
            Text(
              "Categories",
              style: TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_outline, color: Colors.black87),
            onPressed: () {
              _showAddCategoryDialog(context);
            },
          ),
          SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Pie Chart
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Spending Breakdown",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        height: 180,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                            sections: _buildPieSections(),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Total: \$${totalSpending.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 32),

                // Category List
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "All Categories",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                SizedBox(height: 12),

                ...categories.map((cat) {
                  final percentage = (cat['amount'] / totalSpending) * 100;
                  return Container(
                    margin: EdgeInsets.only(bottom: 16),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: cat['color'].withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(cat['icon'], color: cat['color'], size: 24),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cat['name'],
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 6),
                              LinearProgressIndicator(
                                value: percentage / 100,
                                backgroundColor: Colors.grey[200],
                                color: cat['color'],
                                minHeight: 6,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              SizedBox(height: 6),
                              Text(
                                "\$${cat['amount']}  •  ${percentage.toStringAsFixed(1)}%",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.black45),
                          onPressed: () {
                            _editCategoryDialog(context, cat);
                          },
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections() {
    return categories.map((cat) {
      final percentage = (cat['amount'] / totalSpending) * 100;
      return PieChartSectionData(
        color: cat['color'],
        value: percentage,
        title: "${percentage.toStringAsFixed(1)}%",
        radius: 60,
        titleStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  void _showAddCategoryDialog(BuildContext context) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Add Category"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Category Name"),
            ),
            TextField(
              controller: amountController,
              decoration: InputDecoration(labelText: "Amount"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  double.tryParse(amountController.text) != null) {
                setState(() {
                  categories.add({
                    'name': nameController.text,
                    'amount': double.parse(amountController.text),
                    'color': Colors.primaries[categories.length % Colors.primaries.length],
                    'icon': Icons.category,
                  });
                });
                Navigator.pop(context);
              }
            },
            child: Text("Add"),
          ),
        ],
      ),
    );
  }

  void _editCategoryDialog(BuildContext context, Map<String, dynamic> category) {
    final controller = TextEditingController(text: category['amount'].toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Edit ${category['name']}"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: "New Amount"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final value = double.tryParse(controller.text);
              if (value != null) {
                setState(() => category['amount'] = value);
                Navigator.pop(context);
              }
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }
}
