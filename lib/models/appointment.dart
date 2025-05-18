class Appointment {
  final String id;
  final String customerId;
  final DateTime appointmentDateTime;
  final bool isConfirmed;
  final String status;

  Appointment({
    required this.id,
    required this.customerId,
    required this.appointmentDateTime,
    this.isConfirmed = false,
    this.status = 'pending',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'appointmentDateTime': appointmentDateTime.toIso8601String(),
      'isConfirmed': isConfirmed,
      'status': status,
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'] ?? '',
      customerId: map['customerId'] ?? '',
      appointmentDateTime: DateTime.parse(map['appointmentDateTime']),
      isConfirmed: map['isConfirmed'] ?? false,
      status: map['status'] ?? 'pending',
    );
  }
} 