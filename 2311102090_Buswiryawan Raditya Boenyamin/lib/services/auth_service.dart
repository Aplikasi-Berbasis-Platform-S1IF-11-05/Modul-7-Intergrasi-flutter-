// 2311102090-Buswiryawan Raditya Boenyamin
import 'package:supabase_flutter/supabase_flutter.dart';
import 'notification_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  final _supabase = Supabase.instance.client;
  final _notificationService = NotificationService();

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Check if user is logged in
  bool get isLoggedIn => _supabase.auth.currentUser != null;

  // Get user ID
  String? get userId => _supabase.auth.currentUser?.id;

  // Stream for auth changes
  Stream<AuthState> get authStateChanges =>
      _supabase.auth.onAuthStateChange;

  // Register dengan email dan password
  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final AuthResponse res = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      if (res.user != null) {
        await _notificationService.showAuthNotification(
          'DAFTAR_BERHASIL',
          'SYSTEM_LOG: ACCOUNT_$email CREATED',
        );
        return true;
      }
      return false;
    } on AuthException catch (e) {
      await _notificationService.showErrorNotification(e.message);
      rethrow;
    }
  }

  // Login dengan email dan password
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      final AuthResponse res = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (res.user != null) {
        await _notificationService.showAuthNotification(
          'LOGIN_SUCCESS',
          'WELCOME_BACK: ${res.user!.userMetadata?['full_name'] ?? email}',
        );
        return true;
      }
      return false;
    } on AuthException catch (e) {
      await _notificationService.showErrorNotification(e.message);
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
      await _notificationService.showAuthNotification(
        'LOGOUT_SUCCESS',
        'SYSTEM_NODE_LOGGED_OUT',
      );
    } on AuthException catch (e) {
      await _notificationService.showErrorNotification(e.message);
      rethrow;
    }
  }

  // Get user full name
  String getUserFullName() {
    return currentUser?.userMetadata?['full_name'] ?? 'User';
  }

  // Get user email
  String getUserEmail() {
    return currentUser?.email ?? '';
  }

  // Update Nama User
  Future<bool> updateFullName(String newName) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(data: {'full_name': newName}),
      );
      await _notificationService.showAuthNotification(
        'IDENT_UPDATED',
        'SYSTEM_LOG: USER_NAME_CHANGED_TO_${newName.toUpperCase()}',
      );
      return true;
    } on AuthException catch (e) {
      await _notificationService.showErrorNotification(e.message);
      return false;
    }
  }

  // Delete Account
  Future<bool> deleteAccount() async {
    try {
      // Menjalankan RPC 'delete_user' yang harus dibuat di Supabase SQL Editor
      await _supabase.rpc('delete_user');
      await logout();
      await _notificationService.showAuthNotification(
        'ACCOUNT_TERMINATED',
        'SYSTEM_LOG: ALL_USER_DATA_PURGED_FROM_HOST',
      );
      return true;
    } on AuthException catch (e) {
      await _notificationService.showErrorNotification(e.message);
      return false;
    } catch (e) {
      await _notificationService.showErrorNotification('FAILED_TO_EXECUTE_PURGE_SEQUENCE');
      return false;
    }
  }

  // Reset password
  Future<bool> resetPassword({required String email}) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      await _notificationService.showAuthNotification(
        'EMAIL_RESET_SENT',
        'CHECK_INBOX_FOR_NEW_TOKEN',
      );
      return true;
    } on AuthException catch (e) {
      await _notificationService.showErrorNotification(e.message);
      return false;
    }
  }
}
