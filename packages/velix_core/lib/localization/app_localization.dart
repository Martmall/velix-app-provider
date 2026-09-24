import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Supported language codes across the Velix platform
enum AppLanguage {
  english('en', 'English (EN)', '🇺🇸'),
  french('fr', 'Français (FR)', '🇫🇷'),
  yoruba('yo', 'Yorùbá (YO)', '🇳🇬'),
  hausa('ha', 'Hausa (HA)', '🇳🇬'),
  igbo('ig', 'Asụsụ Igbo (IG)', '🇳🇬');

  final String code;
  final String label;
  final String flag;

  const AppLanguage(this.code, this.label, this.flag);

  static AppLanguage fromCode(String code) {
    return AppLanguage.values.firstWhere(
      (lang) => lang.code == code,
      orElse: () => AppLanguage.english,
    );
  }
}

/// Global State Provider for App Language
final appLanguageProvider = StateProvider<AppLanguage>((ref) => AppLanguage.english);

/// Global State Provider for Locale
final appLocaleProvider = Provider<Locale>((ref) {
  final lang = ref.watch(appLanguageProvider);
  return Locale(lang.code);
});

/// Velix Universal Localization Translations Dictionary
class VelixLocalizations {
  final Locale locale;

  VelixLocalizations(this.locale);

  static VelixLocalizations of(BuildContext context) {
    return Localizations.of<VelixLocalizations>(context, VelixLocalizations) ??
        VelixLocalizations(const Locale('en'));
  }

