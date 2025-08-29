import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

import '../models/user.dart';
import '../models/todo.dart';

class ApiService {
  // ✅ 플랫폼/환경별 baseUrl
  static String get baseUrl {
    const injected = String.fromEnvironment('API_BASE'); // flutter run/build 시 주입 가능
    if (injected.isNotEmpty) return injected;
    if (kIsWeb) return 'http://127.0.0.1:4000';
    if (defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:4000';
    return 'http://127.0.0.1:4000'; // iOS 시뮬레이터/맥
  }

  // ✅ 공통 헤더
  static Map<String, String> get headers => {'Content-Type': 'application/json'};

  // ✅ 2xx 전체 허용
  static bool _ok(int s) => s >= 200 && s < 300;

  // ===== Auth =====

  static Future<void> register(String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: headers,
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (_ok(res.statusCode)) {
      final data = jsonDecode(res.body);
      final token = (data['access_token'] ?? data['accessToken'] ?? data['token'])?.toString();
      if (token == null || token.isEmpty) {
        // 토큰이 안 오더라도 실패로 취급 (자동로그인 위해 필요)
        throw Exception('회원가입 성공 응답에 토큰이 없습니다.');
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', token);
      return;
    } else {
      // 서버 메시지 그대로 노출
      try {
        final err = jsonDecode(res.body);
        throw Exception(err['message']?.toString() ?? '회원가입 실패');
      } catch (_) {
        throw Exception('회원가입 실패: ${res.statusCode} ${res.body}');
      }
    }
  }

  static Future<String> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: headers, // 로그인에는 Authorization 금지
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (_ok(res.statusCode)) {
      final data = jsonDecode(res.body);
      final token = (data['access_token'] ?? data['accessToken'] ?? data['token'])?.toString();
      if (token == null || token.isEmpty) {
        throw Exception('로그인 성공 응답에 토큰이 없습니다.');
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', token);
      return token;
    } else {
      try {
        final err = jsonDecode(res.body);
        throw Exception(err['message']?.toString() ?? '로그인 실패');
      } catch (_) {
        throw Exception('로그인 실패: ${res.statusCode} ${res.body}');
      }
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    // 서버에도 알리고 싶으면 주석 해제 (서버가 없다고 해도 finally에서 토큰 제거)
    try {
      if (token != null && token.isNotEmpty) {
        await http.post(
          Uri.parse('$baseUrl/auth/logout'),
          headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        );
      }
    } finally {
      // ✅ clear() 금지 — 토큰 키만 제거
      await prefs.remove('access_token');
    }
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      throw Exception('인증 토큰이 없습니다. 다시 로그인 해주세요.');
    }
    return {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
  }

  static Future<User> getProfile() async {
    final ah = await getAuthHeaders();
    final res = await http.get(Uri.parse('$baseUrl/auth/me'), headers: ah);
    if (_ok(res.statusCode)) {
      return User.fromJson(jsonDecode(res.body));
    } else {
      throw Exception('프로필 조회 실패: ${res.statusCode} ${res.body}');
    }
  }

  // ===== Todos =====

  static Future<List<Todo>> getTodos() async {
    final ah = await getAuthHeaders();
    final res = await http.get(Uri.parse('$baseUrl/todos'), headers: ah);
    if (_ok(res.statusCode)) {
      final list = jsonDecode(res.body) as List<dynamic>;
      return list.map((e) => Todo.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Todo 목록 조회 실패: ${res.statusCode} ${res.body}');
    }
  }

  static Future<Todo> createTodo(String title, {TodoCategory? category, DateTime? dueDate}) async {
    final ah = await getAuthHeaders();
    final body = <String, dynamic>{'title': title};
    if (category != null) body['category'] = category.toString().split('.').last;
    if (dueDate != null) body['dueDate'] = dueDate.toIso8601String();

    final res = await http.post(Uri.parse('$baseUrl/todos'), headers: ah, body: jsonEncode(body));
    if (_ok(res.statusCode)) {
      return Todo.fromJson(jsonDecode(res.body));
    } else {
      throw Exception('Todo 생성 실패: ${res.statusCode} ${res.body}');
    }
  }

  static Future<Todo> updateTodo(int id, {String? title, bool? done, TodoCategory? category, DateTime? dueDate}) async {
    final ah = await getAuthHeaders();
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (done != null) body['done'] = done;
    if (category != null) body['category'] = category.toString().split('.').last;
    if (dueDate != null) body['dueDate'] = dueDate.toIso8601String();

    // 서버 구현에 따라 PATCH/PUT 중 하나면 교체 가능
    final res = await http.patch(Uri.parse('$baseUrl/todos/$id'), headers: ah, body: jsonEncode(body));
    if (_ok(res.statusCode)) {
      return Todo.fromJson(jsonDecode(res.body));
    } else {
      throw Exception('Todo 수정 실패: ${res.statusCode} ${res.body}');
    }
  }

  static Future<void> deleteTodo(int id) async {
    final ah = await getAuthHeaders();
    final res = await http.delete(Uri.parse('$baseUrl/todos/$id'), headers: ah);
    if (_ok(res.statusCode)) {
      return;
    } else {
      throw Exception('Todo 삭제 실패: ${res.statusCode} ${res.body}');
    }
  }
}
