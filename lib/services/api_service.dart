import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';

class ApiService {
  static const String baseUrl = 'https://task.itprojects.web.id';
  static const _storage = FlutterSecureStorage();

  // ── Simpan & ambil token ──────────────────────────────────────
  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'token', value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: 'token');
  }

  // ── Header dengan Bearer Token ────────────────────────────────
  static Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ── 1. LOGIN ──────────────────────────────────────────────────
  static Future<UserModel> login(String nim) async {
    final url = Uri.parse('$baseUrl/api/auth/login');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'username': nim,
        'password': nim,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final user = UserModel.fromJson(data);
      await saveToken(user.token);
      return user;
    } else {
      throw Exception('Login gagal: ${response.body}');
    }
  }

  // ── 2. GET PRODUK ─────────────────────────────────────────────
  static Future<List<ProductModel>> getProducts() async {
    final url = Uri.parse('$baseUrl/api/products');
    final headers = await _authHeaders();

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List products = data['data']['products'];
      return products.map((e) => ProductModel.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil produk: ${response.body}');
    }
  }

  // ── 3. POST PRODUK (Draft) ────────────────────────────────────
  static Future<void> addProduct(
    String name,
    int price,
    String description,
  ) async {
    final url = Uri.parse('$baseUrl/api/products');
    final headers = await _authHeaders();

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({
        'name': name,
        'price': price,
        'description': description,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Gagal menambah produk: ${response.body}');
    }
  }

  // ── 4. SUBMIT TUGAS ───────────────────────────────────────────
  static Future<void> submitTugas(
    String name,
    int price,
    String description,
    String githubUrl,
  ) async {
    final url = Uri.parse('$baseUrl/api/products/submit');
    final headers = await _authHeaders();

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({
        'name': name,
        'price': price,
        'description': description,
        'github_url': githubUrl,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Gagal submit tugas: ${response.body}');
    }
  }
}