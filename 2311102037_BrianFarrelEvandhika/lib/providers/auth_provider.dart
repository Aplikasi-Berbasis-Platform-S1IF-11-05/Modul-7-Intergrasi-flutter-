import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class AuthProvider extends ChangeNotifier {
  User? _supabaseUser;
  String? _localUserEmail;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isOnlineMode => SupabaseConfig.isConfigured;

  // Get current user ID
  String? get userId {
    if (isOnlineMode) {
      return _supabaseUser?.id;
    } else {
      return _localUserEmail; // Use email as local ID
    }
  }

  // Get current user email
  String? get userEmail {
    if (isOnlineMode) {
      return _supabaseUser?.email;
    } else {
      return _localUserEmail;
    }
  }

  bool get isAuthenticated => userId != null;

  static const String _localUserKey = 'local_logged_in_user_email';
  static const String _localUsersDbKey = 'local_registered_users_db';

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();

    if (isOnlineMode) {
      // Listen to Supabase auth state changes
      Supabase.instance.client.auth.onAuthStateChange.listen((data) {
        _supabaseUser = data.session?.user;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      }, onError: (error) {
        _errorMessage = error.toString();
        _isLoading = false;
        notifyListeners();
      });
      _supabaseUser = Supabase.instance.client.auth.currentUser;
    } else {
      // Load local session if any
      final prefs = await SharedPreferences.getInstance();
      _localUserEmail = prefs.getString(_localUserKey);
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear errors helper
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Register user
  Future<bool> signUp(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (isOnlineMode) {
        final response = await Supabase.instance.client.auth.signUp(
          email: email,
          password: password,
        );
        // Supabase will automatically send confirmation or log in depending on config
        _isLoading = false;
        notifyListeners();
        
        if (response.session == null) {
          throw Exception('Pendaftaran berhasil! Silakan periksa inbox/spam email Anda untuk memverifikasi akun sebelum masuk.');
        }
        return true;
      } else {
        // Local fallback registration
        final prefs = await SharedPreferences.getInstance();
        final usersDbString = prefs.getString(_localUsersDbKey) ?? '{}';
        final Map<String, dynamic> usersDb = jsonDecode(usersDbString);

        if (usersDb.containsKey(email)) {
          throw Exception('Email ini sudah terdaftar');
        }

        usersDb[email] = password;
        await prefs.setString(_localUsersDbKey, jsonEncode(usersDb));

        // Auto log in after registration
        _localUserEmail = email;
        await prefs.setString(_localUserKey, email);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Login user
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (isOnlineMode) {
        final response = await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );
        _supabaseUser = response.user;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // Local fallback login
        final prefs = await SharedPreferences.getInstance();
        final usersDbString = prefs.getString(_localUsersDbKey) ?? '{}';
        final Map<String, dynamic> usersDb = jsonDecode(usersDbString);

        if (!usersDb.containsKey(email) || usersDb[email] != password) {
          throw Exception('Email atau password salah');
        }

        _localUserEmail = email;
        await prefs.setString(_localUserKey, email);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout user
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (isOnlineMode) {
        await Supabase.instance.client.auth.signOut();
        _supabaseUser = null;
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_localUserKey);
        _localUserEmail = null;
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
