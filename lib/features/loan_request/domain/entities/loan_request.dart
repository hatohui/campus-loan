import 'package:intl/intl.dart';

/// A fully-specified, submittable loan request.
///
/// Unlike [LoanDraft] every field here is non-null: a [LoanRequest] is only
/// constructed once validation has passed. It knows how to serialise itself
/// into the exact `name` + nested `data` shape the POST endpoint expects, and
/// it carries an [idempotencyKey] so an offline retry can be de-duplicated.
class LoanRequest {
  const LoanRequest({
    required this.deviceId,
    required this.deviceName,
    required this.studentId,
    required this.borrowDate,
    required this.returnDate,
    required this.purpose,
    required this.deposit,
    required this.idempotencyKey,
  });

  final String deviceId;

  /// Display-only snapshot of the device name (not sent in the payload).
  final String deviceName;
  final String studentId;
  final DateTime borrowDate;
  final DateTime returnDate;
  final String purpose;
  final double deposit;

  /// Client-generated id that stays constant across retries so the same
  /// request is never created twice.
  final String idempotencyKey;

  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  /// The nested `data` object exactly as the API example specifies.
  ///
  /// Note: [idempotencyKey] is deliberately NOT sent — it is a *local* concern
  /// (stored on the pending record to guard retries), so the wire payload
  /// matches the required seven fields exactly.
  Map<String, dynamic> toData() => {
        'deviceId': deviceId,
        'studentId': studentId,
        'borrowDate': _dateFormat.format(borrowDate),
        'returnDate': _dateFormat.format(returnDate),
        'purpose': purpose,
        'deposit': deposit,
        'status': 'pending',
      };

  /// The full `POST /objects` body: `name` + nested `data`.
  Map<String, dynamic> toPayload() => {
        'name': 'Campus Equipment Loan Request',
        'data': toData(),
      };
}
