# ArthIQ - AI-Powered Personal Finance Management

> **"Spend Smart. Save Better."**  
> *Your Money · Your Smarter Future*

ArthIQ is an AI-driven personal finance Flutter mobile application with a modern, high-contrast dark/light theme, real-time budgeting, predictive cash-flow forecasting, auto-savings guards, and interactive conversational financial insights.

---

## 📱 Application Screens & Features

The implementation covers all 16 screens and components designed in the ArthIQ specification:

1. **Splash Screen** (`features/splash/`): Animated ArthIQ emerald checkmark logo, ambient gradient aura, and automatic onboarding routing.
2. **Onboarding Carousel (Screens 1, 2, 3)** (`features/onboarding/`):
   - **Track Your Expenses Automatically**: Custom painted phone & live expense graph illustration.
   - **Build Your Savings Goals**: Custom painted piggy bank with falling golden coins.
   - **Get AI-Powered Financial Insights**: Custom painted friendly robot assistant illustration with glowing antennas and visor.
3. **Authentication (Login & Sign Up)** (`features/auth/`): Email/phone sign in, password visibility toggle, remember me checkbox, Google & Apple social sign-in, and onboarding income setup.
4. **Home Dashboard** (`features/dashboard/`):
   - Total Balance Card: ₹28,450 (`+12% from last month` green pill) with live sparkline trend.
   - Income (₹20,000), Expenses (₹14,500), and Savings (₹5,000) breakdown pills.
   - Proactive budget alert banner.
   - Spending Overview Donut Chart (Food 32%, Transport 18%, Bills 15%, Shopping 12%, Others 23%).
   - Recent Transactions feed.
   - Navigation drawer & bottom navigation bar with floating action button.
5. **Add Transaction** (`features/transactions/`): Expense/Income segmented toggle, amount input (₹450), category dropdown with icons, date picker, payment method selector (UPI, Cards, Cash), and camera/gallery receipt attachment.
6. **Transactions List** (`features/transactions/`): Category filter pills (`[All]`, `[Expenses]`, `[Income]`), live search, category icon badges, dismissible item deletion.
7. **Budgets & Rebalancing** (`features/budgets/`): Monthly budget progress (₹14,500 / 15,000, 90%), category budget progress bars, and interactive budget rebalancing modal to shift funds between categories.
8. **Savings Guard** (`features/savings/`): Total savings tracking (₹5,000 / Target ₹10,000), Emergency Fund & Dream Goal tiles, Auto-save weekly toggle (Save ₹500 every week), and milestone motivational alerts.
9. **Wallets & Net Worth** (`features/wallets/`): Aggregated net worth, HDFC Bank, SBI Bank, Cash Wallet, and Credit Cards tracking.
10. **Analytics** (`features/analytics/`): Monthly, Weekly, and Yearly timeframe filters, Expenses vs Income grouped bar chart, and category donut chart breakdown.
11. **Financial Forecast** (`features/forecast/`): Next 30 Days Estimated Balance (₹26,800), glowing trendline sparkline, and AI predicted expenses breakdown.
12. **What-If Budget Simulator** (`features/simulator/`): Interactive sliders for dining out cuts, shopping cuts, auto-save boost, and vacation scenario simulations with real-time 6-month projected savings calculation.
13. **ArthIQ Assistant (AI Chat)** (`features/ai_assistant/`): Interactive robot conversational UI, quick prompt suggestion chips (*"How much can I save?"*, *"Forecast my expenses"*, *"Find unusual spending"*), and dynamic financial advice.
14. **Notifications & Alerts** (`features/notifications/`): Budget warning notifications, goal milestone announcements, and bill reminders.
15. **Profile & Settings** (`features/settings/`): User profile header (Rahul Sharma), dark/light mode toggle, security settings, linked accounts, and session logout.
16. **Alternate Dark Mode Navigation & Design System** (`shared/`): Unified color palette tokens (`#101A2C`, `#65E6B4`, `#F4F7FB`, `#FFB86B`), custom painters, typography, buttons, text inputs, and loaders.

---

## 🏗️ Clean Project Architecture

