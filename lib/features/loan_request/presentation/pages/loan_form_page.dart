import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/widgets/app_bottom_nav.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/failures.dart';
import '../../../equipment/domain/entities/device.dart';
import '../providers/loan_form_provider.dart';
import '../providers/loan_submit_provider.dart';
import '../widgets/date_field.dart';
import '../widgets/deposit_summary.dart';

/// Screen C — the loan request form.
///
/// Seeds the form with the chosen [device], reflects the persisted draft, shows
/// the live date-validation error (CR#3), and submits through the guarded
/// [loanSubmitProvider]. Navigation to the result screen is driven by listening
/// to the submit state, keeping the button handler trivial.
class LoanFormPage extends ConsumerStatefulWidget {
  const LoanFormPage({super.key, required this.device});

  final Device device;

  @override
  ConsumerState<LoanFormPage> createState() => _LoanFormPageState();
}

class _LoanFormPageState extends ConsumerState<LoanFormPage> {
  late final TextEditingController _studentIdController;
  late final TextEditingController _purposeController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(loanFormProvider);
    _studentIdController = TextEditingController(text: draft.studentId ?? '');
    _purposeController = TextEditingController(text: draft.purpose ?? '');

    // Snapshot the selected device into the draft after the first frame, so we
    // never mutate a provider while it is still building.
    Future.microtask(() {
      ref.read(loanFormProvider.notifier).selectDevice(
            id: widget.device.id,
            name: widget.device.name,
            price: widget.device.price,
          );
    });
  }

  @override
  void dispose() {
    _studentIdController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(loanFormProvider);
    final dateError = ref.watch(loanPeriodErrorProvider);
    final submitState = ref.watch(loanSubmitProvider);
    final isSubmitting = submitState.isLoading;

    // React to submit outcomes: navigate on success, surface validation errors.
    ref.listen(loanSubmitProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) {
          final message =
              error is Failure ? error.message : 'Submission failed.';
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(message)));
        },
        data: (result) {
          if (result == null) return;
          context.push(AppRoutes.result, extra: result).then((_) {
            ref.read(loanSubmitProvider.notifier).reset();
          });
        },
      );
    });

    final today = DateTime.now();
    final borrow = draft.borrowDate;
    final loanDays = (borrow != null && draft.returnDate != null)
        ? draft.returnDate!.difference(borrow).inDays
        : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Loan Request')),
      bottomNavigationBar: const AppBottomNav(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _studentIdController,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'Student ID',
              hintText: 'e.g. SE1819',
              border: OutlineInputBorder(),
            ),
            onChanged: ref.read(loanFormProvider.notifier).setStudentId,
          ),
          const SizedBox(height: 16),
          DateField(
            label: 'Borrow date',
            value: draft.borrowDate,
            firstDate: DateTime(today.year, today.month, today.day),
            onPicked: ref.read(loanFormProvider.notifier).setBorrowDate,
          ),
          const SizedBox(height: 16),
          DateField(
            label: 'Return date',
            value: draft.returnDate,
            firstDate: borrow ?? DateTime(today.year, today.month, today.day),
            lastDate: (borrow ?? today)
                .add(const Duration(days: AppConstants.maxLoanDays)),
            onPicked: ref.read(loanFormProvider.notifier).setReturnDate,
          ),
          if (dateError != null) ...[
            const SizedBox(height: 8),
            Text(
              dateError,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 16),
          TextField(
            controller: _purposeController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Purpose',
              hintText: 'Why do you need this device?',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            onChanged: ref.read(loanFormProvider.notifier).setPurpose,
          ),
          const SizedBox(height: 20),
          RequestSummary(loanDays: loanDays, deposit: draft.deposit),
          const SizedBox(height: 24),
          FilledButton(
            // Disabled while a submit is in flight — the notifier also guards
            // against re-entry, so rapid taps still yield a single POST.
            onPressed: isSubmitting
                ? null
                : () => ref.read(loanSubmitProvider.notifier).submit(),
            child: isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('SUBMIT LOAN REQUEST'),
          ),
        ],
      ),
    );
  }
}
