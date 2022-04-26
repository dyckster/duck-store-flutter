import 'dart:convert';

import 'package:duck_store/models/DuckDTO.dart';
import 'package:http/http.dart' as http;

class GetRandomDuckUseCase {
  Future<DuckDTO> fetchDuck() async {
    final response =
        await http.get(Uri.parse('https://random-d.uk/api/v2/quack'));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return DuckDTO.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load a duck');
    }
  }
}
