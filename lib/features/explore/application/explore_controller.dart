import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../search/domain/property.dart';

class ExploreController extends ChangeNotifier {
  ExploreController({double initialValor = 1000, String initialCidade = 'Alegrete, RS' })
      : _valorSelecionado = initialValor,
        _cidade = initialCidade;

  // existing state
  double _valorSelecionado;
  double get valorSelecionado => _valorSelecionado;

  String _cidade;
  String get cidade => _cidade;

  String? _tipoMoradia;
  String? get tipoMoradia => _tipoMoradia;

  String get tipoMoradiaLabel => _tipoMoradia ?? 'Escolha uma opção';

  // new state for search results
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  List<Property> _results = [];
  List<Property> get results => List.unmodifiable(_results);

  static const _baseUrl = 'https://cadastral-imovato-35ca7e6548df.herokuapp.com';

  void setValor(double v) {
    _valorSelecionado = v;
    notifyListeners();
  }

  void setCidade(String value) {
    if (value == _cidade) return;
    _cidade = value;
    notifyListeners();
  }

  void setTipoMoradia(String? value) {
    _tipoMoradia = value;
    notifyListeners();
  }

  /// Fetch accommodations from remote API and map to [Property]
  Future<void> searchAccommodations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final url = Uri.parse('$_baseUrl/accommodations');

    try {
      final res = await http.get(url);
      if (res.statusCode != 200) {
        _error = 'Erro ao buscar imóveis (${res.statusCode})';
        _results = [];
        return;
      }

      final List<dynamic> data = json.decode(res.body) as List<dynamic>;
      _results = data.map<Property>((e) {
        final id = e['id']?.toString() ?? '';
        final title = e['title']?.toString() ?? '';
        final address = e['address']?.toString() ?? '';
        final streetNumber = e['streetNumber']?.toString() ?? '0';
        final neighborhood = e['neighborhood']?.toString() ?? '';
        final city = e['city']?.toString() ?? '';
        final state = e['state']?.toString() ?? '';
        final description = e['description']?.toString() ?? '';
        final price = (e['price'] is num) ? (e['price'] as num).toDouble() : 0.0;
        final maxOccupancy = (e['maxOccupancy'] is num) ? (e['maxOccupancy'] as num).toInt() : 1;
        final images = <String>[];
        if (e['imagesUrls'] is List) {
          images.addAll(List<String>.from(e['imagesUrls']));
        }

        return Property(
          id: id,
          title: title,
          address: address,
          streetNumber: streetNumber,
          neighborhood: neighborhood,
          city: city,
          state: state,
          description: description,
          price: price,
          imagesUrls: images,
          maxOccupancy: maxOccupancy,
        );
      }).toList(growable: false);
    } catch (ex) {
      _error = 'Erro: ${ex.toString()}';
      _results = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Toggle favorite by property id
  void toggleFavoriteById(String id, bool fav) {
    final idx = _results.indexWhere((r) => r.id == id);
    if (idx == -1) return;
    final updated = _results[idx].copyWith(favorito: fav);
    _results = List<Property>.from(_results)
      ..[idx] = updated;
    notifyListeners();
  }
}
