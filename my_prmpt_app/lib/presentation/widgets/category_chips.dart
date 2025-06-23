// views/widgets/
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/prompt_controller.dart';

class CategoryChips extends StatelessWidget {
  final PromptController controller = Get.find<PromptController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: Obx(() => ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: controller.categories.length,
            itemBuilder: (context, index) {
              final category = controller.categories[index];
              final isSelected = controller.selectedCategory.value == category;

              return Padding(
                padding: EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    controller.selectedCategory.value = category;
                  },
                  backgroundColor: Colors.grey[100],
                  selectedColor:
                      Theme.of(context).primaryColor.withOpacity(0.2),
                  checkmarkColor: Theme.of(context).primaryColor,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey[700],
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              );
            },
          )),
    );
  }
}
