// views/widgets/
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/prompt_controller.dart';

class CustomSearchBar extends StatelessWidget {
  final PromptController controller = Get.find<PromptController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) => controller.searchQuery.value = value,
        decoration: InputDecoration(
          hintText: 'Search 190K+ intelligent prompts...',
          prefixIcon: Icon(Icons.search, color: Theme.of(context).primaryColor),
          suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () => controller.searchQuery.value = '',
                )
              : Icon(Icons.mic, color: Colors.grey)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}
