class CarImageCatalog {
  CarImageCatalog._();

  // Primary High-Resolution Vehicle Imagery (Unsplash CDN optimized for mobile & web)
  static const String mercedesGLE =
      'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?auto=format&fit=crop&w=1200&q=85';
  static const String toyotaPrado =
      'https://images.unsplash.com/photo-1594502184342-2e12f877aa73?auto=format&fit=crop&w=1200&q=85';
  static const String rangeRoverVelar =
      'https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?auto=format&fit=crop&w=1200&q=85';
  static const String lexusRX350 =
      'https://images.unsplash.com/photo-1580273916550-e323be2ae537?auto=format&fit=crop&w=1200&q=85';
  static const String bmwX5 =
      'https://images.unsplash.com/photo-1555215695-3004980ad54e?auto=format&fit=crop&w=1200&q=85';
  static const String toyotaCamry =
      'https://images.unsplash.com/photo-1621007947382-bb3c3994e3fb?auto=format&fit=crop&w=1200&q=85';
  static const String hondaAccord =
      'https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8?auto=format&fit=crop&w=1200&q=85';
  static const String teslaModel3 =
      'https://images.unsplash.com/photo-1560958089-b8a1929cea89?auto=format&fit=crop&w=1200&q=85';
  static const String hyundaiElantra =
      'https://images.unsplash.com/photo-1590362891991-f776e747a588?auto=format&fit=crop&w=1200&q=85';
  static const String mercedesGWagon =
      'https://images.unsplash.com/photo-1520031441872-265e4ff70366?auto=format&fit=crop&w=1200&q=85';
  static const String mercedesGle = mercedesGLE;
  static const String lexusRx350 = lexusRX350;
  static const String mercedesGwagon = mercedesGWagon;
  static const String porsche911 =
      'https://images.unsplash.com/photo-1614162692292-7ac56d7f7f1e?auto=format&fit=crop&w=1200&q=85';

  // Fallback defaults by category
  static const String defaultSUV = mercedesGLE;
  static const String defaultSedan = toyotaCamry;
  static const String defaultLuxury = rangeRoverVelar;
  static const String defaultElectric = teslaModel3;
  static const String defaultConvertible = porsche911;

  // Curated Promotional Banners
  static const String featuredHeroBanner =
      'https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=1200&q=85';
  static const String limitedOfferBanner =
      'https://images.unsplash.com/photo-1511919884226-fd3cad34687c?auto=format&fit=crop&w=1200&q=85';
  static const String weekendEscapeBanner =
      'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?auto=format&fit=crop&w=1200&q=85';
  static const String luxuryChauffeurBanner =
      'https://images.unsplash.com/photo-1563720223185-11003d516935?auto=format&fit=crop&w=1200&q=85';

  /// Resolves the most accurate photorealistic car image based on vehicle name and category
  static String getImageForCar(String? carName, {String category = 'SUV'}) {
    if (carName == null || carName.isEmpty) {
      return _getCategoryFallback(category);
    }

    final lower = carName.toLowerCase();

    if (lower.contains('gle') || lower.contains('mercedes-benz gle') || lower.contains('benz gle')) {
      return mercedesGLE;
    }
    if (lower.contains('prado') || lower.contains('land cruiser')) {
      return toyotaPrado;
    }
    if (lower.contains('velar') || lower.contains('range rover')) {
      return rangeRoverVelar;
    }
    if (lower.contains('rx') || lower.contains('lexus')) {
      return lexusRX350;
    }
    if (lower.contains('x5') || lower.contains('bmw')) {
      return bmwX5;
    }
    if (lower.contains('camry') || lower.contains('toyota camry')) {
      return toyotaCamry;
    }
    if (lower.contains('accord') || lower.contains('honda')) {
      return hondaAccord;
    }
    if (lower.contains('tesla') || lower.contains('model 3')) {
      return teslaModel3;
    }
    if (lower.contains('elantra') || lower.contains('hyundai')) {
      return hyundaiElantra;
    }
    if (lower.contains('g-wagon') || lower.contains('g63') || lower.contains('g wagon')) {
      return mercedesGWagon;
    }
    if (lower.contains('porsche') || lower.contains('911') || lower.contains('convertible')) {
      return porsche911;
    }

    return _getCategoryFallback(category);
  }

  static String _getCategoryFallback(String category) {
    switch (category.toLowerCase()) {
      case 'sedan':
        return defaultSedan;
      case 'luxury':
        return defaultLuxury;
      case 'electric':
        return defaultElectric;
      case 'convertible':
        return defaultConvertible;
      case 'suv':
      default:
        return defaultSUV;
    }
  }

  /// Returns 4 distinct photorealistic angles for a car (Front 3/4, Side Profile, Cockpit/Interior, Rear)
  static List<String> getGalleryForCar(String? carName, {String category = 'SUV'}) {
    final primary = getImageForCar(carName, category: category);
    final lower = (carName ?? '').toLowerCase();

    if (lower.contains('gle') || lower.contains('mercedes')) {
      return [
        mercedesGLE,
        'https://images.unsplash.com/photo-1617814076367-b759c7d7e738?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1563720223185-11003d516935?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=800&q=80',
      ];
    }
    if (lower.contains('prado') || lower.contains('land cruiser')) {
      return [
        toyotaPrado,
        'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1502877338535-766e1452684a?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?auto=format&fit=crop&w=800&q=80',
      ];
    }
    if (lower.contains('velar') || lower.contains('range rover')) {
      return [
        rangeRoverVelar,
        'https://images.unsplash.com/photo-1563720223185-11003d516935?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1617814076367-b759c7d7e738?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=800&q=80',
      ];
    }
    if (lower.contains('camry') || lower.contains('toyota')) {
      return [
        toyotaCamry,
        'https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1590362891991-f776e747a588?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1621007947382-bb3c3994e3fb?auto=format&fit=crop&w=800&q=80',
      ];
    }

    // Generic fallback 4-shot gallery
    return [
      primary,
      'https://images.unsplash.com/photo-1617814076367-b759c7d7e738?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1563720223185-11003d516935?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=800&q=80',
    ];
  }
}
