// views/widgets/
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/prompt_controller.dart';

class StatsDashboard extends StatelessWidget {
  final PromptController controller = Get.find<PromptController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prompt Engineering Analytics'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            Row(
              children: [
                Expanded(
                    child: _buildSummaryCard('Total Prompts', '190,000+',
                        Icons.psychology, Colors.blue)),
                SizedBox(width: 12),
                Expanded(
                    child: _buildSummaryCard(
                        'Categories', '10+', Icons.category, Colors.green)),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _buildSummaryCard(
                        'Avg Rating', '4.2/5.0', Icons.star, Colors.orange)),
                SizedBox(width: 12),
                Expanded(
                    child: _buildSummaryCard('Total Usage', '2.5M+',
                        Icons.trending_up, Colors.purple)),
              ],
            ),

            SizedBox(height: 24),

            // Engineering Principles Chart
            Text('Engineering Principles Distribution',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Container(
              height: 200,
              child: Obx(() => PieChart(
                    PieChartData(
                      sections: controller.engineeringPrincipleStats.entries
                          .map((entry) {
                        return PieChartSectionData(
                          value: entry.value.toDouble(),
                          title: entry.key,
                          color: _getPrincipleColor(entry.key),
                          radius: 80,
                          titleStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        );
                      }).toList(),
                      centerSpaceRadius: 40,
                    ),
                  )),
            ),

            SizedBox(height: 24),

            // Category Effectiveness
            Text('Category Effectiveness',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Container(
              height: 300,
              child: Obx(() => BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      barGroups:
                          controller.categoryEffectiveness.entries.map((entry) {
                        return BarChartGroupData(
                          x: controller.categoryEffectiveness.keys
                              .toList()
                              .indexOf(entry.key),
                          barRods: [
                            BarChartRodData(
                              toY: entry.value,
                              color: Theme.of(context).primaryColor,
                              width: 20,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        );
                      }).toList(),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final categories = controller
                                  .categoryEffectiveness.keys
                                  .toList();
                              if (value.toInt() < categories.length) {
                                return Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: Text(
                                    categories[value.toInt()].split(' ').first,
                                    style: TextStyle(fontSize: 10),
                                  ),
                                );
                              }
                              return Text('');
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(show: true),
                    ),
                  )),
            ),

            SizedBox(height: 24),

            // Prompt Engineering Best Practices
            Text('Prompt Engineering Best Practices',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            _buildBestPracticesCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            SizedBox(height: 8),
            Text(value,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(title,
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildBestPracticesCard() {
    final practices = [
      {
        'title': 'Clarity',
        'description': 'Be clear and direct to avoid confusion',
        'icon': Icons.lightbulb
      },
      {
        'title': 'Conciseness',
        'description': 'Keep prompts concise while maintaining context',
        'icon': Icons.compress
      },
      {
        'title': 'Format',
        'description': 'Align with model training for better results',
        'icon': Icons.format_align_left
      },
      {
        'title': 'Context',
        'description': 'Provide relevant context for better understanding',
        'icon': Icons.menu
      },
      {
        'title': 'Specificity',
        'description': 'Be specific about desired outcomes',
        'icon': Icons.flag
      },
    ];

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: practices
              .map(
                (practice) => ListTile(
                  leading: Icon(practice['icon'] as IconData,
                      color: Theme.of(Get.context!).primaryColor),
                  title: Text(practice['title'] as String,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(practice['description'] as String),
                  dense: true,
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Color _getPrincipleColor(String principle) {
    switch (principle) {
      case 'Clarity':
        return Colors.blue;
      case 'Conciseness':
        return Colors.green;
      case 'Format':
        return Colors.orange;
      case 'Context':
        return Colors.purple;
      case 'Specificity':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}
