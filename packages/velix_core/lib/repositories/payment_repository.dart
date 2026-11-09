import 'dart:async';
import '../models/payment_model.dart';
import '../data_sources/remote/payment_remote_data_source.dart';

/// Payments go through Flutterwave's hosted checkout: the app never sees card details.
///   1. [startBookingCheckout] / [startWalletFunding] -> open the session's link in a WebView
///   2. Flutterwave redirects to the callback URL with `transaction_id`
///   3. [confirmBookingCheckout] / [confirmWalletFunding] -> the backend verifies with Flutterwave
/// The Flutterwave webhook also settles payments server-side, so a user who closes the app
/// mid-checkout is still credited.
abstract class IPaymentRepository {
  Future<CheckoutSession> startBookingCheckout(String bookingId);
  Future<PaymentOutcome> confirmBookingCheckout(CheckoutSession session, String transactionId);
  Future<CheckoutSession> startWalletFunding(double amount);
  Future<PaymentOutcome> confirmWalletFunding(CheckoutSession session, String transactionId);
  Future<WalletSummary> getWallet();

  // Partner payouts
  Future<void> saveBankDetails(BankDetails details);
  Future<WalletTransactionModel> requestWithdrawal(double amount);
  Future<List<WalletTransactionModel>> getWalletTransactions();
}

class RemotePaymentRepository implements IPaymentRepository {
  final PaymentRemoteDataSource _remote = PaymentRemoteDataSource();

  @override
  Future<CheckoutSession> startBookingCheckout(String bookingId) => _remote.initiateBookingPayment(bookingId);

  @override
  Future<PaymentOutcome> confirmBookingCheckout(CheckoutSession session, String transactionId) =>
      _remote.verifyBookingPayment(session.id, transactionId);

  @override
  Future<CheckoutSession> startWalletFunding(double amount) => _remote.initiateWalletFunding(amount);

  @override
  Future<PaymentOutcome> confirmWalletFunding(CheckoutSession session, String transactionId) =>
      _remote.verifyWalletFunding(session.id, transactionId);

  @override
  Future<WalletSummary> getWallet() => _remote.getWallet();

  @override
  Future<void> saveBankDetails(BankDetails details) => _remote.updateBankDetails(details);

  @override
  Future<WalletTransactionModel> requestWithdrawal(double amount) => _remote.requestWithdrawal(amount);

  /// Withdrawal history -- the only wallet history the API exposes.
  @override
  Future<List<WalletTransactionModel>> getWalletTransactions() => _remote.listWithdrawals();
}
