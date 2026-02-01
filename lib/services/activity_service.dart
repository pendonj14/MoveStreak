import 'package:movestreak/models/activity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class ActivityService {
  final SupabaseClient _supabase;

  ActivityService({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  Future<Activity> logActivity({
    required String userId,
    required String name,
    String? notes,
    int? durationMinutes,
    DateTime? activityDate,
  }) async {
    try {
      final date = activityDate ?? DateTime.now();
      final now = DateTime.now();

      final response = await _supabase
          .from('activities')
          .insert({
            'user_id': userId,
            'name': name,
            'notes': notes,
            'duration_minutes': durationMinutes,
            'date': DateFormat('yyyy-MM-dd').format(date),
            'created_at': now.toIso8601String(),
          })
          .select()
          .single();

      return Activity(
        id: response['id'],
        userId: response['user_id'],
        name: response['name'],
        notes: response['notes'],
        durationMinutes: response['duration_minutes'],
        date: DateTime.parse(response['date']),
        createdAt: DateTime.parse(response['created_at']),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Activity>> getActivitiesForDate({
    required String userId,
    required DateTime date,
  }) async {
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final response = await _supabase
          .from('activities')
          .select()
          .eq('user_id', userId)
          .eq('date', dateStr)
          .order('created_at', ascending: false);

      return (response as List).map((item) {
        return Activity(
          id: item['id'],
          userId: item['user_id'],
          name: item['name'],
          notes: item['notes'],
          durationMinutes: item['duration_minutes'],
          date: DateTime.parse(item['date']),
          createdAt: DateTime.parse(item['created_at']),
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Activity>> getActivitiesForDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final startStr = DateFormat('yyyy-MM-dd').format(startDate);
      final endStr = DateFormat('yyyy-MM-dd').format(endDate);

      final response = await _supabase
          .from('activities')
          .select()
          .eq('user_id', userId)
          .gte('date', startStr)
          .lte('date', endStr)
          .order('date', ascending: false);

      return (response as List).map((item) {
        return Activity(
          id: item['id'],
          userId: item['user_id'],
          name: item['name'],
          notes: item['notes'],
          durationMinutes: item['duration_minutes'],
          date: DateTime.parse(item['date']),
          createdAt: DateTime.parse(item['created_at']),
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> hasActivityOnDate({
    required String userId,
    required DateTime date,
  }) async {
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final response = await _supabase
          .from('activities')
          .select()
          .eq('user_id', userId)
          .eq('date', dateStr)
          .limit(1);

      return (response as List).isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<void> deleteActivity(String activityId) async {
    try {
      await _supabase.from('activities').delete().eq('id', activityId);
    } catch (e) {
      rethrow;
    }
  }
}