```
mobile_app/
├── lib/
│   ├── core/
│   │   ├── config/
│   │   │   ├── app_config.dart          # App title, locales, defaults
│   │   │   └── env_config.dart          # Dev, staging, prod configurations
│   │   ├── constants/
│   │   │   ├── app_constants.dart       # Categories, colors, icons, keys
│   │   │   └── api_constants.dart       # Endpoints and network constants
│   │   ├── models/
│   │   │   ├── user_model.dart          # User profile model
│   │   │   ├── transaction_model.dart   # Transaction expense/income model
│   │   │   ├── budget_model.dart        # Budget limit model
│   │   │   └── savings_model.dart       # Savings goal and guard model
│   │   ├── network/
│   │   │   ├── api_client.dart          # HTTP client abstraction
│   │   │   └── network_exceptions.dart  # Exception definitions
│   │   ├── providers/
│   │   │   ├── theme_provider.dart      # Dark/Light theme state
│   │   │   ├── auth_provider.dart       # User authentication state
│   │   │   ├── finance_provider.dart    # Balances, transactions, budgets
│   │   │   └── ai_assistant_provider.dart# Chat messages and AI queries
│   │   ├── routing/
│   │   │   ├── route_names.dart         # Named route strings
│   │   │   └── app_router.dart          # Route generator & transitions
│   │   ├── services/
│   │   │   ├── api_service.dart         # Data fetch & mock AI queries
│   │   │   ├── auth_service.dart        # Authentication service
│   │   │   ├── notification_service.dart# Alert & notification service
│   │   │   └── sync_service.dart        # Cloud synchronization
│   │   ├── storage/
│   │   │   └── local_storage_service.dart# SharedPreferences helper
│   │   ├── theme/
│   │   │   ├── app_colors.dart          # Emerald (#65E6B4), Navy (#101A2C), etc.
│   │   │   ├── app_text_styles.dart     # Geometric sans-serif styles
│   │   │   └── app_theme.dart           # Dark and light ThemeData definitions
│   │   └── utils/
│   │       ├── currency_helper.dart     # INR currency formatters (₹)
│   │       ├── formatters.dart          # Date and percentage formatters
│   │       └── validators.dart          # Form input validation rules
│   │
│   ├── features/
│   │   ├── splash/                      # Splash screen
│   │   ├── onboarding/                  # 3-step carousel with illustrations
│   │   ├── auth/                        # Login and Registration screens
│   │   ├── dashboard/                   # Home dashboard and metric cards
│   │   ├── transactions/                # Transaction list and Add Transaction
│   │   ├── budgets/                     # Budget categories and rebalancing
│   │   ├── savings/                     # Savings Guard and goal cards
│   │   ├── wallets/                     # Bank accounts & Net Worth tracking
│   │   ├── analytics/                   # Income vs Expense and spending trends
│   │   ├── forecast/                    # 30-day balance forecast and predictions
│   │   ├── simulator/                   # What-If spending scenarios
│   │   ├── ai_assistant/                # ArthIQ AI chat assistant
│   │   ├── notifications/               # Budget alerts and bill reminders
│   │   └── settings/                    # Profile, theme switch, preferences
│   │
│   ├── shared/
│   │   ├── components/
│   │   │   └── arthiq_illustrations.dart# High-fidelity custom painted vector art
│   │   ├── dialogs/
│   │   │   ├── rebalance_budget_dialog.dart
│   │   │   └── add_goal_dialog.dart
│   │   └── widgets/
│   │       ├── primary_button.dart
│   │       ├── app_text_field.dart
│   │       ├── balance_overview_card.dart
│   │       ├── spending_donut_chart.dart
│   │       ├── income_expense_bar_chart.dart
│   │       ├── sparkline_chart.dart
│   │       ├── custom_bottom_nav.dart
│   │       ├── category_icon_badge.dart
│   │       ├── alert_banner_card.dart
│   │       └── app_loader.dart
│   │
│   └── main.dart                        # Multi-provider root entry point
├── test/
│   ├── unit_test.dart                   # Unit tests for models, providers, math
│   └── widget_test.dart                 # Smoke test and widget tree validation
└── pubspec.yaml                         # Dependencies: provider, intl, uuid, etc.
```

---

## 🚀 Running the Project

```bash
cd mobile_app
flutter run
```

To run the unit and widget test suite:
```bash
flutter test
```
