import 'package:flutter/material.dart';
import 'session.dart';
import '../models/user_role.dart';

// Screens imports
import '../screens/splash/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/auth/welcome/welcome_screen.dart';
import '../screens/auth/login/login_screen.dart';
import '../screens/auth/signup/signup_screen.dart';
import '../screens/auth/otp/otp_screen.dart';
import '../screens/auth/profile_setup/profile_setup_screen.dart';

// Customer Screens
import '../screens/customer/customer_home_screen.dart';
import '../screens/customer/customer_search_screen.dart';
import '../screens/customer/customer_filters_screen.dart';
import '../screens/customer/customer_details_screen.dart';
import '../screens/customer/customer_booking_screen.dart';
import '../screens/customer/customer_charging_screen.dart';
import '../screens/customer/customer_payment_screen.dart';
import '../screens/customer/customer_review_screen.dart';
import '../screens/customer/customer_profile_screen.dart';
import '../screens/customer/charging_history_screen.dart';
import '../screens/customer/saved_chargers_screen.dart';
import '../screens/customer/notifications_screen.dart';
import '../screens/customer/settings_screen.dart';
import '../screens/customer/help_support_screen.dart';
import '../screens/customer/scan_pay_screen.dart';
import '../screens/customer/bundles_screen.dart';
import '../screens/customer/emergency_services_screen.dart';
import '../screens/customer/edit_profile_screen.dart';
import '../screens/customer/change_password_screen.dart';
import '../screens/customer/terms_screen.dart';
import '../screens/customer/privacy_screen.dart';
import '../screens/customer/charger_map_screen.dart';

// Provider Screens
import '../screens/provider/provider_home_screen.dart';
import '../screens/provider/provider_requests_screen.dart';
import '../screens/provider/provider_session_screen.dart';
import '../screens/provider/provider_earnings_screen.dart';
import '../screens/provider/provider_performance_screen.dart';
import '../screens/provider/provider_chargers_screen.dart';
import '../screens/provider/provider_business_screen.dart';
import '../screens/provider/provider_availability_screen.dart';
import '../screens/provider/provider_withdraw_screen.dart';
import '../screens/provider/bank_payout_screen.dart';
import '../screens/provider/provider_documents_screen.dart';
import '../screens/provider/provider_settings_screen.dart';
import '../screens/provider/provider_help_support_screen.dart';
import '../screens/provider/edit_business_profile_screen.dart';

// Admin Screens
import '../screens/admin/admin_login_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/admin_users_screen.dart';
import '../screens/admin/admin_providers_screen.dart';
import '../screens/admin/admin_chargers_screen.dart';
import '../screens/admin/admin_sessions_screen.dart';
import '../screens/admin/admin_revenue_screen.dart';
import '../screens/admin/admin_settings_screen.dart';
import '../screens/admin/admin_transactions_screen.dart';
import '../screens/admin/admin_reports_screen.dart';
import '../screens/admin/admin_edit_profile_screen.dart';
import '../screens/admin/admin_change_password_screen.dart';

class AppRoutes {
  AppRoutes._();

  // Public
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String otp = '/otp';
  static const String profileSetup = '/profile-setup';

  // Customer
  static const String customerHome = '/customer/home';
  static const String customerSearch = '/customer/search';
  static const String customerFilters = '/customer/filters';
  static const String customerDetails = '/customer/details';
  static const String customerBooking = '/customer/booking';
  static const String customerCharging = '/customer/charging';
  static const String customerPayment = '/customer/payment';
  static const String customerReview = '/customer/review';
  static const String customerProfile = '/customer/profile';
  static const String customerChargingHistory = '/customer/charging-history';
  static const String customerSavedChargers = '/customer/saved-chargers';
  static const String customerNotifications = '/customer/notifications';
  static const String customerSettings = '/customer/settings';
  static const String customerHelpSupport = '/customer/help-support';
  static const String customerScanPay = '/customer/scan-pay';
  static const String customerBundles = '/customer/bundles';
  static const String customerEmergency = '/customer/emergency';
  static const String customerEditProfile = '/customer/edit-profile';
  static const String customerChangePassword = '/customer/change-password';
  static const String customerTerms = '/customer/terms';
  static const String customerPrivacy = '/customer/privacy';
  static const String chargerMap = '/customer/map';

  // Provider
  static const String providerHome = '/provider/home';
  static const String providerRequests = '/provider/requests';
  static const String providerSession = '/provider/session';
  static const String providerEarnings = '/provider/earnings';
  static const String providerPerformance = '/provider/performance';
  static const String providerChargers = '/provider/chargers';
  static const String providerBusiness = '/provider/business';
  static const String providerAvailability = '/provider/availability';
  static const String providerWithdraw = '/provider/withdraw';
  static const String providerBankPayout = '/provider/bank-payout';
  static const String providerDocuments = '/provider/documents';
  static const String providerSettings = '/provider/settings';
  static const String providerHelpSupport = '/provider/help-support';
  static const String providerEditBusinessProfile = '/provider/edit-business-profile';

  // Admin
  static const String adminLogin = '/admin/login';
  static const String adminDashboard = '/admin/dashboard';
  static const String adminUsers = '/admin/users';
  static const String adminProviders = '/admin/providers';
  static const String adminChargers = '/admin/chargers';
  static const String adminSessions = '/admin/sessions';
  static const String adminRevenue = '/admin/revenue';
  static const String adminTransactions = '/admin/transactions';
  static const String adminReports = '/admin/reports';
  static const String adminSettings = '/admin/settings';
  static const String adminEditProfile = '/admin/edit-profile';
  static const String adminChangePassword = '/admin/change-password';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final String? routeName = settings.name;
    final Object? arguments = settings.arguments;

