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
  // Abre en Welcome. Si prefieres abrir directo en login, cambia a '/auth/login'
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const WelcomePage()),
    GoRoute(path: '/auth/login', builder: (_, __) => const LoginPage()),
    GoRoute(path: '/auth/signup', builder: (_, __) => const SignupPage()),

    // 👇 Verify recibe verificationId (obligatorio) via state.extra
    GoRoute(
      path: '/auth/verify',
      builder: (_, state) {
        // Esperamos: extra = {'verificationId': String, 'phoneLabel': String?, 'forceResendToken': int?}
        final extra = state.extra as Map<String, dynamic>?;

        final verificationId = extra?['verificationId'] as String?;
        final phoneLabel = extra?['phoneLabel'] as String?;
        final forceResendToken = extra?['forceResendToken'] as int?;

        // Protección: si no vino verificationId, evita crashear
        if (verificationId == null || verificationId.isEmpty) {
          // Puedes redirigir a login o mostrar una página de error;
          // aquí devolvemos una VerifySmsPage con un id dummy para no romper navegación.
          return const VerifySmsPage(verificationId: 'DUMMY_MISSING_VERIFICATION_ID');
        }

        return VerifySmsPage(
          verificationId: verificationId,
          phoneLabel: phoneLabel,
          forceResendToken: forceResendToken,
        );
      },
    ),

    // Conductor
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
