// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart'; // For the pie chart

// class CategoryPage extends StatefulWidget {
//   const CategoryPage({Key? key}) : super(key: key);

//   @override
//   _CategoryPageState createState() => _CategoryPageState();
// }

// class _CategoryPageState extends State<CategoryPage> {
//   List<Map<String, dynamic>> categories = [
//     {'name': 'Food', 'amount': 300, 'color': Colors.orange, 'icon': Icons.fastfood},
//     {'name': 'Transport', 'amount': 120, 'color': Colors.blue, 'icon': Icons.directions_car},
//     {'name': 'Entertainment', 'amount': 80, 'color': Colors.purple, 'icon': Icons.movie},
//     {'name': 'Bills', 'amount': 250, 'color': Colors.redAccent, 'icon': Icons.receipt_long},
//     {'name': 'Shopping', 'amount': 150, 'color': Colors.green, 'icon': Icons.shopping_bag},
//   ];

//   double get totalSpending =>
//       categories.fold(0, (sum, item) => sum + item['amount']);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.transparent,
//         title: Row(
//           children: [
//             Icon(Icons.category, color: Colors.black, size: 26),
//             SizedBox(width: 8),
//             Text(
//               "Categories",
//               style: TextStyle(
//                 color: Colors.black,
//                 fontSize: 22,
//                 fontWeight: FontWeight.w800,
//                 letterSpacing: -0.5,
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.add_circle_outline, color: Colors.black87),
//             onPressed: () {
//               _showAddCategoryDialog(context);
//             },
//           ),
//           SizedBox(width: 12),
//         ],
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           physics: BouncingScrollPhysics(),
//           child: Padding(
//             padding: const EdgeInsets.all(24.0),
//             child: Column(
//               children: [
//                 // Pie Chart
//                 Container(
//                   padding: EdgeInsets.all(20),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(24),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.05),
//                         blurRadius: 15,
//                         offset: Offset(0, 5),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     children: [
//                       Text(
//                         "Spending Breakdown",
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w700,
//                           color: Colors.black87,
//                         ),
//                       ),
//                       SizedBox(height: 20),
//                       SizedBox(
//                         height: 180,
//                         child: PieChart(
//                           PieChartData(
//                             sectionsSpace: 2,
//                             centerSpaceRadius: 40,
//                             sections: _buildPieSections(),
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: 10),
//                       Text(
//                         "Total: \$${totalSpending.toStringAsFixed(2)}",
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: Colors.black54,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 SizedBox(height: 32),

//                 // Category List
//                 Align(
//                   alignment: Alignment.centerLeft,
//                   child: Text(
//                     "All Categories",
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.w700,
//                       color: Colors.black87,
//                       letterSpacing: -0.5,
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 12),

//                 ...categories.map((cat) {
//                   final percentage = (cat['amount'] / totalSpending) * 100;
//                   return Container(
//                     margin: EdgeInsets.only(bottom: 16),
//                     padding: EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(18),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.05),
//                           blurRadius: 10,
//                           offset: Offset(0, 5),
//                         ),
//                       ],
//                     ),
//                     child: Row(
//                       children: [
//                         Container(
//                           padding: EdgeInsets.all(10),
//                           decoration: BoxDecoration(
//                             color: cat['color'].withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Icon(cat['icon'], color: cat['color'], size: 24),
//                         ),
//                         SizedBox(width: 16),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 cat['name'],
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.w700,
//                                   fontSize: 16,
//                                   color: Colors.black87,
//                                 ),
//                               ),
//                               SizedBox(height: 6),
//                               LinearProgressIndicator(
//                                 value: percentage / 100,
//                                 backgroundColor: Colors.grey[200],
//                                 color: cat['color'],
//                                 minHeight: 6,
//                                 borderRadius: BorderRadius.circular(4),
//                               ),
//                               SizedBox(height: 6),
//                               Text(
//                                 "\$${cat['amount']}  •  ${percentage.toStringAsFixed(1)}%",
//                                 style: TextStyle(
//                                   color: Colors.black54,
//                                   fontSize: 13,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         IconButton(
//                           icon: Icon(Icons.edit, color: Colors.black45),
//                           onPressed: () {
//                             _editCategoryDialog(context, cat);
//                           },
//                         ),
//                       ],
//                     ),
//                   );
//                 }),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   List<PieChartSectionData> _buildPieSections() {
//     return categories.map((cat) {
//       final percentage = (cat['amount'] / totalSpending) * 100;
//       return PieChartSectionData(
//         color: cat['color'],
//         value: percentage,
//         title: "${percentage.toStringAsFixed(1)}%",
//         radius: 60,
//         titleStyle: TextStyle(
//           fontSize: 12,
//           fontWeight: FontWeight.w600,
//           color: Colors.white,
//         ),
//       );
//     }).toList();
//   }

