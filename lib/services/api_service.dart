import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../models/item.dart';

class ApiService {
  // Change this to your machine's IP when testing on a physical device.
  // Android emulator: 10.0.2.2 | iOS simulator: 127.0.0.1
  static const String _baseUrl = 'http://10.0.2.2:8000';

  // ── Private helpers ────────────────────────────────────────────

  // Build headers — attaches the JWT token if available
  static Future<Map<String, String>> _headers({bool requireAuth = false}) async {
    final headers = {'Content-Type': 'application/json'};
    if (requireAuth) {
      final token = await AuthService.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  // ── Auth ───────────────────────────────────────────────────────

  /// POST /auth/login — returns the JWT token string on success
  /// Throws an exception with a readable message on failure
  static Future<String> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: await _headers(),
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['access_token'] as String;
    } else if (response.statusCode == 401) {
      throw Exception('Invalid email or password');
    } else {
      throw Exception('Login failed. Please try again.');
    }
  }

  // ── Items ──────────────────────────────────────────────────────

  /// GET /filter/ -fetch all items (public, no auth needed) according to a specific filter
  static Future<List<Item>> getItemsAlongFilter(Map<ItemCategory,dynamic> catFilter,Map<ItemType,dynamic> typeFilter,Map<ItemBrand,dynamic> brandFilter,) async{
    Map<ItemCategory, String> catFilters = {};
    for(var filter in catFilter.entries){if (filter.value!=null){catFilters.putIfAbsent(filter.key, ()=>filter.value.toString());}}
    Map<ItemType, String> typeFilters = {};
    for(var filter in typeFilter.entries){if (filter.value!=null){typeFilters.putIfAbsent(filter.key, ()=>filter.value.toString());}}
    Map<ItemBrand, String> brandFilters = {};
    for(var filter in brandFilter.entries){if (filter.value!=null){brandFilters.putIfAbsent(filter.key, ()=>filter.value.toString());}}
    final response= await http.get(
      Uri.http(_baseUrl,'/items/filter',Map<String, dynamic>.from(catFilters)),//TOCHANGE
      headers: await _headers()
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Item.fromJson(json)).toList();
    }else if (response.statusCode == 404) {
      throw Exception('No items found');
    }else if (response.statusCode == 500) {
      throw Exception('Server error, try again later');
    }else {
      throw Exception('Failed to load items');
    }
  }
  /// GET /items/ — fetch all items (public, no auth needed)
  static Future<List<Item>> getItems() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/items/'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Item.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load items');
    }
  }

  /// POST /items/ — create a new item (requires auth)
  static Future<Item> createItem({
    required String title,
    required String description,
    required double price,
    required String category,
    required String type, // 'sell' or 'lend'
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/items/'),
      headers: await _headers(requireAuth: true),
      body: jsonEncode({
        'title': title,
        'description': description,
        'price': price,
        'category': category,
        'type': type,
      }),
    );

    if (response.statusCode == 201) {
      return Item.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 401) {
      throw Exception('You must be logged in to post an item');
    } else {
      throw Exception('Failed to create item');
    }
  }
}