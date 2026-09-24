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
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    final vehicle = json['vehicle'] is Map ? json['vehicle'] as Map<String, dynamic> : null;
    final customer = json['customer'] is Map ? json['customer'] as Map<String, dynamic> : (json['user'] is Map ? json['user'] as Map<String, dynamic> : null);

    final carId = (json['carId'] ?? json['car_id'] ?? json['vehicle_id'] ?? vehicle?['id'] ?? '').toString();
    final carName = (json['carName'] ?? json['car_name'] ?? json['vehicle_name'] ?? vehicle?['name'] ?? vehicle?['title'] ?? (vehicle != null ? '${vehicle['make'] ?? ''} ${vehicle['model'] ?? ''}'.trim() : '')).toString();
    final carImage = (json['carImage'] ?? json['car_image'] ?? json['vehicle_image'] ?? vehicle?['image_url'] ?? vehicle?['main_image'] ?? vehicle?['image'] ?? '').toString();

    final userId = (json['userId'] ?? json['user_id'] ?? json['customer_id'] ?? customer?['id'] ?? '').toString();
    final userName = (json['userName'] ?? json['user_name'] ?? json['customer_name'] ?? customer?['name'] ?? (customer != null ? '${customer['first_name'] ?? ''} ${customer['last_name'] ?? ''}'.trim() : '')).toString();
    final partnerId = (json['partnerId'] ?? json['partner_id'] ?? json['provider_id'] ?? json['vendor_id'] ?? '').toString();

    final startRaw = json['startDate'] ?? json['start_date'] ?? json['pickup_date'] ?? json['start_time'];
    final endRaw = json['endDate'] ?? json['end_date'] ?? json['return_date'] ?? json['end_time'];

    final startDate = startRaw != null ? (DateTime.tryParse(startRaw.toString()) ?? DateTime.now()) : DateTime.now();
    final endDate = endRaw != null ? (DateTime.tryParse(endRaw.toString()) ?? DateTime.now().add(const Duration(days: 1))) : DateTime.now().add(const Duration(days: 1));

    String pickup = (json['pickupLocation'] ?? json['pickup_location'] ?? json['pickup_address'] ?? '').toString();
    String dropoff = (json['dropoffLocation'] ?? json['dropoff_location'] ?? json['dropoff_address'] ?? '').toString();
    if (pickup.isEmpty) pickup = 'Lagos Pickup Location';
    if (dropoff.isEmpty) dropoff = pickup;

    final totalPrice = (json['totalPrice'] ?? json['total_price'] ?? json['total_amount'] ?? json['amount'] as num?)?.toDouble() ?? 0.0;

    final statusStr = (json['status'] ?? 'CONFIRMED').toString().toLowerCase();
    final status = BookingStatus.values.firstWhere(
      (s) => s.name.toLowerCase() == statusStr,
      orElse: () => BookingStatus.confirmed,
    );

    final paymentMethod = (json['paymentMethod'] ?? json['payment_method'] ?? 'Card Payment').toString();
    final isKeylessUnlocked = json['isKeylessUnlocked'] ?? json['is_keyless_unlocked'] ?? false;

    return BookingModel(
      id: (json['id'] ?? '').toString(),
      carId: carId,
      carName: carName.isNotEmpty ? carName : 'Velix Rental Vehicle',
      carImage: carImage,
      userId: userId,
      userName: userName.isNotEmpty ? userName : 'Velix Customer',
      partnerId: partnerId,
      startDate: startDate,
      endDate: endDate,
      pickupLocation: pickup,
      dropoffLocation: dropoff,
      totalPrice: totalPrice,
      status: status,
      paymentMethod: paymentMethod,
      isKeylessUnlocked: isKeylessUnlocked is bool ? isKeylessUnlocked : false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'carId': carId,
      'car_id': carId,
      'vehicle_id': carId,
      'carName': carName,
      'car_name': carName,
      'carImage': carImage,
      'car_image': carImage,
      'userId': userId,
      'user_id': userId,
      'customer_id': userId,
      'userName': userName,
      'user_name': userName,
      'customer_name': userName,
      'partnerId': partnerId,
      'partner_id': partnerId,
      'startDate': startDate.toIso8601String(),
      'start_date': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'pickupLocation': pickupLocation,
      'pickup_location': pickupLocation,
      'dropoffLocation': dropoffLocation,
      'dropoff_location': dropoffLocation,
      'totalPrice': totalPrice,
      'total_price': totalPrice,
      'status': status.name,
      'paymentMethod': paymentMethod,
      'payment_method': paymentMethod,
      'isKeylessUnlocked': isKeylessUnlocked,
      'is_keyless_unlocked': isKeylessUnlocked,
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
    );
  }
}