//   void _showAddCategoryDialog(BuildContext context) {
//     final nameController = TextEditingController();
//     final amountController = TextEditingController();

//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: Text("Add Category"),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               controller: nameController,
//               decoration: InputDecoration(labelText: "Category Name"),
//             ),
//             TextField(
//               controller: amountController,
//               decoration: InputDecoration(labelText: "Amount"),
//               keyboardType: TextInputType.number,
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
//           ElevatedButton(
//             onPressed: () {
//               if (nameController.text.isNotEmpty &&
//                   double.tryParse(amountController.text) != null) {
//                 setState(() {
//                   categories.add({
//                     'name': nameController.text,
//                     'amount': double.parse(amountController.text),
//                     'color': Colors.primaries[categories.length % Colors.primaries.length],
//                     'icon': Icons.category,
//                   });
//                 });
//                 Navigator.pop(context);
//               }
//             },
//             child: Text("Add"),
//           ),
//         ],
//       ),
//     );
//   }

//   void _editCategoryDialog(BuildContext context, Map<String, dynamic> category) {
//     final controller = TextEditingController(text: category['amount'].toString());

//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: Text("Edit ${category['name']}"),
//         content: TextField(
//           controller: controller,
//           keyboardType: TextInputType.number,
//           decoration: InputDecoration(labelText: "New Amount"),
//         ),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
//           ElevatedButton(
//             onPressed: () {
//               final value = double.tryParse(controller.text);
//               if (value != null) {
//                 setState(() => category['amount'] = value);
//                 Navigator.pop(context);
//               }
//             },
//             child: Text("Save"),
//           ),
//         ],
//       ),
//     );
//   }
// }


// Dart/Flutter imports
import 'package:flutter/material.dart';

// 3rd party packages
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fl_chart/fl_chart.dart';

// Local project files
import 'category_model.dart';
import 'category_model.dart'; // Your main model file

import 'CategoryPage2.dart';





class HiveService {
  static const String categoriesBox = 'categories';
  
  static Future<void> init() async {
    await Hive.openBox<Category>(categoriesBox);
    await _initializePredefinedCategories();
  }

  static Future<void> _initializePredefinedCategories() async {
    final box = Hive.box<Category>(categoriesBox);
    
    if (box.isEmpty) {
      final predefinedCategories = [
        Category(
          id: '1',
          name: 'Food',
          amount: 0.0,
          colorValue: Colors.orange.value,
          iconCode: Icons.fastfood.codePoint,
          isPredefined: true,
        ),
        Category(
          id: '2',
          name: 'Transport',
          amount: 0.0,
          colorValue: Colors.blue.value,
          iconCode: Icons.directions_car.codePoint,
          isPredefined: true,
        ),
        Category(
          id: '3',
          name: 'Entertainment',
          amount: 0.0,
          colorValue: Colors.purple.value,
          iconCode: Icons.movie.codePoint,
          isPredefined: true,
        ),
        Category(
          id: '4',
          name: 'Bills',
          amount: 0.0,
          colorValue: Colors.red.value,
          iconCode: Icons.receipt_long.codePoint,
          isPredefined: true,
        ),
        Category(
          id: '5',
          name: 'Shopping',
          amount: 0.0,
          colorValue: Colors.green.value,
          iconCode: Icons.shopping_bag.codePoint,
          isPredefined: true,
        ),
      ];

      for (final category in predefinedCategories) {
        await box.put(category.id, category);
      }
    }
  }

  static List<Category> getAllCategories() {
    final box = Hive.box<Category>(categoriesBox);
    return box.values.toList();
  }

  static Future<void> addCategory(Category category) async {
    final box = Hive.box<Category>(categoriesBox);
    await box.put(category.id, category);
  }

  static Future<void> updateCategory(Category category) async {
    final box = Hive.box<Category>(categoriesBox);
    await box.put(category.id, category);
  }

  static Future<void> deleteCategory(String id) async {
    final box = Hive.box<Category>(categoriesBox);
    await box.delete(id);
  }

  static Future<void> updateCategoryAmount(String id, double newAmount) async {
    final box = Hive.box<Category>(categoriesBox);
    final category = box.get(id);
    if (category != null) {
      final updatedCategory = category.copyWith(amount: newAmount);
      await box.put(id, updatedCategory);
    }
  }
}






