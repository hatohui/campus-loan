import '../../../../core/utils/deposit_calculator.dart';

/// A work-in-progress loan request captured from the form.
///
/// Every field is nullable because the draft is built up incrementally as the
/// student fills the form, and the whole draft is persisted so a selected
/// device, dates, student id and purpose all survive an app restart (Part 3).
/// The immutable `copyWith` pattern keeps it friendly to Riverpod state.
class LoanDraft {
  const LoanDraft({
    this.deviceId,
    this.deviceName,
    this.devicePrice,
    this.studentId,
    this.borrowDate,
    this.returnDate,
    this.purpose,
  });

  final String? deviceId;
  final String? deviceName;
  final num? devicePrice;
  final String? studentId;
  final DateTime? borrowDate;
  final DateTime? returnDate;
  final String? purpose;

  /// Deposit derived from the snapshotted device price via the shared rule.
  double get deposit => DepositCalculator.estimate(devicePrice);

  /// True once every field required to submit is present.
  bool get isSubmittable =>
      (deviceId?.isNotEmpty ?? false) &&
      (studentId?.trim().isNotEmpty ?? false) &&
      (purpose?.trim().isNotEmpty ?? false) &&
      borrowDate != null &&
      returnDate != null;

  LoanDraft copyWith({
    String? deviceId,
    String? deviceName,
    num? devicePrice,
    String? studentId,
    DateTime? borrowDate,
    DateTime? returnDate,
    String? purpose,
  }) {
    return LoanDraft(
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      devicePrice: devicePrice ?? this.devicePrice,
      studentId: studentId ?? this.studentId,
      borrowDate: borrowDate ?? this.borrowDate,
      returnDate: returnDate ?? this.returnDate,
      purpose: purpose ?? this.purpose,
    );
  }

  Map<String, dynamic> toJson() => {
        'deviceId': deviceId,
        'deviceName': deviceName,
        'devicePrice': devicePrice,
        'studentId': studentId,
        'borrowDate': borrowDate?.toIso8601String(),
        'returnDate': returnDate?.toIso8601String(),
        'purpose': purpose,
      };

  factory LoanDraft.fromJson(Map<String, dynamic> json) => LoanDraft(
        deviceId: json['deviceId'] as String?,
        deviceName: json['deviceName'] as String?,
        devicePrice: json['devicePrice'] as num?,
        studentId: json['studentId'] as String?,
        borrowDate: _parseDate(json['borrowDate']),
        returnDate: _parseDate(json['returnDate']),
        purpose: json['purpose'] as String?,
      );

  static DateTime? _parseDate(Object? raw) =>
      raw is String ? DateTime.tryParse(raw) : null;
}
