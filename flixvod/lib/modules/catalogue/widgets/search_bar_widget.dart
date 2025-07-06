import 'package:flixvod/localization/localized.dart';
import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';
import '../../../core/app_icons.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppTheme.searchBarPadding,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: Localized.of(context).searchMoviesAndSeries,
          prefixIcon: AppIcons.search,
          border: const OutlineInputBorder(),
          contentPadding: AppTheme.formFieldPadding,
        ),
        onChanged: onChanged,
      ),
    );
  }
}