void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  Hive.registerAdapter(CategoryAdapter());
  
  await HiveService.init();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CategoryPage(),
    );
  }
}





class CategoryPage extends StatefulWidget {
  const CategoryPage({Key? key}) : super(key: key);

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final List<Color> availableColors = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
    Colors.pink,
    Colors.teal,
    Colors.cyan,
  ];

  final List<IconData> availableIcons = [
    Icons.fastfood,
    Icons.directions_car,
    Icons.movie,
    Icons.receipt_long,
    Icons.shopping_bag,
    Icons.local_hospital,
    Icons.school,
    Icons.sports,
    Icons.phone,
    Icons.wifi,
    Icons.electric_bolt,
    Icons.water_drop,
    Icons.local_gas_station,
    Icons.card_giftcard,
    Icons.home,
  ];

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
        child: ValueListenableBuilder(
          valueListenable: Hive.box<Category>(HiveService.categoriesBox).listenable(),
          builder: (context, Box<Category> box, widget) {
            final categories = box.values.toList();
            final totalSpending = categories.fold(0.0, (sum, item) => sum + item.amount);

            return SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Pie Chart
                    if (categories.isNotEmpty) ...[
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
                                  sections: _buildPieSections(categories, totalSpending),
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
                    ],

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

                    if (categories.isEmpty)
                      Container(
                        padding: EdgeInsets.all(40),
                        child: Column(
                          children: [
                            Icon(Icons.category_outlined, size: 64, color: Colors.grey[300]),
                            SizedBox(height: 16),
                            Text(
                              "No categories yet",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[500],
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Add your first category to get started",
                              style: TextStyle(
                                color: Colors.grey[400],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    else
                      ...categories.map((cat) {
                        final percentage = totalSpending > 0 ? (cat.amount / totalSpending) * 100 : 0;
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
                                  color: cat.color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(cat.icon, color: cat.color, size: 24),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          cat.name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        if (cat.isPredefined) ...[
                                          SizedBox(width: 6),
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              "Default",
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    SizedBox(height: 6),
                                    LinearProgressIndicator(
                                      value: percentage / 100,
                                      backgroundColor: Colors.grey[200],
                                      color: cat.color,
                                      minHeight: 6,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      "\$${cat.amount.toStringAsFixed(2)}  •  ${percentage.toStringAsFixed(1)}%",
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (!cat.isPredefined)
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    _deleteCategoryDialog(context, cat);
                                  },
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
            );
          },
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections(List<Category> categories, double totalSpending) {
    return categories.map((cat) {
      double   percentage = totalSpending > 0 ? (cat.amount / totalSpending) * 100 : 0;
      return PieChartSectionData(
        color: cat.color,
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
    Color selectedColor = availableColors[0];
    IconData selectedIcon = availableIcons[0];

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text("Add Category"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: "Category Name",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  decoration: InputDecoration(
                    labelText: "Amount",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                SizedBox(height: 16),
                Text("Select Color:", style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: availableColors.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() => selectedColor = availableColors[index]);
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          margin: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: availableColors[index],
                            shape: BoxShape.circle,
                            border: selectedColor == availableColors[index]
                                ? Border.all(color: Colors.black, width: 3)
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 16),
                Text("Select Icon:", style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: availableIcons.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() => selectedIcon = availableIcons[index]);
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          margin: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: selectedIcon == availableIcons[index]
                                ? selectedColor.withOpacity(0.2)
                                : Colors.grey[200],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            availableIcons[index],
                            color: selectedIcon == availableIcons[index]
                                ? selectedColor
                                : Colors.grey[600],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    double.tryParse(amountController.text) != null) {
                  final newCategory = Category(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text,
                    amount: double.parse(amountController.text),
                    colorValue: selectedColor.value,
                    iconCode: selectedIcon.codePoint,
                  );
                  HiveService.addCategory(newCategory);
                  Navigator.pop(context);
                }
              },
              child: Text("Add"),
            ),
          ],
        ),
      ),
    );
  }

  void _editCategoryDialog(BuildContext context, Category category) {
    final controller = TextEditingController(text: category.amount.toStringAsFixed(2));

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Edit ${category.name}"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: "New Amount",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final value = double.tryParse(controller.text);
              if (value != null && value >= 0) {
                HiveService.updateCategoryAmount(category.id, value);
                Navigator.pop(context);
              }
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  void _deleteCategoryDialog(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Delete Category"),
        content: Text("Are you sure you want to delete ${category.name}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              HiveService.deleteCategory(category.id);
              Navigator.pop(context);
            },
            child: Text("Delete"),
          ),
        ],
      ),
    );
  }
}


