import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velix_core/velix_core.dart';

// Repository Providers (Live Backend & Supabase Realtime)
final authRepoProvider = Provider<IAuthRepository>((ref) => RemoteAuthRepository());
final fleetRepoProvider = Provider<IFleetRepository>((ref) => RemoteFleetRepository());
final bookingRepoProvider = Provider<IBookingRepository>((ref) => RemoteBookingRepository());
final paymentRepoProvider = Provider<IPaymentRepository>((ref) => RemotePaymentRepository());
final supportRepoProvider = Provider<ISupportRepository>((ref) => RemoteSupportRepository());
final fileUploadProvider = Provider<FileUploadService>((ref) => RemoteFileUploadService());

// Partner Auth State Notifier
class PartnerAuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  PartnerAuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  PartnerAuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return PartnerAuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class PartnerAuthNotifier extends StateNotifier<PartnerAuthState> {
  final IAuthRepository _repository;
  PartnerAuthNotifier(this._repository) : super(PartnerAuthState()) {
    _init();
  }

  Future<void> _init() async {
    final currentUser = await _repository.getCurrentUser();
    if (currentUser != null) {
      state = state.copyWith(user: currentUser, isAuthenticated: true);
    }
  }

  Future<bool> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _repository.signIn(email: email, password: password);
      state = state.copyWith(user: user, isLoading: false, isAuthenticated: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _repository.registerUser(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
        role: UserRole.partner,
      );
      state = state.copyWith(user: user, isLoading: false, isAuthenticated: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void updateUser(UserModel updatedUser) {
    state = state.copyWith(user: updatedUser);
    _repository.updateProfile(
      fullName: updatedUser.fullName,
      phone: updatedUser.phone,
      avatarUrl: updatedUser.avatarUrl,
      bankName: updatedUser.bankName,
      bankAccount: updatedUser.accountNumber,
      cacNumber: updatedUser.cacNumber,
      businessName: updatedUser.businessName,
    );
  }

  void updatePersonalDetails({required String fullName, required String email, required String phone, String? avatarUrl}) {
    if (state.user != null) {
      final updated = state.user!.copyWith(
        fullName: fullName,
        email: email,
        phone: phone,
        avatarUrl: avatarUrl ?? state.user!.avatarUrl,
      );
      state = state.copyWith(user: updated);
      _repository.updateProfile(
        fullName: fullName,
        phone: phone,
        avatarUrl: avatarUrl ?? state.user!.avatarUrl,
      );
    }
  }

  void updateBankDetails({
    required String bankName,
    required String accountNumber,
    required String accountName,
  }) {
    if (state.user != null) {
      final updated = state.user!.copyWith(
        bankName: bankName,
        accountNumber: accountNumber,
        accountName: accountName,
        isBankVerified: true,
      );
      state = state.copyWith(user: updated);
      _repository.updateProfile(
        bankName: bankName,
        bankAccount: accountNumber,
      );
    }
  }

  void updateBusinessDetails({
    required String businessName,
    required String cacNumber,
    required String cacDocumentUrl,
  }) {
    if (state.user != null) {
      final updated = state.user!.copyWith(
        businessName: businessName,
        cacNumber: cacNumber,
        cacDocumentUrl: cacDocumentUrl,
        cacStatus: 'pending',
      );
      state = state.copyWith(user: updated);
      _repository.updateProfile(
        businessName: businessName,
        cacNumber: cacNumber,
      );
    }
  }

  Future<bool> requestPayout({
    required double amount,
    required String bankName,
    required String accountNumber,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      if (state.user != null) {
        await _repository.updateProfile(
          bankName: bankName,
          bankAccount: accountNumber,
        );
      }
      state = state.copyWith(isLoading: false);
      return true;
    } catch (_) {
      state = state.copyWith(isLoading: false);
      return true;
    }
  }

  Future<void> signOut() async {
    await _repository.signOut();
    state = PartnerAuthState();
  }
}

final partnerAuthProvider = StateNotifierProvider<PartnerAuthNotifier, PartnerAuthState>((ref) {
  return PartnerAuthNotifier(ref.watch(authRepoProvider));
});

// Partner Fleet Provider (Real-time Supabase Stream)
final partnerFleetProvider = StreamProvider<List<CarModel>>((ref) {
  final repo = ref.watch(fleetRepoProvider);
  final auth = ref.watch(partnerAuthProvider);
  final partnerId = auth.user?.id;
  if (partnerId == null || partnerId.isEmpty) {
    return Stream.value(<CarModel>[]);
  }
  return repo.streamPartnerVehicles(partnerId);
});

// Partner Bookings Provider (Real-time Supabase Stream)
final partnerBookingsProvider = StreamProvider<List<BookingModel>>((ref) {
  final repo = ref.watch(bookingRepoProvider);
  final auth = ref.watch(partnerAuthProvider);
  final partnerId = auth.user?.id;
  if (partnerId == null || partnerId.isEmpty) {
    return Stream.value(<BookingModel>[]);
  }
  return repo.streamPartnerBookings(partnerId);
});

// Partner Wallet & Earnings Provider
final partnerWalletProvider = StreamProvider<List<WalletTransactionModel>>((ref) async* {
  final repo = ref.watch(paymentRepoProvider);
  yield await repo.getWalletTransactions();
});

