import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/customer.dart';

class AuthService {
  static const String _customerKey = 'current_customer';

  Future<void> saveCustomer(Customer customer) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_customerKey, jsonEncode(customer.toMap()));
  }

  Future<Customer?> getSavedCustomer() async {
    final prefs = await SharedPreferences.getInstance();
    final customerJson = prefs.getString(_customerKey);
    if (customerJson != null) {
      return Customer.fromMap(jsonDecode(customerJson));
    }
    return null;
  }

  Future<void> clearSavedCustomer() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_customerKey);
  }
} 