import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velix_core/velix_core.dart';

// Repository Providers (live backend REST API)
final authRepoProvider = Provider<IAuthRepository>((ref) => RemoteAuthRepository());
final fleetRepoProvider = Provider<IFleetRepository>((ref) => RemoteFleetRepository());
final bookingRepoProvider = Provider<IBookingRepository>((ref) => RemoteBookingRepository());
final paymentRepoProvider = Provider<IPaymentRepository>((ref) => RemotePaymentRepository());
final supportRepoProvider = Provider<ISupportRepository>((ref) => RemoteSupportRepository());

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

/// Every method reports failure via its return value and [PartnerAuthState.error] (the
/// server's own message). Nothing is updated locally unless the server accepted it.
class PartnerAuthNotifier extends StateNotifier<PartnerAuthState> {
  final IAuthRepository _repository;
  final IPaymentRepository _payments;
  StreamSubscription<void>? _expiry;

  PartnerAuthNotifier(this._repository, this._payments) : super(PartnerAuthState()) {
    _expiry = ApiClient().onSessionExpired.listen((_) => state = PartnerAuthState());
    _init();
  }

  @override
  void dispose() {
    _expiry?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    try {
      final currentUser = await _repository.getCurrentUser();
      if (currentUser != null) {
        state = state.copyWith(user: currentUser, isAuthenticated: true);
      }
    } catch (_) {
      // Offline at launch: stay signed out in the UI; the stored session is kept for next time.
    }
  }

  Future<bool> _run(Future<void> Function() call, {bool refreshUser = false}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await call();
      final user = refreshUser ? await _repository.getCurrentUser(refresh: true) : state.user;
      state = state.copyWith(user: user, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: ApiClient.parseErrorMessage(e));
      return false;
    }
  }

  Future<bool> _session(Future<UserModel> Function() call) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await call();
      state = state.copyWith(user: user, isLoading: false, isAuthenticated: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: ApiClient.parseErrorMessage(e));
      return false;
    }
  }

  Future<bool> signIn(String email, String password) =>
      _session(() => _repository.signIn(email: email, password: password));

  Future<bool> signInWithGoogle() => _session(() => _repository.signInWithGoogle(role: UserRole.partner));

  /// Returns the registration result (an emailed code to confirm), or null on failure.
  Future<RegistrationResult?> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _repository.registerUser(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
        role: UserRole.partner,
      );
      state = state.copyWith(isLoading: false);
      return result;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: ApiClient.parseErrorMessage(e));
      return null;
    }
  }

  Future<bool> verifyRegistration(String email, String code) =>
      _session(() => _repository.verifyRegistrationOtp(email: email, code: code));

  Future<bool> resendVerificationEmail(String email) => _run(() => _repository.resendVerificationEmail(email: email));

  /// Adopts a user whose session was already stored (e.g. by the social sign-in modal).
  void updateUser(UserModel updatedUser) {
    state = state.copyWith(user: updatedUser, isAuthenticated: true);
  }

  /// Email changes need re-verification and aren't supported here; only name and phone are sent.
  Future<bool> updatePersonalDetails({required String fullName, required String phone}) =>
      _run(() => _repository.updateProfile(fullName: fullName, phone: phone), refreshUser: true);

  /// Payout account for withdrawals (PATCH /provider/bank-details).
  Future<bool> updateBankDetails({
    required String bankName,
    required String bankCode,
    required String accountNumber,
    required String accountName,
  }) =>
      _run(
        () => _payments.saveBankDetails(BankDetails(
          bankName: bankName,
          bankCode: bankCode,
          accountNumber: accountNumber,
          accountName: accountName,
        )),
        refreshUser: true,
      );

  /// Uploads business/KYC documents (CAC certificate, ID, ...) for admin review. Until an admin
  /// approves them the account can't list vehicles.
  Future<VerificationStatus?> submitBusinessDocuments(List<UploadFile> files, {String? businessName}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final status = await _repository.submitVerificationDocuments(
        files: files,
        asPartner: true,
        businessName: businessName,
      );
      final user = await _repository.getCurrentUser(refresh: true);
      state = state.copyWith(user: user, isLoading: false);
      return status;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: ApiClient.parseErrorMessage(e));
      return null;
    }
  }

  /// Requests a withdrawal to the saved bank account; the amount is held until an admin pays it.
  Future<bool> requestPayout({required double amount}) => _run(() => _payments.requestWithdrawal(amount));

  Future<void> refreshUser() async {
    try {
      final user = await _repository.getCurrentUser(refresh: true);
      if (user != null) state = state.copyWith(user: user);
    } catch (_) {}
  }

  Future<void> signOut() async {
    await _repository.signOut();
    state = PartnerAuthState();
  }
}

final partnerAuthProvider = StateNotifierProvider<PartnerAuthNotifier, PartnerAuthState>((ref) {
  return PartnerAuthNotifier(ref.watch(authRepoProvider), ref.watch(paymentRepoProvider));
});

/// Document review state (null status = nothing submitted yet).
final partnerVerificationProvider = FutureProvider<VerificationStatus>((ref) async {
  final auth = ref.watch(partnerAuthProvider);
  if (!auth.isAuthenticated) return VerificationStatus();
  return ref.watch(authRepoProvider).getVerificationStatus(asPartner: true);
});

// The partner's own listings, refreshed periodically (scoped server-side).
final partnerFleetProvider = StreamProvider<List<CarModel>>((ref) {
  final repo = ref.watch(fleetRepoProvider);
  final auth = ref.watch(partnerAuthProvider);
  if (!auth.isAuthenticated) return Stream.value(<CarModel>[]);
  return repo.streamPartnerVehicles();
});

// Bookings on the partner's vehicles, refreshed periodically (scoped server-side).
final partnerBookingsProvider = StreamProvider<List<BookingModel>>((ref) {
  final repo = ref.watch(bookingRepoProvider);
  final auth = ref.watch(partnerAuthProvider);
  if (!auth.isAuthenticated) return Stream.value(<BookingModel>[]);
  return repo.streamMyBookings();
});

/// Withdrawable balance: the partner's share of paid bookings, minus withdrawals.
final partnerBalanceProvider = FutureProvider<WalletSummary>((ref) async {
  final auth = ref.watch(partnerAuthProvider);
  if (!auth.isAuthenticated) return WalletSummary(balance: 0, currency: 'NGN');
  return ref.watch(paymentRepoProvider).getWallet();
});

// Withdrawal history
final partnerWalletProvider = FutureProvider<List<WalletTransactionModel>>((ref) async {
  final auth = ref.watch(partnerAuthProvider);
  if (!auth.isAuthenticated) return <WalletTransactionModel>[];
  return ref.watch(paymentRepoProvider).getWalletTransactions();
});
