import 'package:go_router/go_router.dart';
import '../../features/vendor_onboarding/vendor_onboarding1_screen.dart';
import '../../features/vendor_onboarding/vendor_onboarding2_screen.dart';
import '../../features/vendor_onboarding/vendor_onboarding3_screen.dart';
import '../../features/vendor_onboarding/vendor_onboarding4_screen.dart';
import '../../features/auth/partner_sign_in_screen.dart';
import '../../features/auth/create_account_screen.dart';
import '../../features/auth/partner_otp_verification_screen.dart';
import '../../features/auth/partner_set_up_screen.dart';
import '../../features/dashboard/partner_home_screen.dart';
import '../../features/dashboard/my_vehicles_screen.dart';
import '../../features/dashboard/add_vehicle_screen.dart';
import '../../features/bookings/partner_bookings_screen.dart';
import '../../features/bookings/verify_pickup1_screen.dart';
import '../../features/bookings/verify_pickup2_screen.dart';
import '../../features/bookings/partner_trip_updates_screen.dart';
import '../../features/bookings/verify_return1_screen.dart';
import '../../features/bookings/verify_return2_screen.dart';
import '../../features/finance/earnings_screen.dart';
import '../../features/finance/support_disputes_screen.dart';
import 'package:velix_core/velix_core.dart';
import '../../features/profile/partner_profile_screen.dart';
import '../../features/dev_preview_screen.dart';
import 'routes.dart';

final GoRouter partnerAppRouter = GoRouter(
  initialLocation: AppRoutes.vendorOnboarding1,
  routes: [
    GoRoute(path: AppRoutes.devPreview, builder: (context, state) => const DevPreviewScreen()),
    GoRoute(path: AppRoutes.vendorOnboarding1, builder: (context, state) => const VendorOnboarding1Screen()),
    GoRoute(path: AppRoutes.vendorOnboarding2, builder: (context, state) => const VendorOnboarding2Screen()),
    GoRoute(path: AppRoutes.vendorOnboarding3, builder: (context, state) => const VendorOnboarding3Screen()),
    GoRoute(path: AppRoutes.vendorOnboarding4, builder: (context, state) => const VendorOnboarding4Screen()),
    
    GoRoute(path: AppRoutes.partnerSignIn, builder: (context, state) => const PartnerSignInScreen()),
    GoRoute(path: AppRoutes.createAccount, builder: (context, state) => const CreateAccountScreen()),
    GoRoute(
      path: AppRoutes.otpVerification,
      builder: (context, state) => PartnerOtpVerificationScreen(
        phoneNumber: state.extra as String?,
      ),
    ),
    GoRoute(path: AppRoutes.partnerSetUp, builder: (context, state) => const PartnerSetUpScreen()),
    
    GoRoute(path: AppRoutes.partnerHome, builder: (context, state) => const PartnerHomeScreen()),
    GoRoute(path: AppRoutes.myVehicles, builder: (context, state) => const MyVehiclesScreen()),
    GoRoute(
      path: AppRoutes.addVehicle,
      builder: (context, state) => AddVehicleScreen(
        initialCar: state.extra is CarModel ? state.extra as CarModel : null,
      ),
    ),
    
    GoRoute(path: AppRoutes.partnerBookings, builder: (context, state) => const PartnerBookingsScreen()),
    GoRoute(path: AppRoutes.verifyPickup1, builder: (context, state) => const VerifyPickup1Screen()),
    GoRoute(
      path: AppRoutes.verifyPickup2,
      builder: (context, state) => VerifyPickup2Screen(
        booking: state.extra is BookingModel ? state.extra as BookingModel : null,
      ),
    ),
    GoRoute(path: AppRoutes.partnerTripUpdates, builder: (context, state) => const PartnerTripUpdatesScreen()),
    GoRoute(path: AppRoutes.verifyReturn1, builder: (context, state) => const VerifyReturn1Screen()),
    GoRoute(
      path: AppRoutes.verifyReturn2,
      builder: (context, state) => VerifyReturn2Screen(
        booking: state.extra is BookingModel ? state.extra as BookingModel : null,
      ),
    ),
    
    GoRoute(path: AppRoutes.earnings, builder: (context, state) => const EarningsScreen()),
    GoRoute(path: AppRoutes.supportDisputes, builder: (context, state) => const SupportDisputesScreen()),
    GoRoute(path: AppRoutes.partnerProfile, builder: (context, state) => const PartnerProfileScreen()),
  ],
);
