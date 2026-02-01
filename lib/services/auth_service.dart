import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:movestreak/models/user.dart';

class AuthService {
  final SupabaseClient _supabase;

  AuthService({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  Future<User?> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Create user profile in database
        await _createUserProfile(
          userId: response.user!.id,
          email: email,
          displayName: displayName,
        );

        return User(
          id: response.user!.id,
          email: email,
          displayName: displayName,
          createdAt: DateTime.now(),
        );
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        final userProfile = await _getUserProfile(response.user!.id);
        return userProfile;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  User? getCurrentUser() {
    final authUser = _supabase.auth.currentUser;
    if (authUser != null) {
      return User(
        id: authUser.id,
        email: authUser.email ?? '',
        displayName: authUser.userMetadata?['display_name'],
        createdAt: authUser.createdAt != null
            ? DateTime.parse(authUser.createdAt!)
            : DateTime.now(),
      );
    }
    return null;
  }

  bool isLoggedIn() {
    return _supabase.auth.currentUser != null;
  }

  Future<void> _createUserProfile({
    required String userId,
    required String email,
    String? displayName,
  }) async {
    await _supabase.from('users').insert({
      'id': userId,
      'email': email,
      'display_name': displayName ?? email.split('@')[0],
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<User?> _getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      return User(
        id: response['id'],
        email: response['email'],
        displayName: response['display_name'],
        createdAt: DateTime.parse(response['created_at']),
      );
    } catch (e) {
      return null;
    }
  }
}
