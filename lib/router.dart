import 'package:go_router/go_router.dart';

import 'features/welcome/presentation/pages/welcome_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/signup.dart';
import 'features/auth/presentation/pages/verify_sms_page.dart';

import 'features/driver/presentation/pages/driver_home_page.dart';
import 'features/driver/presentation/pages/register_nfc_page.dart';
import 'features/driver/presentation/pages/nfc_validate_page.dart';
import 'features/driver/presentation/pages/payment_success_page.dart';
import 'features/driver/presentation/pages/payment_fail_page.dart';
import 'features/driver/presentation/pages/history_page.dart';
import 'features/driver/domain/models.dart';

final router = GoRouter(
  initialLocation: '/driver', // cambia a '/' si quieres abrir en Welcome
  routes: [
    GoRoute(path: '/', builder: (_, __) => const WelcomePage()),
    GoRoute(path: '/auth/login', builder: (_, __) => const LoginPage()),
    GoRoute(path: '/auth/signup', builder: (_, __) => const SignupPage()),
    GoRoute(path: '/auth/verify', builder: (_, __) => const VerifySmsPage()),

    GoRoute(path: '/driver', builder: (_, __) => const DriverHomePage()),
    GoRoute(path: '/driver/register-nfc', builder: (_, __) => const RegisterNfcPage()),
    GoRoute(path: '/driver/validate/nfc', builder: (_, __) => const NfcValidatePage()),
    GoRoute(
      path: '/driver/success',
      builder: (context, state) => PaymentSuccessPage(
        result: state.extra is PaymentResult ? state.extra as PaymentResult : null,
      ),
    ),
    GoRoute(
      path: '/driver/fail',
      builder: (context, state) => PaymentFailPage(
        result: state.extra is PaymentResult ? state.extra as PaymentResult : null,
      ),
    ),
    GoRoute(path: '/driver/history', builder: (_, __) => const HistoryPage()),
  ],
);
