import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/app_text_field.dart';

class AddBudgetDialog extends StatefulWidget {
  final List<String> existingCategories;
  final Function(String category, double limit) onSaveBudget;

  const AddBudgetDialog({
    super.key,
    required this.existingCategories,
    required this.onSaveBudget,
  });

  @override
  State<AddBudgetDialog> createState() => _AddBudgetDialogState();
}

class _AddBudgetDialogState extends State<AddBudgetDialog> {
  late String _selectedCategory;
  final _limitController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Default to first unused category, or first category
    final available = AppConstants.expenseCategories.where(
      (c) => !widget.existingCategories.contains(c),
    ).toList();

    _selectedCategory = available.isNotEmpty ? available.first : AppConstants.expenseCategories.first;
  }

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? AppColors.darkCard : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(Icons.pie_chart_outline_rounded, color: AppColors.primary, size: 24),
          const SizedBox(width: 8),
          Text(
            'Set Category Budget',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.textLightPrimary,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Category',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
              ),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              dropdownColor: isDark ? AppColors.darkCard : Colors.white,
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark ? AppColors.darkCardLight : const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              items: AppConstants.expenseCategories.map((cat) {
                return DropdownMenuItem(
                  value: cat,
                  child: Text(
                    cat,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white : AppColors.textLightPrimary,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedCategory = val);
              },
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Monthly Limit (₹)',
              hintText: 'e.g. 5000',
              controller: _limitController,
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            final limit = double.tryParse(_limitController.text.trim()) ?? 0.0;
            if (limit > 0) {
              widget.onSaveBudget(_selectedCategory, limit);
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: const Color(0xFF063326),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text('Save Budget'),
        ),
      ],
    );
  }
}
