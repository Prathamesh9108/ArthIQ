import 'package:flutter/material.dart';
import 'route_names.dart';
import '../../features/splash/screens/splash_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/transactions/screens/transactions_screen.dart';
import '../../features/transactions/screens/add_transaction_screen.dart';
import '../../features/budgets/screens/budgets_screen.dart';
import '../../features/savings/screens/savings_screen.dart';
import '../../features/wallets/screens/wallets_screen.dart';
import '../../features/analytics/screens/analytics_screen.dart';
import '../../features/forecast/screens/forecast_screen.dart';
import '../../features/simulator/screens/simulator_screen.dart';
import '../../features/ai_assistant/screens/ai_assistant_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../models/transaction_model.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.splash:
        return _buildRoute(const SplashScreen(), settings);
      case RouteNames.onboarding:
        return _buildRoute(const OnboardingScreen(), settings);
      case RouteNames.login:
        return _buildRoute(const LoginScreen(), settings);
      case RouteNames.register:
        return _buildRoute(const RegisterScreen(), settings);
      case RouteNames.dashboard:
        return _buildRoute(const DashboardScreen(), settings);
      case RouteNames.transactions:
        return _buildRoute(const TransactionsScreen(), settings);
      case RouteNames.addTransaction:
      case RouteNames.editTransaction:
        final initialTx = settings.arguments as TransactionModel?;
        return _buildRoute(AddTransactionScreen(initialTransaction: initialTx), settings);
      case RouteNames.budgets:
        return _buildRoute(const BudgetsScreen(), settings);
      case RouteNames.savings:
        return _buildRoute(const SavingsScreen(), settings);
      case RouteNames.wallets:
        return _buildRoute(const WalletsScreen(), settings);
      case RouteNames.analytics:
        return _buildRoute(const AnalyticsScreen(), settings);
      case RouteNames.forecast:
        return _buildRoute(const ForecastScreen(), settings);
      case RouteNames.simulator:
        return _buildRoute(const SimulatorScreen(), settings);
      case RouteNames.aiAssistant:
        return _buildRoute(const AiAssistantScreen(), settings);
      case RouteNames.notifications:
        return _buildRoute(const NotificationsScreen(), settings);
      case RouteNames.settings:
        return _buildRoute(const SettingsScreen(), settings);
      default:
        return _buildRoute(
          Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
          settings,
        );
    }
  }

  static PageRouteBuilder _buildRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.05, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;
        final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        final fadeTween = Tween<double>(begin: 0.0, end: 1.0);

        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 250),
    );
  }
}
