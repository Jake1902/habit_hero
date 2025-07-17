import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AirtableService {
  AirtableService._();

  static final _baseId  = dotenv.env['AIRTABLE_BASE']!;
  static final _table   = dotenv.env['AIRTABLE_TABLE']!;
  static final _token   = dotenv.env['AIRTABLE_PAT']!;
  static final _url     =
      Uri.https('api.airtable.com', '/v0/$_baseId/$_table');

  /// Throws on non-200/201.
  static Future<void> submitFeedback({
    required String message,
    String? email,
    int? rating,
  }) async {
    final body = jsonEncode({
      'fields': {
        'message': message,
        if (email  != null && email.isNotEmpty) 'email' : email,
        if (rating != null) 'rating': rating,
        'createdAt': DateTime.now().toIso8601String(),
      }
    });

    final res = await http.post(
      _url,
      headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type' : 'application/json',
      },
      body: body,
    );

    if (res.statusCode >= 400) {
      throw Exception('Airtable error ${res.statusCode}: ${res.body}');
    }
  }
}
