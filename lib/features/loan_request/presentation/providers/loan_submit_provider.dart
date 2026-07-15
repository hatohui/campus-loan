import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/providers.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/loan_request.dart';
import '../../domain/entities/loan_result.dart';
import 'loan_form_provider.dart';

/// Drives the submit action and exposes it as an `AsyncValue<LoanResult?>`.
///
/// The in-flight guard (`if (state.isLoading) return null`) is what makes rapid
/// double-taps on Submit produce exactly one POST: the first tap flips state to
/// loading synchronously before the first `await`, so every subsequent tap is
/// ignored until the request settles. This is the behaviour the Part 4 widget
/// test pins down.
class LoanSubmitController extends AsyncNotifier<LoanResult?> {
  static const Uuid _uuid = Uuid();

  @override
  LoanResult? build() => null; // idle

  Future<LoanResult?> submit() async {
    if (state.isLoading) return null; // rapid-tap guard -> single POST

    final draft = ref.read(loanFormProvider);
    if (!draft.isSubmittable) {
      state = AsyncValue<LoanResult?>.error(
        const ValidationFailure('Please complete every field first.'),
        StackTrace.current,
      );
      return null;
    }

    final period = ref.read(validateLoanPeriodProvider).call(
          borrowDate: draft.borrowDate!,
          returnDate: draft.returnDate!,
        );
    if (!period.isValid) {
      state = AsyncValue<LoanResult?>.error(
        ValidationFailure(period.error!),
        StackTrace.current,
      );
      return null;
    }

    final request = LoanRequest(
      deviceId: draft.deviceId!,
      deviceName: draft.deviceName ?? 'Device',
      studentId: draft.studentId!.trim(),
      borrowDate: draft.borrowDate!,
      returnDate: draft.returnDate!,
      purpose: draft.purpose!.trim(),
      deposit: draft.deposit,
      idempotencyKey: _uuid.v4(),
    );

    state = const AsyncValue<LoanResult?>.loading();
    final result = await AsyncValue.guard(
      () => ref.read(submitLoanRequestProvider).call(request),
    );
    state = result;

    // Clear the persisted draft once the request left the form successfully.
    if (!result.hasError) {
      await ref.read(loanFormProvider.notifier).reset();
    }
    return result.valueOrNull;
  }

  /// Returns the controller to idle (e.g. when leaving the result screen).
  void reset() => state = const AsyncValue<LoanResult?>.data(null);
}

final loanSubmitProvider =
    AsyncNotifierProvider<LoanSubmitController, LoanResult?>(
  LoanSubmitController.new,
);
