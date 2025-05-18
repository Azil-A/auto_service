import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/customer.dart';
import '../models/appointment.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Customer> createCustomer(String name, String email, String phoneNumber, String password) async {
    try {
     
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final customer = Customer(
        id: userCredential.user!.uid,
        name: name.trim(),
        email: email.trim(),
        phoneNumber: phoneNumber.trim(),
        password: password,
      );

      await _firestore
          .collection('customers')
          .doc(customer.id)
          .set(customer.toMap());

      return customer;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          throw Exception('The password provided is too weak');
        case 'email-already-in-use':
          throw Exception('An account already exists for this email');
        case 'invalid-email':
          throw Exception('The email address is not valid');
        default:
          throw Exception('Failed to create account: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to create customer: $e');
    }
  }


  Future<Customer> signInCustomer(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final customerDoc = await _firestore
          .collection('customers')
          .doc(userCredential.user!.uid)
          .get();

      if (!customerDoc.exists) {
        throw Exception('Customer profile not found');
      }

      return Customer.fromMap({
        'id': userCredential.user!.uid,
        ...customerDoc.data()!,
        'password': password,
      });
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception('No user found for this email');
        case 'wrong-password':
          throw Exception('Wrong password provided');
        case 'invalid-email':
          throw Exception('The email address is not valid');
        case 'user-disabled':
          throw Exception('This user account has been disabled');
        default:
          throw Exception('Failed to sign in: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  Future<Appointment> createAppointment(String customerId, DateTime appointmentDateTime) async {
    try {

      if (_auth.currentUser == null) {
        throw Exception('User not authenticated. Please sign in again.');
      }

      final appointmentRef = _firestore.collection('appointments').doc();
      final appointment = Appointment(
        id: appointmentRef.id,
        customerId: customerId,
        appointmentDateTime: appointmentDateTime,
      );

      await appointmentRef.set(appointment.toMap());
      return appointment;
    } catch (e) {
      throw Exception('Failed to create appointment: $e');
    }
  }

  Future<void> confirmAppointment(String appointmentId) async {
    try {
  
      if (_auth.currentUser == null) {
        throw Exception('User not authenticated. Please sign in again.');
      }

      await _firestore.collection('appointments').doc(appointmentId).update({
        'isConfirmed': true,
        'status': 'confirmed',
      });
    } catch (e) {
      throw Exception('Failed to confirm appointment: $e');
    }
  }

  Future<List<Appointment>> getCustomerAppointments(String customerId) async {
    try {
      if (_auth.currentUser == null) {
        throw Exception('User not authenticated. Please sign in again.');
      }

      final querySnapshot = await _firestore
          .collection('appointments')
          .where('customerId', isEqualTo: customerId)
          .get();

      return querySnapshot.docs
          .map((doc) => Appointment.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get customer appointments: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
} 