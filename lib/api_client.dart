import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  /// ---------- TOKEN STORAGE ----------
  static const _tokenKey = 'accessToken';
  static const _uidKey = 'uid';

  Future<String?> getUid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('uid');
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> setUid(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_uidKey, uid);
  }

  Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_uidKey);
  }

  /// ---------- HEADERS ----------
  Future<Map<String, String>> _getHeaders({Map<String, String>? extra}) async {
    final token = await getToken();
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      ...?extra,
    };
    return headers;
  }

  /// ---------- GET ----------
  Future<http.Response> get(String url, {Map<String, String>? headers}) async {
    final h = await _getHeaders(extra: headers);
    return http.get(Uri.parse(url), headers: h);
  }

  /// ---------- POST ----------
  Future<http.Response> post(
    String url,
    Object body, {
    Map<String, String>? headers,
  }) async {
    final h = await _getHeaders(extra: headers);
    return http.post(Uri.parse(url), headers: h, body: jsonEncode(body));
  }

  /// ---------- PUT ----------
  Future<http.Response> put(
    String url,
    Object body, {
    Map<String, String>? headers,
  }) async {
    final h = await _getHeaders(extra: headers);
    return http.put(Uri.parse(url), headers: h, body: jsonEncode(body));
  }

  /// ---------- DELETE ----------
  Future<http.Response> delete(
    String url, {
    Map<String, String>? headers,
  }) async {
    final h = await _getHeaders(extra: headers);
    return http.delete(Uri.parse(url), headers: h);
  }

  Future<MultipartRequest> multipartRequest(String url) async {
    final request = MultipartRequest('POST', Uri.parse(url));
    final token = await getToken();

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    return request;
  }

  /// ---------- GET BYTES (например картинки) ----------
  Future<Uint8List> getBytes(String url, {Map<String, String>? headers}) async {
    final h = await _getHeaders(extra: headers);
    final response = await http.get(Uri.parse(url), headers: h);
    if (response.statusCode != 200) {
      throw Exception(
        'getBytes failed ${response.statusCode}: ${response.body}',
      );
    }
    return response.bodyBytes;
  }
}
