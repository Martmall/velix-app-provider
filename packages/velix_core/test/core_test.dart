import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:velix_core/velix_core.dart';

// Fixtures are trimmed copies of real responses captured from the backend (GET /vehicle-list,
// POST /bookings), so these tests pin the app to the actual API contract.

final vehicleJson = <String, dynamic>{
  'id': 'cmw0mxkxr001nrrusb2tuxi1o',
  'provider_id': 'cmw0mx3dd0012mmusgkxyy5f7',
  'provider_name': 'TEST - Jos Plateau Motors',
  'title': 'Hyundai Tucson 2023',
  'make': 'Hyundai',
  'model': 'Tucson',
  'year': 2023,
  'seats': 5,
  'transmission': 'automatic',
  'fuel_type': 'petrol',
  'daily_rate': 70000,
  'category': 'SUV',
  'average_rating': null,
  'review_count': 0,
  'status': 'AVAILABLE',
  'features': <dynamic>[],
  'location': {
    'id': 'cmw0mxkxp001mrrusg5xl9m81',
    'address': '30 Test Street, Jos',
    'city': 'Jos',
  },
  'images': <dynamic>[],
  'photos': <dynamic>[],
  'main_image': null,
};

final bookingJson = <String, dynamic>{
  'id': 'cmw0myadz0001u8us52q9vkqu',
  'customerId': 'cmw0mplv40001h9ussyi23xo9',
  'providerId': 'cmw0mx3dd0012mmusgkxyy5f7',
  'vehicleId': 'cmw0mxkxr001nrrusb2tuxi1o',
  'pickupLocationId': 'cmw0mxkxp001mrrusg5xl9m81',
  'pickupAt': '2026-12-01T10:00:00.000Z',
  'dropoffAt': '2026-12-04T10:00:00.000Z',
  'status': 'PENDING',
  'subtotal': 210000,
  'fee': 21000,
  'tax': 17325,
  'totalAmount': 248325,
  'depositAmount': 49665,
};

void main() {
  group('PricingService mirrors the backend calculateBookingPricing()', () {
    test('matches a real server-priced booking exactly', () {
      final b = PricingService.calculatePrice(
        baseRatePerDay: 70000,
        pickupDate: DateTime.utc(2026, 12, 1, 10),
        returnDate: DateTime.utc(2026, 12, 4, 10),
      );
      expect(b.days, 3);
      expect(b.subtotal, 210000);
      expect(b.serviceFee, 21000);
      expect(b.vat, 17325);
      expect(b.grandTotal, 248325);
      expect(b.securityDeposit, 49665);
    });

    test('a partial day counts as a whole day, minimum 1', () {
      final start = DateTime.utc(2026, 12, 1, 10);
      expect(PricingService.calculatePrice(baseRatePerDay: 1000, pickupDate: start, returnDate: start.add(const Duration(hours: 25))).days, 2);
      expect(PricingService.calculatePrice(baseRatePerDay: 1000, pickupDate: start, returnDate: start.add(const Duration(hours: 2))).days, 1);
    });

    test('never shows add-ons or discounts the backend cannot charge', () {
      final b = PricingService.calculatePrice(
        baseRatePerDay: 1000,
        pickupDate: DateTime.utc(2026, 1, 1),
        returnDate: DateTime.utc(2026, 1, 2),
      );
      expect([b.chauffeurTotal, b.childSeatTotal, b.discount], [0, 0, 0]);
    });
  });

  group('CarModel.fromJson', () {
    test('parses the backend vehicle shape, including the pickup location id', () {
      final car = CarModel.fromJson(vehicleJson);
      expect(car.id, 'cmw0mxkxr001nrrusb2tuxi1o');
      expect(car.name, 'Hyundai Tucson 2023');
      expect(car.brand, 'Hyundai');
      expect(car.pricePerDay, 70000);
      expect(car.category, 'SUV');
      expect(car.locationId, 'cmw0mxkxp001mrrusg5xl9m81');
      expect(car.location, '30 Test Street, Jos, Jos');
      expect(car.partnerName, 'TEST - Jos Plateau Motors');
      expect(car.isAvailable, isTrue);
      expect(car.transmission, 'Automatic');
    });

    test('does not invent a rating or features the partner never listed', () {
      final car = CarModel.fromJson(vehicleJson);
      expect(car.rating, 0);
      expect(car.features, isEmpty);
    });
  });

  group('BookingModel.fromJson', () {
    test('parses the backend booking shape with the server totals', () {
      final b = BookingModel.fromJson(bookingJson);
      expect(b.carId, 'cmw0mxkxr001nrrusb2tuxi1o');
      expect(b.userId, 'cmw0mplv40001h9ussyi23xo9');
      expect(b.partnerId, 'cmw0mx3dd0012mmusgkxyy5f7');
      expect(b.status, BookingStatus.pending);
      expect(b.totalPrice, 248325);
      expect(b.depositAmount, 49665);
      expect(b.startDate.toUtc(), DateTime.utc(2026, 12, 1, 10));
      expect(b.days, 3);
    });

    test('an unknown status is shown as pending, never as confirmed', () {
      final b = BookingModel.fromJson({...bookingJson, 'status': 'SOMETHING_NEW'});
      expect(b.status, BookingStatus.pending);
    });

    test('withVehicle fills the display fields from the booked car', () {
      final b = BookingModel.fromJson(bookingJson).withVehicle(CarModel.fromJson(vehicleJson));
      expect(b.carName, 'Hyundai Tucson 2023');
      expect(b.pickupLocation, '30 Test Street, Jos, Jos');
    });
  });

  group('ApiClient.parseErrorMessage', () {
    DioException withBody(dynamic data, int status) => DioException(
          requestOptions: RequestOptions(path: '/x'),
          type: DioExceptionType.badResponse,
          response: Response(requestOptions: RequestOptions(path: '/x'), statusCode: status, data: data),
        );

    test('reads the nested { error: { message } } envelope', () {
      expect(
        ApiClient.parseErrorMessage(withBody({'success': false, 'error': {'message': 'This booking has already been paid.'}}, 409)),
        'This booking has already been paid.',
      );
    });

    test('prefers the first field-level validation message', () {
      expect(
        ApiClient.parseErrorMessage(withBody({
          'message': 'Validation failed',
          'all_message': {'pickupAt': ['The pickup time cannot be in the past.']},
        }, 406)),
        'The pickup time cannot be in the past.',
      );
    });

    test('reads a bare { error: "..." } body', () {
      expect(ApiClient.parseErrorMessage(withBody({'error': 'Unauthenticated.'}, 401)), 'Unauthenticated.');
    });
  });

  group('toVehicleCategory', () {
    test('maps UI labels to backend enum values', () {
      expect(toVehicleCategory('SUV'), 'SUV');
      expect(toVehicleCategory('Van / Minibus'), 'VAN_MINIBUS');
      expect(toVehicleCategory('Luxury Cars'), 'LUXURY');
      expect(toVehicleCategory('All'), isNull);
    });
  });
}
