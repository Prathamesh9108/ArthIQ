import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/config/env_config.dart';
import 'package:mobile_app/core/models/transaction_model.dart';
import 'package:mobile_app/core/providers/finance_provider.dart';
import 'package:mobile_app/core/storage/local_storage_service.dart';
import 'package:mobile_app/features/transactions/screens/add_transaction_screen.dart';
import 'package:mobile_app/features/transactions/widgets/transaction_item_tile.dart';
import 'package:mobile_app/main.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageService.initialize();
    EnvConfig.initialize(environment: Environment.development);
  });

  final testTransactions = [
    TransactionModel(
      id: 'test_tx_1',
      title: 'Swiggy Dinner',
      amount: 450.0,
      type: TransactionType.expense,
      category: 'Food & Dining',
      date: DateTime.now(),
      paymentMethod: 'UPI',
      note: 'Dinner order',
    ),
    TransactionModel(
      id: 'test_tx_2',
      title: 'Salary Credit',
      amount: 28000.0,
      type: TransactionType.income,
      category: 'Salary Credit',
      date: DateTime.now(),
      paymentMethod: 'Bank Transfer',
      note: 'Monthly salary',
    ),
  ];

  testWidgets('ArthIQ app smoke test and splash screen display', (WidgetTester tester) async {
    await tester.pumpWidget(const ArthIqApp());

    // Expect to find ArthIQ logo text and tagline
    expect(find.text('ArthIQ'), findsOneWidget);
    expect(find.text('Spend Smart. Save Better.'), findsOneWidget);

    // Let the timer and transition settle
    await tester.pumpAndSettle(const Duration(milliseconds: 2800));
  });

  testWidgets('Edit transaction screen opens for transactions without error', (WidgetTester tester) async {
    for (final tx in testTransactions) {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => FinanceProvider(autoSync: false)),
          ],
          child: MaterialApp(
            home: AddTransactionScreen(initialTransaction: tx),
          ),
        ),
      );

      expect(find.text('Edit Transaction'), findsOneWidget, reason: 'Failed for ${tx.title}');
    }
  });

  testWidgets('TransactionItemTile edit button triggers onEdit callback', (WidgetTester tester) async {
    final tx = testTransactions.first;
    bool editCalled = false;
    bool tapCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TransactionItemTile(
            transaction: tx,
            onTap: () => tapCalled = true,
            onEdit: () => editCalled = true,
          ),
        ),
      ),
    );

    // Tap the edit button
    final editButton = find.byIcon(Icons.edit_outlined);
    expect(editButton, findsOneWidget);
    await tester.tap(editButton);
    await tester.pump();

    expect(editCalled, isTrue);
    expect(tapCalled, isFalse);
  });
}