    Widget screen;

    // Route guard logic
    final session = VolteraSession();

    if (routeName != null && routeName.startsWith('/customer/')) {
      if (!session.isAuthenticated) {
        screen = const LoginScreen();
      } else if (!session.hasRole(UserRole.customer)) {
        screen = _getHomeForRole(session.activeRole);
      } else {
        session.activeRole = UserRole.customer;
        screen = _getCustomerScreen(routeName);
      }
    } else if (routeName != null && routeName.startsWith('/provider/')) {
      if (!session.isAuthenticated) {
        screen = const LoginScreen();
      } else if (!session.hasRole(UserRole.provider)) {
        screen = _getHomeForRole(session.activeRole);
      } else {
        session.activeRole = UserRole.provider;
        screen = _getProviderScreen(routeName);
      }
    } else if (routeName != null && routeName.startsWith('/admin/')) {
      if (routeName == adminLogin) {
        screen = const AdminLoginScreen();
      } else {
        if (!session.isAuthenticated) {
          screen = const AdminLoginScreen();
        } else if (session.activeRole != UserRole.admin) {
          screen = _getHomeForRole(session.activeRole);
        } else {
          screen = _getAdminScreen(routeName);
        }
      }
    } else {
      // Public routes
      switch (routeName) {
        case splash:
          screen = const SplashScreen();
          break;
        case onboarding:
          screen = const OnboardingScreen();
          break;
        case welcome:
          screen = const WelcomeScreen();
          break;
        case login:
          screen = const LoginScreen();
          break;
        case signup:
          screen = const SignupScreen();
          break;
        case otp:
          screen = const OtpScreen();
          break;
        case profileSetup:
          screen = const ProfileSetupScreen();
          break;
        default:
          screen = const SplashScreen();
      }
    }

    return MaterialPageRoute(
      builder: (context) => screen,
      settings: RouteSettings(name: routeName, arguments: arguments),
    );
  }

  static Widget _getHomeForRole(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return const CustomerHomeScreen();
      case UserRole.provider:
        return const ProviderHomeScreen();
      case UserRole.admin:
        return const AdminDashboardScreen();
    }
  }

  static Widget _getCustomerScreen(String routeName) {
    switch (routeName) {
      case customerHome:
        return const CustomerHomeScreen();
      case customerSearch:
        return const CustomerSearchScreen();
      case customerFilters:
        return const CustomerFiltersScreen();
      case customerDetails:
        return const CustomerDetailsScreen();
      case customerBooking:
        return const CustomerBookingScreen();
      case customerCharging:
        return const CustomerChargingScreen();
      case customerPayment:
        return const CustomerPaymentScreen();
      case customerReview:
        return const CustomerReviewScreen();
      case customerProfile:
        return const CustomerProfileScreen();
      case customerChargingHistory:
        return const ChargingHistoryScreen();
      case customerSavedChargers:
        return const SavedChargersScreen();
      case customerNotifications:
        return const NotificationsScreen();
      case customerSettings:
        return const SettingsScreen();
      case customerHelpSupport:
        return const HelpSupportScreen();
      case customerScanPay:
        return const ScanPayScreen();
      case customerBundles:
        return const BundlesScreen();
      case customerEmergency:
        return const EmergencyServicesScreen();
      case customerEditProfile:
        return const EditProfileScreen();
      case customerChangePassword:
        return const ChangePasswordScreen();
      case customerTerms:
        return const TermsScreen();
      case customerPrivacy:
        return const PrivacyScreen();
      case chargerMap:
        return const ChargerMapScreen();
      default:
        return const CustomerHomeScreen();
    }
  }

  static Widget _getProviderScreen(String routeName) {
    switch (routeName) {
      case providerHome:
        return const ProviderHomeScreen();
      case providerRequests:
        return const ProviderRequestsScreen();
      case providerSession:
        return const ProviderSessionScreen();
      case providerEarnings:
        return const ProviderEarningsScreen();
      case providerPerformance:
        return const ProviderPerformanceScreen();
      case providerChargers:
        return const ProviderChargersScreen();
      case providerBusiness:
        return const ProviderBusinessScreen();
      case providerAvailability:
        return const ProviderAvailabilityScreen();
      case providerWithdraw:
        return const ProviderWithdrawScreen();
      case providerBankPayout:
        return const BankPayoutScreen();
      case providerDocuments:
        return const ProviderDocumentsScreen();
      case providerSettings:
        return const ProviderSettingsScreen();
      case providerHelpSupport:
        return const ProviderHelpSupportScreen();
      case providerEditBusinessProfile:
        return const EditBusinessProfileScreen();
      default:
        return const ProviderHomeScreen();
    }
  }

  static Widget _getAdminScreen(String routeName) {
    switch (routeName) {
      case adminDashboard:
        return const AdminDashboardScreen();
      case adminUsers:
        return const AdminUsersScreen();
      case adminProviders:
        return const AdminProvidersScreen();
      case adminChargers:
        return const AdminChargersScreen();
      case adminSessions:
        return const AdminSessionsScreen();
      case adminRevenue:
        return const AdminRevenueScreen();
      case adminTransactions:
        return const AdminTransactionsScreen();
      case adminReports:
        return const AdminReportsScreen();
      case adminSettings:
        return const AdminSettingsScreen();
      case adminEditProfile:
        return const AdminEditProfileScreen();
      case adminChangePassword:
        return const AdminChangePasswordScreen();
      default:
        return const AdminDashboardScreen();
    }
  }
}
