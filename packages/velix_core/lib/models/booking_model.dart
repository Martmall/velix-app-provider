import 'car_model.dart';

enum BookingStatus {
  pending,
  confirmed,
  active,
  completed,
  cancelled,
  rejected,
}

class BookingModel {
  final String id;
  final String carId;
  final String carName;
  final String carImage;
  final String userId;
  final String userName;
  final String partnerId;
  final DateTime startDate;
  final DateTime endDate;
  final String pickupLocation;
  final String dropoffLocation;
  final double totalPrice;
  final BookingStatus status;
  final String paymentMethod;
  final bool isKeylessUnlocked;

  // Server-computed price breakdown (booking.service.ts): totalPrice = subtotal + fee + tax.
  // The deposit is a separate refundable hold, not part of totalPrice.
  final double subtotal;
  final double fee;
  final double tax;
  final double depositAmount;
  final String? pickupLocationId;
  final String? driverId;
  final String? notes;
  final String? cancellationReason;

  String get customerName => userName;

  BookingModel({
    required this.id,
    required this.carId,
    required this.carName,
    required this.carImage,
    required this.userId,
    required this.userName,
    required this.partnerId,
    required this.startDate,
    required this.endDate,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.totalPrice,
    required this.status,
    required this.paymentMethod,
    this.isKeylessUnlocked = false,
    this.subtotal = 0,
    this.fee = 0,
    this.tax = 0,
    this.depositAmount = 0,
    this.pickupLocationId,
    this.driverId,
    this.notes,
    this.cancellationReason,
  });

  /// Parses a booking from GET/POST /bookings. The backend returns only ids for the vehicle and
  /// the parties, so vehicle name/image/location are filled in afterwards by [withVehicle] (the
  /// same client-side join the web app does).
  factory BookingModel.fromJson(Map<String, dynamic> json) {
    double money(dynamic value) => value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
    DateTime date(dynamic value) => DateTime.tryParse('${value ?? ''}')?.toLocal() ?? DateTime.now();

    final statusName = (json['status'] ?? '').toString().toLowerCase();

    return BookingModel(
      id: (json['id'] ?? '').toString(),
      carId: (json['vehicleId'] ?? '').toString(),
      carName: '',
      carImage: '',
      userId: (json['customerId'] ?? '').toString(),
      userName: '',
      partnerId: (json['providerId'] ?? '').toString(),
      startDate: date(json['pickupAt']),
      endDate: date(json['dropoffAt']),
      pickupLocation: '',
      dropoffLocation: '',
      totalPrice: money(json['totalAmount']),
      // An unrecognised status is shown as pending (waiting), never as confirmed.
      status: BookingStatus.values.firstWhere((s) => s.name == statusName, orElse: () => BookingStatus.pending),
      paymentMethod: 'Flutterwave',
      subtotal: money(json['subtotal']),
      fee: money(json['fee']),
      tax: money(json['tax']),
      depositAmount: money(json['depositAmount']),
      pickupLocationId: json['pickupLocationId']?.toString(),
      driverId: json['driverId']?.toString(),
      notes: json['notes']?.toString(),
      cancellationReason: json['cancellationReason']?.toString(),
    );
  }

  /// Fills in the display fields that come from the booked vehicle.
  BookingModel withVehicle(CarModel car) => copyWith(
        carName: car.name,
        carImage: car.imageUrl,
        pickupLocation: car.location,
        dropoffLocation: car.location,
      );

  int get days {
    final hours = endDate.difference(startDate).inHours;
    return hours <= 0 ? 1 : (hours / 24).ceil();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicleId': carId,
      'customerId': userId,
      'providerId': partnerId,
      'pickupAt': startDate.toUtc().toIso8601String(),
      'dropoffAt': endDate.toUtc().toIso8601String(),
      'pickupLocationId': pickupLocationId,
      'status': status.name.toUpperCase(),
      'subtotal': subtotal,
      'fee': fee,
      'tax': tax,
      'totalAmount': totalPrice,
      'depositAmount': depositAmount,
    };
  }

  BookingModel copyWith({
    String? id,
    String? carId,
    String? carName,
    String? carImage,
    String? userId,
    String? userName,
    String? partnerId,
    DateTime? startDate,
    DateTime? endDate,
    String? pickupLocation,
    String? dropoffLocation,
    double? totalPrice,
    BookingStatus? status,
    String? paymentMethod,
    bool? isKeylessUnlocked,
    double? subtotal,
    double? fee,
    double? tax,
    double? depositAmount,
    String? pickupLocationId,
    String? driverId,
    String? notes,
    String? cancellationReason,
  }) {
    return BookingModel(
      id: id ?? this.id,
      carId: carId ?? this.carId,
      carName: carName ?? this.carName,
      carImage: carImage ?? this.carImage,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      partnerId: partnerId ?? this.partnerId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      dropoffLocation: dropoffLocation ?? this.dropoffLocation,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isKeylessUnlocked: isKeylessUnlocked ?? this.isKeylessUnlocked,
      subtotal: subtotal ?? this.subtotal,
      fee: fee ?? this.fee,
      tax: tax ?? this.tax,
      depositAmount: depositAmount ?? this.depositAmount,
      pickupLocationId: pickupLocationId ?? this.pickupLocationId,
      driverId: driverId ?? this.driverId,
      notes: notes ?? this.notes,
      cancellationReason: cancellationReason ?? this.cancellationReason,
    );
  }
}
