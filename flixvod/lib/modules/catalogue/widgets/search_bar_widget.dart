import 'package:flixvod/localization/localized.dart';
import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';
import '../../../core/app_icons.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final FocusNode? focusNode;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onChanged,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppTheme.searchBarPadding,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        style: AppTheme.primaryTextStyle,
        autofocus: false,
        enableInteractiveSelection: true,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: Localized.of(context).searchMoviesAndSeries,
          hintStyle: AppTheme.mutedTextStyle,
          prefixIcon: AppIcons.search,
          filled: true,
          fillColor: AppTheme.cardBackgroundColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.mediumBorderRadius),
            borderSide: BorderSide(color: AppTheme.primaryBorderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.mediumBorderRadius),
            borderSide: BorderSide(color: AppTheme.primaryBorderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.mediumBorderRadius),
            borderSide: const BorderSide(color: AppTheme.primaryForegroundColor),
          ),
          contentPadding: AppTheme.formFieldPadding,
        ),
        onChanged: onChanged,
      ),
    );
  }
}
