// // views/home_view.dart
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
// import '../controllers/prompt_controller.dart';
// import '../models/prompt_model.dart';
// import 'widgets/prompt_card.dart';
// import 'widgets/search_bar.dart';
// import 'widgets/category_chips.dart';
// import 'widgets/stats_dashboard.dart';
//
// class HomeView extends StatelessWidget {
//   final PromptController controller = Get.find<PromptController>();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Row(
//           children: [
//             Icon(Icons.psychology, color: Theme.of(context).primaryColor),
//             SizedBox(width: 8),
//             Text('AI Prompt Engineering Hub'),
//           ],
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.school),
//             onPressed: () => Get.to(() => LearningHubView()),
//             tooltip: 'Learning Hub',
//           ),
//           IconButton(
//             icon: Icon(Icons.analytics),
//             onPressed: () => Get.to(() => StatsDashboard()),
//           ),
//           IconButton(
//             icon: Icon(Icons.favorite),
//             onPressed: () => _showFavorites(context),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Search and Filter Section
//           Container(
//             padding: EdgeInsets.all(16),
//             child: Column(
//               children: [
//                 CustomSearchBar(),
//                 SizedBox(height: 12),
//                 CategoryChips(),
//                 SizedBox(height: 12),
//                 _buildSortOptions(),
//               ],
//             ),
//           ),
//
//           // Prompts Grid
//           Expanded(
//             child: Obx(() {
//               if (controller.isLoading.value && controller.filteredPrompts.isEmpty) {
//                 return Center(child: CircularProgressIndicator());
//               }
//
//               return MasonryGridView.count(
//                 crossAxisCount: _getCrossAxisCount(context),
//                 itemCount: controller.filteredPrompts.length,
//                 itemBuilder: (context, index) {
//                   final prompt = controller.filteredPrompts[index];
//                   return PromptCard(prompt: prompt);
//                 },
//                 mainAxisSpacing: 8,
//                 crossAxisSpacing: 8,
//               );
//             }),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () => Get.to(() => LearningHubView()),
//         icon: Icon(Icons.school),
//         label: Text('Master AI'),
//         tooltip: 'Learn the 7 Core Benefits',
//       ),
//     );
//   }
//
//   Widget _buildBenefitsBanner() {
//     return Container(
//       margin: EdgeInsets.all(16),
//       padding: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Get.theme.primaryColor, Get.theme.primaryColor.withOpacity(0.7)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Get.theme.primaryColor.withOpacity(0.3),
//             blurRadius: 8,
//             offset: Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(Icons.auto_awesome, color: Colors.white, size: 24),
//               SizedBox(width: 8),
//               Text(
//                 'Master AI with 7 Core Benefits',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 8),
//           Text(
//             'Transform your AI interaction, enhance output quality, and unlock innovation',
//             style: TextStyle(
//               color: Colors.white.withOpacity(0.9),
//               fontSize: 14,
//             ),
//           ),
//           SizedBox(height: 12),
//           Row(
//             children: [
//               _buildBenefitChip('🚀 Better AI Interaction'),
//               SizedBox(width: 8),
//               _buildBenefitChip('⭐ Enhanced Quality'),
//               SizedBox(width: 8),
//               _buildBenefitChip('⚡ Increased Efficiency'),
//             ],
//           ),
//           SizedBox(height: 8),
//           Row(
//             children: [
//               _buildBenefitChip('🎯 Perfect Customization'),
//               SizedBox(width: 8),
//               _buildBenefitChip('🌍 Broader Applications'),
//             ],
//           ),
//           SizedBox(height: 8),
//           Row(
//             children: [
//               _buildBenefitChip('🧠 AI Limitations Mastery'),
//               SizedBox(width: 8),
//               _buildBenefitChip('💡 Innovation Unlocked'),
//             ],
//           ),
//           SizedBox(height: 12),
//           ElevatedButton(
//             onPressed: () => Get.to(() => LearningHubView()),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.white,
//               foregroundColor: Get.theme.primaryColor,
//               padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//             ),
//             child: Text('Start Learning Journey'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildBenefitChip(String text) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.2),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.white.withOpacity(0.3)),
//       ),
//       child: Text(
//         text,
//         style: TextStyle(
//           color: Colors.white,
//           fontSize: 10,
//           fontWeight: FontWeight.w500,
//         ),
//       ),
//     );
//   }
//
//   int _getCrossAxisCount(BuildContext context) {
//     final width = MediaQuery.of(context).size.width;
//     if (width > 1200) return 4;
//     if (width > 800) return 3;
//     if (width > 600) return 2;
//     return 1;
//   }
//
//   Widget _buildSortOptions() {
//     return Row(
//       children: [
//         Text('Sort by: ', style: TextStyle(fontWeight: FontWeight.w500)),
//         Expanded(
//           child: Obx(() => DropdownButton<String>(
//             value: controller.sortBy.value,
//             isExpanded: true,
//             onChanged: (value) {
//               controller.sortBy.value = value!;
//               controller.filterPrompts();
//             },
//             items: [
//               DropdownMenuItem(value: 'trending', child: Text('🔥 Trending')),
//               DropdownMenuItem(value: 'rating', child: Text('⭐ Highest Rated')),
//               DropdownMenuItem(value: 'usage', child: Text('📈 Most Used')),
//               DropdownMenuItem(value: 'complexity', child: Text('🧠 Complexity')),
//             ],
//           )),
//         ),
//       ],
//     );
//   }
//
//   void _showFavorites(BuildContext context) {
//     Get.bottomSheet(
//       Container(
//         height: Get.height * 0.8,
//         decoration: BoxDecoration(
//           color: Theme.of(context).scaffoldBackgroundColor,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//         ),
//         child: Column(
//           children: [
//             Container(
//               padding: EdgeInsets.all(16),
//               child: Row(
//                 children: [
//                   Icon(Icons.favorite, color: Colors.red),
//                   SizedBox(width: 8),
//                   Text('Favorite Prompts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                 ],
//               ),
//             ),
//             Expanded(
//               child: Obx(() => ListView.builder(
//                 itemCount: controller.favoritePrompts.length,
//                 itemBuilder: (context, index) {
//                   return PromptCard(prompt: controller.favoritePrompts[index]);
//                 },
//               )),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _showCreatePrompt(BuildContext context) {
//     // Implementation for creating new prompts
//     Get.snackbar(
//       'Coming Soon',
//       'Prompt creation feature will be available in the next update!',
//       icon: Icon(Icons.construction, color: Colors.orange),
//     );
//   }
// }
//
// // Enhanced InitialBinding to include LearningController
// class InitialBinding extends Bindings {
//   @override
//   void dependencies() {
//     Get.put(PromptController(), permanent: true);
//     Get.put(LearningController(), permanent: true);
//   }
// }
