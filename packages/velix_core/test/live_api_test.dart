// End-to-end contract test: drives the real repositories against a running backend.
//
//   flutter test test/live_api_test.dart \
//     --dart-define=API_BASE_URL=http://127.0.0.1:4100/api \
//     --dart-define=CUSTOMER_EMAIL=... --dart-define=CUSTOMER_PASSWORD=... \
//     --dart-define=PARTNER_EMAIL=...  --dart-define=PARTNER_PASSWORD=...
//
// Skipped unless API_BASE_URL is set. Creates real rows (a booking, a ticket, a dispute), so
// point it at a test database only.
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velix_core/velix_core.dart';

const apiBaseUrl = String.fromEnvironment('API_BASE_URL');
const customerEmail = String.fromEnvironment('CUSTOMER_EMAIL');
const customerPassword = String.fromEnvironment('CUSTOMER_PASSWORD');
const partnerEmail = String.fromEnvironment('PARTNER_EMAIL');
const partnerPassword = String.fromEnvironment('PARTNER_PASSWORD');

void main() {
  setUpAll(() {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
  });

  const skip = apiBaseUrl == '' ? 'set --dart-define=API_BASE_URL to run against a live backend' : null;
  final auth = RemoteAuthRepository();
  final fleet = RemoteFleetRepository();
  final bookings = RemoteBookingRepository();
  final payments = RemotePaymentRepository();
  final support = RemoteSupportRepository();

  test('a wrong password is rejected -- no fake session', () async {
    await expectLater(
      auth.signIn(email: customerEmail, password: 'definitely-wrong-password'),
      throwsA(isA<ApiException>().having((e) => e.statusCode, 'statusCode', 401)),
    );
    expect(await SecureStorageService().getToken(), isNull);
  }, skip: skip);

  test('customer books a car and contacts support; the partner sees and confirms the booking', () async {
    // --- partner: pick one of their own listings ---
    await auth.signIn(email: partnerEmail, password: partnerPassword);
    final ownCars = await fleet.getPartnerVehicles();
    expect(ownCars, isNotEmpty, reason: 'partner needs a listing');
    final car = ownCars.firstWhere((c) => c.locationId != null && c.pricePerDay > 0);
    await auth.signOut();

    // --- customer ---
    final customer = await auth.signIn(email: customerEmail, password: customerPassword);
    expect(customer.email, customerEmail);

    final start = DateTime.now().add(const Duration(days: 30, hours: 1));
    final end = start.add(const Duration(days: 2));
    final booking = await bookings.createBooking(car: car, pickupAt: start, dropoffAt: end, notes: 'live test');
    expect(booking.status, BookingStatus.pending);
    expect(booking.carName, car.name, reason: 'vehicle join');
    expect(
      booking.totalPrice,
      PricingService.calculatePrice(baseRatePerDay: car.pricePerDay, pickupDate: start, returnDate: end).grandTotal,
      reason: 'the summary screen must show what the server charges',
    );

    final checkout = await payments.startBookingCheckout(booking.id);
    expect(checkout.link, startsWith('http'));

    final ticket = await support.createSupportTicket(subject: 'Live test', category: 'Billing', description: 'Hello');
    expect(ticket.category, 'Billing');
    expect((await support.getMyTickets()).map((t) => t.id), contains(ticket.id));

    await support.sendSupportMessage('Live test chat');
    final chat = await support.getSupportChat(currentUserId: customer.id);
    expect(chat.last.text, 'Live test chat');
    expect(chat.last.isUser, isTrue);

    final wallet = await payments.getWallet();
    expect(wallet.currency, 'NGN');
    await auth.signOut();

    // --- partner ---
    await auth.signIn(email: partnerEmail, password: partnerPassword);
    final mine = await bookings.getMyBookings();
    expect(mine.map((b) => b.id), contains(booking.id), reason: 'partner sees bookings on their cars');

    expect((await bookings.confirmBooking(booking.id)).status, BookingStatus.confirmed);
    await auth.signOut();
  }, skip: skip);
}
