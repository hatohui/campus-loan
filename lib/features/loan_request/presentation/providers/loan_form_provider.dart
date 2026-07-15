import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../domain/entities/loan_draft.dart';

/// Holds the loan form state as a [LoanDraft] and write-through persists it.
///
/// Every mutation updates immutable state *and* saves the draft via the
/// repository, so a selected device, dates, student id and purpose all survive
/// an app restart (Part 3). Widgets call these intent methods and never touch
/// storage themselves.
class LoanFormController extends Notifier<LoanDraft> {
  @override
  LoanDraft build() =>
      ref.read(loanRepositoryProvider).loadDraft() ?? const LoanDraft();

  void selectDevice({
    required String id,
    required String name,
    num? price,
  }) {
    _update(state.copyWith(deviceId: id, deviceName: name, devicePrice: price));
  }

  void setStudentId(String value) =>
      _update(state.copyWith(studentId: value));

  void setPurpose(String value) => _update(state.copyWith(purpose: value));

  void setBorrowDate(DateTime date) =>
      _update(state.copyWith(borrowDate: date));

  void setReturnDate(DateTime date) =>
      _update(state.copyWith(returnDate: date));

  /// Resets the form and clears the persisted draft (after a successful submit).
  Future<void> reset() async {
    state = const LoanDraft();
    await ref.read(loanRepositoryProvider).clearDraft();
  }

  void _update(LoanDraft next) {
    state = next;
    unawaited(ref.read(loanRepositoryProvider).saveDraft(next));
  }
}

final loanFormProvider =
    NotifierProvider<LoanFormController, LoanDraft>(LoanFormController.new);

/// Derived date-validation error for the current draft, or `null` if the dates
/// are valid or not yet both chosen (CR#3). Delegates to the domain use case.
final loanPeriodErrorProvider = Provider<String?>((ref) {
  final draft = ref.watch(loanFormProvider);
  final borrow = draft.borrowDate;
  final ret = draft.returnDate;
  if (borrow == null || ret == null) return null;
  return ref
      .watch(validateLoanPeriodProvider)
      .call(borrowDate: borrow, returnDate: ret)
      .error;
});
