import 'package:flutter/material.dart';
import 'package:frontend/features/search/presentation/widgets/search_empty_state.dart';
import 'package:frontend/features/search/presentation/widgets/search_filters_bar.dart';
import 'package:frontend/features/search/presentation/widgets/search_header.dart';
import 'package:frontend/features/search/presentation/widgets/search_results_view.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String searchQuery = '';
  bool isLoading = false;
  List<String> results = [];

  void onSearchChanged(String value) {
    setState(() {
      searchQuery = value;
      isLoading = true;
      // Simulate search delay
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          isLoading = false;
          results = value.isEmpty
              ? []
              : List.generate(
                  5,
                  (index) => 'Result for "$value" #${index + 1}',
                );
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // ดึง theme จาก context

    return Scaffold(
      backgroundColor:
          theme.colorScheme.background, // ใช้ theme.colorScheme.background
      appBar: AppBar(
        backgroundColor:
            theme.colorScheme.surface, // ใช้ theme.colorScheme.surface
        foregroundColor:
            theme.colorScheme.onSurface, // ใช้ theme.colorScheme.onSurface
        title: Text(
          'Search',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary, // ใช้ theme.colorScheme.primary
          ),
        ),
        elevation: 1,
        // เพิ่ม bottom เหมือน ExportPage เพื่อวาง SearchHeader
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight), // กำหนดความสูง
          child: Padding(
            padding: const EdgeInsets.all(
              8.0,
            ), // เพิ่ม padding รอบ SearchHeader
            child: SearchHeader(onChanged: onSearchChanged),
          ),
        ),
      ),
      body: Column(
        children: [
          // SearchHeader ถูกย้ายไปอยู่ bottom ของ AppBar แล้ว
          const SearchFiltersBar(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : results.isEmpty
                ? const SearchEmptyState()
                : SearchResultsView(results: results),
          ),
        ],
      ),
    );
  }
}
