import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import '../models/appointment.dart';
import '../models/customer.dart';
import 'package:intl/intl.dart';

class EmailService {
  final String? _smtpUsername = dotenv.env['SMTP_USER_NAME']; 
  final String? _smtpPassword = dotenv.env['SMTP_PASS'];
  final DateFormat formatter = DateFormat('dd MMM yyyy, hh:mm a');

  Future<void> sendAppointmentConfirmation(
    Customer customer,
    Appointment appointment,
  ) async {
    final smtpServer = gmail(_smtpUsername!, _smtpPassword!);

    final message = Message()
      ..from = Address(_smtpUsername)
      ..recipients.add(customer.email)
      ..subject = 'Auto Service Appointment Confirmation'
      ..html = '''
        <h2>Appointment Confirmation</h2>
        <p>Dear ${customer.name},</p>
        <p>Your auto service appointment has been scheduled for:</p>
        <p><strong>Date and Time:</strong> ${formatter.format(appointment.appointmentDateTime)}</p>
        <p>Please confirm your appointment by clicking the confirmation link in your app.</p>
        <p>Thank you for choosing our service!</p>
      ''';

    try {
      await send(message, smtpServer);
    } catch (e) {
      throw Exception('Failed to send confirmation email: $e');
    }
  }
} 