  static const _localizedValues = <String, Map<String, String>>{
    'en': {
      'home': 'Home',
      'vehicles': 'Vehicles',
      'bookings': 'Bookings',
      'saved': 'Saved',
      'profile': 'Profile',
      'wallet': 'Wallet',
      'wallet_balance': 'Wallet Balance',
      'available_balance': 'Available Balance',
      'top_up': 'Top Up',
      'fund_wallet': 'Fund Wallet',
      'payment_methods': 'Payment Methods',
      'transaction_history': 'Transaction History',
      'featured_deals': 'Featured Deals',
      'see_all': 'See all',
      'browse_categories': 'Browse Categories',
      'book_now': 'Book Now',
      'book': 'Book',
      'good_day': 'Good Day',
      'ride_experience': 'Velix Ride Experience',
      'location_hint': 'Lekki Phase 1, Lagos',
      'dark_mode': 'Dark Mode',
      'language': 'Language',
      'notifications': 'Notifications',
      'help_support': 'Help & Support',
      'log_out': 'Log Out',
      'my_bookings': 'My Bookings',
      'saved_cars': 'Saved Cars',
      'switch_partner': 'Switch to Fleet Partner Mode',
      'all': 'All',
      'suvs': 'SUVs',
      'sedans': 'Sedans',
      'luxury': 'Luxury',
      'electric': 'Electric',
      'per_day': '/day',
    },
    'fr': {
      'home': 'Accueil',
      'vehicles': 'Véhicules',
      'bookings': 'Réservations',
      'saved': 'Enregistrés',
      'profile': 'Profil',
      'wallet': 'Portefeuille',
      'wallet_balance': 'Solde du portefeuille',
      'available_balance': 'Solde disponible',
      'top_up': 'Recharger',
      'fund_wallet': 'Recharger le compte',
      'payment_methods': 'Moyens de paiement',
      'transaction_history': 'Historique des transactions',
      'featured_deals': 'Offres en vedette',
      'see_all': 'Voir tout',
      'browse_categories': 'Parcourir les catégories',
      'book_now': 'Réserver maintenant',
      'book': 'Réserver',
      'good_day': 'Bonjour',
      'ride_experience': 'Expérience de conduite Velix',
      'location_hint': 'Lekki Phase 1, Lagos',
      'dark_mode': 'Mode sombre',
      'language': 'Langue',
      'notifications': 'Notifications',
      'help_support': 'Aide & Support',
      'log_out': 'Se déconnecter',
      'my_bookings': 'Mes réservations',
      'saved_cars': 'Voitures enregistrées',
      'switch_partner': 'Passer en mode partenaire',
      'all': 'Tous',
      'suvs': 'SUVs',
      'sedans': 'Berlines',
      'luxury': 'Luxe',
      'electric': 'Électrique',
      'per_day': '/jour',
    },
    'yo': {
      'home': 'Ilé',
      'vehicles': 'Awọn ọkọ',
      'bookings': 'Awọn ifiweranṣẹ',
      'saved': 'Ti fipamọ',
      'profile': 'Profaili',
      'wallet': 'Àpò owó',
      'wallet_balance': 'Iye owo inu apo',
      'available_balance': 'Owo to wa',
      'top_up': 'Fi owo kun',
      'fund_wallet': 'San owo sinu apo',
      'payment_methods': 'Ọna isanwo',
      'transaction_history': 'Itan sisanwo',
      'featured_deals': 'Awọn ipese pataki',
      'see_all': 'Wo gbogbo rẹ',
      'browse_categories': 'Wo awọn oriṣiriṣi',
      'book_now': 'Gba wọle nisisiyi',
      'book': 'Gba ọkọ',
      'good_day': 'Ẹ ku ojumo',
      'ride_experience': 'Irin-ajo Velix',
      'location_hint': 'Lekki Phase 1, Eko',
      'dark_mode': 'Ipo okunkun',
      'language': 'Ede',
      'notifications': 'Awọn ifitonileti',
      'help_support': 'Iranlọwọ & Atilẹyin',
      'log_out': 'Jade',
      'my_bookings': 'Awọn irin-ajo mi',
      'saved_cars': 'Awọn ọkọ ti mo fẹran',
      'switch_partner': 'Yipada si alabaṣiṣẹpọ',
      'all': 'Gbogbo',
      'suvs': 'SUVs',
      'sedans': 'Ọkọ ayọkẹlẹ',
      'luxury': 'Ọkọ iyebiye',
      'electric': 'Ina mọnamọna',
      'per_day': '/ọjọ',
    },
    'ha': {
      'home': 'Gida',
      'vehicles': 'Motoci',
      'bookings': 'Rikodi',
      'saved': 'Adana',
      'profile': 'Bayanin martaba',
      'wallet': 'Asusun kuɗi',
      'wallet_balance': 'Kuɗin da ke cikin asusu',
      'available_balance': 'Kuɗin da za a iya amfani da su',
      'top_up': 'Ƙara kuɗi',
      'fund_wallet': 'Sanya kuɗi a asusu',
      'payment_methods': 'Hanyoyin biyan kuɗi',
      'transaction_history': 'Tarihin ma\'amaloli',
      'featured_deals': 'Tayin na musamman',
      'see_all': 'Duba duka',
      'browse_categories': 'Bincika nau\'ikan',
      'book_now': 'Yi oda yanzu',
      'book': 'Oda',
      'good_day': 'Ina kwana',
      'ride_experience': 'Kwarewar Tafiya ta Velix',
      'location_hint': 'Lekki Phase 1, Legas',
      'dark_mode': 'Yanayin dare',
      'language': 'Harshe',
      'notifications': 'Sanarwa',
      'help_support': 'Taimako & Tallafi',
      'log_out': 'Fita',
      'my_bookings': 'Tafiye-tafiyena',
      'saved_cars': 'Motocin da aka adana',
      'switch_partner': 'Koma Yanayin Abokin Hulɗa',
      'all': 'Duka',
      'suvs': 'SUVs',
      'sedans': 'Motoci',
      'luxury': 'Motocin Alfarma',
      'electric': 'Mai aiki da wutar lantarki',
      'per_day': '/rana',
    },
    'ig': {
      'home': 'Ulo',
      'vehicles': 'Ugbo ala',
      'bookings': 'Ntinye akwukwo',
      'saved': 'Chekwaara',
      'profile': 'Profaili',
      'wallet': 'Akpa ego',
      'wallet_balance': 'Ego ole di n\'akpa',
      'available_balance': 'Ego di ugbu a',
      'top_up': 'Tinye ego',
      'fund_wallet': 'Kwuputa ego n\'akpa',
      'payment_methods': 'Uzo eji akwu ugwo',
      'transaction_history': 'Akuko ihe mere',
      'featured_deals': 'Onyinye puru iche',
      'see_all': 'Hụ ha niile',
      'browse_categories': 'Chọgharịa udi dị iche iche',
      'book_now': 'Nye iwu ugbua',
      'book': 'Nye iwu',
      'good_day': 'Nnọọ',
      'ride_experience': 'Ahụmịhe ịnya ụgbọ ala Velix',
      'location_hint': 'Lekki Phase 1, Lagos',
      'dark_mode': 'Ọnọdụ gbara ọchịchịrị',
      'language': 'Asụsụ',
      'notifications': 'Ozi mkpesa',
      'help_support': 'Enyemaka & Nkwado',
      'log_out': 'Pụọ',
      'my_bookings': 'Njem m',
      'saved_cars': 'Ụgbọ ala echekwara',
      'switch_partner': 'Gbanwee gaa na Onye Mmekọ',
      'all': 'Niile',
      'suvs': 'SUVs',
      'sedans': 'Ugbo ala nkiti',
      'luxury': 'Ugbo ala mara mma',
      'electric': 'Nke na-eji ọkụ eletrik',
      'per_day': '/ụbọchị',
    },
  };

  String tr(String key) {
    final langCode = locale.languageCode;
    return _localizedValues[langCode]?[key] ?? _localizedValues['en']?[key] ?? key;
  }
}

/// Localization Delegate
class VelixLocalizationsDelegate extends LocalizationsDelegate<VelixLocalizations> {
  const VelixLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'fr', 'yo', 'ha', 'ig'].contains(locale.languageCode);

  @override
  Future<VelixLocalizations> load(Locale locale) async {
    return VelixLocalizations(locale);
  }

  @override
  bool shouldReload(VelixLocalizationsDelegate old) => false;
}
