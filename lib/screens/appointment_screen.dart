import 'package:auto_services/screens/login_screen.dart';
import 'package:auto_services/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import '../models/customer.dart';
import '../models/appointment.dart';
import '../services/firebase_service.dart';
import '../services/email_service.dart';
import 'package:intl/intl.dart';


class AppointmentScreen extends StatefulWidget {
  final Customer customer;

  const AppointmentScreen({super.key, required this.customer});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  DateTime? _selectedDateTime;
  final DateFormat formatter = DateFormat('dd MMM yyyy, hh:mm a');
  bool _isBookingLoading = false;
  final _emailService = EmailService();
  List<Appointment> _appointments = [];

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    try {
      final firebaseService = context.read<FirebaseService>();
      final appointments = await firebaseService.getCustomerAppointments(
        widget.customer.id,
      );
      setState(() => _appointments = appointments);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load appointments: $e')),
      );
    }
  }

  Future<void> _bookAppointment() async {
    if (_selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date and time')),
      );
      return;
    }

    setState(() => _isBookingLoading = true);

    try {
      final firebaseService = context.read<FirebaseService>();
      final appointment = await firebaseService.createAppointment(
        widget.customer.id,
        _selectedDateTime!,
      );

      await _emailService.sendAppointmentConfirmation(
        widget.customer,
        appointment,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Appointment booked successfully! Check your email.'),
        ),
      );

      setState(() {
        _appointments = [..._appointments, appointment];
        _selectedDateTime = null;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to book appointment: $e')));
    } finally {
      if (mounted) setState(() => _isBookingLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () async {
              await AuthService().clearSavedCustomer();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (Route<dynamic> route) => false,
              );
            },
            icon: Icon(Icons.logout),
          ),
        ],
        title: const Text('Book Appointment'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome ${widget.customer.name}!',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Email: ${widget.customer.email}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      'Phone: ${widget.customer.phoneNumber}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isBookingLoading
                  ? null
                  : () {
                      DatePicker.showDateTimePicker(
                        context,
                        minTime: DateTime.now(),
                        maxTime: DateTime.now().add(const Duration(days: 30)),
                        onConfirm: (dateTime) {
                          setState(() => _selectedDateTime = dateTime);
                        },
                      );
                    },
              child: Text(
                _selectedDateTime == null
                    ? 'Select Date and Time'
                    : 'Selected: ${formatter.format(_selectedDateTime!)}',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isBookingLoading ? null : _bookAppointment,
              child: _isBookingLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Book Appointment'),
            ),
            const SizedBox(height: 24),
            Text(
              'Your Appointments',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (_appointments.isEmpty)
              const Center(child: Text('No appointments booked yet.'))
            else
              AppointmentsList(
                appointments: _appointments,
                formatter: formatter,
                onAppointmentUpdated: (updatedAppointment) {
                  setState(() {
                    _appointments = _appointments.map((appointment) {
                      return appointment.id == updatedAppointment.id
                          ? updatedAppointment
                          : appointment;
                    }).toList();
                  });
                },
              ),
          ],
        ),
      ),
    );
  }
}

class AppointmentsList extends StatelessWidget {
  final List<Appointment> appointments;
  final DateFormat formatter;
  final Function(Appointment) onAppointmentUpdated;

  const AppointmentsList({
    super.key,
    required this.appointments,
    required this.formatter,
    required this.onAppointmentUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return AppointmentTile(
          appointment: appointment,
          formatter: formatter,
          onAppointmentUpdated: onAppointmentUpdated,
        );
      },
    );
  }
}

class AppointmentTile extends StatefulWidget {
  final Appointment appointment;
  final DateFormat formatter;
  final Function(Appointment) onAppointmentUpdated;

  const AppointmentTile({
    super.key,
    required this.appointment,
    required this.formatter,
    required this.onAppointmentUpdated,
  });

  @override
  State<AppointmentTile> createState() => _AppointmentTileState();
}

class _AppointmentTileState extends State<AppointmentTile> {
  bool _isConfirming = false;

  Future<void> _confirmAppointment() async {
    setState(() => _isConfirming = true);
    try {
      final firebaseService = context.read<FirebaseService>();
      await firebaseService.confirmAppointment(widget.appointment.id);
      
      final updatedAppointment = Appointment(
        id: widget.appointment.id,
        customerId: widget.appointment.customerId,
        appointmentDateTime: widget.appointment.appointmentDateTime,
        status: 'confirmed',
        isConfirmed: true,
      );
      
      widget.onAppointmentUpdated(updatedAppointment);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to confirm appointment: $e')),
      );
    } finally {
      if (mounted) setState(() => _isConfirming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(
          'Appointment on ${widget.formatter.format(widget.appointment.appointmentDateTime)}'
        ),
        subtitle: Text('Status: ${widget.appointment.status}'),
        trailing: widget.appointment.isConfirmed
            ? const Icon(
                Icons.check_circle,
                color: Colors.green,
              )
            : _isConfirming
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : TextButton(
                    onPressed: _confirmAppointment,
                    child: const Text('Confirm'),
                  ),
      ),
    );
  }
}

