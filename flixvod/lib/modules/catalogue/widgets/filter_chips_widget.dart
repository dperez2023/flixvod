import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';

class FilterChipsWidget<T> extends StatelessWidget {
  final List<T> availableOptions;
  final T? selectedOption;
  final ValueChanged<T?> onFilterChanged;
  final String Function(BuildContext, T) getOptionLabel;
  final String allLabel;

  const FilterChipsWidget({
    super.key,
    required this.availableOptions,
    required this.selectedOption,
    required this.onFilterChanged,
    required this.getOptionLabel,
    required this.allLabel,
  });

  @override
  Widget build(BuildContext context) {
    // Don't show filter chips if there's only one option or no data
    if (availableOptions.length <= 1) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: AppTheme.standardPadding.copyWith(top: 4.0, bottom: 4.0),
      child: SizedBox(
        height: 40,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // Always show "All" filter when there are multiple options
              ChoiceChip(
                label: Text(allLabel),
                selected: selectedOption == null,
                onSelected: (selected) {
                  if (selected) {
                    onFilterChanged(null);
                  }
                },
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              AppTheme.mediumHorizontalSpacer,
              ...availableOptions.map((option) => [
                ChoiceChip(
                  label: Text(getOptionLabel(context, option)),
                  selected: selectedOption == option,
                  onSelected: (selected) {
                    if (selected) {
                      onFilterChanged(option);
                    }
                  },
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                AppTheme.mediumHorizontalSpacer,
              ]).expand((widget) => widget),
            ],
          ),
        ),
      ),
    );
  }
}
