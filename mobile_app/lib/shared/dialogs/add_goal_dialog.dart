import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/app_text_field.dart';

class AddGoalDialog extends StatefulWidget {
  final Function(String title, double targetAmount, double initialAmount, String iconType) onAddGoal;

  const AddGoalDialog({super.key, required this.onAddGoal});

  @override
  State<AddGoalDialog> createState() => _AddGoalDialogState();
}

class _AddGoalDialogState extends State<AddGoalDialog> {
  final _titleController = TextEditingController();
  final _targetController = TextEditingController();
  final _initialController = TextEditingController();
  final String _selectedIcon = 'emergency';

  @override
  void dispose() {
    _titleController.dispose();
    _targetController.dispose();
    _initialController.dispose();
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
          const Icon(Icons.stars_rounded, color: AppColors.primary, size: 24),
          const SizedBox(width: 8),
          Text(
            'New Savings Goal',
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
          children: [
            AppTextField(
              label: 'Goal Name',
              hintText: 'e.g. New Laptop, Vacation',
              controller: _titleController,
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Target Amount (₹)',
              hintText: 'e.g. 50000',
              controller: _targetController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Initial Deposit (Optional)',
              hintText: 'e.g. 2000',
              controller: _initialController,
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
            final title = _titleController.text.trim();
            final target = double.tryParse(_targetController.text) ?? 0.0;
            final initial = double.tryParse(_initialController.text) ?? 0.0;
            if (title.isNotEmpty && target > 0) {
              widget.onAddGoal(title, target, initial, _selectedIcon);
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: const Color(0xFF063326),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text('Create Goal'),
        ),
      ],
    );
  }
}
