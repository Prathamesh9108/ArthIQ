import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/transaction_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/providers/finance_provider.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/category_icon_badge.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionModel? initialTransaction;

  const AddTransactionScreen({super.key, this.initialTransaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  late TransactionType _type;
  late final TextEditingController _amountController;
  late final TextEditingController _titleController;
  late final TextEditingController _noteController;

  late String _selectedCategory;
  late DateTime _selectedDate;
  late String _selectedPaymentMethod;
  late bool _hasReceipt;

  bool get isEditing => widget.initialTransaction != null;

  static String normalizePaymentMethod(String method) {
    final trimmed = method.trim();
    if (AppConstants.paymentModes.contains(trimmed)) return trimmed;
    final lower = trimmed.toLowerCase();
    if (lower == 'upi' || lower.contains('upi') || lower.contains('gpay') || lower.contains('phonepe')) {
      return 'UPI (GPay / PhonePe)';
    }
    if (lower.contains('transfer') || lower.contains('net banking') || lower.contains('bank')) {
      return 'Bank Account (HDFC/SBI)';
    }
    if (lower.contains('credit')) return 'Credit Card';
    if (lower.contains('debit')) return 'Debit Card';
    if (lower.contains('cash')) return 'Cash Wallet';
    return AppConstants.paymentModes.first;
  }

  static String normalizeCategory(String category, TransactionType type) {
    final categories = type == TransactionType.expense
        ? AppConstants.expenseCategories
        : AppConstants.incomeCategories;
    if (categories.contains(category)) return category;
    final lower = category.trim().toLowerCase();
    if (type == TransactionType.expense) {
      if (lower == 'rent') return 'Rent';
      if (lower.contains('food') || lower.contains('dining')) return 'Food & Dining';
      if (lower.contains('bill') || lower.contains('util')) return 'Bills & Utilities';
    } else {
      if (lower.contains('invest') || lower.contains('dividend')) return 'Investments & Dividends';
      if (lower.contains('salary')) return 'Salary Credit';
      if (lower.contains('freelance')) return 'Freelance';
    }
    return categories.first;
  }

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final tx = widget.initialTransaction;
    if (tx != null) {
      _type = tx.type;
      _amountController = TextEditingController(
        text: tx.amount % 1 == 0 ? tx.amount.toInt().toString() : tx.amount.toString(),
      );
      _titleController = TextEditingController(text: tx.title);
      _noteController = TextEditingController(text: tx.note ?? '');
      _selectedCategory = normalizeCategory(tx.category, _type);
      _selectedDate = tx.date;
      _selectedPaymentMethod = normalizePaymentMethod(tx.paymentMethod);
      _hasReceipt = tx.receiptPath != null;
    } else {
      _type = TransactionType.expense;
      _amountController = TextEditingController();
      _titleController = TextEditingController();
      _noteController = TextEditingController();
      _selectedCategory = 'Food & Dining';
      _selectedDate = DateTime.now();
      _selectedPaymentMethod = 'UPI (GPay / PhonePe)';
      _hasReceipt = false;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (_isSaving) return;

    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    final title = _titleController.text.trim().isEmpty
        ? _selectedCategory
        : _titleController.text.trim();

    final finance = context.read<FinanceProvider>();
    setState(() => _isSaving = true);

    try {
      if (isEditing) {
        final updatedTx = widget.initialTransaction!.copyWith(
          title: title,
          amount: amount,
          type: _type,
          category: _selectedCategory,
          date: _selectedDate,
          paymentMethod: _selectedPaymentMethod,
          note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
          receiptPath: _hasReceipt ? (widget.initialTransaction!.receiptPath ?? 'receipt_mock_photo.png') : null,
        );

        final success = await finance.updateTransaction(updatedTx);
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Updated transaction "$title"'),
              backgroundColor: AppColors.primaryDark,
            ),
          );
          Navigator.pop(context, true);
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(finance.errorMessage ?? 'Failed to update transaction in database.'),
              backgroundColor: AppColors.expenseRed,
            ),
          );
        }
      } else {
        final success = await finance.addTransaction(
          title: title,
          amount: amount,
          type: _type,
          category: _selectedCategory,
          date: _selectedDate,
          paymentMethod: _selectedPaymentMethod,
          note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
          receiptPath: _hasReceipt ? 'receipt_mock_photo.png' : null,
        );

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added ${_type == TransactionType.expense ? 'Expense' : 'Income'} of ₹${amount.toStringAsFixed(0)}'),
              backgroundColor: AppColors.primaryDark,
            ),
          );
          Navigator.pop(context, true);
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(finance.errorMessage ?? 'Failed to save transaction to database.'),
              backgroundColor: AppColors.expenseRed,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categories = _type == TransactionType.expense
        ? AppConstants.expenseCategories
        : AppConstants.incomeCategories;

    if (!categories.contains(_selectedCategory)) {
      _selectedCategory = normalizeCategory(_selectedCategory, _type);
    }
    final List<String> categoriesList = categories.contains(_selectedCategory)
        ? categories
        : [_selectedCategory, ...categories];

    if (!AppConstants.paymentModes.contains(_selectedPaymentMethod)) {
      _selectedPaymentMethod = normalizePaymentMethod(_selectedPaymentMethod);
    }
    final List<String> paymentModesList = AppConstants.paymentModes.contains(_selectedPaymentMethod)
        ? AppConstants.paymentModes
        : [_selectedPaymentMethod, ...AppConstants.paymentModes];

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Transaction' : 'Add Transaction'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Expense / Income Segmented Switch
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTypeSegment(
                        'Expense',
                        _type == TransactionType.expense,
                        () => setState(() {
                          _type = TransactionType.expense;
                          _selectedCategory = 'Food & Dining';
                        }),
                      ),
                    ),
                    Expanded(
                      child: _buildTypeSegment(
                        'Income',
                        _type == TransactionType.income,
                        () => setState(() {
                          _type = TransactionType.income;
                          _selectedCategory = 'Salary Credit';
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Large Amount Input Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      '₹',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.primary : AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AppColors.textLightPrimary,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          hintText: '0',
                          fillColor: Colors.transparent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Title / Description
              AppTextField(
                label: 'Title / Payee',
                hintText: 'e.g. Swiggy, Uber, Rent',
                controller: _titleController,
                prefixIcon: const Icon(Icons.edit_note_rounded),
              ),
              const SizedBox(height: 16),

              // Category Selector
              Text(
                'Category',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    dropdownColor: isDark ? AppColors.darkCard : Colors.white,
                    items: categoriesList.map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Row(
                          children: [
                            CategoryIconBadge(category: cat, size: 34, iconSize: 18),
                            const SizedBox(width: 12),
                            Text(
                              cat,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : AppColors.textLightPrimary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCategory = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Date Picker
              Text(
                'Date',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                  }
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 18,
                            color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            AppFormatters.formatFullDate(_selectedDate),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : AppColors.textLightPrimary,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.arrow_drop_down,
                        color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Payment Method
              Text(
                'Payment Account',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedPaymentMethod,
                    isExpanded: true,
                    dropdownColor: isDark ? AppColors.darkCard : Colors.white,
                    items: paymentModesList.map((mode) {
                      return DropdownMenuItem(
                        value: mode,
                        child: Row(
                          children: [
                            const Icon(Icons.account_balance_wallet_outlined, size: 20, color: AppColors.primary),
                            const SizedBox(width: 10),
                            Text(
                              mode,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.white : AppColors.textLightPrimary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedPaymentMethod = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Add Receipt (Optional) - matching Screen 7 design
              Text(
                'Add Receipt (optional)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildReceiptButton(
                    context,
                    icon: Icons.camera_alt_outlined,
                    label: 'Camera',
                    onTap: () {
                      setState(() => _hasReceipt = true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Receipt captured and attached!')),
                      );
                    },
                  ),
                  const SizedBox(width: 14),
                  _buildReceiptButton(
                    context,
                    icon: Icons.photo_library_outlined,
                    label: 'Gallery',
                    onTap: () {
                      setState(() => _hasReceipt = true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Receipt image selected from gallery!')),
                      );
                    },
                  ),
                ],
              ),
              if (_hasReceipt) ...[
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Icon(Icons.check_circle, size: 16, color: AppColors.primary),
                    SizedBox(width: 6),
                    Text(
                      'Receipt attached (smart scanned)',
                      style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 28),

              // Save Button
              PrimaryButton(
                text: isEditing ? 'Save Changes' : 'Save',
                isLoading: _isSaving,
                onPressed: _onSave,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSegment(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isSelected ? const Color(0xFF063326) : AppColors.textDarkMuted,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.textLightPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
