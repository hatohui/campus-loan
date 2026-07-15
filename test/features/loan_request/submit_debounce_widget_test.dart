import 'package:flutter/material.dart';
import 'package:flutter_application_1/app/providers.dart';
import 'package:flutter_application_1/features/loan_request/domain/entities/loan_draft.dart';
import 'package:flutter_application_1/features/loan_request/domain/entities/loan_request.dart';
import 'package:flutter_application_1/features/loan_request/domain/entities/loan_result.dart';
import 'package:flutter_application_1/features/loan_request/domain/repositories/loan_repository.dart';
import 'package:flutter_application_1/features/loan_request/presentation/providers/loan_form_provider.dart';
import 'package:flutter_application_1/features/loan_request/presentation/providers/loan_submit_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Part 4 — widget test: rapid Submit taps must produce only one POST.
///
/// The fake repository counts submissions and stays in-flight (a 100 ms delay)
/// so the second and third taps land while the controller is still loading;
/// the in-flight guard should reject them.
class _FakeLoanRepository implements LoanRepository {
  int submitCount = 0;

  @override
  Future<LoanResult> submit(LoanRequest request) async {
    submitCount++;
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return LoanResult(
      request: request,
      status: LoanStatus.created,
      id: 'server-1',
      createdAt: '2026-08-01T00:00:00.000Z',
    );
  }

  @override
  Future<void> saveDraft(LoanDraft draft) async {}

  @override
  LoanDraft? loadDraft() => null;

  @override
  Future<void> clearDraft() async {}

  @override
  Future<int> retryPending() async => 0;

  @override
  int pendingCount() => 0;
}

/// A form controller seeded with a ready-to-submit draft (valid dates).
class _ReadyFormController extends LoanFormController {
  @override
  LoanDraft build() {
    final base = DateTime.now();
    final borrow = DateTime(base.year, base.month, base.day)
        .add(const Duration(days: 1));
    return LoanDraft(
      deviceId: '7',
      deviceName: 'Test Device',
      devicePrice: 100,
      studentId: 'SE1819',
      borrowDate: borrow,
      returnDate: borrow.add(const Duration(days: 2)),
      purpose: 'Demo',
    );
  }
}

/// Minimal harness exposing a single submit button.
class _SubmitHarness extends ConsumerWidget {
  const _SubmitHarness();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () => ref.read(loanSubmitProvider.notifier).submit(),
            child: const Text('Submit'),
          ),
        ),
      ),
    );
  }
}

void main() {
  testWidgets('rapid submit taps trigger only one POST', (tester) async {
    final fakeRepo = _FakeLoanRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          loanRepositoryProvider.overrideWithValue(fakeRepo),
          loanFormProvider.overrideWith(_ReadyFormController.new),
        ],
        child: const _SubmitHarness(),
      ),
    );

    // Three taps before the in-flight request settles.
    await tester.tap(find.byType(ElevatedButton));
    await tester.tap(find.byType(ElevatedButton));
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(fakeRepo.submitCount, 1);
  });
}
